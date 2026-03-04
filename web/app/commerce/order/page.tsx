'use client'

import { useCallback, useEffect, useState } from 'react'
import { useRouter, useSearchParams } from 'next/navigation'
import { ArrowLeft, Loader2, CheckCircle, ShoppingCart } from 'lucide-react'
import { getShop, placeOrder, type ShopItem } from '@/lib/api'
import type { CartItem } from '@/lib/types'
import { toast } from 'sonner'

export default function OrderPage() {
  const router     = useRouter()
  const params     = useSearchParams()
  const shopId     = params.get('shopId') ?? ''
  const [shop, setShop]     = useState<ShopItem | null>(null)
  const [loading, setLoading]   = useState(true)
  const [error, setError]       = useState('')
  const [cart, setCart]         = useState<CartItem[]>([])
  const [placing, setPlacing]   = useState(false)
  const [orderId, setOrderId]   = useState<string | null>(null)
  const [total, setTotal]       = useState(0)

  useEffect(() => {
    setTotal(cart.reduce((s, i) => s + i.price * i.qty, 0))
  }, [cart])

  useEffect(() => {
    if (!shopId) return
    getShop(shopId)
      .then(setShop)
      .catch(() => setError('Could not load shop. Please try again.'))
      .finally(() => setLoading(false))
  }, [shopId])

  const setQty = useCallback((item: ShopItem['inventory'][0], qty: number) => {
    setCart(prev => {
      if (qty <= 0) return prev.filter(c => c.itemId !== item.itemId)
      const existing = prev.find(c => c.itemId === item.itemId)
      if (existing) return prev.map(c => c.itemId === item.itemId ? { ...c, qty } : c)
      return [...prev, { itemId: item.itemId, name: item.name, nameHindi: item.nameHindi, price: item.price, qty }]
    })
  }, [])

  const getQty = (itemId: string) => cart.find(c => c.itemId === itemId)?.qty ?? 0

  const handleOrder = async () => {
    if (cart.length === 0) return
    setPlacing(true)
    try {
      const res = await placeOrder({
        shopId,
        items: cart.map(c => ({ itemId: c.itemId, name: c.name, price: c.price, qty: c.qty })),
      })
      setOrderId(res.orderId.slice(0, 8))
    } catch (err) {
      toast.error(err instanceof Error ? err.message : 'Order failed')
    } finally {
      setPlacing(false)
    }
  }

  if (loading) return (
    <div className="flex h-dvh items-center justify-center">
      <Loader2 className="h-8 w-8 animate-spin text-primary" />
    </div>
  )

  if (error) return (
    <div className="flex h-dvh flex-col items-center justify-center gap-4 px-8 text-center">
      <p className="text-emergency">{error}</p>
      <button onClick={() => router.back()} className="rounded-xl bg-primary px-6 py-3 text-sm font-semibold text-white">
        Go Back
      </button>
    </div>
  )

  // Order success
  if (orderId) return (
    <div className="flex h-dvh flex-col items-center justify-center gap-4 px-8 text-center">
      <div className="flex h-20 w-20 items-center justify-center rounded-full bg-success/10">
        <CheckCircle className="h-12 w-12 text-success" />
      </div>
      <h2 className="text-2xl font-bold text-textPrimary">Order Placed!</h2>
      <p className="text-sm text-textSecondary">Order #{orderId}</p>
      <p className="text-lg font-semibold text-primary">Total: ₹{total.toFixed(2)}</p>
      <button
        onClick={() => router.push('/home')}
        className="mt-2 w-full rounded-2xl bg-primary py-4 font-semibold text-white"
      >
        Go Home
      </button>
    </div>
  )

  const inventory = shop?.inventory ?? []

  return (
    <div className="flex h-dvh flex-col">
      {/* Header */}
      <div className="flex items-center gap-3 bg-primary px-4 py-3 text-white shadow-md">
        <button onClick={() => router.back()} className="rounded-full p-1 hover:bg-white/20">
          <ArrowLeft className="h-5 w-5" />
        </button>
        <div className="flex-1 min-w-0">
          <p className="font-semibold truncate">{shop?.name}</p>
          <p className="text-xs text-white/70">{cart.length > 0 ? `${cart.length} items` : 'Browse items'}</p>
        </div>
        {total > 0 && (
          <p className="font-bold text-sm bg-white/20 rounded-lg px-2.5 py-1">₹{total.toFixed(0)}</p>
        )}
      </div>

      {/* Items */}
      <div className="flex-1 overflow-y-auto divide-y divide-divider">
        {inventory.length === 0 ? (
          <div className="flex flex-col items-center py-16 text-center">
            <ShoppingCart className="mb-3 h-12 w-12 text-textHint" />
            <p className="text-textSecondary">No items in inventory</p>
          </div>
        ) : inventory.map(item => {
          const qty = getQty(item.itemId)
          const outOfStock = item.stockQty <= 0
          return (
            <div key={item.itemId} className="flex items-center gap-3 px-4 py-3 bg-surface">
              <div className="flex-1 min-w-0">
                <p className="font-medium text-textPrimary text-sm">{item.nameHindi || item.name}</p>
                <p className="text-xs text-textSecondary mt-0.5">₹{item.price} / {item.unit}</p>
                {outOfStock && <p className="text-xs text-textHint">Not available</p>}
              </div>
              <div className="flex-shrink-0">
                {qty === 0 ? (
                  <button
                    onClick={() => !outOfStock && setQty(item, 1)}
                    disabled={outOfStock}
                    className="rounded-xl border border-primary px-4 py-1.5 text-xs font-semibold text-primary disabled:opacity-40 hover:bg-primary hover:text-white transition"
                  >
                    Add
                  </button>
                ) : (
                  <div className="flex items-center gap-2 rounded-xl border border-primary">
                    <button
                      onClick={() => setQty(item, qty - 1)}
                      className="px-2.5 py-1 text-sm font-bold text-primary hover:bg-primary/10 rounded-l-xl"
                    >−</button>
                    <span className="min-w-[1.5rem] text-center text-sm font-semibold text-primary">{qty}</span>
                    <button
                      onClick={() => qty < item.stockQty && setQty(item, qty + 1)}
                      disabled={qty >= item.stockQty}
                      className="px-2.5 py-1 text-sm font-bold text-primary hover:bg-primary/10 rounded-r-xl disabled:opacity-30"
                    >+</button>
                  </div>
                )}
              </div>
            </div>
          )
        })}
      </div>

      {/* Cart bar */}
      {cart.length > 0 && (
        <div className="border-t border-divider bg-surface px-4 py-3">
          <div className="mb-3 flex items-center justify-between text-sm">
            <span className="text-textSecondary">{cart.length} item{cart.length > 1 ? 's' : ''}</span>
            <span className="font-bold text-textPrimary">Total: ₹{total.toFixed(2)}</span>
          </div>
          <button
            onClick={handleOrder}
            disabled={placing}
            className="flex w-full items-center justify-center gap-2 rounded-2xl bg-primary py-3.5 font-semibold text-white disabled:opacity-70"
          >
            {placing && <Loader2 className="h-4 w-4 animate-spin" />}
            Place Order • ₹{total.toFixed(2)}
          </button>
        </div>
      )}
    </div>
  )
}
