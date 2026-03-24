import { Card, CardContent, CardHeader } from '@/components/ui/card'

export default function LogsLoading() {
    return (
        <div className="max-w-screen-3xl mx-auto space-y-4 p-1 14in:p-2 animate-pulse">
            {/* Header Skeleton */}
            <div className="bg-white/80 backdrop-blur-md p-3 14in:p-4 rounded-xl border border-slate-100 shadow-sm">
                <div className="h-8 bg-gray-200 rounded w-64 mb-2"></div>
                <div className="h-4 bg-gray-100 rounded w-32"></div>
            </div>

            {/* Stats Skeleton */}
            <div className="grid gap-3 grid-cols-2 md:grid-cols-3 lg:grid-cols-6">
                {[1, 2, 3, 4, 5, 6].map(i => (
                    <div key={i} className="bg-white rounded-xl border border-gray-100 p-4 h-24"></div>
                ))}
            </div>

            {/* Table Skeleton */}
            <Card className="bg-white/90 backdrop-blur-xl shadow-2xl shadow-slate-200/50 border-none rounded-[2.5rem] ring-1 ring-slate-100">
                <CardHeader className="bg-white/50 border-b border-slate-50 p-4 14in:p-5">
                    <div className="h-10 bg-gray-200 rounded w-full"></div>
                </CardHeader>
                <CardContent className="p-6">
                    {[1, 2, 3, 4, 5].map(i => (
                        <div key={i} className="h-16 bg-gray-100 rounded mb-3"></div>
                    ))}
                </CardContent>
            </Card>
        </div>
    )
}
