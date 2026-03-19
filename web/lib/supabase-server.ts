import { createServerClient } from '@supabase/ssr'
import { cookies } from 'next/headers'

/**
 * Tactical Server Client Factory
 * 
 * This creates a Supabase client that inherits the browser's cookies.
 * REQUIRED for Server Actions and Server Components to perform 
 * authenticated operations (RLS).
 */
export async function createSupabaseServer() {
    const cookieStore = await cookies()

    return createServerClient(
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
                    } catch (error) {
                        // This might be called in a Server Component where cookies can't be set.
                        // We ignore it here as the Middleware usually handles the refresh.
                    }
                },
                remove(name: string, options: any) {
                    try {
                        cookieStore.set({ name, value: '', ...options })
                    } catch (error) {
                        // Ignore
                    }
                },
            },
        }
    )
}
