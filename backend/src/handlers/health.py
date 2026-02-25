"""
Health handler (US-05 → US-09)

POST /health/query  – symptom capture + AI guidance
POST /health/nearby – nearby clinics / pharmacies by pincode
"""
import uuid
from datetime import datetime, timezone

from src.models.conversation import Conversation, Intent, Message, MessageRole
from src.services.bedrock_service import bedrock, detect_red_flags_fast
from src.services.dynamodb_service import dynamo
from src.services.polly_service import polly
from src.utils.auth import require_auth
from src.utils.config import config
from src.utils.logger import logger
from src.utils.response import error, ok, parse_body


HEALTH_SYSTEM_EXTRA = """You are handling a HEALTH query.
- Provide safe home-care advice and when to see a doctor.
- NEVER diagnose.
- Always end with: "यह सामान्य जानकारी है। डॉक्टर से परामर्श अवश्य लें।"
"""


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
    language: str = body.get("language", config.DEFAULT_LANGUAGE)
    conversation_id: str = body.get("conversationId", "")
    generate_summary: bool = body.get("generateSummary", False)
    low_bandwidth: bool = body.get("lowBandwidth", False)

    if not text:
        return error("text is required", 400)

    conversation: Conversation
    if conversation_id:
        existing = dynamo.get_conversation(conversation_id)
        conversation = Conversation.from_dynamo(existing) if existing else _new_health_conv(user_id, language)
    else:
        conversation = _new_health_conv(user_id, language)

    logger.info("health_query", user_id=user_id, language=language)

    # Free keyword check — no Bedrock call needed for obvious emergencies
    is_emergency = detect_red_flags_fast(text)

    if is_emergency:
        logger.warning("emergency_detected", user_id=user_id, text_preview=text[:80])
        ai_reply = (
            "⚠️ यह गंभीर स्थिति लग रही है। कृपया तुरंत नजदीकी अस्पताल जाएं या 108 पर कॉल करें।\n\n"
            "This appears to be an emergency. Please call 108 or go to the nearest hospital immediately."
        )
    else:
        history = [{"role": m.role.value, "content": m.content} for m in conversation.messages]
        try:
            ai_reply = bedrock.chat(
                text,
                conversation_history=history,
                system_extra=HEALTH_SYSTEM_EXTRA,
                # Cache only first messages — recurring questions like "fever treatment"
                # asked by many users will hit cache instead of Bedrock
                use_cache=not bool(history),
                language=language,
            )
        except Exception as exc:
            return error(f"AI error: {str(exc)}", 500)

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
    dynamo.save_conversation(conversation.to_dynamo())

    response_body: dict = {
        "conversationId": conversation.conversationId,
        "text": ai_reply,
        "audioUrl": audio_url,
        "isEmergency": is_emergency,
        "language": language,
    }

    if generate_summary:
        summary = bedrock.generate_doctor_summary(
            conversation.symptoms,
            [{"role": m.role.value, "content": m.content} for m in conversation.messages],
        )
        response_body["doctorSummary"] = summary

    return ok(response_body)


def _handle_nearby(event: dict) -> dict:
    """Public endpoint — no auth required for nearby search."""
    body = parse_body(event)
    pincode: str = body.get("pincode", "")

    if not pincode:
        return error("pincode is required", 400)

    all_shops = dynamo.get_shops_by_pincode(pincode)
    health_facilities = [
        s for s in all_shops
        if s.get("category") in ("clinic", "pharmacy", "hospital")
    ]
    return ok({"pincode": pincode, "facilities": health_facilities[:5]})


def _new_health_conv(user_id: str, language: str) -> Conversation:
    return Conversation(
        conversationId=str(uuid.uuid4()),
        userId=user_id,
        intent=Intent.HEALTH,
        language=language,
    )
