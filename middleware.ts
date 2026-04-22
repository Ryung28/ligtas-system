import { createServerClient, type CookieOptions } from '@supabase/ssr'
import { NextResponse, type NextRequest } from 'next/server'
import { isMobileDevice } from '@/lib/device-detection'

/**
 * 🛰️ High-Speed Auth Guard Middleware
 * 🛡️ SUPER SENIOR PROTOCOL: Purely stateless session guarding.
 * No database calls here. Only cookie-to-auth handshake.
 */
export async function middleware(request: NextRequest) {
    const { pathname } = request.nextUrl
    const userAgent = request.headers.get('user-agent') || ''
    const isMobile = isMobileDevice(userAgent)

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

    const { data: { session: rawSession }, error } = await supabase.auth.getSession()
    
    // 🛡️ Safety Shield: Handle corrupted session strings (TypeError fix)
    let session = null;
    if (rawSession) {
        if (typeof rawSession === 'string') {
            console.error('[Middleware] Corrupted session string detected. Clearing cookies.');
            // Clear all auth cookies if we find a naked string where an object should be
            const response = NextResponse.redirect(new URL('/login', request.url));
            const authCookies = request.cookies.getAll().filter(c => c.name.includes('auth-token'));
            authCookies.forEach(c => response.cookies.delete(c.name));
            return response;
        }
        session = rawSession;
    }

    const isDashboardPath = pathname.startsWith('/dashboard')
    const isMobilePath = pathname.startsWith('/m')
    const isLoginPage = pathname === '/login'
    const isRoot = pathname === '/'

    // ── 3. High-Efficiency Traffic Control ──
    
    // Auth Guard: Kicking non-users to Login
    if ((isDashboardPath || isMobilePath) && !session) {
        const redirectUrl = new URL('/login', request.url)
        return NextResponse.redirect(redirectUrl)
    }

    // Unauthenticated root: Send to login
    if (isRoot && !session) {
        return NextResponse.redirect(new URL('/login', request.url))
    }

    // Authenticated: Device-Based Segment Pivot
    if (session) {
        // Desktop user trying to access mobile routes
        if (!isMobile && isMobilePath) {
            return NextResponse.redirect(new URL('/dashboard/inventory', request.url))
        }

        // Mobile user trying to access desktop routes
        if (isMobile && isDashboardPath) {
            return NextResponse.redirect(new URL('/m', request.url))
        }

        // Root/Login redirection
        if (isRoot || isLoginPage) {
            if (!request.nextUrl.searchParams.get('error')) {
                const target = isMobile ? '/m' : '/dashboard/inventory'
                return NextResponse.redirect(new URL(target, request.url))
            }
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
