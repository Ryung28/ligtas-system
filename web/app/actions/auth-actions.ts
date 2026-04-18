'use server'

import { createSupabaseServer } from '@/lib/supabase-server'
import { redirect } from 'next/navigation'

/**
 * Server-side logout action.
 * Uses the server Supabase client to clear the HTTP-only session cookies
 * that middleware reads. The client-side signOut() in lib/auth.ts only
 * clears localStorage — it never touches cookies, so middleware keeps
 * redirecting back to the dashboard.
 */
export async function logoutAction(): Promise<void> {
    const supabase = await createSupabaseServer()
    await supabase.auth.signOut()
    redirect('/login')
}
