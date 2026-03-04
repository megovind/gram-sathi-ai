import { store } from './store'

const BASE = process.env.NEXT_PUBLIC_API_URL!

class ApiError extends Error {
  constructor(public status: number, message: string) {
    super(message)
  }
}

async function request<T>(
  path: string,
  options: RequestInit = {},
  auth = true,
): Promise<T> {
  const headers: Record<string, string> = {
    'Content-Type': 'application/json',
    ...(options.headers as Record<string, string>),
  }
  if (auth) {
    const token = store.getToken()
    if (token) headers['Authorization'] = `Bearer ${token}`
  }
  const res = await fetch(`${BASE}${path}`, { ...options, headers })
  if (!res.ok) {
    const body = await res.json().catch(() => ({}))
    throw new ApiError(res.status, body.message ?? res.statusText)
  }
  return res.json()
}

// ── User ──────────────────────────────────────────────────────────────────────

export interface UserResponse {
  userId: string
  language: string
  name?: string
  token: string
}

export function registerUser(phone: string, language: string, name?: string) {
  return request<UserResponse>('/user', {
    method: 'POST',
    body: JSON.stringify({ phone, language, name }),
  }, false)
}

// ── Audio ─────────────────────────────────────────────────────────────────────

export interface UploadUrlResponse {
  uploadUrl: string
  s3Key: string
}

// Strip codec params so the signed content-type matches what we send in the PUT
function baseContentType(mimeType: string): string {
  return mimeType.split(';')[0].trim()
}

export function getAudioUploadUrl(fileName: string, contentType: string) {
  return request<UploadUrlResponse>('/audio/upload-url', {
    method: 'POST',
    body: JSON.stringify({ fileName, contentType: baseContentType(contentType) }),
  })
}

export async function uploadAudioToS3(
  uploadUrl: string,
  blob: Blob,
  contentType: string,
) {
  const ct = baseContentType(contentType)
  const res = await fetch(uploadUrl, {
    method: 'PUT',
    body: blob,
    headers: { 'Content-Type': ct },
  })
  if (!res.ok) throw new Error(`S3 upload failed: ${res.status}`)
}

// ── Health ────────────────────────────────────────────────────────────────────

export interface HealthQueryRequest {
  text?: string
  audioS3Key?: string
  language: string
  conversationId?: string
  generateSummary?: boolean
  pincode?: string
  latitude?: number
  longitude?: number
  lowBandwidth?: boolean
}

export interface HealthQueryResponse {
  conversationId: string
  text: string
  userText?: string
  audioUrl?: string
  isEmergency: boolean
  language: string
  facilities?: Record<string, unknown>[]
  nearbyKind?: string
  doctorSummary?: string
}

export function healthQuery(body: HealthQueryRequest) {
  return request<HealthQueryResponse>('/health/query', {
    method: 'POST',
    body: JSON.stringify(body),
  })
}

// ── Commerce ──────────────────────────────────────────────────────────────────

export interface ShopItem {
  shopId: string
  name: string
  ownerName?: string
  phone?: string
  pincode: string
  address?: string
  status: string
  inventory?: {
    itemId: string
    name: string
    nameHindi?: string
    price: number
    unit: string
    stockQty: number
  }[]
}

export function getShops(pincode: string, category?: string) {
  return request<{ shops: ShopItem[] }>('/commerce/shops', {
    method: 'POST',
    body: JSON.stringify({ pincode, ...(category ? { category } : {}) }),
  }, false)
}

export function getShop(shopId: string) {
  return request<ShopItem>(`/shop/${shopId}`)
}

export interface PlaceOrderRequest {
  shopId: string
  items: { itemId: string; name: string; price: number; qty: number }[]
  deliveryAddress?: string
  notes?: string
}

export function placeOrder(body: PlaceOrderRequest) {
  return request<{ orderId: string; status: string; totalAmount: number; message: string }>(
    '/commerce/order',
    { method: 'POST', body: JSON.stringify(body) },
  )
}

// ── Shop Owner ────────────────────────────────────────────────────────────────

export function getShopAnalytics(shopId: string) {
  return request<{
    today: { revenue: number; orderCount: number }
    allTime: { orderCount: number; pendingOrders: number }
  }>(`/shop/${shopId}/analytics`)
}

export function getShopOrders(shopId: string) {
  return request<{ orders: Record<string, unknown>[] }>(`/shop/${shopId}/orders`)
}

export interface InventoryPayload {
  items: { name: string; nameHindi?: string; price: number; unit: string; stockQty: number }[]
  replace: boolean
}

export function updateInventory(shopId: string, payload: InventoryPayload) {
  return request(`/shop/${shopId}/inventory`, {
    method: 'POST',
    body: JSON.stringify(payload),
  })
}
