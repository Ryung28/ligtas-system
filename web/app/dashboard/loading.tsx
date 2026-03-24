export default function DashboardLoading() {
    return (
        <div className="space-y-6">
            {/* Header Skeleton - Loads First */}
            <header className="flex flex-col gap-4 sm:flex-row sm:items-center sm:justify-between animate-in fade-in duration-300">
                <div className="space-y-2">
                    <div className="h-3 w-32 bg-gradient-to-r from-gray-100 via-gray-200 to-gray-100 rounded-full animate-shimmer bg-[length:200%_100%]" />
                    <div className="h-8 w-64 bg-gradient-to-r from-gray-100 via-gray-200 to-gray-100 rounded-lg animate-shimmer bg-[length:200%_100%]" />
                </div>
                <div className="h-9 w-32 bg-gradient-to-r from-gray-100 via-gray-200 to-gray-100 rounded-xl animate-shimmer bg-[length:200%_100%]" />
            </header>

            {/* KPI Cards - Staggered 100ms */}
            <section className="grid gap-4 md:grid-cols-2 lg:grid-cols-4 animate-in fade-in duration-300 delay-100">
                {[1, 2, 3, 4].map(i => (
                    <div 
                        key={i} 
                        className="relative overflow-hidden bg-white rounded-2xl border border-gray-100 p-5 shadow-sm"
                    >
                        {/* Shimmer overlay */}
                        <div className="absolute inset-0 -translate-x-full animate-shimmer bg-gradient-to-r from-transparent via-white/60 to-transparent" />
                        
                        {/* Content skeleton */}
                        <div className="space-y-3">
                            <div className="flex items-center justify-between">
                                <div className="h-10 w-10 bg-gray-100 rounded-xl" />
                                <div className="h-6 w-6 bg-gray-100 rounded-full" />
                            </div>
                            <div className="space-y-2">
                                <div className="h-8 w-20 bg-gray-100 rounded" />
                                <div className="h-3 w-24 bg-gray-100 rounded-full" />
                            </div>
                        </div>
                    </div>
                ))}
            </section>

            {/* Alert Banner Skeleton - Staggered 150ms */}
            <div className="animate-in fade-in duration-300 delay-150">
                <div className="relative overflow-hidden bg-white/80 backdrop-blur-md border border-orange-100 rounded-2xl p-4">
                    <div className="absolute inset-0 -translate-x-full animate-shimmer bg-gradient-to-r from-transparent via-white/60 to-transparent" />
                    <div className="flex items-center gap-4">
                        <div className="h-10 w-10 bg-orange-100 rounded-xl shrink-0" />
                        <div className="flex-1 space-y-2">
                            <div className="h-3 w-3/4 bg-gray-100 rounded-full" />
                            <div className="h-3 w-1/2 bg-gray-100 rounded-full" />
                        </div>
                        <div className="h-8 w-20 bg-gray-100 rounded-lg" />
                    </div>
                </div>
            </div>

            {/* Charts Grid - Staggered 200ms */}
            <div className="grid gap-5 lg:grid-cols-12 animate-in fade-in duration-300 delay-200">
                {/* Main Chart */}
                <div className="lg:col-span-8 relative overflow-hidden bg-white rounded-2xl border border-gray-100 p-6 shadow-sm">
                    <div className="absolute inset-0 -translate-x-full animate-shimmer bg-gradient-to-r from-transparent via-white/60 to-transparent" />
                    
                    <div className="space-y-4">
                        {/* Chart header */}
                        <div className="flex items-center justify-between">
                            <div className="space-y-2">
                                <div className="h-5 w-40 bg-gray-100 rounded" />
                                <div className="h-3 w-32 bg-gray-100 rounded-full" />
                            </div>
                            <div className="h-8 w-24 bg-gray-100 rounded-lg" />
                        </div>
                        
                        {/* Chart bars */}
                        <div className="space-y-3 pt-4">
                            {[80, 65, 90, 45, 70, 55, 85].map((height, i) => (
                                <div key={i} className="flex items-center gap-3">
                                    <div className="h-3 w-20 bg-gray-100 rounded-full" />
                                    <div 
                                        className="h-8 bg-gradient-to-r from-gray-100 to-gray-200 rounded-lg transition-all"
                                        style={{ width: `${height}%` }}
                                    />
                                    <div className="h-3 w-12 bg-gray-100 rounded-full" />
                                </div>
                            ))}
                        </div>
                    </div>
                </div>

                {/* Side Column */}
                <div className="lg:col-span-4 space-y-5">
                    {/* Pie Chart */}
                    <div className="relative overflow-hidden bg-white rounded-2xl border border-gray-100 p-6 shadow-sm">
                        <div className="absolute inset-0 -translate-x-full animate-shimmer bg-gradient-to-r from-transparent via-white/60 to-transparent" />
                        
                        <div className="space-y-4">
                            <div className="space-y-2">
                                <div className="h-5 w-36 bg-gray-100 rounded" />
                                <div className="h-3 w-28 bg-gray-100 rounded-full" />
                            </div>
                            
                            {/* Pie chart circle */}
                            <div className="flex items-center justify-center py-6">
                                <div className="h-40 w-40 bg-gradient-to-br from-gray-100 to-gray-200 rounded-full" />
                            </div>
                            
                            {/* Legend */}
                            <div className="space-y-2">
                                {[1, 2, 3, 4].map(i => (
                                    <div key={i} className="flex items-center gap-2">
                                        <div className="h-3 w-3 bg-gray-200 rounded-full" />
                                        <div className="h-3 flex-1 bg-gray-100 rounded-full" />
                                        <div className="h-3 w-12 bg-gray-100 rounded-full" />
                                    </div>
                                ))}
                            </div>
                        </div>
                    </div>

                    {/* Controls Card */}
                    <div className="relative overflow-hidden bg-white rounded-2xl border border-gray-100 p-6 shadow-sm">
                        <div className="absolute inset-0 -translate-x-full animate-shimmer bg-gradient-to-r from-transparent via-white/60 to-transparent" />
                        
                        <div className="space-y-3">
                            <div className="h-5 w-32 bg-gray-100 rounded" />
                            <div className="grid grid-cols-2 gap-3">
                                {[1, 2, 3, 4].map(i => (
                                    <div key={i} className="h-20 bg-gradient-to-br from-gray-100 to-gray-200 rounded-xl" />
                                ))}
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    )
}
