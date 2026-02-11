'use client'

import { Card, CardContent } from '@/components/ui/card'

interface SummaryCardProps {
    title: string
    value: number | string
    label: string
    color: 'blue' | 'orange' | 'indigo' | 'emerald' | 'purple' | 'slate'
}

export function SummaryCard({ title, value, label, color }: SummaryCardProps) {
    const colorMap: Record<string, string> = {
        blue: 'from-blue-600 to-blue-700 shadow-blue-100',
        orange: 'from-orange-500 to-orange-600 shadow-orange-100',
        indigo: 'from-indigo-600 to-indigo-700 shadow-indigo-100',
        emerald: 'from-emerald-500 to-emerald-600 shadow-emerald-100',
        purple: 'from-purple-600 to-purple-700 shadow-purple-100',
        slate: 'from-slate-600 to-slate-700 shadow-slate-100',
    }

    return (
        <Card className="border-none shadow-sm bg-white overflow-hidden rounded-2xl ring-1 ring-slate-100 group hover:shadow-md transition-all">
            <div className={`h-1 bg-gradient-to-r ${colorMap[color].split(' shadow-')[0]}`} />
            <CardContent className="p-4 14in:p-5">
                <p className="text-[9px] font-bold text-slate-400 uppercase tracking-[0.15em] mb-1">{title}</p>
                <div className="flex items-baseline gap-2">
                    <div className="text-2xl 14in:text-3xl font-heading font-bold text-slate-900 tracking-tight group-hover:scale-105 transition-transform origin-left">{value}</div>
                    <span className="text-[10px] font-bold text-slate-400 uppercase tracking-widest">{label}</span>
                </div>
            </CardContent>
        </Card>
    )
}
