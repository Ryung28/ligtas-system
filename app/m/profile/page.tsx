import { Suspense } from 'react'
import { createSupabaseServer } from '@/lib/supabase-server'
import { MobileHeader } from '@/components/mobile/mobile-header'
import { ErrorState } from '@/components/mobile/primitives'
import { UserX } from 'lucide-react'
import { ProfileClient } from './profile-client'
import { ProfileSkeleton } from './profile-skeleton'

export const dynamic = 'force-dynamic'

async function getInitialProfile() {
    try {
        const supabase = await createSupabaseServer()
        const {
            data: { user },
        } = await supabase.auth.getUser()
        if (!user) return null

        const { data, error } = await supabase
            .from('user_profiles')
            .select('*')
            .eq('id', user.id)
            .single()

        if (error) throw error
        return data
    } catch (err) {
        console.error('[/m/profile] failed to load profile', err)
        return null
    }
}

export default async function MobileProfilePage() {
    const initialProfile = await getInitialProfile()

    if (!initialProfile) {
        return (
            <div className="space-y-6">
                <MobileHeader title="Profile" />
                <ErrorState
                    icon={UserX}
                    title="Couldn't load profile"
                    description="Please sign out and back in, or try again shortly."
                />
            </div>
        )
    }

    return (
        <Suspense fallback={<ProfileSkeleton />}>
            <ProfileClient initialProfile={initialProfile} />
        </Suspense>
    )
}
