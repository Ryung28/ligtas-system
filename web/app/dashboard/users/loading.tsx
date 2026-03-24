export default function UsersLoading() {
    return (
        <div className="space-y-4 animate-pulse">
            {/* Header Skeleton */}
            <div className="h-16 bg-white rounded-xl border border-gray-200/60"></div>

            {/* Stats Skeleton */}
            <div className="grid gap-4 grid-cols-2 md:grid-cols-4">
                {[1, 2, 3, 4].map(i => (
                    <div key={i} className="h-24 bg-white rounded-xl border border-gray-200/60"></div>
                ))}
            </div>

            {/* Two Column Layout Skeleton */}
            <div className="grid grid-cols-1 lg:grid-cols-2 gap-4">
                <div className="h-96 bg-white rounded-xl border border-gray-200/60"></div>
                <div className="h-96 bg-white rounded-xl border border-gray-200/60"></div>
            </div>

            {/* Footer Skeleton */}
            <div className="h-32 bg-gradient-to-br from-slate-900/5 to-blue-900/5 rounded-[1.5rem] border border-slate-100"></div>
        </div>
    )
}
