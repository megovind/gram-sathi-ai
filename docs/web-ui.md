# GramSathi Web UI — Documentation

> Next.js 15 · TypeScript · Tailwind CSS  
> Path: `web/`

---

## Table of Contents

1. [Overview](#overview)
2. [Tech Stack](#tech-stack)
3. [Project Structure](#project-structure)
4. [Screens & Routes](#screens--routes)
5. [Components](#components)
6. [Hooks](#hooks)
7. [Library (`lib/`)](#library-lib)
8. [Internationalization (i18n)](#internationalization-i18n)
9. [State Management](#state-management)
10. [API Integration](#api-integration)
11. [Location & GPS](#location--gps)
12. [Audio (Voice Input/Output)](#audio-voice-inputoutput)
13. [Language Selection](#language-selection)
14. [Environment Variables](#environment-variables)
15. [Styling & Theming](#styling--theming)
16. [Known Patterns & Decisions](#known-patterns--decisions)

---

## Overview

The web client is a responsive progressive-web application. It mirrors the Flutter mobile app's feature set and is the primary channel for non-Android users. All text is fully translated into 8 Indian languages; the app works on desktop, tablet, and mobile browsers.

---

## Tech Stack

| Tool | Purpose |
|---|---|
| Next.js 15 (App Router) | Routing, SSR/CSR, metadata |
| React 19 | UI |
| TypeScript 5 | Type safety |
| Tailwind CSS 3 | Utility-first styling |
| Lucide React | Icon library |
| Sonner | Toast notifications |
| `clsx` + `tailwind-merge` | Conditional class names |

---

## Project Structure

```
web/
├── app/                    # Next.js App Router pages
│   ├── page.tsx            # / — Login (phone number entry)
│   ├── layout.tsx          # Root layout (font, Toaster)
│   ├── globals.css         # Tailwind base + custom tokens
│   ├── phone/
│   │   └── page.tsx        # /phone — OTP / phone verify step
│   ├── welcome/
│   │   └── page.tsx        # /welcome — post-login welcome
│   ├── home/
│   │   └── page.tsx        # /home — main dashboard
│   ├── health/
│   │   └── page.tsx        # /health — AI health chat
│   ├── commerce/
│   │   ├── shops/
│   │   │   └── page.tsx    # /commerce/shops — shop discovery
│   │   └── order/
│   │       └── page.tsx    # /commerce/order — order placement
│   ├── shop/
│   │   ├── dashboard/
│   │   │   └── page.tsx    # /shop/dashboard — shop owner home
│   │   └── inventory/
│   │       └── page.tsx    # /shop/inventory — inventory management
│   └── legal/
│       └── privacy-policy/
│           └── page.tsx    # /legal/privacy-policy — static privacy page
├── components/             # Shared React components
│   ├── AudioPlayer.tsx
│   ├── FacilityCard.tsx
│   ├── FormattedMessage.tsx
│   ├── LanguageModal.tsx
│   ├── MessageBubble.tsx
│   └── VoiceButton.tsx
├── hooks/
│   └── useAudio.ts         # Browser MediaRecorder hook
├── lib/
│   ├── api.ts              # All backend API calls
│   ├── store.ts            # localStorage wrapper
│   ├── strings.ts          # i18n translations (8 languages)
│   ├── types.ts            # Shared TypeScript types
│   └── utils.ts            # cn() helper
├── public/                 # Static assets (logo, icons)
├── middleware.ts            # Auth redirect (unauthenticated → /)
├── next.config.ts
├── tailwind.config.ts
└── .env.local.example
```

---

## Screens & Routes

### `/` — Login

**File:** `app/page.tsx`

The entry point of the app. Unauthenticated users always land here (enforced by `middleware.ts`).

**Features:**
- Phone number input (10-digit validation)
- Language selector button → opens `LanguageModal`
- Calls `POST /user` → receives JWT
- Stores `token`, `phone`, `userId` in localStorage via `store`
- Links to `/legal/privacy-policy` in the privacy notice

**Flow:**
```
Enter phone → POST /user → store JWT → router.push('/welcome')
```

---

### `/welcome` — Welcome Screen

**File:** `app/welcome/page.tsx`

A brief intro screen shown once after first login. Shows the GramSathi logo and a "Continue" button.

---

### `/home` — Dashboard

**File:** `app/home/page.tsx`

**Features:**
- Greeting with user's saved name/phone
- Two primary feature cards: **Health Advice** and **Local Shops**
- **Voice Ask** section with microphone button for quick voice queries
- **Quick Access** links: Nearby Clinics, My Orders, My Shop
- **Settings** panel (bottom): Change Language (opens `LanguageModal`), Sign Out
- All text is i18n-translated using `getStrings(language)`

---

### `/health` — AI Health Chat

**File:** `app/health/page.tsx`

The most feature-rich screen.

**Features:**
- Conversational chat UI (user bubbles on the right, AI on the left)
- Text input + voice recording button
- Suggestion chips for common queries (e.g., "Nearby clinics", "I have fever")
- **GPS indicator** in the app bar:
  - `LocateFixed` icon (lit) = GPS active, nearby searches use coordinates
  - `LocateOff` icon (dimmed) = no GPS, falls back to stored pincode
- **Emergency banner** — appears when `red_flags` is `true` in the API response; displays "Call 108 immediately" in the user's language
- **Doctor Summary** — floating button + modal for a clinical conversation summary (for sharing with a doctor)
- Audio playback of AI responses (via `useAudio` hook)
- Facility cards rendered inline when the AI returns nearby results (`FacilityCard`)
- Supports low-bandwidth mode (OGG audio)
- Sends `latitude`, `longitude`, and `pincode` with every query for location-aware responses

**GPS capture logic:**
```typescript
useEffect(() => {
  navigator.geolocation.getCurrentPosition(
    pos => setUserLocation({ lat, lon }),
    () => { /* graceful silent failure */ },
    { enableHighAccuracy: false, timeout: 8000, maximumAge: 300_000 }
  )
}, [])
```

---

### `/commerce/shops` — Shop Discovery

**File:** `app/commerce/shops/page.tsx`

- Pincode-based shop search (user can enter or use stored pincode)
- Displays shop cards with name, type, address
- "Order from Shop" → navigates to `/commerce/order`

---

### `/commerce/order` — Order Placement

**File:** `app/commerce/order/page.tsx`

- Browse shop inventory
- Add items, set quantities
- Submit order → `POST /commerce/order`
- Shows order confirmation with order ID

---

### `/shop/dashboard` — Shop Owner Dashboard

**File:** `app/shop/dashboard/page.tsx`

- Incoming orders list
- Daily revenue analytics
- Link to inventory management

---

### `/shop/inventory` — Inventory Management

**File:** `app/shop/inventory/page.tsx`

- Upload/edit inventory items (name, price, unit, stock)
- `POST /shop/{shopId}/inventory`

---

### `/legal/privacy-policy` — Privacy Policy

**File:** `app/legal/privacy-policy/page.tsx`

- Static server-rendered page
- SEO metadata with canonical URL from `NEXT_PUBLIC_APP_URL`
- Linked from the login page's privacy notice

---

## Components

### `LanguageModal.tsx`

A full-screen overlay (accessible as a modal/popup from any screen) that lets the user pick from the 8 supported languages. Saves the choice to localStorage and immediately updates the UI without a page reload.

**Used in:** Login (`/`), Home dashboard settings panel.

---

### `MessageBubble.tsx`

Renders a single chat message. Handles:
- User messages (right-aligned, primary colour)
- AI messages (left-aligned, surface colour)
- Voice recording indicator ("🎤 Recording…")
- Uploading indicator
- `FormattedMessage` for markdown-like AI responses

---

### `FormattedMessage.tsx`

Renders AI response text with basic formatting (bold text, numbered lists, bullet points) parsed from plain text conventions.

---

### `VoiceButton.tsx`

Animated microphone button. States:
- Idle — tap to start recording
- Recording (pulsing animation) — tap to stop and send
- Loading — spinner while processing

Delegates recording to the `useAudio` hook.

---

### `FacilityCard.tsx`

Displays a single nearby clinic, pharmacy, or hospital returned by the AI. Shows:
- Facility name
- Address
- Rating (if available)
- Distance (if available)
- "Get Directions" link (Google Maps URL)

---

### `AudioPlayer.tsx`

Plays AI audio responses from a presigned S3 URL or data URL. Shows a play/pause button with a progress bar.

---

## Hooks

### `useAudio.ts`

Wraps the browser `MediaRecorder` API.

**Returns:**
```typescript
{
  isRecording: boolean
  startRecording: () => void
  stopRecording: () => Promise<Blob | null>
  error: string | null
}
```

**Flow:**
1. `startRecording()` — requests `getUserMedia({ audio: true })`, starts `MediaRecorder`
2. `stopRecording()` — stops recorder, resolves with the audio `Blob`
3. The caller (health page) then uploads the blob to S3 via presigned URL and passes the S3 key to the backend

---

## Library (`lib/`)

### `api.ts`

All calls to the backend. Uses `fetch` with the JWT token from `store`. Key functions:

| Function | Endpoint | Description |
|---|---|---|
| `registerUser(phone, lang)` | `POST /user` | Register / login |
| `healthQuery(params)` | `POST /health/query` | Health chat query |
| `getDoctorSummary(convId)` | `POST /health/query` (summary flag) | Clinical summary |
| `getAudioUploadUrl(contentType)` | `POST /audio/upload-url` | Presigned S3 URL |
| `uploadAudioToS3(url, blob)` | PUT (S3 direct) | Upload audio blob |
| `getShops(pincode)` | `POST /commerce/shops` | Shop discovery |
| `placeOrder(shopId, items)` | `POST /commerce/order` | Place order |
| `getOrder(orderId)` | `GET /commerce/order/{id}` | Order status |

---

### `store.ts`

A thin `localStorage` wrapper. Keys stored:

| Key | Value | Description |
|---|---|---|
| `token` | JWT string | Auth token |
| `userId` | string | User ID |
| `phone` | string | User's phone number |
| `language` | language code | UI language preference |
| `pincode` | string | User's stored pincode for location fallback |

**Note:** The phone number is stored only in `localStorage` on the client — it is never exposed in URLs or logs.

---

### `strings.ts`

Contains the `Strings` interface and full translations for all 8 languages. The `getStrings(language: string): Strings` function is called in every page component to get the correct translation object.

See [Internationalization](#internationalization-i18n) for details.

---

### `types.ts`

Shared TypeScript interfaces:

```typescript
interface Message {
  id: string
  role: 'user' | 'assistant'
  content: string
  timestamp: Date
  isVoice?: boolean
  isUploading?: boolean
  audioUrl?: string
  facilities?: Facility[]
  isEmergency?: boolean
}

interface Facility {
  name: string
  address: string
  rating?: number
  distance?: string
  mapsUrl?: string
}

type NearbyKind = 'clinic' | 'pharmacy' | 'hospital' | 'doctor'
```

---

### `utils.ts`

```typescript
// Merges Tailwind class names safely (clsx + tailwind-merge)
function cn(...inputs: ClassValue[]): string
```

---

## Internationalization (i18n)

All UI text is managed in `lib/strings.ts`. There is no external i18n library — the translations are plain TypeScript objects.

**Supported languages:**

| Code | Language | Script |
|---|---|---|
| `hi` | Hindi | Devanagari |
| `en` | English | Latin |
| `mr` | Marathi | Devanagari |
| `ta` | Tamil | Tamil |
| `te` | Telugu | Telugu |
| `kn` | Kannada | Kannada |
| `bn` | Bengali | Bengali |
| `gu` | Gujarati | Gujarati |

**Usage pattern in every page:**
```typescript
const t = getStrings(store.getLanguage())
// then use t.healthTitle, t.typeMessage, etc.
```

The language code is persisted in `localStorage`. When the user changes language in `LanguageModal`, the component updates the store and triggers a re-render.

---

## State Management

There is no global React state library (no Redux, Zustand, etc.). State is managed via:

1. **`localStorage` (`lib/store.ts`)** — persistent cross-session data (token, language, pincode)
2. **React `useState`** — local component state (messages, loading, input value, GPS location)
3. **`useRouter`** — navigation between screens

This keeps the bundle small and avoids unnecessary complexity for the app's scope.

---

## API Integration

All API calls go through `lib/api.ts`. The base URL is read from `NEXT_PUBLIC_API_URL`.

**Auth header pattern:**
```typescript
headers: {
  'Content-Type': 'application/json',
  'Authorization': `Bearer ${store.getToken()}`
}
```

**Health query payload:**
```typescript
{
  text?: string          // typed message
  audioS3Key?: string    // S3 key of voice recording
  language: string       // user's language code
  conversationId?: string // for multi-turn context
  lowBandwidth: false
  latitude?: number      // GPS lat (if available)
  longitude?: number     // GPS lon (if available)
  pincode?: string       // stored pincode (fallback)
}
```

---

## Location & GPS

The health page captures the user's GPS position on mount:

```typescript
navigator.geolocation.getCurrentPosition(
  pos => setUserLocation({ lat, lon }),
  () => { /* silent failure — falls back to pincode */ },
  { enableHighAccuracy: false, timeout: 8000, maximumAge: 300_000 }
)
```

**Location resolution priority (frontend contribution):**
1. GPS coordinates sent in every health query
2. Stored `pincode` sent as fallback
3. User-typed location in the query (resolved by the backend LLM)

The GPS status indicator (lock icon) in the health page app bar provides visual feedback to the user.

---

## Audio (Voice Input/Output)

**Input (user → backend):**
1. User taps `VoiceButton` → `useAudio.startRecording()` → `MediaRecorder` starts
2. User taps again → `stopRecording()` returns audio `Blob` (WebM format)
3. App calls `getAudioUploadUrl()` → gets presigned S3 URL
4. App `PUT` uploads blob directly to S3
5. App sends the S3 key in the health query — backend calls Amazon Transcribe

**Output (backend → user):**
1. API response includes an `audioUrl` (presigned S3 URL for the Polly-generated audio)
2. `AudioPlayer` component streams and plays it

---

## Language Selection

Language selection is available as a modal/popup (not a separate page):

- **Login screen** — "Language" button in the top-right corner opens `LanguageModal`
- **Home screen** — Settings panel → "Change Language" opens `LanguageModal`

The `LanguageModal`:
1. Shows a grid of all 8 language options with their native-script names
2. Highlights the currently selected language
3. On selection: calls `store.setLanguage(code)` and closes; the page re-renders with new strings immediately (no navigation)

---

## Environment Variables

File: `web/.env.local` (not committed — copy from `.env.local.example`)

| Variable | Example | Description |
|---|---|---|
| `NEXT_PUBLIC_API_URL` | `https://abc.execute-api.ap-south-1.amazonaws.com/dev` | Backend API base URL |
| `NEXT_PUBLIC_APP_URL` | `https://gramsathi.example.com` | Web app public URL (canonical links, privacy policy) |

Both variables are prefixed `NEXT_PUBLIC_` so they are available in client-side code.

---

## Styling & Theming

Tailwind CSS with custom colour tokens defined in `tailwind.config.ts` and `globals.css`:

| Token | Usage |
|---|---|
| `primary` | Buttons, active states, links |
| `surface` | Card backgrounds |
| `background` | Page background |
| `textPrimary` | Main body text |
| `textHint` | Placeholder / hint text |
| `emergency` | Red alert banner (emergency detections) |

The app uses a warm green-based palette inspired by rural India's landscape.

---

## Known Patterns & Decisions

### No hydration mismatch
All client-only state (language, token) is read inside `useEffect` or event handlers, not during SSR render, to avoid React hydration mismatches.

### Auth middleware
`middleware.ts` checks for a `token` cookie/header and redirects unauthenticated requests to `/`. The health and home pages require a valid JWT.

### No separate language page
Language selection was intentionally converted from a dedicated `/language` route to a reusable modal to reduce navigation steps and improve UX on both mobile and desktop.

### Full-width desktop layout
Pages use `max-w-2xl mx-auto` on the content container so the app looks intentional on wide screens rather than being a narrow mobile strip.

### Privacy policy canonical URL
The `/legal/privacy-policy` page uses `NEXT_PUBLIC_APP_URL` to generate the canonical `<link>` tag, ensuring correct SEO regardless of the deployment domain.
