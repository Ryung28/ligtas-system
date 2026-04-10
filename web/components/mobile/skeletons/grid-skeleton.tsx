export function GridSkeleton({ count = 6 }: { count?: number }) {
    return (
        <div className="grid grid-cols-2 gap-4">
            {Array(count).fill(0).map((_, i) => (
                <div key={i} className="bg-white rounded-2xl border border-gray-100 h-64 animate-pulse overflow-hidden shadow-sm">
                    <div className="h-40 bg-slate-50" />
                    <div className="p-4 space-y-2">
                        <div className="h-4 bg-slate-50 rounded w-full" />
                        <div className="h-3 bg-slate-50 rounded w-2/3" />
                    </div>
                </div>
            ))}
        </div>
    )
}
