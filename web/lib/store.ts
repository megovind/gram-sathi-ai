'use client'

const TOKEN_KEY   = 'gs_token'
const USER_KEY    = 'gs_userId'
const PHONE_KEY   = 'gs_phone'
const LANG_KEY    = 'gs_language'
const PINCODE_KEY = 'gs_pincode'
const SHOP_KEY    = 'gs_shopId'

const isBrowser = () => typeof window !== 'undefined'

function isTokenValid(token: string): boolean {
  try {
    const payload = token.split('.')[1]
    const decoded = JSON.parse(atob(payload.replace(/-/g, '+').replace(/_/g, '/')))
    return decoded.exp * 1000 > Date.now()
  } catch {
    return false
  }
}

export const store = {
  getToken:    (): string | null => (isBrowser() ? localStorage.getItem(TOKEN_KEY) : null),
  getUserId:   (): string | null => (isBrowser() ? localStorage.getItem(USER_KEY) : null),
  getPhone:    (): string | null => (isBrowser() ? localStorage.getItem(PHONE_KEY) : null),
  getLanguage: (): string        => (isBrowser() ? localStorage.getItem(LANG_KEY) ?? 'hi' : 'hi'),
  getPincode:  (): string | null => (isBrowser() ? localStorage.getItem(PINCODE_KEY) : null),
  getShopId:   (): string | null => (isBrowser() ? localStorage.getItem(SHOP_KEY) : null),

  isLoggedIn(): boolean {
    const token = this.getToken()
    return !!token && isTokenValid(token)
  },

  setAuth(token: string, userId: string, phone: string) {
    if (!isBrowser()) return
    localStorage.setItem(TOKEN_KEY, token)
    localStorage.setItem(USER_KEY, userId)
    localStorage.setItem(PHONE_KEY, phone)
    document.cookie = `gs_token=${token}; path=/; max-age=${60 * 60 * 24 * 30}; SameSite=Lax`
  },

  setLanguage(lang: string) {
    if (!isBrowser()) return
    localStorage.setItem(LANG_KEY, lang)
  },

  setPincode(pincode: string) {
    if (!isBrowser()) return
    localStorage.setItem(PINCODE_KEY, pincode)
  },

  setShopId(shopId: string) {
    if (!isBrowser()) return
    localStorage.setItem(SHOP_KEY, shopId)
  },

  clear() {
    if (!isBrowser()) return
    ;[TOKEN_KEY, USER_KEY, PHONE_KEY, PINCODE_KEY, SHOP_KEY].forEach(k =>
      localStorage.removeItem(k)
    )
    document.cookie = 'gs_token=; path=/; max-age=0'
  },
}
