'use client'

import { useState, useEffect } from 'react'
import { supabase } from '@/lib/supabase'
import { ReportsHeader } from '@/components/reports/reports-header'
import { QuickStats } from '@/components/reports/quick-stats'
import { RecommendedReports } from '@/components/reports/recommended-reports'
import { ReportSections } from '@/components/reports/report-sections'
import { RecentReports } from '@/components/reports/recent-reports'
import { ReportConfigDialog } from '@/components/reports/report-config-dialog'
import type { ReportType, ReportStats } from '@/components/reports/types'

import { getInventory } from '@/lib/queries/inventory'

export default function PrintReports() {
    const [stats, setStats] = useState<ReportStats | null>(null)
    const [selectedReport, setSelectedReport] = useState<ReportType | null>(null)
    const [showConfig, setShowConfig] = useState(false)

    useEffect(() => {
        loadStats()
    }, [])

    const loadStats = async () => {
        try {
            const [inventory, logsResult] = await Promise.all([
                getInventory(),
                supabase.from('borrow_logs').select('status, expected_return_date')
            ])

            const totalItems = inventory.length
            const lowStock = inventory.filter(i => i.stock_available < 5).length
            const borrowed = logsResult.data?.filter(l => l.status === 'borrowed').length || 0
            const overdue = logsResult.data?.filter(l => 
                l.status === 'borrowed' && new Date(l.expected_return_date) < new Date()
            ).length || 0
            
            const expiringSoon = inventory.filter(i => {
                if (!i.expiry_date) return false
                const daysUntilExpiry = Math.floor((new Date(i.expiry_date).getTime() - Date.now()) / (1000 * 60 * 60 * 24))
                return daysUntilExpiry <= (i.expiry_alert_days || 30) && daysUntilExpiry >= 0
            }).length || 0

            setStats({ totalItems, lowStock, borrowed, overdue, expiringSoon })
        } catch (error) {
            console.error('Failed to load stats:', error)
        }
    }

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
