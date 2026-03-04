'use client'

import { Copy, MapPin, Phone, Star } from 'lucide-react'
import { toast } from 'sonner'
import type { Facility, NearbyKind } from '@/lib/types'
import { cn } from '@/lib/utils'

const KIND_COLORS: Record<string, string> = {
  clinic:    'border-l-secondary',
  doctor:    'border-l-secondary',
  pharmacy:  'border-l-purple-500',
  hospital:  'border-l-primary',
  facilities:'border-l-primary',
  shops:     'border-l-accent',
  store:     'border-l-accent',
  default:   'border-l-primary',
}

const KIND_ICON: Record<string, string> = {
  clinic:   '🏥',
  doctor:   '👨‍⚕️',
  pharmacy: '💊',
  hospital: '🏨',
  shops:    '🏪',
  store:    '🏪',
  default:  '📍',
}

interface Props {
  facility: Facility
  kind: NearbyKind
}

export function FacilityCard({ facility, kind }: Props) {
  const borderColor = KIND_COLORS[kind] ?? KIND_COLORS[facility.category ?? ''] ?? KIND_COLORS.default
  const icon = KIND_ICON[kind] ?? KIND_ICON[facility.category ?? ''] ?? KIND_ICON.default

  const copyPhone = async () => {
    if (!facility.phone) return
    await navigator.clipboard.writeText(facility.phone)
    toast.success('Phone number copied')
  }

  return (
    <div
      className={cn(
        'flex gap-3 rounded-xl border border-divider bg-surface p-3 shadow-card',
        'border-l-4', borderColor,
      )}
    >
      {/* Icon */}
      <div className="flex h-10 w-10 flex-shrink-0 items-center justify-center rounded-full bg-surface-variant text-xl">
        {icon}
      </div>

      <div className="min-w-0 flex-1">
        {/* Name + category */}
        <div className="flex items-start justify-between gap-2">
          <p className="font-semibold leading-tight text-textPrimary">{facility.name}</p>
          {facility.category && (
            <span className="flex-shrink-0 rounded-full bg-primary/10 px-2 py-0.5 text-xs font-medium text-primary capitalize">
              {facility.category.replace(/_/g, ' ')}
            </span>
          )}
        </div>

        {/* Rating */}
        {facility.rating != null && (
          <div className="mt-0.5 flex items-center gap-1 text-xs text-warn">
            <Star className="h-3 w-3 fill-warn" />
            <span>{facility.rating.toFixed(1)}</span>
          </div>
        )}

        {/* Address */}
        {facility.address && (
          <div className="mt-1 flex items-start gap-1 text-xs text-textSecondary">
            <MapPin className="mt-0.5 h-3 w-3 flex-shrink-0" />
            <span className="line-clamp-2">{facility.address}</span>
          </div>
        )}

        {/* Phone */}
        {facility.phone && (
          <button
            onClick={copyPhone}
            className="mt-1.5 flex items-center gap-1 rounded-md bg-primary/8 px-2 py-0.5 text-xs text-primary hover:bg-primary/15 transition"
          >
            <Phone className="h-3 w-3" />
            <span>{facility.phone}</span>
            <Copy className="ml-1 h-3 w-3 opacity-60" />
          </button>
        )}
      </div>
    </div>
  )
}
