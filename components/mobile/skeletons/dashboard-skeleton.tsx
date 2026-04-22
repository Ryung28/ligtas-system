export function DashboardSkeleton() {
    return (
        <div className="flex flex-col h-full bg-slate-50 p-4 space-y-6">
            <div className="h-40 bg-white rounded-3xl animate-pulse shadow-sm" />
            
            <div className="grid grid-cols-2 gap-4">
                {[1, 2, 3, 4].map(i => (
                    <div key={i} className="h-24 bg-white rounded-2xl animate-pulse shadow-sm" />
                ))}
            </div>

            <div className="space-y-4">
                <div className="h-4 w-32 bg-slate-200 rounded animate-pulse" />
                {[1, 2, 3].map(i => (
                    <div key={i} className="h-32 bg-white rounded-2xl animate-pulse shadow-sm" />
                ))}
            </div>
        </div>
    )
}
