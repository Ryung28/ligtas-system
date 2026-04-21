import { Package, AlertTriangle, Clock, TrendingDown, XCircle } from 'lucide-react'
import type { ReportStats } from './types'

interface QuickStatsProps {
    stats: ReportStats | null
}

export function QuickStats({ stats }: QuickStatsProps) {
    if (!stats) return null

    const statItems = [
        { label: 'Total Items', value: stats.totalItems, icon: Package, color: 'text-blue-600' },
        { label: 'Borrowed', value: stats.borrowed, icon: Clock, color: 'text-emerald-600' },
        { label: 'Overdue', value: stats.overdue, icon: AlertTriangle, color: 'text-red-600' },
        { label: 'Out of Stock', value: stats.outOfStock, icon: XCircle, color: 'text-rose-600' },
        { label: 'Low Stock', value: stats.lowStock, icon: TrendingDown, color: 'text-orange-600' },
    ]

    return (
        <div className="bg-white/90 backdrop-blur-xl border border-slate-100 rounded-xl p-4 shadow-sm">
            <h3 className="text-xs font-bold text-slate-500 uppercase tracking-wider mb-3">Quick Overview</h3>
            <div className="grid grid-cols-2 sm:grid-cols-3 lg:grid-cols-5 gap-4">
                {statItems.map((stat) => {
                    const Icon = stat.icon
                    return (
                        <div key={stat.label} className="flex items-center gap-3">
                            <div className={`p-2 rounded-lg bg-slate-50 ${stat.color}`}>
                                <Icon className="h-4 w-4" />
                            </div>
                            <div>
                                <p className="text-2xl font-bold text-slate-900">{stat.value}</p>
                                <p className="text-[10px] font-semibold text-slate-500 uppercase tracking-wide">{stat.label}</p>
                            </div>
                        </div>
                    )
                })}
            </div>
        </div>
    )
}
