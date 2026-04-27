import React, { Suspense } from 'react'
import { DashboardClient } from './dashboard-client'
import { DashboardSkeleton } from '@/components/mobile/skeletons/dashboard-skeleton'
import { createSupabaseServer } from '@/lib/supabase-server'

export const dynamic = 'force-dynamic'

/**
 * 📱 ResQTrack Mobile Dashboard
 * 🏛️ ARCHITECTURE: "The Command Hub"
 */
export default async function MobileDashboardPage() {
    const supabase = await createSupabaseServer()
    const { data: { user } } = await supabase.auth.getUser()
    
    let userName = 'ANALYST'
    if (user) {
        const { data: profile } = await supabase
            .from('user_profiles')
            .select('full_name')
            .eq('id', user.id)
            .single()
        
        if (profile?.full_name) {
            userName = profile.full_name
        }
    }

    return (
        <Suspense fallback={<DashboardSkeleton />}>
            <DashboardClient initialUserName={userName} />
        </Suspense>
    )
}
