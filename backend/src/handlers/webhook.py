"""
WhatsApp webhook handler (US-02 via WhatsApp channel)

GET  /webhook/whatsapp  – Meta verification challenge
POST /webhook/whatsapp  – Incoming messages from users
"""
import hashlib
import hmac
import json
import urllib.request

from src.services.bedrock_service import bedrock
from src.services.dynamodb_service import dynamo
from src.utils.config import config
from src.utils.logger import logger
from src.utils.response import ok, error, parse_body
from src.models.conversation import Conversation, Message, MessageRole
import uuid
from datetime import datetime, timezone


def verify(event: dict, context) -> dict:
    """WhatsApp webhook verification (Meta challenge-response)."""
    params = event.get("queryStringParameters") or {}
    mode = params.get("hub.mode", "")
    token = params.get("hub.verify_token", "")
    challenge = params.get("hub.challenge", "")

    if mode == "subscribe" and token == config.WHATSAPP_VERIFY_TOKEN:
        return {"statusCode": 200, "body": challenge}
    return error("Verification failed", 403)


def incoming(event: dict, context) -> dict:
    """Handle incoming WhatsApp messages and reply using the AI pipeline."""
    # Verify the payload came from Meta using X-Hub-Signature-256
    if not _verify_webhook_signature(event):
        logger.warning("webhook_signature_invalid")
        # Return 200 anyway so Meta doesn't disable the webhook — but do nothing
        return ok("ok")

    try:
        body = parse_body(event)
    except Exception:
        return ok("ok")

    try:
        entry = body.get("entry", [{}])[0]
        change = entry.get("changes", [{}])[0]
        value = change.get("value", {})
        messages = value.get("messages", [])

        if not messages:
            return ok("ok")

        msg = messages[0]
        from_number: str = msg.get("from", "")
        msg_type: str = msg.get("type", "text")

        if msg_type == "text":
            user_text = msg.get("text", {}).get("body", "")
        elif msg_type == "audio":
            user_text = "[Voice message received — please type your query for now]"
        else:
            user_text = "[Unsupported message type]"

        if not user_text or not from_number:
            return ok("ok")

        # Enforce input length limit even on WhatsApp channel
        user_text = user_text[: config.MAX_TEXT_LENGTH]

        user_id = f"wa-{from_number}"
        logger.info("whatsapp_message", user_id=user_id, msg_type=msg_type)

        conversations = dynamo.get_conversations_by_user(user_id)
        if conversations:
            latest = sorted(conversations, key=lambda c: c.get("updatedAt", ""), reverse=True)[0]
            conversation = Conversation.from_dynamo(latest)
        else:
            conversation = Conversation(
                conversationId=str(uuid.uuid4()),
                userId=user_id,
                language="hi",
            )

        history = [{"role": m.role.value, "content": m.content} for m in conversation.messages]
        ai_reply = bedrock.chat(user_text, conversation_history=history)

        now = datetime.now(timezone.utc).isoformat()
        conversation.messages.extend([
            Message(role=MessageRole.USER, content=user_text, timestamp=now),
            Message(role=MessageRole.ASSISTANT, content=ai_reply, timestamp=now),
        ])
        conversation.updatedAt = now
        dynamo.save_conversation(conversation.to_dynamo())

        _send_whatsapp_message(from_number, ai_reply)

    except Exception as exc:
        # Log but always return 200 so WhatsApp doesn't retry aggressively
        logger.error("webhook_error", error=str(exc))

    return ok("ok")


def _verify_webhook_signature(event: dict) -> bool:
    """
    Verify that the POST came from Meta using HMAC-SHA256.
    Meta sends X-Hub-Signature-256: sha256=<hex> on every webhook call.
    If WHATSAPP_APP_SECRET is not configured, skip verification (dev mode).
    """
    if not config.WHATSAPP_APP_SECRET:
        return True  # Skip in dev when not configured

    headers = event.get("headers") or {}
    signature_header = (
        headers.get("X-Hub-Signature-256")
        or headers.get("x-hub-signature-256")
        or ""
    )
    if not signature_header.startswith("sha256="):
        return False

    raw_body: str = event.get("body") or ""
    expected = hmac.new(
        config.WHATSAPP_APP_SECRET.encode(),
        raw_body.encode(),
        hashlib.sha256,
    ).hexdigest()

    received = signature_header[7:]  # strip "sha256="
    return hmac.compare_digest(expected, received)


def _send_whatsapp_message(to: str, text: str) -> None:
    if not config.WHATSAPP_ACCESS_TOKEN or not config.WHATSAPP_PHONE_NUMBER_ID:
        logger.debug("whatsapp_not_configured", to=to)
        return

    url = f"https://graph.facebook.com/v20.0/{config.WHATSAPP_PHONE_NUMBER_ID}/messages"
    payload = json.dumps({
        "messaging_product": "whatsapp",
        "to": to,
        "type": "text",
        "text": {"body": text},
    }).encode()

    req = urllib.request.Request(
        url,
        data=payload,
        headers={
            "Content-Type": "application/json",
            "Authorization": f"Bearer {config.WHATSAPP_ACCESS_TOKEN}",
        },
        method="POST",
    )
    try:
        with urllib.request.urlopen(req) as resp:
            resp.read()
    except Exception as exc:
        logger.error("whatsapp_send_failed", to=to, error=str(exc))
