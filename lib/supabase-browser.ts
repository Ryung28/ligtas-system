import { createBrowserClient } from '@supabase/ssr'

/**
 * 🛰️ TACTICAL BROWSER CLIENT
 * Factory for instantiating the Supabase client in Client Components.
 * Used exclusively for Realtime and Session management on the edge.
 */
export function createClient() {
  return createBrowserClient(
    process.env.NEXT_PUBLIC_SUPABASE_URL!,
    process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY!
  )
}
