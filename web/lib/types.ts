export type Language = 'hi' | 'en' | 'mr' | 'ta' | 'te' | 'kn' | 'bn' | 'gu'

export const LANGUAGES: { code: Language; label: string; nativeLabel: string }[] = [
  { code: 'hi', label: 'Hindi',     nativeLabel: 'हिंदी'    },
  { code: 'en', label: 'English',   nativeLabel: 'English'  },
  { code: 'mr', label: 'Marathi',   nativeLabel: 'मराठी'    },
  { code: 'ta', label: 'Tamil',     nativeLabel: 'தமிழ்'    },
  { code: 'te', label: 'Telugu',    nativeLabel: 'తెలుగు'   },
  { code: 'kn', label: 'Kannada',   nativeLabel: 'ಕನ್ನಡ'    },
  { code: 'bn', label: 'Bengali',   nativeLabel: 'বাংলা'    },
  { code: 'gu', label: 'Gujarati',  nativeLabel: 'ગુજરાતી'  },
]

export interface Facility {
  name: string
  address?: string
  phone?: string
  category?: string
  rating?: number
  lat?: number
  lon?: number
  source?: 'google' | 'dynamo'
}

export type MessageRole = 'user' | 'assistant'
export type NearbyKind = 'clinic' | 'pharmacy' | 'hospital' | 'facilities' | 'shops' | ''

export interface Message {
  id: string
  role: MessageRole
  content: string
  audioUrl?: string
  timestamp: Date
  isVoice?: boolean
  isUploading?: boolean
  facilities?: Facility[]
  nearbyKind?: NearbyKind
}

export interface InventoryItem {
  itemId: string
  name: string
  nameHindi?: string
  price: number
  unit: string
  stockQty: number
}

export interface Shop {
  shopId: string
  name: string
  ownerName?: string
  phone?: string
  pincode: string
  address?: string
  status: 'approved' | 'pending'
  inventory?: InventoryItem[]
}

export interface CartItem {
  itemId: string
  name: string
  nameHindi?: string
  price: number
  qty: number
}

export interface Order {
  orderId: string
  shopId: string
  status: 'pending' | 'confirmed' | 'ready' | 'delivered' | 'cancelled'
  totalAmount: number
  message?: string
  createdAt?: string
}
