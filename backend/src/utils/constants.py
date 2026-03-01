"""
Centralised constants for GramSathi backend.

Import from this module instead of scattering string literals across handlers
and services.  Grouping here makes it easy to audit, translate, or change
any user-facing message in one place.
"""

# ── HTTP / routing ───────────────────────────────────────────────────────────
ERR_ROUTE_NOT_FOUND = "Route not found"
ERR_UNAUTHORIZED = "Unauthorized"
ERR_FORBIDDEN = "Forbidden"
ERR_FORBIDDEN_NOT_YOUR_SHOP = "Forbidden — not your shop"
ERR_VERIFICATION_FAILED = "Verification failed"

# ── Input validation ─────────────────────────────────────────────────────────
ERR_TEXT_OR_AUDIO_REQUIRED = "Either text or audioS3Key must be provided"
ERR_PINCODE_REQUIRED = "pincode is required"
ERR_PINCODE_FORMAT = "pincode must be a 6-digit number"
ERR_UNSUPPORTED_LANGUAGE = "Unsupported language: {}"
ERR_UNSUPPORTED_CONTENT_TYPE = "Unsupported content type: {}"
ERR_SHOP_ID_REQUIRED = "shopId is required"
ERR_SHOP_ID_AND_ITEMS_REQUIRED = "shopId and items are required"
ERR_ORDER_ID_REQUIRED = "orderId is required"
ERR_ITEMS_LIST_REQUIRED = "items list is required"
ERR_MISSING_FIELDS = "Missing fields: {}"
ERR_INVALID_ITEM_DATA = "Invalid item data: {}"
ERR_ITEM_QTY_POSITIVE = "Item quantities must be greater than zero"
ERR_ITEM_PRICE_NEGATIVE = "Item prices cannot be negative"
ERR_STOCK_QTY_NEGATIVE = "Stock quantities cannot be negative"
ERR_TOO_MANY_ITEMS = "Too many items (max {})"

# ── Resource not-found ───────────────────────────────────────────────────────
ERR_SHOP_NOT_FOUND = "Shop not found"
ERR_ORDER_NOT_FOUND = "Order not found"
ERR_USER_NOT_FOUND = "User not found"

# ── Service error prefixes  (callers append ': <exception>') ─────────────────
ERR_TRANSCRIPTION_FAILED = "Transcription failed"
ERR_AI_SERVICE = "AI service error"
ERR_AI = "AI error"
ERR_UPLOAD_URL_FAILED = "Could not generate upload URL"

# ── Shop / order status values ───────────────────────────────────────────────
SHOP_STATUS_APPROVED = "approved"
SHOP_STATUS_PENDING = "pending"
ORDER_STATUS_PENDING = "pending"
ORDER_STATUS_CONFIRMED = "confirmed"
ORDER_STATUS_READY = "ready"
ORDER_STATUS_DELIVERED = "delivered"
ORDER_STATUS_CANCELLED = "cancelled"

# ── User-ID prefixes ─────────────────────────────────────────────────────────
USER_ID_PHONE_PREFIX = "ph-"
USER_ID_WHATSAPP_PREFIX = "wa-"

# ── Health ───────────────────────────────────────────────────────────────────
HEALTH_FACILITY_CATEGORIES: frozenset = frozenset({"clinic", "pharmacy", "hospital"})
MAX_NEARBY_FACILITIES = 5
# Fallback pincode when user asks "nearby" without providing one (Kota 324008 — matches seed data)
DEFAULT_NEARBY_PINCODE = "324008"

# Emergency message in user's selected language
MSG_EMERGENCY_RESPONSE_BY_LANG = {
    "hi": "⚠️ यह गंभीर स्थिति लग रही है। कृपया तुरंत नजदीकी अस्पताल जाएं या 108 पर कॉल करें।",
    "en": "⚠️ This appears to be an emergency. Please call 108 or go to the nearest hospital immediately.",
    "mr": "⚠️ ही गंभीर परिस्थिती वाटते. कृपया त्वरित नजीकच्या रुग्णालयात जा किंवा 108 वर कॉल करा.",
    "ta": "⚠️ இது அவசரநிலை போல் தெரிகிறது. 108 அழைக்கவும் அல்லது அருகிலுள்ள மருத்துவமனைக்கு உடனடியாக செல்லுங்கள்.",
    "te": "⚠️ ఇది అత్యవసర పరిస్థితిగా కనిపిస్తోంది. 108 కు కాల్ చేయండి లేదా సమీప ఆసుపత్రికి వెంటనే వెళ్లండి.",
    "kn": "⚠️ ಇದು ತುರ್ತು ಪರಿಸ್ಥಿತಿಯಂತೆ ಕಾಣುತ್ತದೆ. 108 ಕ್ಕೆ ಕರೆ ಮಾಡಿ ಅಥವಾ ಹತ್ತಿರದ ಆಸ್ಪತ್ರೆಗೆ ತಕ್ಷಣ ಹೋಗಿ.",
    "bn": "⚠️ এটি জরুরি পরিস্থিতির মতো মনে হচ্ছে। 108 এ কল করুন বা নিকটতম হাসপাতালে যান।",
    "gu": "⚠️ આ ગંભીર પરિસ્થિતિ લાગે છે. કૃપા કરીને તરત નજીકની હોસ્પિટલ જાઓ અથવા 108 પર કૉલ કરો.",
}
MSG_EMERGENCY_RESPONSE = (
    "⚠️ यह गंभीर स्थिति लग रही है। कृपया तुरंत नजदीकी अस्पताल जाएं या 108 पर कॉल करें।\n\n"
    "This appears to be an emergency. Please call 108 or go to the nearest hospital immediately."
)  # fallback (bilingual)

# ── Commerce ─────────────────────────────────────────────────────────────────
ORDER_ID_DISPLAY_LEN = 8
MSG_ORDER_CONFIRMED = "ऑर्डर #{} कन्फर्म हो गया।"

# ── Shop owner ───────────────────────────────────────────────────────────────
MSG_SHOP_REGISTERED = "Shop registered. Awaiting admin approval."
PRIVATE_SHOP_FIELDS: frozenset = frozenset({"ownerId", "phone"})

# ── Inventory ────────────────────────────────────────────────────────────────
DEFAULT_INVENTORY_UNIT = "piece"

# ── WhatsApp ─────────────────────────────────────────────────────────────────
WHATSAPP_MAX_CHARS = 4096
MSG_VOICE_NOT_SUPPORTED = "[Voice message received — please type your query for now]"
MSG_UNSUPPORTED_MESSAGE_TYPE = "[Unsupported message type]"

# ── Defaults ─────────────────────────────────────────────────────────────────
DEFAULT_LANGUAGE = "hi"
DEFAULT_AUDIO_CONTENT_TYPE = "audio/m4a"
