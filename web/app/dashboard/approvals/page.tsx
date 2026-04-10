import { ApprovalsClient } from './approvals-client'
import { createSupabaseServer } from '@/lib/supabase-server'
import { Suspense } from 'react'
import Loading from './loading'

export const dynamic = 'force-dynamic'

export default async function ApprovalsPage() {
    const initialRequests = await getInitialPendingRequests()

    return (
        <Suspense fallback={<Loading />}>
            <ApprovalsClient initialRequests={initialRequests} />
        </Suspense>
    )
}

async function getInitialPendingRequests() {
    try {
        const supabase = await createSupabaseServer()
        const { data, error } = await supabase
            .from('borrow_logs')
            .select(`
                *,
                inventory:inventory_id (*)
            `)
            .eq('status', 'pending')
            .order('created_at', { ascending: false })

        if (error) throw error
        return data || []
    } catch (error) {
        console.error('Failed to load pending requests on server:', error)
        return []
    }
}
