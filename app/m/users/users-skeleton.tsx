import { MobileHeader } from '@/components/mobile/mobile-header'

export function UsersSkeleton() {
    return (
        <div className="space-y-5">
            <MobileHeader title="Users" />

            <div className="grid grid-cols-3 gap-2">
                {[1, 2, 3].map((i) => (
                    <div key={i} className="h-20 rounded-2xl bg-white border border-gray-100 animate-pulse" />
                ))}
            </div>

            <div className="h-10 rounded-xl bg-white border border-gray-100 animate-pulse" />

            <div className="space-y-3">
                {[1, 2, 3, 4].map((i) => (
                    <div key={i} className="h-20 rounded-2xl bg-white border border-gray-100 animate-pulse" />
                ))}
            </div>
        </div>
    )
}
