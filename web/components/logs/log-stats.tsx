import { Card, CardContent } from '@/components/ui/card'
import { LogStats } from '@/lib/types/inventory'

export function LogStatsCards({ stats }: { stats: LogStats }) {
    return (
        <div className="grid gap-4 grid-cols-2 md:grid-cols-4">
            <StatsCard title="Total Transactions" value={stats.total} color="slate" label="Logged" />
            <StatsCard title="Active Borrows" value={stats.borrowed} color="blue" label="Units" />
            <StatsCard title="Returned Items" value={stats.returned} color="emerald" label="Units" />
            <StatsCard title="Overdue Items" value={stats.overdue} color="rose" label="Alert" />
        </div>
    )
}

function StatsCard({ title, value, color = 'slate', label }: { title: string, value: number, color?: string, label: string }) {
    const colorMap: Record<string, string> = {
        slate: 'bg-slate-50/50 text-slate-700 ring-slate-100',
        blue: 'bg-blue-50/50 text-blue-700 ring-blue-100',
        emerald: 'bg-emerald-50/50 text-emerald-700 ring-emerald-100',
        rose: 'bg-rose-50/50 text-rose-700 ring-rose-100',
    }

    return (
        <Card className="bg-white/80 backdrop-blur-sm border-none ring-1 ring-slate-100 shadow-sm hover:shadow-md transition-all duration-300 rounded-2xl group">
            <CardContent className="p-4 14in:p-5 flex items-center justify-between">
                <div className="min-w-0">
                    <p className="text-[9px] font-bold tracking-[0.15em] text-slate-400 uppercase truncate mb-1.5 leading-none">{title}</p>
                    <div className="flex items-baseline gap-2">
                        <p className={`text-2xl 14in:text-3xl font-heading font-bold tracking-tight leading-none text-slate-900 group-hover:scale-105 transition-transform origin-left`}>
                            {value}
                        </p>
                        <span className="text-[10px] font-bold text-slate-400 uppercase tracking-widest leading-none">{label}</span>
                    </div>
                </div>
                <div className={`h-10 w-10 14in:h-12 14in:w-12 rounded-xl ring-1 flex items-center justify-center shrink-0 ${colorMap[color]} group-hover:rotate-3 transition-transform`}>
                    <div className="text-[10px] font-bold uppercase tracking-wider">{color.charAt(0)}</div>
                </div>
            </CardContent>
        </Card>
    )
}
