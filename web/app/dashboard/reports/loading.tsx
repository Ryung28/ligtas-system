export default function ReportsLoading() {
    return (
        <div className="max-w-screen-2xl mx-auto space-y-6 p-1 14in:p-2 animate-pulse">
            {/* Header Skeleton */}
            <div className="h-20 bg-white rounded-xl border border-slate-100"></div>

            {/* Report Cards Skeleton */}
            <div className="grid gap-4 md:grid-cols-2 lg:grid-cols-4">
                {[1, 2, 3, 4].map(i => (
                    <div key={i} className="h-40 bg-white rounded-xl border border-slate-100"></div>
                ))}
            </div>
        </div>
    )
}
