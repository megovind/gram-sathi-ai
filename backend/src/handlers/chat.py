"""
Chat handler — main orchestrator (US-02, US-03, US-04, US-17, US-18)

POST /chat
  headers: Authorization: Bearer <token>
  body: { text?, audioS3Key?, language, conversationId? }

POST /audio/upload-url
  headers: Authorization: Bearer <token>
  body: { fileName, contentType }
"""
import uuid
from datetime import datetime, timezone

from src.models.conversation import Conversation, Intent, Message, MessageRole
from src.services.bedrock_service import bedrock
from src.services.database import db
from src.services.polly_service import polly
from src.services.s3_service import s3
from src.services.transcribe_service import transcribe
from src.utils.auth import require_auth
from src.utils.config import config
from src.utils.constants import (
    DEFAULT_AUDIO_CONTENT_TYPE,
    ERR_AI_SERVICE,
    ERR_TEXT_OR_AUDIO_REQUIRED,
    ERR_TRANSCRIPTION_FAILED,
    ERR_UNSUPPORTED_CONTENT_TYPE,
    ERR_UPLOAD_URL_FAILED,
)
from src.utils.logger import logger
from src.utils.response import error, ok, parse_body


def handler(event: dict, context) -> dict:
    user_id, auth_err = require_auth(event)
    if auth_err:
        return auth_err

    body = parse_body(event)
    text_input: str = body.get("text", "")[:config.MAX_TEXT_LENGTH]
    audio_s3_key: str = body.get("audioS3Key", "")
    language: str = body.get("language", config.DEFAULT_LANGUAGE)
    conversation_id: str = body.get("conversationId", "")
    low_bandwidth: bool = body.get("lowBandwidth", False)

    if not text_input and not audio_s3_key:
        return error(ERR_TEXT_OR_AUDIO_REQUIRED, 400)

    logger.info("chat_request", user_id=user_id, language=language, has_audio=bool(audio_s3_key))

    # Step 1: Speech to text (US-02)
    if audio_s3_key and not text_input:
        try:
            text_input = transcribe.transcribe_audio(audio_s3_key, language)
        except Exception as exc:
            return error(f"{ERR_TRANSCRIPTION_FAILED}: {str(exc)}", 500)

    # Step 2: Load or create conversation (US-18)
    conversation: Conversation
    if conversation_id:
        existing = db.get_conversation(conversation_id)
        conversation = Conversation.from_dynamo(existing) if existing else _new_conversation(user_id, language)
    else:
        conversation = _new_conversation(user_id, language)

    # Step 3: Intent classification (US-17)
    if conversation.intent == Intent.UNKNOWN:
        conversation.intent = Intent(bedrock.classify_intent(text_input))

    history = [{"role": m.role.value, "content": m.content} for m in conversation.messages]

    # Step 4: AI response (US-04)
    try:
        ai_reply = bedrock.chat(
            text_input,
            conversation_history=history,
            language=language,
        )
    except Exception as exc:
        logger.error("bedrock_failed", user_id=user_id, error=str(exc))
        err_str = str(exc)
        if "use case details" in err_str.lower() or "Model use case" in err_str:
            err_str = (
                "AI model access not configured. In AWS Bedrock Console, open the model "
                "catalog, select Claude, and complete the use case form. Wait ~15 min after submitting."
            )
        return error(f"{ERR_AI_SERVICE}: {err_str}", 500)

    # Step 5: Text to speech (US-04)
    try:
        audio_url = polly.synthesize(ai_reply, language, low_bandwidth=low_bandwidth)
    except Exception as exc:
        logger.warning("polly_synthesis_failed", user_id=user_id, language=language, error=str(exc))
        audio_url = None

    # Step 6: Persist conversation
    now = datetime.now(timezone.utc).isoformat()
    conversation.messages.append(Message(role=MessageRole.USER, content=text_input, timestamp=now))
    conversation.messages.append(
        Message(role=MessageRole.ASSISTANT, content=ai_reply, audioUrl=audio_url, timestamp=now)
    )
    conversation.updatedAt = now
    db.save_conversation(conversation.to_dynamo())

    logger.info("chat_response", user_id=user_id, intent=conversation.intent.value,
                conversation_id=conversation.conversationId, has_audio=bool(audio_url))

    return ok({
        "conversationId": conversation.conversationId,
        "intent": conversation.intent.value,
        "text": ai_reply,
        "userText": text_input,
        "audioUrl": audio_url,
        "language": language,
    })


def get_upload_url(event: dict, context) -> dict:
    user_id, auth_err = require_auth(event)
    if auth_err:
        return auth_err

    body = parse_body(event)
    file_name: str = body.get("fileName", f"{uuid.uuid4().hex}.m4a")
    content_type: str = body.get("contentType", DEFAULT_AUDIO_CONTENT_TYPE)

    if content_type not in config.ALLOWED_AUDIO_CONTENT_TYPES:
        return error(ERR_UNSUPPORTED_CONTENT_TYPE.format(content_type), 400)

    object_key = f"uploads/{user_id}/{uuid.uuid4().hex}-{file_name}"
    try:
        upload_url = s3.generate_presigned_upload_url(object_key, content_type)
    except Exception as exc:
        return error(f"{ERR_UPLOAD_URL_FAILED}: {str(exc)}", 500)

    return ok({"uploadUrl": upload_url, "s3Key": object_key})


def _new_conversation(user_id: str, language: str) -> Conversation:
    return Conversation(conversationId=str(uuid.uuid4()), userId=user_id, language=language)
