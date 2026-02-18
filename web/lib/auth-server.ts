import { createServerClient } from '@supabase/ssr'
import { cookies } from 'next/headers'

// ── Senior Dev: Server-Side Authentication Helper ──
// This function must be used in Server Components (page.tsx, layout.tsx)
// to correctly access cookies and validate the session.

export async function getCurrentUserServer() {
    const cookieStore = await cookies()

    const supabase = createServerClient(
        process.env.NEXT_PUBLIC_SUPABASE_URL!,
        process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY!,
        {
            cookies: {
                get(name: string) {
                    return cookieStore.get(name)?.value
                },
            },
        }
    )

    try {
        const { data: { user }, error } = await supabase.auth.getUser()
        if (error || !user) return null

        // Fetch custom profile data (role, status, etc.)
        const { data: profile } = await supabase
            .from('user_profiles')
            .select('*')
            .eq('id', user.id)
            .maybeSingle()

        // ── Senior Dev: Runtime Authorization Fallback ──
        // If the profile is pending or not found, check the whitelist directly
        let role = profile?.role || 'viewer'
        let status = profile?.status || 'pending'

        // Only perform whitelist check if not already active admin/editor
        if (status !== 'active' || (role !== 'admin' && role !== 'editor')) {
            const { data: whitelist } = await supabase
                .from('authorized_emails')
                .select('role')
                .eq('email', user.email?.toLowerCase())
                .maybeSingle()

            if (whitelist) {
                role = whitelist.role
                status = 'active' // Force active for whitelisted staff
                console.log(`[Auth-Server] Manual runtime promotion for ${user.email}`)

                // Optional: We could trigger an update here, but let's keep server fetch pure.
                // The client-side auth provider or callback route handles the DB update.
            }
        }

        return {
            ...user,
            ...profile,
            role,
            status
        }
    } catch (error) {
        console.error('Get user server error:', error)
        return null
    }
}
