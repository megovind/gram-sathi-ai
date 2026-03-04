"""
Health handler (US-05 → US-09)

POST /health/query  – all user queries routed through the LangGraph agent graph:
                      health advice, nearby clinics/pharmacies/hospitals, or shops
POST /health/nearby – legacy pincode-based lookup (kept for backward compat)
"""
import re
import uuid
from datetime import datetime, timezone
from typing import Optional

from src.agents.graph import agent_graph
from src.models.conversation import Conversation, Intent, Message, MessageRole
from src.services.bedrock_service import bedrock
from src.services.database import db
from src.services.polly_service import polly
from src.services.transcribe_service import transcribe
from src.utils.auth import require_auth
from src.utils.config import config
from src.utils.constants import (
    ERR_PINCODE_FORMAT,
    ERR_PINCODE_REQUIRED,
    ERR_TEXT_OR_AUDIO_REQUIRED,
    ERR_TRANSCRIPTION_FAILED,
    HEALTH_FACILITY_CATEGORIES,
    MAX_NEARBY_FACILITIES,
)
from src.utils.logger import logger
from src.utils.response import error, ok, parse_body

_PINCODE_RE = re.compile(r"^\d{6}$")

_HEALTH_DISCLAIMER = {
    "hi": "यह सामान्य जानकारी है। डॉक्टर से परामर्श अवश्य लें।",
    "en": "This is general information only. Please consult a doctor.",
    "mr": "ही सामान्य माहिती आहे. डॉक्टरांचा सल्ला घ्या.",
    "ta": "இது பொதுவான தகவல் மட்டுமே. மருத்துவரைக் கலந்தாலோசிக்கவும்.",
    "te": "ఇది సాధారణ సమాచారం మాత్రమే. డాక్టర్తో సంప్రదించండి.",
    "kn": "ಇದು ಸಾಮಾನ್ಯ ಮಾಹಿತಿ ಮಾತ್ರ. ವೈದ್ಯರನ್ನು ಸಂಪರ್ಕಿಸಿ.",
    "bn": "এটি সাধারণ তথ্য মাত্র। ডাক্তারের পরামর্শ নিন।",
    "gu": "આ સામાન્ય માહિતી છે. ડોક્ટरની સલાહ લો.",
}


def _health_system_extra(language: str) -> str:
    disclaimer = _HEALTH_DISCLAIMER.get(language, _HEALTH_DISCLAIMER["en"])
    return (
        "You are handling a HEALTH query.\n"
        "- Provide safe home-care advice and when to see a doctor.\n"
        "- NEVER diagnose.\n"
        f'- Always end with: "{disclaimer}"'
    )


def handler(event: dict, context) -> dict:
    path = event.get("path", "")
    if path.endswith("/nearby"):
        return _handle_nearby(event)
    return _handle_query(event)


def _handle_query(event: dict) -> dict:
    user_id, auth_err = require_auth(event)
    if auth_err:
        return auth_err

    try:
        return _handle_query_impl(event, user_id)
    except Exception as exc:
        logger.exception("health_query_failed", user_id=user_id, error=str(exc))
        return error(f"Internal server error: {exc!s}", 500)


def _handle_query_impl(event: dict, user_id: str) -> dict:
    body = parse_body(event)
    text: str = body.get("text", "")[:config.MAX_TEXT_LENGTH]
    audio_s3_key: str = body.get("audioS3Key", "")
    language: str = body.get("language", config.DEFAULT_LANGUAGE)
    conversation_id: str = body.get("conversationId", "")
    generate_summary: bool = body.get("generateSummary", False)
    low_bandwidth: bool = body.get("lowBandwidth", False)

    body_lat: Optional[float] = None
    body_lon: Optional[float] = None
    try:
        if body.get("latitude") is not None and body.get("longitude") is not None:
            body_lat = float(body["latitude"])
            body_lon = float(body["longitude"])
    except (TypeError, ValueError):
        pass

    # Pincode from the request body (sent by the frontend from localStorage).
    # Preferred over the DynamoDB value because it reflects the user's latest input.
    body_pincode: Optional[str] = body.get("pincode") or None

    if not text and not audio_s3_key:
        return error(ERR_TEXT_OR_AUDIO_REQUIRED, 400)

    if audio_s3_key and not text:
        try:
            text = transcribe.transcribe_audio(audio_s3_key, language)
        except Exception as exc:
            logger.error("health_transcription_failed", user_id=user_id, error=str(exc))
            return error(f"{ERR_TRANSCRIPTION_FAILED}: {str(exc)}", 500)

    user_pincode: Optional[str] = None
    user_row = None
    try:
        user_row = db.get_user(user_id)
        if user_row:
            user_pincode = user_row.get("pincode")
    except Exception:
        pass

    # Prefer pincode from request body (fresh, from device localStorage) over DynamoDB.
    # No hardcoded fallback — the agent nodes handle the no-location case gracefully.
    resolved_pincode: Optional[str] = body_pincode or user_pincode or None

    # Load conversation history for multi-turn health advice
    if conversation_id:
        existing = db.get_conversation(conversation_id)
        conversation = (
            Conversation.from_dynamo(existing) if existing
            else _new_conv(user_id, language)
        )
    else:
        conversation = _new_conv(user_id, language)

    history = [
        {"role": m.role.value, "content": m.content}
        for m in conversation.messages
    ]

    # ── Invoke the LangGraph agent ────────────────────────────────────────────
    result = agent_graph.invoke({
        "text": text,
        "language": language,
        "user_id": user_id,
        "pincode": resolved_pincode,
        "lat": body_lat,
        "lon": body_lon,
        "conversation_history": history,
        "system_extra": _health_system_extra(language),
        "use_cache": not bool(history),
        "low_bandwidth": low_bandwidth,
        # outputs (graph will populate these)
        "intent":             "",
        "nearby_kind":        "",
        "extracted_location": None,
        "reply":              "",
        "facilities":         [],
    })
    # ─────────────────────────────────────────────────────────────────────────

    reply_text: str = result["reply"]
    facilities: list = result.get("facilities") or []
    nearby_kind: str = result.get("nearby_kind") or ""
    intent: str = result.get("intent") or "health_advice"
    is_search: bool = intent in ("nearby_facilities", "shops")

    try:
        audio_url = polly.synthesize(reply_text, language, low_bandwidth=low_bandwidth)
    except Exception:
        audio_url = None

    now = datetime.now(timezone.utc).isoformat()

    # Only persist health advice turns to conversation history, not search results
    if not is_search:
        conversation.messages.extend([
            Message(role=MessageRole.USER, content=text, timestamp=now),
            Message(role=MessageRole.ASSISTANT, content=reply_text,
                    audioUrl=audio_url, timestamp=now),
        ])
        conversation.updatedAt = now
        db.save_conversation(conversation.to_dynamo())

    response_body: dict = {
        "conversationId": conversation.conversationId,
        "text": reply_text,
        "userText": text,
        "audioUrl": audio_url,
        "isEmergency": False,
        "language": language,
        "facilities": facilities,
        "nearbyKind": nearby_kind,
    }

    if generate_summary and not is_search:
        try:
            summary = bedrock.generate_doctor_summary(
                conversation.symptoms if hasattr(conversation, "symptoms") else [],
                history,
                language=language,
            )
            response_body["doctorSummary"] = summary
        except Exception:
            pass

    return ok(response_body)


def _handle_nearby(event: dict) -> dict:
    """Legacy endpoint — direct pincode-based DynamoDB lookup (no AI)."""
    body = parse_body(event)
    pincode: str = body.get("pincode", "").strip()

    if not pincode:
        return error(ERR_PINCODE_REQUIRED, 400)
    if not _PINCODE_RE.match(pincode):
        return error(ERR_PINCODE_FORMAT, 400)

    all_shops = db.get_shops_by_pincode(pincode)
    facilities = [
        s for s in all_shops
        if s.get("category") in HEALTH_FACILITY_CATEGORIES
    ]
    return ok({"pincode": pincode, "facilities": facilities[:MAX_NEARBY_FACILITIES]})


def _new_conv(user_id: str, language: str) -> Conversation:
    return Conversation(
        conversationId=str(uuid.uuid4()),
        userId=user_id,
        intent=Intent.HEALTH,
        language=language,
    )
