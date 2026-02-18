import { createBrowserClient } from '@supabase/ssr'

const supabase = createBrowserClient(
    process.env.NEXT_PUBLIC_SUPABASE_URL!,
    process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY!
)

/**
 * Check if user is authenticated
 * @returns Promise<boolean>
 */
export async function isAuthenticated(): Promise<boolean> {
    try {
        const { data: { session } } = await supabase.auth.getSession()
        return !!session
    } catch (error) {
        console.error('Auth check error:', error)
        return false
    }
}

/**
 * Get current user session
 */
export async function getSession() {
    try {
        const { data: { session }, error } = await supabase.auth.getSession()
        if (error) throw error
        return session
    } catch (error) {
        console.error('Get session error:', error)
        return null
    }
}

/**
 * Sign out user
 */
export async function signOut() {
    try {
        const { error } = await supabase.auth.signOut()
        if (error) throw error
        return true
    } catch (error) {
        console.error('Sign out error:', error)
        return false
    }
}

/**
 * Get current user with profile data
 */
export async function getCurrentUser() {
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

        if (status !== 'active') {
            const { data: whitelist } = await supabase
                .from('authorized_emails')
                .select('role')
                .eq('email', user.email?.toLowerCase())
                .maybeSingle()

            if (whitelist) {
                role = whitelist.role
                status = 'active' // Force active for whitelisted staff
                console.log(`[Auth] Manual runtime promotion for ${user.email}`)
            }
        }

        return {
            ...user,
            ...profile,
            role,
            status
        }
    } catch (error) {
        console.error('Get user error:', error)
        return null
    }
}
