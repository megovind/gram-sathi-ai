'use client'

import { useEffect, useState } from 'react'
import { useRouter } from 'next/navigation'
import { ArrowLeft, RefreshCw, TrendingUp, Package, Clock, BadgeCheck } from 'lucide-react'
import { getShopAnalytics, getShopOrders } from '@/lib/api'
import { store } from '@/lib/store'
import { cn } from '@/lib/utils'
import { useAuthGuard } from '@/hooks/useAuthGuard'

interface Analytics {
  today:   { revenue: number; orderCount: number }
  allTime: { orderCount: number; pendingOrders: number }
}

const STATUS_COLORS: Record<string, string> = {
  pending:   'bg-warn/10 text-warn',
  confirmed: 'bg-primary/10 text-primary',
  ready:     'bg-secondary/10 text-secondary',
  delivered: 'bg-success/10 text-success',
  cancelled: 'bg-emergency/10 text-emergency',
}

export default function ShopDashboardPage() {
  const router  = useRouter()
  useAuthGuard()
  const [shopId, setShopId]       = useState<string | null>(null)
  const [mounted, setMounted]     = useState(false)
  const [analytics, setAnalytics] = useState<Analytics | null>(null)
  const [orders, setOrders]       = useState<Record<string, unknown>[]>([])
  const [loading, setLoading]     = useState(true)

  useEffect(() => {
    setShopId(store.getShopId())
    setMounted(true)
  }, [])

  const load = async () => {
    const id = store.getShopId()
    if (!id) { setLoading(false); return }
    setLoading(true)
    try {
      const [a, o] = await Promise.all([getShopAnalytics(id), getShopOrders(id)])
      setAnalytics(a)
      setOrders(o.orders.slice(0, 10))
    } catch {
      // silence
    } finally {
      setLoading(false)
    }
  }

  useEffect(() => { load() }, [shopId])

  if (!mounted) return null

  if (!shopId) return (
    <div className="flex h-dvh flex-col items-center justify-center gap-4 text-center px-8">
      <div className="text-5xl">🏪</div>
      <p className="font-semibold text-textPrimary">No shop linked</p>
      <p className="text-sm text-textSecondary">Register your shop to start managing orders</p>
      <button onClick={() => router.push('/home')} className="mt-2 rounded-2xl bg-primary px-6 py-3 font-semibold text-white">
        Go Home
      </button>
    </div>
  )

  const stats = [
    { label: 'Today Revenue', value: `₹${analytics?.today.revenue?.toFixed(0) ?? 0}`, icon: TrendingUp, color: 'text-success bg-success/10' },
    { label: 'Today Orders',  value: analytics?.today.orderCount ?? 0,   icon: Package,    color: 'text-primary bg-primary/10' },
    { label: 'Total Orders',  value: analytics?.allTime.orderCount ?? 0, icon: BadgeCheck,  color: 'text-accent  bg-accent/10' },
    { label: 'Pending',       value: analytics?.allTime.pendingOrders ?? 0, icon: Clock,   color: 'text-warn    bg-warn/10' },
  ]

  return (
    <div className="flex h-dvh flex-col">
      <div className="flex items-center gap-3 bg-primary px-4 py-3 text-white shadow-md">
        <button onClick={() => router.push('/home')} className="rounded-full p-1 hover:bg-white/20">
          <ArrowLeft className="h-5 w-5" />
        </button>
        <p className="flex-1 font-semibold">Shop Dashboard</p>
        <button onClick={load} className="rounded-full p-1 hover:bg-white/20">
          <RefreshCw className={cn('h-4 w-4', loading && 'animate-spin')} />
        </button>
      </div>

      <div className="flex-1 overflow-y-auto px-4 py-4 space-y-4">
        {/* Stats grid */}
        <div className="grid grid-cols-2 gap-3">
          {stats.map(s => (
            <div key={s.label} className="rounded-2xl bg-surface p-4 shadow-card">
              <div className={cn('mb-2 flex h-9 w-9 items-center justify-center rounded-xl', s.color)}>
                <s.icon className="h-5 w-5" />
              </div>
              <p className="text-xl font-bold text-textPrimary">{s.value}</p>
              <p className="text-xs text-textSecondary mt-0.5">{s.label}</p>
            </div>
          ))}
        </div>

        {/* Manage inventory */}
        <button
          onClick={() => router.push(`/shop/inventory?shopId=${shopId}`)}
          className="flex w-full items-center justify-center gap-2 rounded-2xl bg-primary py-3.5 font-semibold text-white shadow-md"
        >
          <Package className="h-5 w-5" />
          Manage Inventory
        </button>

        {/* Recent orders */}
        {orders.length > 0 && (
          <div>
            <p className="mb-2 text-sm font-semibold text-textSecondary">Recent Orders</p>
            <div className="space-y-2">
              {orders.map((order: Record<string, unknown>, i) => {
                const status = (order.status as string) ?? 'pending'
                return (
                  <div key={i} className="flex items-center gap-3 rounded-xl bg-surface p-3 shadow-card">
                    <div className="flex-1 min-w-0">
                      <p className="text-xs font-mono text-textSecondary">
                        #{(order.orderId as string)?.slice(0, 8)}
                      </p>
                      <p className="text-sm font-semibold text-textPrimary">₹{(order.totalAmount as number)?.toFixed(2)}</p>
                    </div>
                    <span className={cn('rounded-full px-2.5 py-0.5 text-xs font-medium capitalize', STATUS_COLORS[status] ?? STATUS_COLORS.pending)}>
                      {status}
                    </span>
                  </div>
                )
              })}
            </div>
          </div>
        )}
      </div>
    </div>
  )
}
