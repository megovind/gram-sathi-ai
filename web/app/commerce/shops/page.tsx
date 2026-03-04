'use client'

import { useEffect, useState } from 'react'
import { useRouter } from 'next/navigation'
import { ArrowLeft, Search, Store, ChevronRight, Star, MapPin } from 'lucide-react'
import { getShops, type ShopItem } from '@/lib/api'
import { store } from '@/lib/store'
import { getStrings } from '@/lib/strings'
import { toast } from 'sonner'
import { cn } from '@/lib/utils'

export default function ShopsPage() {
  const router = useRouter()
  const t = getStrings(store.getLanguage())
  const [pincode, setPincode] = useState('')
  const [shops, setShops]     = useState<ShopItem[]>([])
  const [loading, setLoading] = useState(false)
  const [searched, setSearched] = useState(false)

  useEffect(() => {
    const saved = store.getPincode() ?? '324008'
    setPincode(saved)
    if (saved) loadShops(saved)
  // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [])

  const loadShops = async (pc: string) => {
    if (pc.length !== 6) return
    setLoading(true)
    try {
      const res = await getShops(pc)
      setShops(res.shops)
      setSearched(true)
      store.setPincode(pc)
    } catch (err) {
      toast.error(err instanceof Error ? err.message : 'Search failed')
    } finally {
      setLoading(false)
    }
  }

  return (
    <div className="flex h-dvh flex-col">
      <div className="bg-primary px-4 py-3 text-white shadow-md md:px-8">
        <div className="mx-auto max-w-5xl">
          <div className="flex items-center gap-3 mb-3">
            <button onClick={() => router.push('/home')} className="rounded-full p-1 hover:bg-white/20">
              <ArrowLeft className="h-5 w-5" />
            </button>
            <p className="font-semibold">{t.nearbyShopsTitle}</p>
          </div>
          <div className="flex gap-2">
            <input
              type="tel"
              inputMode="numeric"
              maxLength={6}
              value={pincode}
              onChange={e => setPincode(e.target.value.replace(/\D/g, '').slice(0, 6))}
              placeholder={t.enterPincode}
              className="flex-1 rounded-xl bg-white/20 px-3 py-2 text-sm text-white placeholder:text-white/60 outline-none"
            />
            <button
              onClick={() => loadShops(pincode)}
              disabled={pincode.length !== 6 || loading}
            className="flex items-center gap-1.5 rounded-xl bg-white px-4 py-2 text-sm font-semibold text-primary disabled:opacity-60"
          >
            <Search className="h-4 w-4" />
            {t.searchButton}
          </button>
          </div>
        </div>
      </div>

      <div className="flex-1 overflow-y-auto px-4 py-4 md:px-8">
        <div className="mx-auto max-w-5xl">
          {loading && (
            <div className="flex flex-col items-center py-16">
              <div className="h-8 w-8 animate-spin rounded-full border-2 border-primary/20 border-t-primary" />
              <p className="mt-3 text-sm text-textSecondary">{t.searchingShops}</p>
            </div>
          )}

          {!loading && searched && shops.length === 0 && (
            <div className="flex flex-col items-center py-16 text-center">
              <Store className="mb-3 h-12 w-12 text-textHint" />
              <p className="font-semibold text-textPrimary">{t.noShopsFound}</p>
              <p className="mt-1 text-sm text-textSecondary">{t.noShopsTryDiff}</p>
            </div>
          )}

          {!loading && shops.length > 0 && (
            <>
              <p className="mb-3 text-sm text-textSecondary">{t.shopsFound(shops.length)}</p>
              <div className="grid grid-cols-1 gap-3 sm:grid-cols-2 lg:grid-cols-3">
                {shops.map(shop => <ShopCard key={shop.shopId} shop={shop} />)}
              </div>
            </>
          )}
        </div>
      </div>
    </div>
  )
}

function ShopCard({ shop }: { shop: ShopItem }) {
  const router = useRouter()
  const t = getStrings(store.getLanguage())
  const itemCount = shop.inventory?.length ?? 0
  const preview   = shop.inventory?.slice(0, 3) ?? []
  const remaining = itemCount - 3

  return (
    <div className="overflow-hidden rounded-2xl bg-surface shadow-card">
      <div className="flex items-start gap-3 p-4">
        {/* Icon */}
        <div className="flex h-12 w-12 flex-shrink-0 items-center justify-center rounded-xl bg-gradient-to-br from-accent/20 to-accent/10">
          <Store className="h-6 w-6 text-accent" />
        </div>

        <div className="flex-1 min-w-0">
          <div className="flex items-start justify-between">
            <p className="font-semibold text-textPrimary leading-tight">{shop.name}</p>
            {itemCount > 0 && (
              <span className="ml-2 flex-shrink-0 rounded-full bg-primary/10 px-2 py-0.5 text-xs font-medium text-primary">
                {itemCount} items
              </span>
            )}
          </div>
          {shop.ownerName && (
            <p className="mt-0.5 text-xs text-textSecondary">by {shop.ownerName}</p>
          )}
          {shop.address && (
            <div className="mt-1 flex items-center gap-1 text-xs text-textHint">
              <MapPin className="h-3 w-3 flex-shrink-0" />
              <span className="truncate">{shop.address}</span>
            </div>
          )}
        </div>
      </div>

      {/* Inventory preview */}
      {preview.length > 0 && (
        <div className="flex flex-wrap gap-1.5 border-t border-divider px-4 pb-3 pt-2">
          {preview.map(item => (
            <span
              key={item.itemId}
              className="rounded-full bg-surface-variant px-2.5 py-0.5 text-xs text-textSecondary"
            >
              {item.nameHindi || item.name}
            </span>
          ))}
          {remaining > 0 && (
            <span className="rounded-full bg-primary/10 px-2.5 py-0.5 text-xs font-medium text-primary">
              +{remaining} more
            </span>
          )}
        </div>
      )}

      <div className="border-t border-divider px-4 pb-4 pt-3">
        <button
          onClick={() => router.push(`/commerce/order?shopId=${shop.shopId}`)}
          className="flex w-full items-center justify-center gap-2 rounded-xl bg-accent/10 py-2.5 text-sm font-semibold text-accent hover:bg-accent/20 transition"
        >
          {t.orderFromShop} <ChevronRight className="h-4 w-4" />
        </button>
      </div>
    </div>
  )
}
