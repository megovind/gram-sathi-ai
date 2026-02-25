# GramSathi AI

Voice-first AI assistant for rural India — healthcare guidance + local commerce.

---

## Project Structure

```
gram-sathi-ai/
├── backend/          # Python AWS Lambda (Serverless Framework)
├── ui/app/           # Flutter mobile app (Android + iOS)
├── docs/
├── design.md
├── requirements.md
└── user-stories.md
```

---

## Tech Stack

| Layer | Technology |
|---|---|
| Frontend | Flutter 3.x |
| Backend | Python 3.12 · AWS Lambda · Serverless Framework |
| AI | Amazon Bedrock (Claude 3.5 Sonnet) |
| Speech-to-Text | Amazon Transcribe |
| Text-to-Speech | Amazon Polly |
| Database | Amazon DynamoDB |
| Storage | Amazon S3 |
| Notifications | Amazon SNS |
| Auth | JWT (HS256) |
| Monitoring | Amazon CloudWatch |

---

## Backend Setup

### Prerequisites

- Python 3.12+
- Node.js 20+ (for Serverless Framework CLI)
- AWS CLI configured (`aws configure`)
- Amazon Bedrock: enable **Claude 3.5 Sonnet** model access in `ap-south-1`

### Install

```bash
cd backend

# Python dependencies
python3 -m venv venv
source venv/bin/activate        # Windows: venv\Scripts\activate
pip install -r requirements.txt

# Serverless Framework + plugins
npm install
```

### Environment

```bash
cp .env.example .env
# Edit .env — fill in AWS credentials, JWT_SECRET, WhatsApp tokens
```

### Run locally

```bash
# Starts all Lambda functions on http://localhost:3000
npm run dev
```

### Run tests

```bash
# Unit + handler tests (no AWS needed — uses moto mocks)
pytest tests/ -v
```

### Deploy to AWS

```bash
npm run deploy:dev     # → dev stage
npm run deploy:prod    # → prod stage
```

---

## Flutter App Setup

### Prerequisites

- Flutter 3.3+ (`flutter --version`)
- Android Studio / Xcode

### Install

```bash
cd ui/app
flutter pub get
```

### Configure API URL

By default the app points to `http://localhost:3000` (local backend).

To use your deployed AWS API Gateway URL:

```bash
# Run
flutter run --dart-define=API_BASE_URL=https://abc123.execute-api.ap-south-1.amazonaws.com/dev

# Build
flutter build apk --dart-define=API_BASE_URL=https://abc123...
```

### Run on device/emulator

```bash
flutter run
```

---

## Onboarding Flow

```
1. Language Selection  →  select Hindi / English / regional language
2. Phone Number        →  mobile number + optional name  →  POST /user  →  JWT issued
3. Welcome             →  feature intro
4. Home                →  voice chat, health, commerce
```

---

## API Reference

All protected endpoints require:
```
Authorization: Bearer <token>
```

| Method | Path | Auth | Description |
|---|---|---|---|
| POST | `/user` | — | Register / login, returns JWT |
| GET | `/user/{userId}` | — | Get user profile |
| POST | `/chat` | ✅ | Voice/text → AI reply + audio |
| POST | `/audio/upload-url` | ✅ | Presigned S3 URL for audio upload |
| POST | `/health/query` | ✅ | Symptom → health guidance |
| POST | `/health/nearby` | — | Clinics/pharmacies by pincode |
| POST | `/commerce/shops` | — | Nearby shops by pincode |
| POST | `/commerce/order` | ✅ | Place order |
| GET | `/commerce/order/{id}` | ✅ | Order status |
| POST | `/shop` | ✅ | Register shop |
| GET | `/shop/{shopId}` | — | Shop profile |
| POST | `/shop/{shopId}/inventory` | ✅ Owner | Upload inventory |
| GET | `/shop/{shopId}/orders` | ✅ Owner | Incoming orders |
| GET | `/shop/{shopId}/analytics` | ✅ Owner | Daily revenue |
| GET | `/webhook/whatsapp` | — | WhatsApp verify |
| POST | `/webhook/whatsapp` | — | Incoming WhatsApp messages |

---

## Low Bandwidth Mode (US-22)

Pass `"lowBandwidth": true` in any request body to receive compressed OGG audio (~70% smaller than MP3, optimised for 2G/slow connections).

---

## CloudWatch Logs

All handlers emit structured JSON logs:

```json
{
  "timestamp": "2025-02-25T10:00:00Z",
  "level": "INFO",
  "service": "gramsathi-backend",
  "stage": "dev",
  "event": "chat_request",
  "user_id": "ph-9876543210",
  "language": "hi",
  "has_audio": false
}
```

---

## WhatsApp Integration

1. Create a Meta App and enable WhatsApp Business API
2. Set webhook URL to: `https://<api-gw-url>/webhook/whatsapp`
3. Set verify token in `.env`: `WHATSAPP_VERIFY_TOKEN=your-token`
4. Add `WHATSAPP_ACCESS_TOKEN` and `WHATSAPP_PHONE_NUMBER_ID`

---

## User Stories Coverage

| Story | Description | Status |
|---|---|---|
| US-01 | Language selection & onboarding | ✅ |
| US-02 | Voice input | ✅ |
| US-03 | Text input fallback | ✅ |
| US-04 | Voice + text output | ✅ |
| US-05 | Symptom capture | ✅ |
| US-06 | Basic health guidance | ✅ |
| US-07 | Red flag detection | ✅ |
| US-08 | Nearby clinics/pharmacies | ✅ |
| US-09 | Doctor summary | ✅ |
| US-10 | Discover local shops | ✅ |
| US-11 | Assisted ordering | ✅ |
| US-12 | Order confirmation | ✅ |
| US-13 | Shop registration | ✅ |
| US-14 | Inventory upload | ✅ |
| US-15 | Order notifications (SNS) | ✅ |
| US-16 | Analytics dashboard | ✅ |
| US-17 | Intent classification | ✅ |
| US-18 | Conversation memory | ✅ |
| US-19 | Regional language processing | ✅ |
| US-20 | JWT Authentication | ✅ |
| US-21 | PII minimisation | ✅ |
| US-22 | Low bandwidth mode | ✅ |
| US-23 | CloudWatch monitoring | ✅ |
