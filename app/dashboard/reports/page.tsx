import dynamic from 'next/dynamic'
import { Suspense } from 'react'

const ReportsClient = dynamic(() => import('./reports-client').then(mod => mod.ReportsClient), {
    loading: () => <ReportsSkeleton />
})

export default function ReportsDashboardPage() {
    return (
        <Suspense fallback={<ReportsSkeleton />}>
            <ReportsClient initialStats={null} />
        </Suspense>
    )
}

function ReportsSkeleton() {
    return (
        <div className="space-y-6 p-4 opacity-40 transition-opacity">
            <div className="h-20 bg-white rounded-2xl border border-slate-100"></div>
            <div className="grid grid-cols-5 gap-4">
                {[1, 2, 3, 4, 5].map(i => (
                    <div key={i} className="h-24 bg-white rounded-xl border border-slate-100"></div>
                ))}
            </div>
            <div className="h-32 bg-amber-50 rounded-xl border border-amber-200"></div>
            <div className="grid grid-cols-3 gap-6">
                {[1, 2, 3].map(i => (
                    <div key={i} className="h-64 bg-white rounded-2xl border border-slate-100"></div>
                ))}
            </div>
        </div>
    )
}
