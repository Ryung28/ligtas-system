'use client'

import { Card, CardContent } from '@/components/ui/card'
import { LucideIcon } from 'lucide-react'

interface StatsCardProps {
    title: string
    value: string | number
    icon: LucideIcon
    color: 'blue' | 'indigo' | 'purple' | 'emerald'
    description: string
}

export function StatsCard({ title, value, icon: Icon, color, description }: StatsCardProps) {
    const colorVariants = {
        blue: { bg: 'bg-blue-50', icon: 'text-blue-600', shadow: 'shadow-blue-100' },
        indigo: { bg: 'bg-indigo-50', icon: 'text-indigo-600', shadow: 'shadow-indigo-100' },
        purple: { bg: 'bg-purple-50', icon: 'text-purple-600', shadow: 'shadow-purple-100' },
        emerald: { bg: 'bg-emerald-50', icon: 'text-emerald-600', shadow: 'shadow-emerald-100' },
    }

    const theme = colorVariants[color] || colorVariants.blue

    return (
        <Card className="bg-white border-none shadow-lg shadow-slate-200/30 rounded-2xl hover:shadow-xl hover:translate-y-[-2px] transition-all duration-300 overflow-hidden group">
            <CardContent className="p-5 flex items-center gap-4">
                <div className={`p-3 rounded-xl ${theme.bg} ${theme.shadow} border border-white shrink-0 group-hover:scale-110 transition-transform`}>
                    <Icon className={`h-5 w-5 ${theme.icon}`} />
                </div>
                <div className="flex-1 min-w-0">
                    <h4 className="text-[9px] font-bold text-slate-400 uppercase tracking-[0.15em] mb-0.5 truncate">{title}</h4>
                    <h3 className="text-xl 14in:text-2xl font-heading font-bold tracking-tight text-slate-900 leading-none">{value}</h3>
                    <p className="text-[8px] font-bold text-slate-400 mt-1 uppercase tracking-tight truncate">{description}</p>
                </div>
            </CardContent>
        </Card>
    )
}
