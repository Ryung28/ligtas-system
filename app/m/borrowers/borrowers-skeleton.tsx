import { MobileHeader } from '@/components/mobile/mobile-header'

export function BorrowersSkeleton() {
    return (
        <div className="space-y-5">
            <MobileHeader title="Borrowers" />

            <div className="grid grid-cols-2 gap-3">
                {[1, 2, 3, 4].map((i) => (
                    <div
                        key={i}
                        className="h-20 rounded-2xl bg-white border border-gray-100 animate-pulse"
                    />
                ))}
            </div>

            <div className="h-12 rounded-xl bg-white border border-gray-100 animate-pulse" />

            <div className="space-y-3">
                {[1, 2, 3, 4, 5].map((i) => (
                    <div
                        key={i}
                        className="h-24 rounded-2xl bg-white border border-gray-100 animate-pulse"
                    />
                ))}
            </div>
        </div>
    )
}
