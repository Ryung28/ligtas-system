import { createServerClient } from '@supabase/ssr'
import { cookies } from 'next/headers'
import { NextResponse } from 'next/server'

export async function GET(request: Request) {
    const { searchParams, origin } = new URL(request.url)
    const code = searchParams.get('code')
    const next = searchParams.get('next') ?? '/dashboard'

    if (code) {
        // Next.js 14.1.0: cookies() is synchronous
        const cookieStore = cookies()
        const supabase = createServerClient(
            process.env.NEXT_PUBLIC_SUPABASE_URL!,
            process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY!,
            {
                cookies: {
                    get(name: string) {
                        return cookieStore.get(name)?.value
                    },
                    set(name: string, value: string, options: any) {
                        try {
                            cookieStore.set({ name, value, ...options })
                        } catch (err) {
                            // Can happen in Server Components if used incorrectly
                        }
                    },
                    remove(name: string, options: any) {
                        try {
                            cookieStore.delete({ name, ...options })
                        } catch (err) {
                            // Can happen in Server Components if used incorrectly
                        }
                    },
                },
            }
        )

        try {
            const { error: sessionError } = await supabase.auth.exchangeCodeForSession(code)
            if (sessionError) throw sessionError

            const { data: { user } } = await supabase.auth.getUser()

            if (user?.email) {
                // Check if user is whitelisted - Use maybeSingle() to prevent PGRST116 (0 rows found)
                const { data: whitelistEntry, error: whitelistError } = await supabase
                    .from('authorized_emails')
                    .select('role')
                    .eq('email', user.email.toLowerCase())
                    .maybeSingle()

                if (!whitelistEntry) {
                    console.log(`[Auth] Unauthorized login attempt: ${user.email}`)

                    // Optional: Delete unauthorized account if service role key is available
                    const serviceKey = process.env.SUPABASE_SERVICE_ROLE_KEY
                    if (serviceKey) {
                        const { createClient } = await import('@supabase/supabase-js')
                        const supabaseAdmin = createClient(
                            process.env.NEXT_PUBLIC_SUPABASE_URL!,
                            serviceKey
                        )
                        await supabaseAdmin.auth.admin.deleteUser(user.id)
                    }

                    return NextResponse.redirect(`${origin}/login?error=ACCESS DENIED: You must be invited by an Administrator to use this system.`)
                }

                // Authorized: Update user profile
                await supabase
                    .from('user_profiles')
                    .update({
                        role: whitelistEntry.role,
                        status: 'active',
                        approved_at: new Date().toISOString()
                    })
                    .eq('id', user.id)

                console.log(`[Auth] Authorized & Promoted ${user.email} as ${whitelistEntry.role}`)
            }

            return NextResponse.redirect(`${origin}${next}`)
        } catch (error) {
            console.error('[Auth Callback Error]:', error)
            return NextResponse.redirect(`${origin}/login?error=Authentication failed. Please contact support.`)
        }
    }

    return NextResponse.redirect(`${origin}/login?error=Could not authenticate user`)
}
