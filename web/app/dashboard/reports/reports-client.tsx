'use client'

import { useState } from 'react'
import { ReportsHeader } from '@/components/reports/reports-header'
import { QuickStats } from '@/components/reports/quick-stats'
import { RecommendedReports } from '@/components/reports/recommended-reports'
import { ReportSections } from '@/components/reports/report-sections'
import { RecentReports } from '@/components/reports/recent-reports'
import { ReportConfigDialog } from '@/components/reports/report-config-dialog'
import type { ReportType, ReportStats } from '@/components/reports/types'

interface ReportsClientProps {
    initialStats: ReportStats | null
}

export function ReportsClient({ initialStats }: ReportsClientProps) {
    const stats = initialStats
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
