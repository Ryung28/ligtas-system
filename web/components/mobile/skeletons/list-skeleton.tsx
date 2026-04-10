export function ListSkeleton({ count = 5 }: { count?: number }) {
    return (
        <div className="space-y-4">
            {Array(count).fill(0).map((_, i) => (
                <div key={i} className="bg-white p-4 rounded-2xl shadow-sm border border-slate-50 animate-pulse">
                    <div className="flex justify-between mb-3">
                        <div className="flex gap-3">
                            <div className="w-10 h-10 bg-slate-100 rounded-xl" />
                            <div className="space-y-2">
                                <div className="h-4 bg-slate-100 rounded w-32" />
                                <div className="h-3 bg-slate-50 rounded w-20" />
                            </div>
                        </div>
                        <div className="w-16 h-5 bg-slate-50 rounded-full" />
                    </div>
                    <div className="h-3 bg-slate-50 rounded w-full" />
                </div>
            ))}
        </div>
    )
}
