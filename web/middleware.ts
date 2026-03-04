import { NextResponse } from 'next/server'
import type { NextRequest } from 'next/server'

const PROTECTED = ['/home', '/health', '/commerce', '/shop']

export function middleware(request: NextRequest) {
  const token    = request.cookies.get('gs_token')?.value
  const { pathname } = request.nextUrl

  const isProtected = PROTECTED.some(p => pathname.startsWith(p))
  if (isProtected && !token) {
    return NextResponse.redirect(new URL('/', request.url))
  }
  return NextResponse.next()
}

export const config = {
  matcher: ['/home/:path*', '/health/:path*', '/commerce/:path*', '/shop/:path*'],
}
