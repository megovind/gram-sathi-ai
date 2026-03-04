'use client'

import { useEffect } from 'react'
import { X } from 'lucide-react'
import { LANGUAGES, type Language } from '@/lib/types'
import { cn } from '@/lib/utils'

interface Props {
  isOpen: boolean
  selected: Language | ''
  onSelect: (lang: Language) => void
  onClose: () => void
}

export function LanguageModal({ isOpen, selected, onSelect, onClose }: Props) {
  // Close on Escape key
  useEffect(() => {
    if (!isOpen) return
    const handler = (e: KeyboardEvent) => { if (e.key === 'Escape') onClose() }
    window.addEventListener('keydown', handler)
    return () => window.removeEventListener('keydown', handler)
  }, [isOpen, onClose])

  if (!isOpen) return null

  return (
    <div
      className="fixed inset-0 z-50 flex items-end justify-center bg-black/50 sm:items-center sm:px-4"
      onClick={onClose}
    >
      <div
        className="w-full rounded-t-3xl bg-surface px-5 pb-8 pt-5 shadow-2xl sm:max-w-lg sm:rounded-3xl"
        onClick={e => e.stopPropagation()}
      >
        {/* Handle */}
        <div className="mx-auto mb-4 h-1 w-10 rounded-full bg-divider sm:hidden" />

        <div className="mb-4 flex items-center justify-between">
          <h2 className="text-lg font-bold text-textPrimary">Choose Language</h2>
          <button
            onClick={onClose}
            className="rounded-full p-1.5 hover:bg-surface-variant"
            aria-label="Close"
          >
            <X className="h-5 w-5 text-textSecondary" />
          </button>
        </div>

        <p className="mb-4 text-sm text-textSecondary">अपनी भाषा चुनें • Select your language</p>

        <div className="grid grid-cols-2 gap-2.5 sm:grid-cols-4">
          {LANGUAGES.map(lang => (
            <button
              key={lang.code}
              onClick={() => { onSelect(lang.code); onClose() }}
              className={cn(
                'rounded-2xl border-2 px-3 py-3 text-center transition-all duration-150 active:scale-95',
                selected === lang.code
                  ? 'border-primary bg-primary text-white shadow-md'
                  : 'border-divider bg-surface text-textPrimary hover:border-primary/40',
              )}
            >
              <p className="text-lg font-bold">{lang.nativeLabel}</p>
              <p className={cn('mt-0.5 text-xs', selected === lang.code ? 'text-white/80' : 'text-textSecondary')}>
                {lang.label}
              </p>
            </button>
          ))}
        </div>
      </div>
    </div>
  )
}
