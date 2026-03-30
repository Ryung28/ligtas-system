import { Card, CardContent } from '@/components/ui/card'
import { LogStats } from '@/lib/types/inventory'
import { TransactionStatus } from '@/lib/types/inventory'
import { 
    Clock, 
    Package, 
    RefreshCcw, 
    AlertCircle, 
    ClipboardList 
} from 'lucide-react'

interface LogStatsCardsProps {
    stats: LogStats
    currentFilter: TransactionStatus
    onFilterChange: (filter: TransactionStatus) => void
}

export function LogStatsCards({ stats, currentFilter, onFilterChange }: LogStatsCardsProps) {
    return (
        <div className="grid gap-3 grid-cols-2 lg:grid-cols-5">
            <StatsCard 
                title="Total Registry" 
                value={stats.total} 
                color="slate" 
                label="Logged" 
                icon={ClipboardList}
                isActive={currentFilter === 'all'}
                onClick={() => onFilterChange('all')}
            />
            <StatsCard 
                title="Pending Requests" 
                value={stats.pending} 
                color="amber" 
                label="Requests" 
                icon={Clock}
                isActive={currentFilter === 'pending'}
                onClick={() => onFilterChange('pending')}
            />
            <StatsCard 
                title="Active Borrows" 
                value={stats.borrowed} 
                color="blue" 
                label="Units" 
                icon={Package}
                isActive={currentFilter === 'borrowed'}
                onClick={() => onFilterChange('borrowed')}
            />
            <StatsCard 
                title="Returned Items" 
                value={stats.returned} 
                color="emerald" 
                label="Units" 
                icon={RefreshCcw}
                isActive={currentFilter === 'returned'}
                onClick={() => onFilterChange('returned')}
            />
            <StatsCard 
                title="Overdue Items" 
                value={stats.overdue} 
                color="rose" 
                label="Alert" 
                icon={AlertCircle}
                isActive={currentFilter === 'overdue'}
                onClick={() => onFilterChange('overdue')}
            />
        </div>
    )
}

function StatsCard({ 
    title, 
    value, 
    color = 'slate', 
    label, 
    icon: Icon,
    isActive = false,
    onClick
}: { 
    title: string, 
    value: number, 
    color?: string, 
    label: string,
    icon: any,
    isActive?: boolean,
    onClick?: () => void
}) {
    const colorTheme: Record<string, { dot: string, text: string, activeBg: string, activeRing: string }> = {
        slate: { dot: 'bg-slate-400', text: 'text-slate-500', activeBg: 'bg-slate-50', activeRing: 'ring-slate-300' },
        blue: { dot: 'bg-blue-500', text: 'text-blue-500', activeBg: 'bg-blue-50', activeRing: 'ring-blue-300' },
        emerald: { dot: 'bg-emerald-500', text: 'text-emerald-500', activeBg: 'bg-emerald-50', activeRing: 'ring-emerald-300' },
        rose: { dot: 'bg-rose-500', text: 'text-rose-500', activeBg: 'bg-rose-50', activeRing: 'ring-rose-300' },
        amber: { dot: 'bg-amber-500', text: 'text-amber-500', activeBg: 'bg-amber-50', activeRing: 'ring-amber-300' },
    }

    const theme = colorTheme[color] || colorTheme.slate

    return (
        <Card 
            onClick={onClick}
            className={`relative overflow-hidden border-none ring-1 shadow-sm hover:shadow-[0_8px_16px_-6px_rgba(0,0,0,0.05)] transition-all duration-300 rounded-2xl group cursor-pointer ${
                isActive 
                    ? `${theme.activeBg} ${theme.activeRing} ring-2` 
                    : 'bg-white ring-zinc-200/60 hover:ring-zinc-300'
            }`}
        >
            <CardContent className="p-3.5 14in:p-5 flex items-center justify-between gap-3">
                <div className="min-w-0 flex-1">
                    <div className="flex items-center mb-1.5">
                        <p className="text-[9px] 14in:text-[10px] font-bold tracking-[0.1em] text-zinc-400 uppercase truncate leading-none">
                            {title}
                        </p>
                    </div>
                    <div className="flex items-baseline gap-1.5 overflow-hidden">
                        <p className="text-xl 14in:text-2xl font-mono font-black tabular-nums tracking-tighter text-zinc-900 group-hover:translate-x-0.5 transition-transform duration-300">
                            {value}
                        </p>
                        <span className="text-[8px] 14in:text-[9px] font-bold text-zinc-400 uppercase tracking-widest leading-none opacity-60 italic shrink-0">{label}</span>
                    </div>
                </div>
                
                <div className={`flex-shrink-0 h-10 w-10 rounded-xl flex items-center justify-center bg-white border border-zinc-200 shadow-sm shadow-[inset_0_2px_4px_rgba(255,255,255,0.8)] transition-all duration-300 group-hover:border-zinc-300 group-hover:-translate-y-0.5`}>
                    <Icon className={`h-5 w-5 ${theme.text} stroke-[2px] transition-transform duration-300 group-hover:scale-110`} />
                </div>
            </CardContent>
            
            {/* Minimal Grid - Faint Operational Texture */}
            <div className="absolute inset-x-0 bottom-0 h-8 opacity-[0.015] pointer-events-none" 
                 style={{ backgroundImage: 'radial-gradient(circle, #000 1px, transparent 1px)', backgroundSize: '10px 10px' }} />
        </Card>
    )
}
