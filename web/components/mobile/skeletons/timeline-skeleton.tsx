export function TimelineSkeleton({ count = 5 }: { count?: number }) {
    return (
        <div className="space-y-3">
            {Array(count).fill(0).map((_, i) => (
                <div key={i} className="bg-white p-4 rounded-[1.5rem] shadow-sm border border-slate-100 animate-pulse space-y-3">
                    <div className="flex justify-between items-center">
                        <div className="flex gap-2">
                            <div className="h-6 w-6 bg-slate-100 rounded-lg" />
                            <div className="h-4 bg-slate-100 rounded w-32" />
                        </div>
                        <div className="h-3 bg-slate-50 rounded w-16" />
                    </div>
                    <div className="space-y-2 pt-2 border-y border-slate-50">
                        <div className="h-3 bg-slate-100 rounded w-full" />
                        <div className="h-3 bg-slate-100 rounded w-4/5" />
                    </div>
                    <div className="flex justify-between">
                         <div className="h-3 bg-slate-50 rounded w-24" />
                         <div className="h-3 bg-slate-50 rounded w-12" />
                    </div>
                </div>
            ))}
        </div>
    )
}
