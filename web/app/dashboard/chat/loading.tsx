export default function ChatLoading() {
    return (
        <div className="flex bg-white h-[calc(100vh-140px)] rounded-3xl shadow-2xl overflow-hidden border border-slate-200/50 animate-pulse">
            {/* Sidebar Skeleton */}
            <div className="w-80 border-r border-slate-200 p-4 space-y-3">
                {[1, 2, 3, 4, 5].map(i => (
                    <div key={i} className="h-16 bg-gray-100 rounded-xl"></div>
                ))}
            </div>

            {/* Main Content Skeleton */}
            <div className="flex-1 flex flex-col">
                <div className="h-16 bg-gray-50 border-b border-slate-200"></div>
                <div className="flex-1 p-6 space-y-3">
                    {[1, 2, 3, 4].map(i => (
                        <div key={i} className="h-12 bg-gray-100 rounded-xl max-w-md"></div>
                    ))}
                </div>
                <div className="h-16 bg-gray-50 border-t border-slate-200"></div>
            </div>
        </div>
    )
}
