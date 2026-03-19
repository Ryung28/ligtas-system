import { createBrowserClient } from '@supabase/ssr'
import { resolveUserStatus } from '@/lib/auth-utils'

const supabase = createBrowserClient(
    process.env.NEXT_PUBLIC_SUPABASE_URL!,
    process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY!
)

/**
 * Check if user is authenticated
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
 * Get current user with profile data.
 * 🛡️ DRY: Delegates identity resolution to resolveUserStatus (auth-utils.ts).
 */
export async function getCurrentUser() {
    try {
        const { data: { user }, error } = await supabase.auth.getUser()
        if (error || !user) return null

        const { data: profile } = await supabase
            .from('user_profiles')
            .select('*')
            .eq('id', user.id)
            .maybeSingle()

        // 🛡️ Unified resolution — no duplicated whitelist logic here
        const { role, status } = await resolveUserStatus(supabase, user, profile)

        return { ...user, ...profile, role, status }
    } catch (error) {
        console.error('Get user error:', error)
        return null
    }
}
