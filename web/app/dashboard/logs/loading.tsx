export default function LogsLoading() {
    return (
        <div className="space-y-6 animate-pulse">
            {/* Header Skeleton */}
            <div className="flex flex-col gap-4 md:flex-row md:items-center md:justify-between">
                <div>
                    <div className="h-9 w-64 bg-gray-200 rounded-lg"></div>
                    <div className="h-4 w-48 bg-gray-100 rounded mt-2"></div>
                </div>
                <div className="flex gap-2">
                    <div className="h-10 w-28 bg-gray-200 rounded-xl"></div>
                    <div className="h-10 w-32 bg-gray-200 rounded-xl"></div>
                </div>
            </div>

            {/* Stats Skeleton */}
            <div className="grid gap-4 md:grid-cols-4">
                {[1, 2, 3, 4].map((i) => (
                    <div key={i} className="h-32 bg-gray-100 border border-gray-200 rounded-xl"></div>
                ))}
            </div>

            {/* Table Skeleton */}
            <div className="bg-white rounded-xl shadow-sm border border-gray-200 overflow-hidden">
                <div className="p-5 border-b border-gray-100 flex justify-between">
                    <div className="h-10 w-64 bg-gray-100 rounded-lg"></div>
                    <div className="h-10 w-96 bg-gray-100 rounded-lg"></div>
                </div>
                <div className="p-0">
                    <div className="space-y-0.5">
                        {[1, 2, 3, 4, 5, 6].map((i) => (
                            <div key={i} className="h-16 border-b border-gray-50 flex items-center px-6 gap-4">
                                <div className="h-4 w-4 bg-gray-100 rounded"></div>
                                <div className="h-10 w-10 bg-gray-100 rounded-full"></div>
                                <div className="space-y-2 flex-1">
                                    <div className="h-4 w-1/4 bg-gray-100 rounded"></div>
                                    <div className="h-3 w-1/6 bg-gray-50 rounded"></div>
                                </div>
                                <div className="h-4 w-32 bg-gray-50 rounded"></div>
                                <div className="h-8 w-20 bg-gray-100 rounded-lg"></div>
                            </div>
                        ))}
                    </div>
                </div>
            </div>
        </div>
    )
}
