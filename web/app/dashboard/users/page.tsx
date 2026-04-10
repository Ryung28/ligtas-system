import { UsersClient } from './users-client'
import { createSupabaseServer } from '@/lib/supabase-server'
import { Suspense } from 'react'
import Loading from './loading'

export const dynamic = 'force-dynamic'

export default async function AccessControlPage() {
    const initialUsers = await getInitialUsers()

    return (
        <Suspense fallback={<Loading />}>
            <UsersClient initialUsers={initialUsers} />
        </Suspense>
    )
}

async function getInitialUsers() {
    try {
        const supabase = await createSupabaseServer()
        const { data, error } = await supabase
            .from('user_profiles')
            .select('*')
            .order('created_at', { ascending: false })

        if (error) throw error
        return data || []
    } catch (error) {
        console.error('Failed to load users on server:', error)
        return []
    }
}
