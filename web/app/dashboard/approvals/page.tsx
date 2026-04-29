import { ApprovalsClient } from './approvals-client'
import { createSupabaseServer } from '@/lib/supabase-server'

/**
 * 🎖️ LIGTAS TACTICAL OVERHAUL
 * This page now performs server-side data seeding to eliminate the 
 * "blank screen" client-side hydration waterfall.
 */
export default async function ApprovalsPage() {
    const supabase = await createSupabaseServer()
    
    // Seed the first 20 items and staff profile directly on the server
    const [{ data: requests }, { data: { user } }] = await Promise.all([
        supabase
            .from('borrow_logs')
            .select(`
                id,
                status,
                created_at,
                item_name,
                borrower_name,
                borrower_contact,
                borrower_department,
                requested_units,
                purpose,
                pickup_scheduled_at,
                inventory:inventory_id (
                    id,
                    item_name,
                    current_stock,
                    unit_type
                )
            `)
            .in('status', ['pending', 'staged', 'reserved'])
            .order('created_at', { ascending: false })
            .limit(20),
        supabase.auth.getUser()
    ])

    let staffProfile = { name: '', role: null as string | null }
    if (user) {
        const { data: profile } = await supabase
            .from('user_profiles')
            .select('full_name, role')
            .eq('id', user.id)
            .single()
        
        if (profile) {
            staffProfile = { name: profile.full_name || '', role: profile.role }
        }
    }

    return (
        <ApprovalsClient 
            initialRequests={requests || []} 
            staffName={staffProfile.name}
            staffRole={staffProfile.role}
        />
    )
}
