export default function ApprovalsLoading() {
    return (
        <div className="space-y-6 animate-pulse">
            {/* Header Skeleton */}
            <div className="h-32 bg-white rounded-3xl border border-slate-100"></div>

            {/* Table Skeleton */}
            <div className="bg-white rounded-3xl border border-slate-100 p-6">
                {[1, 2, 3, 4, 5].map(i => (
                    <div key={i} className="h-20 bg-gray-100 rounded-xl mb-3"></div>
                ))}
            </div>

            {/* Advisory Skeleton */}
            <div className="h-24 bg-blue-50 rounded-2xl border border-blue-100"></div>
        </div>
    )
}
