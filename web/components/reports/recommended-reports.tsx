import { AlertCircle } from 'lucide-react'
import { Button } from '@/components/ui/button'
import type { ReportStats, ReportType } from './types'

interface RecommendedReportsProps {
    stats: ReportStats | null
    onConfigure: (type: ReportType) => void
}

export function RecommendedReports({ stats, onConfigure }: RecommendedReportsProps) {
    if (!stats) return null

    const recommendations = []
    if (stats.overdue > 0) recommendations.push({ type: 'overdue' as ReportType, message: `${stats.overdue} items overdue`, color: 'text-red-600' })
    if (stats.lowStock > 0) recommendations.push({ type: 'low-stock' as ReportType, message: `${stats.lowStock} items low stock`, color: 'text-orange-600' })
    if (stats.expiringSoon > 0) recommendations.push({ type: 'expiry-alert' as ReportType, message: `${stats.expiringSoon} items expiring soon`, color: 'text-yellow-600' })

    if (recommendations.length === 0) return null

    return (
        <div className="bg-amber-50 border border-amber-200 rounded-xl p-4">
            <div className="flex items-start gap-3">
                <AlertCircle className="h-5 w-5 text-amber-600 flex-shrink-0 mt-0.5" />
                <div className="flex-1">
                    <h3 className="text-sm font-bold text-amber-900 mb-2">Recommended Actions</h3>
                    <div className="space-y-2">
                        {recommendations.map((rec) => (
                            <div key={rec.type} className="flex items-center justify-between">
                                <span className={`text-sm font-semibold ${rec.color}`}>{rec.message}</span>
                                <Button
                                    onClick={() => onConfigure(rec.type)}
                                    size="sm"
                                    variant="outline"
                                    className="h-7 text-xs"
                                >
                                    Print Report
                                </Button>
                            </div>
                        ))}
                    </div>
                </div>
            </div>
        </div>
    )
}
