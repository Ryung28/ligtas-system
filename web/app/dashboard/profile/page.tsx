import { ProfileClient } from './profile-client'
import { createSupabaseServer } from '@/lib/supabase-server'
import { Suspense } from 'react'
import { Loader2 } from 'lucide-react'

export const dynamic = 'force-dynamic'

export default async function ProfilePage() {
    const initialProfile = await getInitialProfile()

    if (!initialProfile) {
        return (
            <div className="flex h-[50vh] items-center justify-center">
                <p className="text-slate-500">Failed to load profile. Please try again.</p>
            </div>
        )
    }

    return (
        <Suspense fallback={<ProfileSkeleton />}>
            <ProfileClient initialProfile={initialProfile} />
        </Suspense>
    )
}

async function getInitialProfile() {
    try {
        const supabase = await createSupabaseServer()
        
        // 1. Get auth user
        const { data: { user } } = await supabase.auth.getUser()
        if (!user) return null

        // 2. Get profile data
        const { data, error } = await supabase
            .from('user_profiles')
            .select('*')
            .eq('id', user.id)
            .single()

        if (error) throw error
        return data
    } catch (error) {
        console.error('Failed to load profile on server:', error)
        return null
    }
}

function ProfileSkeleton() {
    return (
        <div className="flex h-[50vh] items-center justify-center">
            <Loader2 className="h-8 w-8 animate-spin text-slate-300" />
        </div>
    )
}
