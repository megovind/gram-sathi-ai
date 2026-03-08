'use client'

import { Suspense, useState } from 'react'
import { useRouter, useSearchParams } from 'next/navigation'
import { ArrowLeft, Plus, Trash2, Loader2 } from 'lucide-react'
import { updateInventory } from '@/lib/api'
import { toast } from 'sonner'
import { cn } from '@/lib/utils'
import { useAuthGuard } from '@/hooks/useAuthGuard'

interface StagedItem {
  name: string; nameHindi: string; price: string; unit: string; stockQty: string
}

const EMPTY: StagedItem = { name: '', nameHindi: '', price: '', unit: 'piece', stockQty: '' }

export default function InventoryPage() {
  return (
    <Suspense>
      <InventoryPageInner />
    </Suspense>
  )
}

function InventoryPageInner() {
  const router  = useRouter()
  useAuthGuard()
  const params  = useSearchParams()
  const shopId  = params.get('shopId') ?? ''
  const [form, setForm]     = useState<StagedItem>({ ...EMPTY })
  const [staged, setStaged] = useState<StagedItem[]>([])
  const [saving, setSaving] = useState(false)

  const addItem = () => {
    if (!form.name.trim() || !form.price || !form.stockQty) {
      toast.error('Name, price and stock qty are required')
      return
    }
    setStaged(prev => [...prev, { ...form }])
    setForm({ ...EMPTY })
  }

  const save = async () => {
    if (staged.length === 0 || !shopId) return
    setSaving(true)
    try {
      await updateInventory(shopId, {
        items: staged.map(i => ({
          name: i.name,
          nameHindi: i.nameHindi || undefined,
          price: Number(i.price),
          unit: i.unit || 'piece',
          stockQty: Number(i.stockQty),
        })),
        replace: false,
      })
      toast.success(`${staged.length} item(s) saved`)
      setStaged([])
      router.push(`/shop/dashboard`)
    } catch (err) {
      toast.error(err instanceof Error ? err.message : 'Save failed')
    } finally {
      setSaving(false)
    }
  }

  return (
    <div className="flex h-dvh flex-col">
      <div className="flex items-center gap-3 bg-primary px-4 py-3 text-white shadow-md">
        <button onClick={() => router.back()} className="rounded-full p-1 hover:bg-white/20">
          <ArrowLeft className="h-5 w-5" />
        </button>
        <p className="flex-1 font-semibold">Inventory</p>
        {staged.length > 0 && (
          <button
            onClick={save}
            disabled={saving}
            className="flex items-center gap-1.5 rounded-lg bg-white px-3 py-1.5 text-sm font-semibold text-primary disabled:opacity-60"
          >
            {saving && <Loader2 className="h-3 w-3 animate-spin" />}
            Save ({staged.length})
          </button>
        )}
      </div>

      <div className="flex-1 overflow-y-auto">
        {/* Add item form */}
        <div className="bg-surface-variant px-4 py-4 space-y-3">
          <p className="text-sm font-semibold text-textSecondary">Add New Item</p>
          <div className="grid grid-cols-2 gap-2">
            <Field label="Name (English)" value={form.name} onChange={v => setForm(p => ({ ...p, name: v }))} placeholder="e.g. Rice" />
            <Field label="Name (Hindi)" value={form.nameHindi} onChange={v => setForm(p => ({ ...p, nameHindi: v }))} placeholder="चावल" />
          </div>
          <div className="grid grid-cols-3 gap-2">
            <Field label="Price (₹)" type="number" value={form.price} onChange={v => setForm(p => ({ ...p, price: v }))} placeholder="0.00" />
            <Field label="Unit" value={form.unit} onChange={v => setForm(p => ({ ...p, unit: v }))} placeholder="piece" />
            <Field label="Stock Qty" type="number" value={form.stockQty} onChange={v => setForm(p => ({ ...p, stockQty: v }))} placeholder="0" />
          </div>
          <button
            onClick={addItem}
            className="flex w-full items-center justify-center gap-2 rounded-xl border-2 border-dashed border-primary/40 py-2.5 text-sm font-semibold text-primary hover:border-primary hover:bg-primary/5 transition"
          >
            <Plus className="h-4 w-4" /> Add to List
          </button>
        </div>

        {/* Staged items */}
        {staged.length > 0 && (
          <div className="divide-y divide-divider">
            {staged.map((item, i) => (
              <div key={i} className="flex items-center gap-3 bg-surface px-4 py-3">
                <div className="flex-1 min-w-0">
                  <p className="text-sm font-medium text-textPrimary">{item.nameHindi || item.name}</p>
                  <p className="text-xs text-textSecondary">₹{item.price} / {item.unit} · Stock: {item.stockQty}</p>
                </div>
                <button onClick={() => setStaged(prev => prev.filter((_, j) => j !== i))}>
                  <Trash2 className="h-4 w-4 text-emergency" />
                </button>
              </div>
            ))}
          </div>
        )}

        {staged.length === 0 && (
          <div className="flex flex-col items-center py-12 text-center">
            <p className="text-textHint text-sm">No items staged yet</p>
          </div>
        )}
      </div>
    </div>
  )
}


function Field({ label, value, onChange, placeholder, type = 'text' }: {
  label: string; value: string; onChange: (v: string) => void; placeholder?: string; type?: string
}) {
  return (
    <div>
      <p className="mb-1 text-xs text-textSecondary">{label}</p>
      <input
        type={type}
        value={value}
        onChange={e => onChange(e.target.value)}
        placeholder={placeholder}
        className="w-full rounded-xl bg-surface px-3 py-2 text-sm text-textPrimary placeholder:text-textHint outline-none border border-divider focus:border-primary"
      />
    </div>
  )
}
