'use client'

import { useEffect, useState } from 'react'
import { useRouter } from 'next/navigation'
import Image from 'next/image'
import Link from 'next/link'
import { Loader2, Globe, Phone, User } from 'lucide-react'
import { LANGUAGES, type Language } from '@/lib/types'
import { store } from '@/lib/store'
import { registerUser } from '@/lib/api'
import { LanguageModal } from '@/components/LanguageModal'
import { getStrings } from '@/lib/strings'
import { toast } from 'sonner'

export default function LoginPage() {
  const router = useRouter()
  const [phone, setPhone]       = useState('')
  const [name, setName]         = useState('')
  const [language, setLanguage] = useState<Language | ''>('')
  const [loading, setLoading]   = useState(false)
  const [showLang, setShowLang] = useState(false)

  useEffect(() => {
    if (store.isLoggedIn()) {
      router.replace('/home')
      return
    }
    const saved = store.getLanguage() as Language
    setLanguage(saved || 'hi')
  }, [router])

  const selectedLang = LANGUAGES.find(l => l.code === language)
  const t = getStrings(language)

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault()
    if (phone.length !== 10) { toast.error('Enter a valid 10-digit mobile number'); return }
    if (!language) { toast.error('Please choose a language first'); return }

    setLoading(true)
    try {
      store.setLanguage(language as Language)
      const res = await registerUser(phone, language as Language, name.trim() || undefined)
      store.setAuth(res.token, res.userId, phone)
      // Do NOT use res.language here — the backend may return a previously stored
      // language (e.g. 'en') which would silently override the user's current choice.
      router.push('/home')
    } catch (err) {
      toast.error(err instanceof Error ? err.message : 'Login failed. Please try again.')
    } finally {
      setLoading(false)
    }
  }

  return (
    <>
      <LanguageModal
        isOpen={showLang}
        selected={language}
        onSelect={lang => { setLanguage(lang); store.setLanguage(lang) }}
        onClose={() => setShowLang(false)}
      />

      <div className="flex min-h-dvh items-center justify-center bg-background px-4 py-8">
        <div className="w-full max-w-sm">

          {/* Branding */}
          <div className="mb-8 flex flex-col items-center text-center">
            <div className="mb-4 flex h-20 w-20 items-center justify-center overflow-hidden rounded-2xl bg-primary/10 shadow-card">
              <Image src="/app_icon.png" alt="GramSathi" width={80} height={80} className="object-cover" priority />
            </div>
            <h1 className="text-2xl font-bold text-primary">GramSathi</h1>
            <p className="mt-1 text-sm text-textSecondary">{t.tagline}</p>
          </div>

          {/* Login card */}
          <div className="rounded-3xl bg-surface px-6 py-7 shadow-card-hover">
            <h2 className="mb-5 text-base font-semibold text-textPrimary">{t.enterPhoneTitle}</h2>
            <p className="mb-4 text-sm text-textSecondary">{t.enterPhoneSubtitle}</p>

            {/* Language selector button */}
            <button
              type="button"
              onClick={() => setShowLang(true)}
              className="mb-4 flex w-full items-center gap-3 rounded-2xl border-2 border-divider bg-surface px-4 py-3 hover:border-primary/40 transition"
            >
              <div className="flex h-8 w-8 flex-shrink-0 items-center justify-center rounded-xl bg-primary/10">
                <Globe className="h-4 w-4 text-primary" />
              </div>
              <div className="flex-1 text-left">
                <p className="text-xs text-textSecondary">{t.languageLabel}</p>
                <p className="text-sm font-semibold text-textPrimary">
                  {selectedLang ? `${selectedLang.nativeLabel} — ${selectedLang.label}` : 'Choose language'}
                </p>
              </div>
              <span className="text-xs text-primary font-medium">{t.changeLanguage}</span>
            </button>

            <form onSubmit={handleSubmit} className="space-y-3">
              {/* Phone */}
              <div className="flex items-center gap-3 overflow-hidden rounded-2xl bg-surface-variant px-4 py-3">
                <Phone className="h-4 w-4 flex-shrink-0 text-textHint" />
                <span className="text-sm font-medium text-textSecondary">+91</span>
                <div className="h-4 w-px bg-divider" />
                <input
                  type="tel"
                  inputMode="numeric"
                  pattern="[0-9]{10}"
                  maxLength={10}
                  value={phone}
                  onChange={e => setPhone(e.target.value.replace(/\D/g, '').slice(0, 10))}
                  placeholder="9876543210"
                  className="flex-1 bg-transparent text-sm text-textPrimary placeholder:text-textHint outline-none"
                  required
                  autoFocus
                />
              </div>

              {/* Name (optional) */}
              <div className="flex items-center gap-3 rounded-2xl bg-surface-variant px-4 py-3">
                <User className="h-4 w-4 flex-shrink-0 text-textHint" />
                <input
                  type="text"
                  value={name}
                  onChange={e => setName(e.target.value)}
                  placeholder={language === 'hi' ? 'आपका नाम (वैकल्पिक)' : 'Your name (optional)'}
                  className="flex-1 bg-transparent text-sm text-textPrimary placeholder:text-textHint outline-none"
                />
              </div>

              <button
                type="submit"
                disabled={loading || phone.length !== 10}
                className="flex w-full items-center justify-center gap-2 rounded-2xl bg-primary py-4 font-semibold text-white shadow-md active:scale-[0.98] disabled:opacity-60 transition"
              >
                {loading && <Loader2 className="h-5 w-5 animate-spin" />}
                {t.continueText}
              </button>
            </form>

            <p className="mt-5 text-center text-xs text-textHint">
              {t.privacyNotice.split('Privacy Policy')[0]}
              <Link
                href={`${process.env.NEXT_PUBLIC_APP_URL ?? ''}/legal/privacy-policy`}
                className="text-primary underline underline-offset-2 hover:text-primary/80"
              >
                Privacy Policy
              </Link>
              {t.privacyNotice.split('Privacy Policy')[1] ?? ''}
            </p>
          </div>

        </div>
      </div>
    </>
  )
}
