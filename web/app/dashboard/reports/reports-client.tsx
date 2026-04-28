'use client'

import { useState, useEffect } from 'react'
import { ReportsHeader } from '@/components/reports/reports-header'
import { QuickStats } from '@/components/reports/quick-stats'
import { RecommendedReports } from '@/components/reports/recommended-reports'
import { ReportSections } from '@/components/reports/report-sections'
import { RecentReports } from '@/components/reports/recent-reports'
import { ReportConfigDialog } from '@/components/reports/report-config-dialog'
import useSWR from 'swr'
import { getReportStatsAction } from '@/app/actions/report-actions'
import type { ReportType, ReportStats } from '@/components/reports/types'
import { createClient } from '@/lib/supabase-browser'

interface ReportsClientProps {
    initialStats: ReportStats | null
}

export function ReportsClient({ initialStats }: ReportsClientProps) {
    const { data: statsResponse, mutate } = useSWR('report_stats_aggregator', async () => {
        const res = await getReportStatsAction()
        return res.data
    }, {
        fallbackData: initialStats || undefined,
        revalidateOnFocus: true,
        revalidateOnReconnect: true,
        refreshInterval: 300_000, // Increase interval since we have realtime
    })

    useEffect(() => {
        const supabase = createClient()
        
        const logsChannel = supabase
            .channel('reports_logs_realtime')
            .on(
                'postgres_changes',
                {
                    event: '*',
                    schema: 'public',
                    table: 'borrow_logs'
                },
                () => mutate()
            )
            .subscribe()

        const inventoryChannel = supabase
            .channel('reports_inventory_realtime')
            .on(
                'postgres_changes',
                {
                    event: '*',
                    schema: 'public',
                    table: 'inventory'
                },
                () => mutate()
            )
            .subscribe()

        return () => {
            supabase.removeChannel(logsChannel)
            supabase.removeChannel(inventoryChannel)
        }
    }, [mutate])

    const stats = statsResponse || null
    const [selectedReport, setSelectedReport] = useState<ReportType | null>(null)
    const [showConfig, setShowConfig] = useState(false)

    const handleConfigureReport = (type: ReportType) => {
        setSelectedReport(type)
        setShowConfig(true)
    }

    return (
        <div className="max-w-screen-2xl mx-auto space-y-6 p-1 14in:p-2">
            <ReportsHeader />
            <QuickStats stats={stats} />
            <RecommendedReports stats={stats} onConfigure={handleConfigureReport} />
            <ReportSections onConfigure={handleConfigureReport} />
            <RecentReports />
            
            {showConfig && selectedReport && (
                <ReportConfigDialog
                    reportType={selectedReport}
                    onClose={() => setShowConfig(false)}
                    onGenerate={() => setShowConfig(false)}
                />
            )}
        </div>
    )
}
