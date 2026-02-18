import { createServerClient, type CookieOptions } from '@supabase/ssr'
import { cookies } from 'next/headers'
import { redirect } from 'next/navigation'

export default async function RootPage() {
    const cookieStore = await cookies()

    // Create Supabase client to check session server-side
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

    const { data: { session } } = await supabase.auth.getSession()

    // Senior Dev Logic: The root path (/) is no longer a landing page.
    // It's a traffic controller.
    if (session) {
        redirect('/dashboard/inventory')
    } else {
        redirect('/login')
    }
}
