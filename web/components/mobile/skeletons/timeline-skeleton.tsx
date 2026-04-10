export function TimelineSkeleton({ count = 5 }: { count?: number }) {
    return (
        <div className="space-y-0 px-1">
            {Array(count).fill(0).map((_, i) => (
                <div key={i} className="relative pl-8 pb-8">
                    {/* The Line */}
                    <div className="absolute left-[15px] top-0 bottom-0 w-0.5 bg-slate-100" />
                    
                    {/* The Dot */}
                    <div className="absolute left-0 w-8 h-8 rounded-full bg-slate-100 border-4 border-slate-50 z-10 animate-pulse" />
                    
                    {/* The Content */}
                    <div className="bg-white p-4 rounded-2xl shadow-sm border border-slate-100 animate-pulse">
                        <div className="flex justify-between mb-2">
                            <div className="h-4 bg-slate-100 rounded w-2/3" />
                            <div className="h-3 bg-slate-50 rounded w-16" />
                        </div>
                        <div className="h-3 bg-slate-50 rounded w-full" />
                    </div>
                </div>
            ))}
        </div>
    )
}
