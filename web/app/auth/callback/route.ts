import { createServerClient } from '@supabase/ssr'
import { cookies } from 'next/headers'
import { NextResponse } from 'next/server'

export async function GET(request: Request) {
    const { searchParams, origin } = new URL(request.url)
    const code = searchParams.get('code')
    // if "next" is in search params, use it as the redirection URL after successful connection
    const next = searchParams.get('next') ?? '/dashboard'

    if (code) {
        const cookieStore = await cookies()
        const supabase = createServerClient(
            process.env.NEXT_PUBLIC_SUPABASE_URL!,
            process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY!,
            {
                cookies: {
                    get(name: string) {
                        return cookieStore.get(name)?.value
                    },
                    set(name: string, value: string, options: any) {
                        cookieStore.set({ name, value, ...options })
                    },
                    remove(name: string, options: any) {
                        cookieStore.delete({ name, ...options })
                    },
                },
            }
        )
        const { error } = await supabase.auth.exchangeCodeForSession(code)
        if (!error) {
            const { data: { user } } = await supabase.auth.getUser()

            if (user?.email) {
                // ── Senior Dev: Strict Whitelist Access Control ──
                // Check if this user is explicitly invited/whitelisted
                const { data: whitelistEntry } = await supabase
                    .from('authorized_emails')
                    .select('role')
                    .eq('email', user.email.toLowerCase())
                    .single()

                if (!whitelistEntry) {
                    // ⛔ UNAUTHORIZED: User is NOT in the whitelist
                    // We must prevent them from clogging up the "Pending Requests" list.
                    console.log(`[Auth] Blocked unauthorized login attempt: ${user.email}`)

                    // 1. Initialize Service Role Client to purge the unauthorized account
                    // (This prevents the user from existing in Auth and user_profiles)
                    const { createClient } = require('@supabase/supabase-js')
                    const supabaseAdmin = createClient(
                        process.env.NEXT_PUBLIC_SUPABASE_URL!,
                        process.env.SUPABASE_SERVICE_ROLE_KEY!
                    )

                    await supabaseAdmin.auth.admin.deleteUser(user.id)

                    return NextResponse.redirect(`${origin}/login?error=ACCESS DENIED: You must be invited by an Administrator to use this system.`)
                }

                // ✅ AUTHORIZED: Promote based on whitelist role
                if (whitelistEntry) {
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
            }

            return NextResponse.redirect(`${origin}${next}`)
        }
    }

    // return the user to an error page with instructions
    return NextResponse.redirect(`${origin}/login?error=Could not authenticate user`)
}
