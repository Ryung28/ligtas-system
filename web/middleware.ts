import { createServerClient, type CookieOptions } from '@supabase/ssr'
import { NextResponse, type NextRequest } from 'next/server'

/**
 * 🛰️ High-Speed Auth Guard Middleware
 * 🛡️ SUPER SENIOR PROTOCOL: Purely stateless session guarding.
 * No database calls here. Only cookie-to-auth handshake.
 */
export async function middleware(request: NextRequest) {
    const { pathname } = request.nextUrl

    // ── 1. Fast Asset Pass ──
    // The matcher handles most, but we double-check common static patterns
    if (pathname.includes('.') || pathname.startsWith('/_next')) {
        return NextResponse.next()
    }

    let response = NextResponse.next({
        request: {
            headers: request.headers,
        },
    })

    const supabase = createServerClient(
        process.env.NEXT_PUBLIC_SUPABASE_URL!,
        process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY!,
        {
            cookies: {
                get(name: string) {
                    return request.cookies.get(name)?.value
                },
                set(name: string, value: string, options: CookieOptions) {
                    request.cookies.set({ name, value, ...options })
                    response = NextResponse.next({ request: { headers: request.headers } })
                    response.cookies.set({ name, value, ...options })
                },
                remove(name: string, options: CookieOptions) {
                    request.cookies.set({ name, value: '', ...options })
                    response = NextResponse.next({ request: { headers: request.headers } })
                    response.cookies.set({ name, value: '', ...options })
                },
            },
        }
    )

    // ── 2. Session Integrity Check ──
    // Note: getSession() is purely cookie-based, getUser() hits Supabase.
    // For middleware, getSession() is the "Speed" choice.
    const { data: { session } } = await supabase.auth.getSession()

    const isDashboardPath = pathname.startsWith('/dashboard')
    const isLoginPage = pathname === '/login'
    const isRoot = pathname === '/'

    // ── 3. High-Efficiency Traffic Control ──
    
    // Auth Guard: Kicking non-users to Login
    if (isDashboardPath && !session) {
        const redirectUrl = new URL('/login', request.url)
        return NextResponse.redirect(redirectUrl)
    }

    // Unauthenticated root: Send to login
    if (isRoot && !session) {
        return NextResponse.redirect(new URL('/login', request.url))
    }

    // Authenticated root: Send to inventory
    if ((isRoot || isLoginPage) && session) {
        // Only redirect if there's no auth error in params
        if (!request.nextUrl.searchParams.get('error')) {
            return NextResponse.redirect(new URL('/dashboard/inventory', request.url))
        }
    }

    return response
}

export const config = {
    matcher: [
        /*
         * 🏛️ Absolute Matcher Exclusion
         * Optimized to bypass static assets, icons, and internals immediately.
         */
        '/((?!api|_next/static|_next/image|favicon.ico|icons/|manifest.json|.*\\.(?:svg|png|jpg|jpeg|gif|webp|css|js)$).*)',
    ],
}
