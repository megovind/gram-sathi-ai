"""
Health handler (US-05 → US-09, US-L1 → US-L3)

POST /health/query  – symptom capture + AI guidance, OR nearby clinics/shops/pharmacies (voice or text)
POST /health/nearby – nearby clinics / pharmacies by pincode (legacy endpoint, kept for backward compat)

Nearby flow (health facilities):
  GPS in body  → Overpass API (OSM live data)  → fallback DynamoDB
  City in text → Nominatim geocode → Overpass   → fallback DynamoDB
  No location  → DynamoDB by stored pincode / default pincode
"""
import re
import uuid
from datetime import datetime, timezone
from typing import Optional, Tuple

from src.models.conversation import Conversation, Intent, Message, MessageRole
from src.services.bedrock_service import bedrock, detect_red_flags_fast
from src.services.database import db
from src.services.nominatim_service import nominatim
from src.services.overpass_service import overpass
from src.services.polly_service import polly
from src.services.transcribe_service import transcribe
from src.utils.auth import require_auth
from src.utils.config import config
from src.utils.constants import (
    DEFAULT_NEARBY_PINCODE,
    ERR_AI,
    ERR_PINCODE_FORMAT,
    ERR_PINCODE_REQUIRED,
    ERR_TEXT_OR_AUDIO_REQUIRED,
    ERR_TRANSCRIPTION_FAILED,
    HEALTH_FACILITY_CATEGORIES,
    MAX_NEARBY_FACILITIES,
    MSG_EMERGENCY_RESPONSE_BY_LANG,
    SHOP_STATUS_APPROVED,
)
from src.utils.logger import logger
from src.utils.response import error, ok, parse_body

_PINCODE_RE = re.compile(r"^\d{6}$")
_PINCODE_IN_TEXT_RE = re.compile(r"\b(\d{6})\b")

# Keywords for nearby intent — "near me" / "nearby shop" work without pincode in message
_NEARBY_FACILITY_KEYWORDS = re.compile(
    r"nearby|near me|clinic|clinics|pharmacy|pharmacies|hospital|hospitals|"
    r"नजदीक|मेरे पास|मेरे आसपास|क्लीनिक|फार्मेसी|अस्पताल|दवाखाना",
    re.IGNORECASE,
)
_NEARBY_SHOP_KEYWORDS = re.compile(
    r"nearby|near me|shop|shops|store|stores|"
    r"नजदीक|मेरे पास|मेरे आसपास|दुकान|दुकानें|स्टोर",
    re.IGNORECASE,
)


# Health disclaimer in user's language — AI must end health replies with this
_HEALTH_DISCLAIMER = {
    "hi": "यह सामान्य जानकारी है। डॉक्टर से परामर्श अवश्य लें।",
    "en": "This is general information only. Please consult a doctor.",
    "mr": "ही सामान्य माहिती आहे. डॉक्टरांचा सल्ला घ्या.",
    "ta": "இது பொதுவான தகவல் மட்டுமே. மருத்துவரைக் கலந்தாலோசிக்கவும்.",
    "te": "ఇది సాధారణ సమాచారం మాత్రమే. డాక్టర్తో సంప్రదించండి.",
    "kn": "ಇದು ಸಾಮಾನ್ಯ ಮಾಹಿತಿ ಮಾತ್ರ. ವೈದ್ಯರನ್ನು ಸಂಪರ್ಕಿಸಿ.",
    "bn": "এটি সাধারণ তথ্য মাত্র। ডাক্তারের পরামর্শ নিন।",
    "gu": "આ સામાન્ય માહિતી છે. ડોક્ટરની સલાહ લો.",
}


def _health_system_extra(language: str) -> str:
    disclaimer = _HEALTH_DISCLAIMER.get(language, _HEALTH_DISCLAIMER["en"])
    return f"""You are handling a HEALTH query.
- Provide safe home-care advice and when to see a doctor.
- NEVER diagnose.
- Always end with: "{disclaimer}"
"""


def _detect_nearby_and_pincode(
    text: str,
    body_pincode: Optional[str],
    user_pincode: Optional[str],
) -> Tuple[Optional[str], Optional[str]]:
    """
    Returns (pincode, kind) if this is a nearby query, else (None, None).
    kind: 'clinic' | 'pharmacy' | 'hospital' | 'facilities' (all medical) | 'shops' (retail only)
    Pincode resolution order: body > in text > user saved > default.
    """
    normalized = " ".join(text.lower().strip().split())
    has_facility = bool(_NEARBY_FACILITY_KEYWORDS.search(normalized))
    has_shop = bool(_NEARBY_SHOP_KEYWORDS.search(normalized))
    if not has_facility and not has_shop:
        return None, None

    # Prefer specific type when user says it explicitly
    if re.search(r"\b(clinic|clinics|क्लीनिक)\b", normalized, re.I):
        kind = "clinic"
    elif re.search(r"\b(pharmacy|pharmacies|फार्मेसी|दवाखाना)\b", normalized, re.I):
        kind = "pharmacy"
    elif re.search(r"\b(hospital|hospitals|अस्पताल)\b", normalized, re.I):
        kind = "hospital"
    elif re.search(r"\b(shop|shops|store|stores|दुकान|दुकानें|स्टोर)\b", normalized, re.I):
        kind = "shops"  # retail only, exclude medical
    elif has_facility:
        kind = "facilities"  # all medical (clinic + pharmacy + hospital)
    else:
        kind = "shops"

    # Resolve pincode: body > in message > user saved > default
    pincode = body_pincode
    if not pincode:
        match = _PINCODE_IN_TEXT_RE.search(text)
        if match:
            pincode = match.group(1)
    if not pincode and user_pincode:
        pincode = user_pincode
    if not pincode:
        pincode = DEFAULT_NEARBY_PINCODE

    return pincode, kind


def _format_nearby_for_tts(items: list[dict], kind: str, language: str, location_desc: str) -> str:
    """Format nearby list as short spoken text for Polly."""
    _empty_hi = {
        "clinic": f"{location_desc} पर कोई क्लीनिक नहीं मिली।",
        "pharmacy": f"{location_desc} पर कोई फार्मेसी नहीं मिली।",
        "hospital": f"{location_desc} पर कोई अस्पताल नहीं मिला।",
        "facilities": f"{location_desc} पर कोई क्लीनिक या फार्मेसी नहीं मिली।",
        "shops": f"{location_desc} पर कोई दुकान नहीं मिली।",
    }
    _empty_en = {
        "clinic": f"No clinic found near {location_desc}.",
        "pharmacy": f"No pharmacy found near {location_desc}.",
        "hospital": f"No hospital found near {location_desc}.",
        "facilities": f"No clinics or pharmacies found near {location_desc}.",
        "shops": f"No shops found near {location_desc}.",
    }
    if not items:
        return _empty_hi.get(kind, _empty_hi["shops"]) if language == "hi" else _empty_en.get(kind, _empty_en["shops"])

    _intro_hi = {
        "clinic": f"आपके एरिया में {len(items)} क्लीनिक मिली। ",
        "pharmacy": f"आपके एरिया में {len(items)} फार्मेसी मिली। ",
        "hospital": f"आपके एरिया में {len(items)} अस्पताल मिला। ",
        "facilities": f"आपके एरिया में {len(items)} जगह मिली। ",
        "shops": f"आपके एरिया में {len(items)} दुकान मिली। ",
    }
    _intro_en = {
        "clinic": f"Found {len(items)} clinic(s) in your area. ",
        "pharmacy": f"Found {len(items)} pharmacy(ies) in your area. ",
        "hospital": f"Found {len(items)} hospital(s) in your area. ",
        "facilities": f"Found {len(items)} places in your area. ",
        "shops": f"Found {len(items)} shop(s) in your area. ",
    }
    if language == "hi":
        intro = _intro_hi.get(kind, _intro_hi["shops"])
        parts = []
        for i, s in enumerate(items, 1):
            name = s.get("name", "?")
            phone = s.get("phone", "")
            addr = s.get("address") or ""
            if i == 1:
                parts.append(f"पहली: {name}.")
            elif i == 2:
                parts.append(f"दूसरी: {name}.")
            else:
                parts.append(f"तीसरी: {name}." if i == 3 else f"{name}.")
            if phone:
                parts.append(f" फोन {phone}.")
            if addr and i <= 2:
                parts.append(f" पता {addr[:50]}.")
        return intro + " ".join(parts)

    # English
    intro = _intro_en.get(kind, _intro_en["shops"])
    parts = []
    for i, s in enumerate(items, 1):
        name = s.get("name", "?")
        phone = s.get("phone", "")
        addr = s.get("address") or ""
        ordinals = ["First", "Second", "Third", "Fourth", "Fifth"]
        pre = ordinals[i - 1] + ": " if i <= 5 else ""
        parts.append(f"{pre}{name}.")
        if phone:
            parts.append(f" Phone {phone}.")
        if addr and i <= 2:
            parts.append(f" Address {addr[:50]}.")
    return intro + " ".join(parts)


def _search_health_facilities(
    text: str,
    near_kind: str,
    body_lat: Optional[float],
    body_lon: Optional[float],
    pincode: str,
    language: str,
) -> Tuple[list, str]:
    """
    Resolve (items, location_desc) for a health facility nearby query.

    Priority:
      1. GPS from app body  → Overpass   → DynamoDB fallback
      2. City from Bedrock  → Nominatim  → Overpass → DynamoDB fallback
      3. DynamoDB by pincode (last resort)
    """
    # 1. GPS coordinates provided by the app
    if body_lat is not None and body_lon is not None:
        osm_items = overpass.search_nearby(body_lat, body_lon, near_kind, MAX_NEARBY_FACILITIES)
        if osm_items:
            loc = "आपके पास" if language == "hi" else "your location"
            return osm_items, loc
        logger.info("overpass_empty_gps_fallback", lat=body_lat, lon=body_lon, kind=near_kind)
        # Fall through to DynamoDB

    # 2. No GPS — ask Bedrock if user mentioned a specific city
    else:
        try:
            city = bedrock.extract_nearby_location(text)
        except Exception:
            city = None

        if city:
            coords: Optional[Tuple[float, float]] = nominatim.geocode(city)
            if coords:
                lat, lon = coords
                osm_items = overpass.search_nearby(lat, lon, near_kind, MAX_NEARBY_FACILITIES)
                if osm_items:
                    return osm_items, city
                logger.info("overpass_empty_city_fallback", city=city, kind=near_kind)
                # Fall through to DynamoDB

    # 3. DynamoDB fallback — use stored/default pincode
    all_shops = db.get_shops_by_pincode(pincode)
    if near_kind in ("clinic", "pharmacy", "hospital"):
        dynamo_items = [
            s for s in all_shops if s.get("category") == near_kind
        ][:MAX_NEARBY_FACILITIES]
    else:
        dynamo_items = [
            s for s in all_shops if s.get("category") in HEALTH_FACILITY_CATEGORIES
        ][:MAX_NEARBY_FACILITIES]

    loc_desc = f"पिनकोड {pincode}" if language == "hi" else f"pincode {pincode}"
    return dynamo_items, loc_desc


def handler(event: dict, context) -> dict:
    path = event.get("path", "")
    if path.endswith("/nearby"):
        return _handle_nearby(event)
    return _handle_query(event)


def _handle_query(event: dict) -> dict:
    user_id, auth_err = require_auth(event)
    if auth_err:
        return auth_err

    body = parse_body(event)
    text: str = body.get("text", "")[:config.MAX_TEXT_LENGTH]
    audio_s3_key: str = body.get("audioS3Key", "")
    language: str = body.get("language", config.DEFAULT_LANGUAGE)
    conversation_id: str = body.get("conversationId", "")
    generate_summary: bool = body.get("generateSummary", False)
    low_bandwidth: bool = body.get("lowBandwidth", False)
    body_pincode: Optional[str] = (body.get("pincode") or "").strip() or None
    if body_pincode and not _PINCODE_RE.match(body_pincode):
        body_pincode = None

    # GPS coordinates from the app (optional — sent by Flutter when available)
    body_lat: Optional[float] = None
    body_lon: Optional[float] = None
    try:
        if body.get("latitude") is not None and body.get("longitude") is not None:
            body_lat = float(body["latitude"])
            body_lon = float(body["longitude"])
    except (TypeError, ValueError):
        pass

    if not text and not audio_s3_key:
        return error(ERR_TEXT_OR_AUDIO_REQUIRED, 400)

    if audio_s3_key and not text:
        try:
            text = transcribe.transcribe_audio(audio_s3_key, language)
        except Exception as exc:
            logger.error("health_transcription_failed", user_id=user_id, error=str(exc))
            return error(f"{ERR_TRANSCRIPTION_FAILED}: {str(exc)}", 500)

    # Optional: user's saved pincode for "near me" DynamoDB fallback
    user_row = None
    user_pincode = None
    try:
        user_row = db.get_user(user_id)
        if user_row and user_row.get("pincode"):
            user_pincode = user_row.get("pincode")
    except Exception:
        pass

    # Nearby intent: clinics/pharmacies/shops by voice or text — return spoken list
    pincode, near_kind = _detect_nearby_and_pincode(text, body_pincode, user_pincode)
    if pincode and near_kind:
        if near_kind == "shops":
            # Retail shops — DynamoDB only (no OSM for commerce)
            if not _PINCODE_RE.match(pincode):
                return error(ERR_PINCODE_FORMAT, 400)
            all_shops = db.get_shops_by_pincode(pincode)
            items = [
                s for s in all_shops
                if s.get("status") == SHOP_STATUS_APPROVED
                and s.get("category") not in HEALTH_FACILITY_CATEGORIES
            ][:MAX_NEARBY_FACILITIES]
            location_desc = f"पिनकोड {pincode}" if language == "hi" else f"pincode {pincode}"
        else:
            # Health facilities — try OSM (Overpass) first, fall back to DynamoDB
            items, location_desc = _search_health_facilities(
                text=text,
                near_kind=near_kind,
                body_lat=body_lat,
                body_lon=body_lon,
                pincode=pincode,
                language=language,
            )

        reply_text = _format_nearby_for_tts(items, near_kind, language, location_desc)
        try:
            audio_url = polly.synthesize(reply_text, language, low_bandwidth=low_bandwidth)
        except Exception:
            audio_url = None
        conversation = _new_health_conv(user_id, language)
        now = datetime.now(timezone.utc).isoformat()
        conversation.messages.extend([
            Message(role=MessageRole.USER, content=text, timestamp=now),
            Message(role=MessageRole.ASSISTANT, content=reply_text, audioUrl=audio_url, timestamp=now),
        ])
        conversation.updatedAt = now
        db.save_conversation(conversation.to_dynamo())
        # Persist pincode for future "nearby" queries
        if user_row and near_kind == "shops" and user_row.get("pincode") != pincode:
            try:
                user_row["pincode"] = pincode
                user_row["updatedAt"] = now
                db.save_user(user_row)
            except Exception:
                pass
        return ok({
            "conversationId": conversation.conversationId,
            "text": reply_text,
            "userText": text,
            "audioUrl": audio_url,
            "isEmergency": False,
            "language": language,
        })

    conversation: Conversation
    if conversation_id:
        existing = db.get_conversation(conversation_id)
        conversation = Conversation.from_dynamo(existing) if existing else _new_health_conv(user_id, language)
    else:
        conversation = _new_health_conv(user_id, language)

    logger.info("health_query", user_id=user_id, language=language)

    # Free keyword check — no Bedrock call needed for obvious emergencies
    is_emergency = detect_red_flags_fast(text)

    if is_emergency:
        logger.warning("emergency_detected", user_id=user_id, text_preview=text[:80])
        ai_reply = MSG_EMERGENCY_RESPONSE_BY_LANG.get(language, MSG_EMERGENCY_RESPONSE_BY_LANG["en"])
    else:
        history = [{"role": m.role.value, "content": m.content} for m in conversation.messages]
        try:
            ai_reply = bedrock.chat(
                text,
                conversation_history=history,
                system_extra=_health_system_extra(language),
                # Cache only first messages — recurring questions like "fever treatment"
                # asked by many users will hit cache instead of Bedrock
                use_cache=not bool(history),
                language=language,
            )
        except Exception as exc:
            err_str = str(exc)
            if "use case details" in err_str.lower() or "Model use case" in err_str:
                err_str = (
                    "AI model access not configured. In AWS Bedrock Console, open the model "
                    "catalog, select Claude, and complete the use case form. Wait ~15 min after submitting."
                )
            return error(f"{ERR_AI}: {err_str}", 500)

    try:
        audio_url = polly.synthesize(ai_reply, language, low_bandwidth=low_bandwidth)
    except Exception:
        audio_url = None

    now = datetime.now(timezone.utc).isoformat()
    conversation.messages.extend([
        Message(role=MessageRole.USER, content=text, timestamp=now),
        Message(role=MessageRole.ASSISTANT, content=ai_reply, audioUrl=audio_url, timestamp=now),
    ])
    conversation.updatedAt = now
    db.save_conversation(conversation.to_dynamo())

    response_body: dict = {
        "conversationId": conversation.conversationId,
        "text": ai_reply,
        "userText": text,
        "audioUrl": audio_url,
        "isEmergency": is_emergency,
        "language": language,
    }

    if generate_summary:
        summary = bedrock.generate_doctor_summary(
            conversation.symptoms,
            [{"role": m.role.value, "content": m.content} for m in conversation.messages],
            language=language,
        )
        response_body["doctorSummary"] = summary

    return ok(response_body)


def _handle_nearby(event: dict) -> dict:
    """Public endpoint — no auth required for nearby search."""
    body = parse_body(event)
    pincode: str = body.get("pincode", "").strip()

    if not pincode:
        return error(ERR_PINCODE_REQUIRED, 400)
    if not _PINCODE_RE.match(pincode):
        return error(ERR_PINCODE_FORMAT, 400)

    all_shops = db.get_shops_by_pincode(pincode)
    health_facilities = [
        s for s in all_shops
        if s.get("category") in HEALTH_FACILITY_CATEGORIES
    ]
    return ok({"pincode": pincode, "facilities": health_facilities[:MAX_NEARBY_FACILITIES]})


def _new_health_conv(user_id: str, language: str) -> Conversation:
    return Conversation(
        conversationId=str(uuid.uuid4()),
        userId=user_id,
        intent=Intent.HEALTH,
        language=language,
    )
