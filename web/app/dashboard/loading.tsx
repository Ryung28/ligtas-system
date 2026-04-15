export default function DashboardLoading() {
    return (
        <div className="space-y-6 opacity-40 transition-opacity duration-300">
            {/* Ultra-Lean Header Frame */}
            <div className="flex flex-col gap-4 sm:flex-row sm:items-center sm:justify-between py-2">
                <div className="space-y-2">
                    <div className="h-4 w-48 bg-slate-50 rounded-full" />
                    <div className="h-8 w-64 bg-slate-50 rounded-lg" />
                </div>
                <div className="h-10 w-32 bg-slate-50 rounded-xl" />
            </div>

            {/* Quick Segment Grid */}
            <div className="grid gap-4 md:grid-cols-2 lg:grid-cols-4">
                {[1, 2, 3, 4].map(i => (
                    <div key={i} className="h-28 bg-slate-50/50 rounded-2xl border border-slate-100 p-5 shadow-sm" />
                ))}
            </div>

            {/* Content Body Placeholder */}
            <div className="h-[400px] w-full bg-white rounded-2xl border border-slate-100 shadow-sm" />
        </div>
    )
}
