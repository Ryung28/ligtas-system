import { Card, CardContent } from '@/components/ui/card'
import { LogStats } from '@/lib/types/inventory'
import { TransactionStatus } from '@/lib/types/inventory'
import { cn } from '@/lib/utils'
import { 
    Clock, 
    Package, 
    RefreshCcw, 
    AlertCircle, 
    ClipboardList,
    Bookmark 
} from 'lucide-react'

interface LogStatsCardsProps {
    stats: LogStats
    currentFilter: TransactionStatus
    onFilterChange: (filter: TransactionStatus) => void
}

export function LogStatsCards({ stats, currentFilter, onFilterChange }: LogStatsCardsProps) {
    const metrics = [
        { id: 'all', title: 'Total', value: stats.total, color: 'slate', icon: ClipboardList, label: 'Records' },
        { id: 'pending', title: 'Pending', value: stats.pending, color: 'amber', icon: Clock, label: 'Requests' },
        { id: 'staged', title: 'Staged', value: stats.staged, color: 'amber', icon: Package, label: 'Pickup' },
        { id: 'borrowed', title: 'Borrowed', value: stats.borrowed, color: 'blue', icon: Package, label: 'Units' },
        { id: 'returned', title: 'Returned', value: stats.returned, color: 'emerald', icon: RefreshCcw, label: 'Units' },
        { id: 'overdue', title: 'Overdue', value: stats.overdue, color: 'rose', icon: AlertCircle, label: 'Alert' },
        { id: 'reserved', title: 'Reserved', value: stats.reserved, color: 'indigo', icon: Bookmark, label: 'Units' },
    ]

    return (
        <Card className="border-none ring-1 ring-zinc-200/60 shadow-sm overflow-hidden bg-white/50 backdrop-blur-sm">
            <div className="flex flex-wrap md:flex-nowrap divide-y md:divide-y-0 md:divide-x divide-zinc-100">
                {metrics.map((metric) => {
                    const isActive = currentFilter === metric.id
                    const Icon = metric.icon
                    const theme: any = {
                        slate: 'text-zinc-500',
                        amber: 'text-amber-500',
                        blue: 'text-blue-500',
                        emerald: 'text-emerald-500',
                        rose: 'text-rose-500',
                        indigo: 'text-indigo-500'
                    }[metric.color] || 'text-zinc-500'

                    return (
                        <button
                            key={metric.id}
                            onClick={() => onFilterChange(metric.id as any)}
                            className={cn(
                                "flex-1 px-4 py-3 14in:py-4 transition-all duration-300 group relative",
                                isActive ? "bg-white shadow-[inset_0_-2px_0_0_#000]" : "hover:bg-zinc-50"
                            )}
                        >
                            <div className="flex items-center gap-3">
                                <div className={cn(
                                    "h-8 w-8 rounded-lg flex items-center justify-center border border-zinc-200/60 shadow-sm transition-all group-hover:scale-110",
                                    isActive ? "bg-zinc-950 border-zinc-950" : "bg-white"
                                )}>
                                    <Icon className={cn(
                                        "h-4 w-4 stroke-[2.5px]",
                                        isActive ? "text-white" : theme
                                    )} />
                                </div>
                                
                                <div className="text-left min-w-0">
                                    <p className="text-[9px] font-black uppercase tracking-widest text-zinc-400 group-hover:text-zinc-600 transition-colors">
                                        {metric.title}
                                    </p>
                                    <div className="flex items-baseline gap-1">
                                        <span className="text-lg 14in:text-xl font-black text-zinc-950 tabular-nums tracking-tighter">
                                            {metric.value}
                                        </span>
                                        <span className="text-[8px] font-bold text-zinc-400 uppercase tracking-tight">
                                            {metric.label}
                                        </span>
                                    </div>
                                </div>
                            </div>
                        </button>
                    )
                })}
            </div>
        </Card>
    )
}
