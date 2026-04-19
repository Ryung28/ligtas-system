import { MobileHeader } from '@/components/mobile/mobile-header'

export function ProfileSkeleton() {
    return (
        <div className="space-y-6">
            <MobileHeader title="Profile" />

            <div className="rounded-3xl overflow-hidden border border-gray-100 bg-white shadow-sm">
                <div className="h-24 bg-gradient-to-br from-gray-200 to-gray-100 animate-pulse" />
                <div className="px-5 pb-5 -mt-10">
                    <div className="w-20 h-20 rounded-full bg-gray-200 border-4 border-white animate-pulse" />
                    <div className="mt-4 h-5 w-40 bg-gray-200 rounded animate-pulse" />
                    <div className="mt-2 h-3 w-56 bg-gray-100 rounded animate-pulse" />
                    <div className="mt-3 h-5 w-16 bg-gray-100 rounded-full animate-pulse" />
                </div>
            </div>

            <div className="space-y-4">
                {[1, 2, 3].map((i) => (
                    <div key={i} className="space-y-2">
                        <div className="h-3 w-24 bg-gray-100 rounded animate-pulse" />
                        <div className="h-12 bg-gray-50 rounded-xl border border-gray-100 animate-pulse" />
                    </div>
                ))}
            </div>
        </div>
    )
}
