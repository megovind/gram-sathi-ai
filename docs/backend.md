# GramSathi Backend — Documentation

> Python 3.12 · AWS Lambda · Serverless Framework · LangGraph · Amazon Bedrock  
> Path: `backend/`

---

## Table of Contents

1. [Overview](#overview)
2. [Tech Stack](#tech-stack)
3. [Project Structure](#project-structure)
4. [LangGraph Agent](#langgraph-agent)
5. [Location Resolution](#location-resolution)
6. [Handlers](#handlers)
7. [Services](#services)
8. [Data Models](#data-models)
9. [Utilities](#utilities)
10. [DynamoDB Tables](#dynamodb-tables)
11. [Configuration & Environment](#configuration--environment)
12. [Authentication](#authentication)
13. [WhatsApp Integration](#whatsapp-integration)
14. [Testing](#testing)

---

## Overview

The backend is a serverless Python application deployed on AWS Lambda via the Serverless Framework. Every HTTP route is a separate Lambda function. The core intelligence lives in a **LangGraph agent** (`src/agents/graph.py`) that orchestrates intent classification, health guidance, location-aware search, and general Q&A using Amazon Bedrock.

---

## Tech Stack

| Component | Technology |
|---|---|
| Runtime | Python 3.12 |
| Deployment | AWS Lambda + Serverless Framework |
| API Gateway | AWS API Gateway (REST) |
| AI / LLM | Amazon Bedrock — Claude 3 Haiku (`anthropic.claude-3-haiku-20240307-v1:0`) |
| Agent Framework | LangGraph |
| Speech-to-Text | Amazon Transcribe |
| Text-to-Speech | Amazon Polly |
| Location Search | Google Places API (New) |
| Database | Amazon DynamoDB |
| File Storage | Amazon S3 |
| Notifications | Amazon SNS |
| Local Dev DB | MongoDB (via `serverless-offline`) |
| Logging | `structlog` (JSON structured logs → CloudWatch) |

---

## Project Structure

```
backend/
├── src/
│   ├── agents/
│   │   └── graph.py              # LangGraph agent — core AI logic
│   ├── handlers/
│   │   ├── chat.py               # POST /chat
│   │   ├── commerce.py           # POST /commerce/shops, /commerce/order, GET /commerce/order/{id}
│   │   ├── health.py             # POST /health/query, /health/nearby
│   │   ├── legal.py              # Privacy policy helpers
│   │   ├── shop_owner.py         # Shop registration, inventory, analytics
│   │   ├── user.py               # POST /user, GET /user/{userId}
│   │   └── webhook.py            # WhatsApp webhook
│   ├── models/
│   │   ├── conversation.py
│   │   ├── order.py
│   │   ├── shop.py
│   │   └── user.py
│   ├── services/
│   │   ├── bedrock_service.py    # Amazon Bedrock (LLM) wrapper
│   │   ├── database.py           # DB selector (DynamoDB vs MongoDB)
│   │   ├── dynamodb_service.py   # DynamoDB CRUD
│   │   ├── google_places_service.py  # Google Places API (New)
│   │   ├── mongodb_service.py    # MongoDB CRUD (local dev only)
│   │   ├── polly_service.py      # Amazon Polly TTS
│   │   ├── s3_service.py         # S3 presigned URL generation
│   │   ├── sns_service.py        # SMS notifications
│   │   └── transcribe_service.py # Amazon Transcribe STT
│   └── utils/
│       ├── auth.py               # JWT helpers
│       ├── config.py             # Centralised config from env vars
│       ├── constants.py          # Intent names, Polly voices, language maps
│       ├── decimal_utils.py      # DynamoDB Decimal ↔ float helpers
│       ├── logger.py             # structlog setup
│       └── response.py           # Standard API response builders
├── tests/
│   ├── test_auth.py
│   ├── test_commerce_handler.py
│   ├── test_health_handler.py
│   ├── test_nearby_features.py
│   ├── test_shop_owner_handler.py
│   ├── test_user_handler.py
│   └── test_utils.py
├── serverless.yml                # Function + resource definitions
├── requirements.txt
└── .env.example
```

---

## LangGraph Agent

**File:** `src/agents/graph.py`

The heart of the backend. A LangGraph state machine that handles all user queries end-to-end.

### State

```python
class QueryState(TypedDict):
    text: str                          # User's text (transcribed or typed)
    language: str                      # ISO language code
    lat: Optional[float]               # GPS latitude from client
    lon: Optional[float]               # GPS longitude from client
    pincode: Optional[str]             # User's stored pincode
    conversation_history: list         # Last N turns for Bedrock context
    intent: str                        # Classified intent
    nearby_kind: str                   # Facility type (clinic/pharmacy/…)
    extracted_location: Optional[str]  # LLM-extracted named location
    response_text: str                 # Final text response
    audio_url: Optional[str]           # Presigned Polly audio URL
    red_flags: bool                    # Emergency detection flag
    facilities: list                   # Nearby facility results
    conversation_id: str
```

### Graph Nodes

```
START
  └─► classify_node
          │
          ├─► health_node         (intent: health_query)
          ├─► nearby_facilities_node  (intent: nearby_facilities)
          ├─► shops_node          (intent: shops)
          └─► general_node        (intent: general / fallback)
                │
                ▼
             END  (response_text + optional audio_url)
```

### `classify_node`

1. Runs `_fast_classify()` — rule-based keyword matching for speed (Hindi + English keywords)
2. If uncertain, calls `_llm_classify()` — sends query to Bedrock with a structured classification prompt
3. For `nearby_facilities` and `shops` intents, calls `_llm_extract_location()` to detect any named place in the query

**Fast classifier keywords (sample):**
- Health: `बुखार`, `दर्द`, `fever`, `pain`, `clinic`, `hospital`, `doctor`
- Nearby: `नजदीकी`, `nearby`, `पास में`, `near`, `close to`
- Shops: `दुकान`, `shop`, `order`, `buy`, `store`

### `health_node`

1. Calls `detect_red_flags_fast()` — keyword scan for medical emergencies (chest pain, unconscious, etc.)
2. If red flag detected → returns emergency response immediately (no Bedrock call)
3. Else → sends to Bedrock with conversation history for non-diagnostic health guidance
4. Calls Polly to generate audio response

### `nearby_facilities_node`

See [Location Resolution](#location-resolution).

### `shops_node`

1. If `extracted_location` is present → Google Places text search for `"shops in {location}, India"`
2. Else if no GPS and no pincode → `_no_location_reply()` asking user to share location
3. Else → DynamoDB lookup by pincode; if empty, falls back to Google Places with GPS/pincode

### `general_node`

Sends the query to Bedrock with conversation history. Used for agriculture info, government schemes, general rural Q&A.

### `_llm_extract_location(text)`

Calls Bedrock with a focused prompt to extract a specific city, town, or area name from the user's text. Returns `None` if no named location is found. This function handles multilingual input (Hindi, Telugu, etc.) naturally.

```python
# Example inputs → outputs
"clinics in Kota"            → "Kota"
"Aklera ke shops"            → "Aklera"
"जयपुर में दुकान"             → "Jaipur"
"nearby clinic"              → None   (no named location)
"मुझे बुखार है"               → None   (not a location query)
```

### `_no_location_reply(language)`

Returns a localised message asking the user to share their location or pincode, in their selected language.

---

## Location Resolution

The system resolves location using a strict priority order:

```
Query text
    │
    ▼
_llm_extract_location()
    │
    ├─ Location found? → Google Places text search: "{kind} in {location}, India"
    │                    (ignores GPS and pincode)
    │
    └─ No location?
           │
           ├─ GPS coordinates available?
           │       → _nearby_search() with radius ladder:
           │         10 km → 20 km → 50 km (auto-expand until results found)
           │
           ├─ No GPS but pincode available?
           │       → _text_search(): "{kind} near {pincode}, India"
           │
           └─ Nothing available?
                   → _no_location_reply() prompting user
```

### `GooglePlacesService` (`src/services/google_places_service.py`)

Wraps the Google Places API (New).

**`search_facilities(query, kind, lat, lon, max_results, force_text_search, pincode)`**

- `force_text_search=True` → always uses `_text_search` with the raw query verbatim (used for named-location queries)
- `lat`/`lon` present → `_nearby_search` with radius ladder
- `pincode` present → `_text_search` anchored to the pincode
- Returns a list of dicts: `{name, address, rating, distance, maps_url}`

**Radius ladder:**
```python
_NEARBY_RADIUS_LADDER = [10_000, 20_000, 50_000]  # metres: 10 km → 20 km → 50 km
```
The search tries 10 km first; if no results, expands to 20 km, then 50 km.

**Kind → search term mapping:**
```python
_KIND_SEARCH_TERM = {
    "clinic":    "clinics and doctors",
    "pharmacy":  "medical stores and pharmacies",
    "hospital":  "hospitals",
    "doctor":    "doctors and clinics",
    "shop":      "general stores and shops",
    "grocery":   "grocery stores",
    "farm":      "agriculture and farm supply stores",
}
```

---

## Handlers

### `health.py` — `POST /health/query`

1. Validates JWT
2. Extracts `text`, `audioS3Key`, `language`, `conversationId`, `latitude`, `longitude`, `pincode` from request body
3. If `audioS3Key` present → calls Transcribe to get text
4. Loads conversation history from DynamoDB (last 4 turns)
5. Resolves pincode: request body pincode → user profile pincode → `None`
6. Invokes `agent_graph.invoke(state)` → LangGraph processes everything
7. Saves new turn to conversation history in DynamoDB
8. Returns `{text, audioUrl, redFlags, facilities, conversationId}`

### `commerce.py` — Shop & Order endpoints

- `POST /commerce/shops` — queries DynamoDB by pincode; returns shop list
- `POST /commerce/order` — validates JWT, creates order in DynamoDB, sends SNS notification to shop owner
- `GET /commerce/order/{id}` — returns order status

### `shop_owner.py` — Shop Management

- `POST /shop` — registers new shop (requires JWT)
- `GET /shop/{shopId}` — public shop profile
- `POST /shop/{shopId}/inventory` — replaces inventory (owner JWT required)
- `GET /shop/{shopId}/orders` — incoming orders for owner
- `GET /shop/{shopId}/analytics` — daily revenue grouped by date

### `user.py` — Auth

- `POST /user` — registers or logs in via phone number; returns JWT
- `GET /user/{userId}` — returns user profile (name, phone, language, pincode)

**Phone number storage:** The phone number is stored in DynamoDB (`gramsathi-{stage}-users` table) as the primary key. It is hashed with a stable hash before storage to minimise PII exposure. The raw phone is never logged.

### `chat.py` — `POST /chat`

General-purpose voice/text chat. Used for non-health queries. Feeds into `general_node` of the LangGraph agent.

### `webhook.py` — WhatsApp

- `GET /webhook/whatsapp` — Meta webhook verification challenge
- `POST /webhook/whatsapp` — receives incoming messages, validates `X-Hub-Signature-256`, routes to the agent

---

## Services

### `bedrock_service.py`

Wraps `boto3` calls to Amazon Bedrock (Claude 3 Haiku).

```python
class BedrockService:
    def chat(self, prompt: str, language: str = "en") -> str
    def classify(self, text: str) -> str
```

- Model: `anthropic.claude-3-haiku-20240307-v1:0` (configurable via `BEDROCK_MODEL_ID`)
- Max tokens: 512 (configurable via `BEDROCK_MAX_TOKENS`)
- Region: `ap-south-1`

### `google_places_service.py`

See [Location Resolution](#location-resolution) above.

### `transcribe_service.py`

```python
class TranscribeService:
    def transcribe_audio(self, s3_key: str, language_code: str) -> str
```

- Starts a Transcribe job, polls until complete
- Returns the transcript text
- Language code mapped from app language code (e.g., `hi` → `hi-IN`)

### `polly_service.py`

```python
class PollyService:
    def synthesise(self, text: str, language: str, low_bandwidth: bool = False) -> str
    # Returns presigned S3 URL of the generated audio file
```

- MP3 format by default
- OGG Vorbis for low-bandwidth mode
- Polly voice selected per language (e.g., `Aditi` for Hindi, `Raveena` for Tamil)

### `s3_service.py`

```python
class S3Service:
    def get_upload_url(self, content_type: str) -> dict  # {url, key}
    def get_download_url(self, key: str) -> str
```

- Generates presigned URLs for audio uploads (1-hour expiry)
- Allowed content types validated against a safelist

### `sns_service.py`

Sends SMS notifications to shop owners when a new order arrives.

### `dynamodb_service.py`

CRUD layer for all DynamoDB tables. Key methods:
- `get_user`, `put_user`, `update_user`
- `get_conversation`, `put_conversation`
- `get_shops_by_pincode`, `put_shop`, `update_shop`
- `get_orders_by_shop`, `put_order`, `update_order_status`
- `get_cached_response`, `put_cached_response` (24-hour LLM response cache)

### `database.py`

Selector that returns `DynamoDBService` in production (AWS) and `MongoDBService` in local dev (when `IS_OFFLINE=true`).

---

## Data Models

### User
```python
{
    "userId": str,          # phone hash (PK)
    "phone": str,           # hashed phone number
    "name": str,
    "language": str,        # language preference
    "pincode": str,         # stored location for nearby searches
    "createdAt": ISO8601
}
```

### Conversation
```python
{
    "conversationId": str,  # PK
    "userId": str,
    "turns": [              # last 4 turns
        {"role": "user" | "assistant", "content": str}
    ],
    "updatedAt": ISO8601,
    "ttl": int              # Unix timestamp for DynamoDB TTL (24h)
}
```

### Shop
```python
{
    "shopId": str,          # PK
    "ownerId": str,
    "name": str,
    "type": str,            # grocery, pharmacy, hardware, etc.
    "pincode": str,
    "address": str,
    "phone": str,
    "inventory": [
        {"name": str, "price": float, "unit": str, "stock": int}
    ],
    "approved": bool,
    "createdAt": ISO8601
}
```

### Order
```python
{
    "orderId": str,         # PK
    "shopId": str,
    "buyerId": str,
    "items": [
        {"name": str, "quantity": int, "price": float}
    ],
    "total": float,
    "status": "pending" | "confirmed" | "delivered" | "cancelled",
    "createdAt": ISO8601
}
```

---

## Utilities

### `config.py`

Central `Config` class reading all settings from environment variables with sensible defaults. Key settings:

| Setting | Default | Description |
|---|---|---|
| `STAGE` | `dev` | Deployment stage |
| `AWS_REGION` | `ap-south-1` | AWS region |
| `BEDROCK_MODEL_ID` | Claude 3 Haiku | LLM model |
| `BEDROCK_MAX_TOKENS` | `512` | Max response tokens |
| `BEDROCK_HISTORY_TURNS` | `4` | Conversation turns to include |
| `RESPONSE_CACHE_TTL_SECONDS` | `86400` | 24h LLM response cache TTL |
| `MAX_TEXT_LENGTH` | `1000` | Max chars per user message |
| `MAX_INVENTORY_ITEMS` | `200` | Max items per shop inventory |
| `SUPPORTED_LANGUAGES` | `[hi, en, mr, ta, te, kn, bn, gu]` | Accepted language codes |
| `DEFAULT_LANGUAGE` | `hi` | Fallback language |

### `constants.py`

- Intent name constants (`INTENT_HEALTH`, `INTENT_NEARBY`, etc.)
- Polly voice IDs per language
- Language code mappings (app code → Transcribe language code, Polly language code)

### `auth.py`

```python
def issue_token(user_id: str) -> str      # Signs a JWT (HS256, no expiry)
def verify_token(token: str) -> str        # Returns user_id or raises
def require_auth(event) -> str             # Lambda middleware helper
```

### `logger.py`

Configures `structlog` for JSON-formatted structured logging. All handlers call `logger.info(...)`, `logger.warning(...)` with context fields. Logs flow to CloudWatch automatically in Lambda.

### `response.py`

```python
def ok(body: dict, status: int = 200) -> dict     # Standard 200 response
def error(message: str, status: int = 400) -> dict # Standard error response
```

---

## DynamoDB Tables

All tables are prefixed with `gramsathi-{stage}-`.

| Table | PK | SK | Description |
|---|---|---|---|
| `users` | `userId` | — | User profiles |
| `conversations` | `conversationId` | — | Chat history (TTL: 24h) |
| `shops` | `shopId` | — | Shop profiles & inventory |
| `orders` | `orderId` | — | Orders (GSI on `shopId`) |
| `response-cache` | `cacheKey` | — | LLM response cache (TTL: 24h) |
| `geo-cache` | `geoKey` | — | Places API cache (no TTL) |

---

## Configuration & Environment

File: `backend/.env` (copy from `.env.example`)

| Variable | Required | Description |
|---|---|---|
| `JWT_SECRET` | ✅ | Secret for JWT signing |
| `GOOGLE_PLACES_API_KEY` | ✅ | Google Places API (New) key |
| `BEDROCK_MODEL_ID` | — | Override Bedrock model |
| `WHATSAPP_VERIFY_TOKEN` | WhatsApp only | Meta webhook verify token |
| `WHATSAPP_ACCESS_TOKEN` | WhatsApp only | Meta Graph API token |
| `WHATSAPP_PHONE_NUMBER_ID` | WhatsApp only | Meta phone number ID |
| `WHATSAPP_APP_SECRET` | WhatsApp only | Payload signature verification |
| `STAGE` | — | `dev` or `prod` (default: `dev`) |
| `AWS_REGION` | — | AWS region (default: `ap-south-1`) |
| `MONGODB_URI` | Local dev | MongoDB URI for `serverless-offline` |

---

## Authentication

JWT-based auth (HS256, no expiry).

**Login flow:**
1. Client sends `POST /user` with phone number
2. Server creates/updates user in DynamoDB
3. Server signs JWT: `{"userId": "...", "iat": ...}`
4. Client stores JWT in localStorage
5. All protected routes check `Authorization: Bearer <token>` header

There is no OTP verification step in the current implementation — phone number is the identity.

---

## WhatsApp Integration

The webhook handler (`src/handlers/webhook.py`):

1. `GET` — responds to Meta's verification challenge (`hub.challenge`)
2. `POST` — validates `X-Hub-Signature-256` HMAC signature
3. Extracts message text / audio URL from Meta payload
4. Routes text messages to `agent_graph.invoke()`
5. If audio message → downloads audio, uploads to S3, transcribes, then routes
6. Sends response back via Meta Graph API (`messages` endpoint)

---

## Testing

**Run all tests:**
```bash
cd backend
source venv/bin/activate
pytest tests/ -v
```

**Test suites (85 tests total):**

| File | Tests | What it covers |
|---|---|---|
| `test_auth.py` | ~8 | JWT issue, verify, invalid token handling |
| `test_user_handler.py` | ~10 | Register, login, profile fetch |
| `test_health_handler.py` | ~15 | Health query, red-flag emergency path, audio transcription flow |
| `test_nearby_features.py` | ~42 | Google Places routing, radius ladder auto-expansion, LLM location extraction, `nearby_facilities_node`, `shops_node`, named-location override, no-location fallback |
| `test_commerce_handler.py` | ~5 | Shop search, order placement, order status |
| `test_shop_owner_handler.py` | ~5 | Shop registration, inventory upload, analytics |
| `test_utils.py` | — | Config, constants, response builders |

**Key testing patterns:**
- `monkeypatch` to mock Bedrock, DynamoDB, Google Places, and Transcribe
- `pytest.fixture` for fake API keys and test data
- Mocking at the module import level (e.g., `src.agents.graph.bedrock.chat`)
