export default function BorrowersLoading() {
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

            {/* Table Skeleton */}
            <div className="bg-white rounded-xl border border-gray-200/60 p-6">
                {[1, 2, 3, 4, 5].map(i => (
                    <div key={i} className="h-16 bg-gray-100 rounded mb-3"></div>
                ))}
            </div>
        </div>
    )
}
