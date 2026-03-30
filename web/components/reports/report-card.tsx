import { Settings } from 'lucide-react'
import { Button } from '@/components/ui/button'
import { Card, CardContent } from '@/components/ui/card'
import type { ReportDefinition } from './types'

interface ReportCardProps {
    report: ReportDefinition
    onConfigure: () => void
}

export function ReportCard({ report, onConfigure }: ReportCardProps) {
    const Icon = report.icon
    
    const colorClasses = {
        blue: 'bg-blue-500/10 text-blue-600 border-blue-500/20',
        emerald: 'bg-emerald-500/10 text-emerald-600 border-emerald-500/20',
        orange: 'bg-orange-500/10 text-orange-600 border-orange-500/20',
        violet: 'bg-violet-500/10 text-violet-600 border-violet-500/20',
        red: 'bg-red-500/10 text-red-600 border-red-500/20',
        indigo: 'bg-indigo-500/10 text-indigo-600 border-indigo-500/20',
    }

    return (
        <Card className="bg-white/90 backdrop-blur-xl border-slate-100 hover:shadow-lg transition-all duration-300">
            <CardContent className="p-4 space-y-3">
                <div className="flex items-start gap-3">
                    <div className={`p-2.5 rounded-lg border ${colorClasses[report.color]}`}>
                        <Icon className="h-4 w-4" />
                    </div>
                    <div className="flex-1 min-w-0">
                        <h3 className="font-bold text-sm text-slate-900 truncate">{report.title}</h3>
                        <p className="text-[10px] font-semibold text-slate-400 uppercase tracking-wide">{report.subtitle}</p>
                    </div>
                </div>
                
                <p className="text-xs text-slate-600">{report.description}</p>
                
                <div className="space-y-1">
                    <p className="text-[10px] font-bold text-slate-500 uppercase tracking-wide">Includes:</p>
                    <ul className="space-y-0.5">
                        {report.includes.map((item, i) => (
                            <li key={i} className="text-xs text-slate-600 flex items-start gap-1.5">
                                <span className="text-emerald-500 mt-0.5">✓</span>
                                <span>{item}</span>
                            </li>
                        ))}
                    </ul>
                </div>
                
                <div className="flex gap-2 pt-2">
                    <Button onClick={onConfigure} size="sm" className="w-full h-8 text-xs">
                        <Settings className="h-3 w-3 mr-1.5" />
                        Configure & Print
                    </Button>
                </div>
            </CardContent>
        </Card>
    )
}
