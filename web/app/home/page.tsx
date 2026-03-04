'use client'

import { useEffect, useState } from 'react'
import { useRouter } from 'next/navigation'
import Image from 'next/image'
import {
  HeartPulse, ShoppingBag, Mic, Stethoscope, Package,
  Store, Settings, LogOut, Languages, ChevronRight,
} from 'lucide-react'
import { store } from '@/lib/store'
import { cn } from '@/lib/utils'
import { LanguageModal } from '@/components/LanguageModal'
import { getStrings } from '@/lib/strings'
import type { Language } from '@/lib/types'

export default function HomePage() {
  const router = useRouter()
  const [showSettings, setShowSettings] = useState(false)
  const [showLang, setShowLang]         = useState(false)
  const [shopId, setShopId]             = useState<string | null>(null)
  const [phone, setPhone]               = useState('')
  const [language, setLanguage]         = useState<Language | ''>('')

  useEffect(() => {
    setShopId(store.getShopId())
    setPhone(store.getPhone() ?? '')
    setLanguage((store.getLanguage() as Language) || 'hi')
  }, [])

  const t = getStrings(language)

  const handleLogout = () => {
    store.clear()
    router.replace('/')
  }

  return (
    <div className="flex flex-col">
      {/* Language modal */}
      <LanguageModal
        isOpen={showLang}
        selected={language}
        onSelect={lang => {
          setLanguage(lang)
          store.setLanguage(lang)
        }}
        onClose={() => setShowLang(false)}
      />

      {/* Settings bottom sheet */}
      {showSettings && (
        <div
          className="fixed inset-0 z-40 flex flex-col-reverse bg-black/40 sm:items-end sm:justify-center sm:flex-row"
          onClick={() => setShowSettings(false)}
        >
          <div
            className="w-full rounded-t-3xl bg-surface px-5 pb-8 pt-4 shadow-2xl sm:max-w-sm sm:rounded-3xl sm:mb-0 sm:mr-4 sm:self-end"
            onClick={e => e.stopPropagation()}
          >
            <div className="mx-auto mb-4 h-1 w-10 rounded-full bg-divider sm:hidden" />
            <h2 className="mb-4 font-semibold text-textPrimary">{t.settings}</h2>
            <button
              onClick={() => { setShowSettings(false); setShowLang(true) }}
              className="flex w-full items-center gap-3 rounded-xl px-3 py-3 hover:bg-surface-variant"
            >
              <div className="flex h-9 w-9 items-center justify-center rounded-xl bg-primary/10">
                <Languages className="h-5 w-5 text-primary" />
              </div>
              <div className="flex-1 text-left">
                <p className="text-sm font-medium text-textPrimary">{t.changeLanguage}</p>
                <p className="text-xs text-textSecondary" suppressHydrationWarning>
                  {language ? `${t.currentlyLabel} ${language.toUpperCase()}` : ''}
                </p>
              </div>
              <ChevronRight className="h-4 w-4 text-textHint" />
            </button>
            <button
              onClick={handleLogout}
              className="mt-2 flex w-full items-center gap-3 rounded-xl px-3 py-3 hover:bg-emergency/5"
            >
              <div className="flex h-9 w-9 items-center justify-center rounded-xl bg-emergency/10">
                <LogOut className="h-5 w-5 text-emergency" />
              </div>
              <span className="text-sm font-medium text-emergency">{t.signOut}</span>
            </button>
          </div>
        </div>
      )}

      {/* Header */}
      <div className="flex items-center gap-3 bg-surface px-5 py-4 shadow-sm">
        <div className="flex h-10 w-10 items-center justify-center rounded-xl bg-primary/10 overflow-hidden">
          <Image src="/app_icon.png" alt="GramSathi" width={40} height={40} className="object-cover" />
        </div>
        <div className="flex-1 min-w-0">
          <p className="font-bold text-primary leading-tight">GramSathi</p>
          <p className="text-xs text-textSecondary truncate" suppressHydrationWarning>{phone ? `+91 ${phone}` : t.welcomeBack}</p>
        </div>
        <button onClick={() => setShowSettings(true)} className="rounded-full p-2 hover:bg-surface-variant">
          <Settings className="h-5 w-5 text-textSecondary" />
        </button>
      </div>

      {/* Content — 1 col on mobile, 2 col on desktop */}
      <div className="flex-1 overflow-y-auto">
        <div className="page-center py-6">
          <div className="grid grid-cols-1 gap-6 lg:grid-cols-3">

            {/* Left / main column */}
            <div className="space-y-5 lg:col-span-2">
              <div>
                <h1 className="text-xl font-bold text-textPrimary">{t.howCanIHelp}</h1>
                <p className="text-sm text-textSecondary mt-0.5">{t.howCanIHelpSub}</p>
              </div>

              {/* Main action cards */}
              <div className="grid grid-cols-2 gap-3">
                <ActionCard
                  onClick={() => router.push('/health')}
                  icon={<HeartPulse className="h-7 w-7" />}
                  label={t.healthCard}
                  sub={t.healthCardSub}
                  gradient="from-[#E8F8F0] to-[#D4F0E3]"
                  iconColor="text-secondary"
                />
                <ActionCard
                  onClick={() => router.push('/commerce/shops')}
                  icon={<ShoppingBag className="h-7 w-7" />}
                  label={t.commerceCard}
                  sub={t.commerceCardSub}
                  gradient="from-[#FFF3E0] to-[#FFE0B2]"
                  iconColor="text-accent"
                />
              </div>

              {/* Voice CTA */}
              <div
                className="gradient-primary flex cursor-pointer items-center gap-4 rounded-2xl px-5 py-4 shadow-md active:scale-[0.98] transition"
                onClick={() => router.push('/health')}
              >
                <div className="flex h-12 w-12 flex-shrink-0 items-center justify-center rounded-xl bg-white/20">
                  <Mic className="h-6 w-6 text-white" />
                </div>
                <div className="flex-1 text-white">
                  <p className="font-semibold">{t.voiceAsk}</p>
                  <p className="text-xs text-white/80">{t.voiceAskSubtitle}</p>
                </div>
                <ChevronRight className="h-5 w-5 text-white/70" />
              </div>
            </div>

            {/* Right / sidebar */}
            <div className="space-y-2 lg:col-span-1">
              <p className="text-sm font-semibold text-textSecondary uppercase tracking-wider">{t.quickAccess}</p>
              <QuickLink
                icon={<Stethoscope className="h-5 w-5 text-secondary" />}
                label={t.nearbyClinicLink}
                sub={t.nearbyClinicSub}
                bg="bg-secondary/10"
                onClick={() => router.push('/health')}
              />
              <QuickLink
                icon={<Package className="h-5 w-5 text-accent" />}
                label={t.myOrdersLink}
                sub={t.myOrdersSub}
                bg="bg-accent/10"
                onClick={() => router.push('/commerce/shops')}
              />
              {shopId && (
                <QuickLink
                  icon={<Store className="h-5 w-5 text-primary" />}
                  label={t.myShopLink}
                  sub={t.myShopSub}
                  bg="bg-primary/10"
                  onClick={() => router.push('/shop/dashboard')}
                />
              )}
            </div>

          </div>
        </div>
      </div>
    </div>
  )
}

function ActionCard({ onClick, icon, label, sub, gradient, iconColor }: {
  onClick: () => void; icon: React.ReactNode; label: string; sub: string; gradient: string; iconColor: string
}) {
  return (
    <button
      onClick={onClick}
      className={cn(
        'rounded-2xl bg-gradient-to-br p-4 text-left shadow-card active:scale-[0.97] transition',
        gradient,
      )}
    >
      <div className={cn('mb-3', iconColor)}>{icon}</div>
      <p className="font-semibold text-textPrimary text-sm leading-tight">{label}</p>
      <p className="text-xs text-textSecondary mt-0.5">{sub}</p>
    </button>
  )
}

function QuickLink({ icon, label, sub, bg, onClick }: {
  icon: React.ReactNode; label: string; sub: string; bg: string; onClick: () => void
}) {
  return (
    <button
      onClick={onClick}
      className="flex w-full items-center gap-3 rounded-2xl bg-surface p-3.5 shadow-card hover:shadow-card-hover active:scale-[0.98] transition"
    >
      <div className={cn('flex h-10 w-10 flex-shrink-0 items-center justify-center rounded-xl', bg)}>
        {icon}
      </div>
      <div className="flex-1 text-left min-w-0">
        <p className="font-medium text-sm text-textPrimary">{label}</p>
        <p className="text-xs text-textSecondary">{sub}</p>
      </div>
      <ChevronRight className="h-4 w-4 flex-shrink-0 text-textHint" />
    </button>
  )
}
