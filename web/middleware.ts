import { createServerClient } from '@supabase/ssr'
import { NextResponse, type NextRequest } from 'next/server'
import { isMobileDevice } from '@/lib/device-detection'

/**
 * 🛰️ High-Speed Auth Guard Middleware
 * 🛡️ SUPER SENIOR PROTOCOL: Purely stateless session guarding.
 * We use atomic setAll to prevent refresh token desync/logout loops.
 */
export async function middleware(request: NextRequest) {
    const { pathname } = request.nextUrl
    const userAgent = request.headers.get('user-agent') || ''
    const isMobile = isMobileDevice(userAgent)

    // ── 1. Fast Asset Pass ──
    if (pathname.includes('.') || pathname.startsWith('/_next')) {
        return NextResponse.next()
    }

    let response = NextResponse.next({
        request,
    })

    const supabase = createServerClient(
        process.env.NEXT_PUBLIC_SUPABASE_URL!,
        process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY!,
        {
            cookies: {
                getAll() {
                    return request.cookies.getAll()
                },
                setAll(cookiesToSet) {
                    cookiesToSet.forEach(({ name, value }) => request.cookies.set(name, value))
                    response = NextResponse.next({
                        request,
                    })
                    cookiesToSet.forEach(({ name, value, options }) =>
                        response.cookies.set(name, value, options)
                    )
                },
            },
        }
    )

    // 🛡️ High-Reliability Handshake: getUser() validates against server to prevent ghost sessions
    const { data: { user }, error: authError } = await supabase.auth.getUser()
    
    // 🛡️ Safety Shield: Handle invalid refresh token scenarios
    if (authError && authError.message.includes('Refresh Token Not Found')) {
        console.warn('[Middleware] Refresh Token Invalidated. Executing Graceful Cleanup.');
        // The logic below will handle redirection to /login since 'user' is null
    }

    const isDashboardPath = pathname.startsWith('/dashboard')
    const isMobilePath = pathname.startsWith('/m')
    const isLoginPage = pathname === '/login'
    const isRoot = pathname === '/'

    // ── 3. High-Efficiency Traffic Control ──
    
    // Auth Guard: Kicking non-users to Login
    if ((isDashboardPath || isMobilePath) && !user) {
        const redirectUrl = new URL('/login', request.url)
        return NextResponse.redirect(redirectUrl)
    }

    // Unauthenticated root: Send to login
    if (isRoot && !user) {
        return NextResponse.redirect(new URL('/login', request.url))
    }

    // Authenticated: Device-Based Segment Pivot
    if (user) {
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

