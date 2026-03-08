import { useEffect } from 'react'
import { useRouter } from 'next/navigation'
import { store } from '@/lib/store'

/**
 * Redirect to login if no token is found in localStorage.
 * Drop-in replacement for the middleware auth check — works with static export.
 */
export function useAuthGuard() {
  const router = useRouter()

  useEffect(() => {
    if (!store.getToken()) {
      router.replace('/')
    }
  }, [router])
}
