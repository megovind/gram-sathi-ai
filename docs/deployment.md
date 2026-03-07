# GramSathi — Deployment Guide

This document covers deploying all three parts of GramSathi:
1. [Backend (AWS Lambda)](#1-backend-aws-lambda)
2. [Web App (AWS Amplify)](#2-web-app-aws-amplify)
3. [Flutter App (Android)](#3-flutter-app-android)

---

## Prerequisites

### AWS
- AWS account with CLI configured (`aws configure --profile personal`)
- Region: `ap-south-1` (Mumbai)
- Enable **Amazon Bedrock model access** for Claude 3 Haiku in `ap-south-1` (Console → Bedrock → Model access)

### Tools
```bash
# Node.js 20+
node --version

# Python 3.12+
python3 --version

# Serverless Framework v4
npm install -g serverless

# Flutter 3.x (for mobile only)
flutter --version
```

---

## 1. Backend (AWS Lambda)

### 1a. Setup

```bash
cd backend

# Python virtual environment
python3 -m venv venv
source venv/bin/activate   # Windows: venv\Scripts\activate
pip install -r requirements.txt

# Serverless plugins
npm install
```

### 1b. Environment

```bash
cp .env.example .env
```

Edit `.env` with real values:

```dotenv
JWT_SECRET=<generate with: openssl rand -hex 32>
GOOGLE_PLACES_API_KEY=<Google Places API (New) key>
WHATSAPP_VERIFY_TOKEN=<choose any string>
WHATSAPP_ACCESS_TOKEN=<Meta Graph API token>
WHATSAPP_PHONE_NUMBER_ID=<Meta phone number ID>
WHATSAPP_APP_SECRET=<Meta app secret>
```

**How to get a Google Places API key:**
1. Go to [Google Cloud Console](https://console.cloud.google.com/)
2. Enable the **Places API (New)**
3. Create an API key under "Credentials"
4. Restrict the key to "Places API (New)" for security

### 1c. Local Development

```bash
# Start serverless-offline (uses MongoDB instead of DynamoDB)
npm run dev

# API runs at http://localhost:3000
# Test: curl -X POST http://localhost:3000/user -d '{"phone":"9876543210","language":"hi"}'
```

### 1d. Run Tests

```bash
cd backend
source venv/bin/activate
pytest tests/ -v        # 85 tests
pytest tests/ -v -k "nearby"   # run only nearby-feature tests
```

### 1e. Deploy to AWS

```bash
# Deploy to dev stage
npm run deploy:dev

# Deploy to prod stage
npm run deploy:prod

# Deploy only changed functions (faster)
npx serverless deploy function --function healthQuery --stage dev
```

After deployment, the CLI prints the API Gateway base URL:
```
endpoints:
  POST - https://abc123.execute-api.ap-south-1.amazonaws.com/dev/user
  POST - https://abc123.execute-api.ap-south-1.amazonaws.com/dev/health/query
  ...
```

Save this base URL — you'll need it for the web and Flutter apps.

### 1f. DynamoDB Tables

Tables are created automatically by the Serverless Framework on first deploy. All tables follow the naming pattern `gramsathi-{stage}-{resource}`.

Table names created:
- `gramsathi-dev-users`
- `gramsathi-dev-conversations`
- `gramsathi-dev-shops`
- `gramsathi-dev-orders`
- `gramsathi-dev-response-cache`
- `gramsathi-dev-geo-cache`

### 1g. WhatsApp Webhook Setup

After deploying:
1. Go to [Meta for Developers](https://developers.facebook.com/)
2. Select your WhatsApp Business app
3. Under **Webhooks → WhatsApp → Configure**:
   - Callback URL: `https://<your-api-id>.execute-api.ap-south-1.amazonaws.com/dev/webhook/whatsapp`
   - Verify token: the value you set for `WHATSAPP_VERIFY_TOKEN`
4. Subscribe to `messages` webhook field

---

## 2. Web App (AWS Amplify)

The web app is deployed via **AWS Amplify** using the `amplify.yml` config at the root of the repo.

### 2a. Local Development

```bash
cd web
npm install
cp .env.local.example .env.local
```

Edit `.env.local`:
```dotenv
NEXT_PUBLIC_API_URL=https://abc123.execute-api.ap-south-1.amazonaws.com/dev
NEXT_PUBLIC_APP_URL=http://localhost:3000
```

```bash
npm run dev     # http://localhost:3000
npm run build   # production build check
npm run lint    # ESLint
```

### 2b. Deploy via AWS Amplify Console

1. Push your code to a Git repository (GitHub / CodeCommit)
2. Go to [AWS Amplify Console](https://console.aws.amazon.com/amplify/)
3. Click **"New app" → "Host web app"**
4. Connect your repository and select the branch to deploy
5. Amplify auto-detects `amplify.yml` at the repo root — it builds from the `web/` directory
6. Under **"Environment variables"** in Amplify Console, add:
   ```
   NEXT_PUBLIC_API_URL   = https://<your-backend-url>/prod
   NEXT_PUBLIC_APP_URL   = https://<your-amplify-domain>.amplifyapp.com
   ```
7. Click **"Save and deploy"**

**Amplify build config** (already in `amplify.yml`):
```yaml
version: 1
applications:
  - frontend:
      phases:
        preBuild:
          commands:
            - npm ci
        build:
          commands:
            - npm run build
      artifacts:
        baseDirectory: out
        files:
          - '**/*'
      cache:
        paths:
          - node_modules/**/*
          - .next/cache/**/*
    appRoot: web
```

> **Note:** `next.config.ts` must set `output: 'export'` for static export to work with the `out` directory. If using server-side features (API routes, SSR), configure Amplify SSR hosting instead.

### 2c. Custom Domain (optional)

In Amplify Console → **"Domain management"**, connect your custom domain (e.g., `gramsathi.in`). Amplify provisions an SSL certificate automatically.

Update `NEXT_PUBLIC_APP_URL` to the custom domain and redeploy.

---

## 3. Flutter App (Android)

### 3a. Setup

```bash
cd ui/app
flutter pub get
flutter doctor     # verify environment
```

### 3b. Development Build

```bash
# Run on connected device or emulator
flutter run --dart-define=API_BASE_URL=https://abc123.execute-api.ap-south-1.amazonaws.com/dev

# Run in debug mode
flutter run --debug
```

### 3c. Production Build (APK)

```bash
flutter build apk --release \
  --dart-define=API_BASE_URL=https://abc123.execute-api.ap-south-1.amazonaws.com/prod
```

Output: `build/app/outputs/flutter-apk/app-release.apk`

### 3d. Production Build (App Bundle for Play Store)

```bash
flutter build appbundle --release \
  --dart-define=API_BASE_URL=https://abc123.execute-api.ap-south-1.amazonaws.com/prod
```

Output: `build/app/outputs/bundle/release/app-release.aab`

### 3e. Signing for Release

1. Generate a keystore:
   ```bash
   keytool -genkey -v -keystore gramsathi.keystore \
     -alias gramsathi -keyalg RSA -keysize 2048 -validity 10000
   ```
2. Create `ui/app/android/key.properties`:
   ```properties
   storePassword=<your password>
   keyPassword=<your password>
   keyAlias=gramsathi
   storeFile=../gramsathi.keystore
   ```
3. Update `ui/app/android/app/build.gradle` to reference the keystore (see Flutter docs for signing config)

### 3f. Google Play Store

Upload the `.aab` file in the [Play Console](https://play.google.com/console):
1. Internal testing → Closed testing → Production
2. Fill in the store listing (description, screenshots)
3. Link the privacy policy URL: `https://<your-domain>/legal/privacy-policy`
4. Set content rating (suitable for all ages)

**Permissions used by the app:**

| Permission | Why |
|---|---|
| `INTERNET` | API calls to the backend |
| `RECORD_AUDIO` | Voice input for health queries |
| `ACCESS_FINE_LOCATION` | GPS for nearby clinic/shop searches |
| `ACCESS_COARSE_LOCATION` | Coarse location fallback |

> `FOREGROUND_SERVICE` and `FOREGROUND_SERVICE_MICROPHONE` have been **removed** from the manifest — audio recording happens entirely in the foreground without a persistent notification.

---

## Environment Summary

| Variable | Backend | Web | Flutter | Description |
|---|---|---|---|---|
| `JWT_SECRET` | ✅ | — | — | JWT signing secret |
| `GOOGLE_PLACES_API_KEY` | ✅ | — | — | Google Places API key |
| `NEXT_PUBLIC_API_URL` | — | ✅ | — | Backend API base URL |
| `NEXT_PUBLIC_APP_URL` | — | ✅ | — | Web app public URL |
| `API_BASE_URL` | — | — | ✅ | Backend API base URL (dart-define) |
| `WHATSAPP_*` | ✅ | — | — | Meta WhatsApp credentials |

---

## Monitoring

All Lambda functions log JSON to **CloudWatch Logs** automatically. Log groups follow the pattern `/aws/lambda/gramsathi-{stage}-{function}`.

**Key log fields to watch:**
- `intent` — classified user intent
- `extracted_location` — LLM-extracted location name
- `radius_km` — radius used for nearby search
- `red_flags` — emergency detection boolean
- `error` — any caught exceptions

**Useful CloudWatch Insights query:**
```sql
fields @timestamp, intent, extracted_location, @message
| filter ispresent(intent)
| sort @timestamp desc
| limit 100
```
