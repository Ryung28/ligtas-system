import { Clock } from 'lucide-react'

export function RecentReports() {
    // TODO: Implement report history tracking in database
    const recentReports = [
        { name: 'Transaction Logs', date: 'Mar 27, 10:30 AM' },
        { name: 'Low Stock Alert', date: 'Mar 26, 3:15 PM' },
        { name: 'System Summary', date: 'Mar 25, 9:00 AM' },
    ]

    return (
        <div className="bg-white/90 backdrop-blur-xl border border-slate-100 rounded-xl p-4 shadow-sm">
            <h3 className="text-xs font-bold text-slate-500 uppercase tracking-wider mb-3">Recently Generated</h3>
            <div className="space-y-2">
                {recentReports.map((report, i) => (
                    <div key={i} className="flex items-center justify-between py-2 border-b border-slate-100 last:border-0">
                        <div className="flex items-center gap-2">
                            <Clock className="h-3.5 w-3.5 text-slate-400" />
                            <span className="text-sm font-medium text-slate-700">{report.name}</span>
                        </div>
                        <span className="text-xs text-slate-500">{report.date}</span>
                    </div>
                ))}
            </div>
        </div>
    )
}
