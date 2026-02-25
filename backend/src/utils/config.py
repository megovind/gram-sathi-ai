import os


class Config:
    STAGE: str = os.environ.get("STAGE", "dev")
    AWS_REGION: str = os.environ.get("AWS_REGION", "ap-south-1")

    TABLE_PREFIX: str = os.environ.get("TABLE_PREFIX", f"gramsathi-{STAGE}")
    USERS_TABLE: str = f"{TABLE_PREFIX}-users"
    CONVERSATIONS_TABLE: str = f"{TABLE_PREFIX}-conversations"
    SHOPS_TABLE: str = f"{TABLE_PREFIX}-shops"
    ORDERS_TABLE: str = f"{TABLE_PREFIX}-orders"
    RESPONSE_CACHE_TABLE: str = f"{TABLE_PREFIX}-response-cache"

    S3_AUDIO_BUCKET: str = os.environ.get("S3_AUDIO_BUCKET", f"gramsathi-audio-{STAGE}")
    AUDIO_EXPIRY_SECONDS: int = 3600

    # Allowed content types for audio uploads — reject anything else
    ALLOWED_AUDIO_CONTENT_TYPES: frozenset = frozenset({
        "audio/m4a", "audio/mp4", "audio/webm", "audio/ogg",
        "audio/mpeg", "audio/wav", "audio/aac",
    })

    # Claude 3 Haiku — ~10x cheaper than Sonnet, fast enough for rural queries
    BEDROCK_MODEL_ID: str = os.environ.get(
        "BEDROCK_MODEL_ID", "anthropic.claude-3-haiku-20240307-v1:0"
    )
    BEDROCK_MAX_TOKENS: int = int(os.environ.get("BEDROCK_MAX_TOKENS", "512"))
    BEDROCK_HISTORY_TURNS: int = 4
    RESPONSE_CACHE_TTL_SECONDS: int = 86400

    # Input validation limits — prevents token abuse and DynamoDB oversized items
    MAX_TEXT_LENGTH: int = 1000       # characters per user message
    MAX_ITEM_NAME_LENGTH: int = 100
    MAX_ADDRESS_LENGTH: int = 300
    MAX_NOTES_LENGTH: int = 500
    MAX_ORDER_ITEMS: int = 20
    MAX_INVENTORY_ITEMS: int = 200

    WHATSAPP_VERIFY_TOKEN: str = os.environ.get("WHATSAPP_VERIFY_TOKEN", "")
    WHATSAPP_ACCESS_TOKEN: str = os.environ.get("WHATSAPP_ACCESS_TOKEN", "")
    WHATSAPP_PHONE_NUMBER_ID: str = os.environ.get("WHATSAPP_PHONE_NUMBER_ID", "")
    # Used to verify incoming webhook payloads from Meta (X-Hub-Signature-256)
    WHATSAPP_APP_SECRET: str = os.environ.get("WHATSAPP_APP_SECRET", "")

    SUPPORTED_LANGUAGES: list = ["hi", "en", "mr", "ta", "te", "kn", "bn", "gu"]
    DEFAULT_LANGUAGE: str = "hi"


config = Config()
