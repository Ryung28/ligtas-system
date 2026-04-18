import { createServerClient } from '@supabase/ssr'
import { cookies } from 'next/headers'
import { NextResponse } from 'next/server'

export async function GET(request: Request) {
    const { searchParams, origin } = new URL(request.url)
    const code = searchParams.get('code')
    const next = searchParams.get('next') ?? '/dashboard'

    if (code) {
        // Next.js 15+: cookies() is an asynchronous Promise
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
                // Check if user is whitelisted - case-insensitive match
                const { data: whitelistEntry, error: whitelistError } = await supabase
                    .from('authorized_emails')
                    .select('role')
                    .ilike('email', user.email)
                    .maybeSingle()

                if (!whitelistEntry) {
                    console.log(`[Auth] Unauthorized login attempt: ${user.email}`)

                    // Sign out the unauthorized user so the middleware doesn't redirect them back in
                    await supabase.auth.signOut()

                    return NextResponse.redirect(`${origin}/login?error=ACCESS DENIED: You must be invited by an Administrator to use this system.`)
                }

                // Authorized: Upsert user profile to handle race condition
                // The DB trigger (on_auth_user_created) may not have committed
                // the row yet, so UPDATE would silently no-op on 0 rows.
                // UPSERT guarantees the profile exists and is promoted.
                const fullName = user.user_metadata?.full_name
                    || user.user_metadata?.name
                    || user.email?.split('@')[0]
                    || 'User'

                await supabase
                    .from('user_profiles')
                    .upsert({
                        id: user.id,
                        email: user.email,
                        full_name: fullName,
                        role: whitelistEntry.role,
                        status: 'active',
                        approved_at: new Date().toISOString()
                    }, { onConflict: 'id' })

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
