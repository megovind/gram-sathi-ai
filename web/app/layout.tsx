import type { Metadata, Viewport } from 'next'
import { Toaster } from 'sonner'
import './globals.css'

export const metadata: Metadata = {
  title: 'GramSathi — Your Rural AI Assistant',
  description: 'Health advice, nearby clinics, and local commerce for rural India',
  icons: { icon: '/app_icon.png', apple: '/app_icon.png' },
}

export const viewport: Viewport = {
  width: 'device-width',
  initialScale: 1,
  maximumScale: 1,
}

export default function RootLayout({ children }: { children: React.ReactNode }) {
  return (
    <html lang="hi">
      <body>
        <div className="app-shell">
          {children}
        </div>
        <Toaster position="top-center" richColors />
      </body>
    </html>
  )
}
