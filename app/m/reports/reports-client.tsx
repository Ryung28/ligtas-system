'use client'

import React, { useState } from 'react'
import useSWR from 'swr'
import { 
    BarChart3, 
    FileText, 
    ChevronRight, 
    Printer, 
    Download, 
    AlertTriangle,
    Clock,
    Package,
    Users
} from 'lucide-react'
import { getReportStatsAction } from '@/app/actions/report-actions'
import { MobileHeader } from '@/components/mobile/mobile-header'
import { BottomSheet } from '@/components/mobile/primitives/bottom-sheet'
import { MBadge } from '@/components/mobile/primitives/badge'
import { SectionHeader } from '@/components/mobile/primitives/section-header'
import { MInput, FormField } from '@/components/mobile/primitives/form-field'
import { Button } from '@/components/ui/button'
import { generateReport } from '@/components/reports/report-generator'
import type { ReportType, ReportConfig, ReportStats } from '@/components/reports/types'
import { cn } from '@/lib/utils'

/**
 * 📊 MOBILE REPORTS EXPLORER
 * Simplified interface for tactical data generation.
 */
export function ReportsClient() {
    const { data: statsResponse, mutate, isLoading } = useSWR('report_stats_aggregator', async () => {
        const res = await getReportStatsAction()
        return res.data
    })

    const stats = statsResponse || { totalItems: 0, lowStock: 0, borrowed: 0, overdue: 0, expiringSoon: 0 }
    const [selectedType, setSelectedType] = useState<ReportType | null>(null)
    const [config, setConfig] = useState<ReportConfig>({
        dateFrom: new Date(Date.now() - 30 * 24 * 60 * 60 * 1000).toLocaleDateString('en-CA'),
        dateTo: new Date().toLocaleDateString('en-CA'),
        includeWatermark: true,
        category: 'all',
        sortOrder: 'latest'
    })

    const reportCards: { type: ReportType; title: string; desc: string; icon: any; color: string }[] = [
        { type: 'summary', title: 'System Summary', desc: 'Overall status snapshot', icon: BarChart3, color: 'text-blue-600 bg-blue-50' },
        { type: 'inventory', title: 'Asset List', desc: 'Current catalog & quantities', icon: Package, color: 'text-indigo-600 bg-indigo-50' },
        { type: 'logs', title: 'Transaction Logs', desc: 'Borrow & return history', icon: FileText, color: 'text-emerald-600 bg-emerald-50' },
        { type: 'overdue', title: 'Overdue Alerts', desc: 'Pending returns report', icon: Clock, color: 'text-orange-600 bg-orange-50' },
        { type: 'low-stock', title: 'Low Stock', desc: 'Critical supply shortages', icon: AlertTriangle, color: 'text-red-600 bg-red-50' },
        { type: 'borrower-activity', title: 'Borrowers', desc: 'User engagement stats', icon: Users, color: 'text-violet-600 bg-violet-50' },
    ]

    const handleAction = async (method: 'print' | 'excel') => {
        if (!selectedType) return
        try {
            await generateReport(selectedType, config, method)
            setSelectedType(null)
        } catch (error) {
            console.error('[Reports] generation failed', error)
        }
    }

    return (
        <div className="space-y-6">
            <MobileHeader title="Reports" onRefresh={() => mutate()} isLoading={isLoading} />

            {/* Quick Pulse Stats */}
            <div className="grid grid-cols-2 gap-3">
                <div className="p-4 bg-white rounded-2xl border border-gray-100 shadow-sm">
                    <p className="text-[10px] font-black uppercase tracking-widest text-gray-400 mb-1">Stocked</p>
                    <p className="text-2xl font-black text-gray-900 leading-none">{stats.totalItems}</p>
                    <MBadge tone="neutral" className="mt-2">Inventory</MBadge>
                </div>
                <div className="p-4 bg-white rounded-2xl border border-gray-100 shadow-sm">
                    <p className="text-[10px] font-black uppercase tracking-widest text-gray-400 mb-1">Borrowed</p>
                    <p className="text-2xl font-black text-gray-900 leading-none">{stats.borrowed}</p>
                    <MBadge tone="info" className="mt-2">Active</MBadge>
                </div>
            </div>

            {/* Report Catalog */}
            <div className="space-y-3">
                <SectionHeader title="Available Reports" />
                <div className="space-y-2">
                    {reportCards.map((report) => (
                        <button
                            key={report.type}
                            onClick={() => setSelectedType(report.type)}
                            className="w-full flex items-center gap-4 p-4 bg-white rounded-2xl border border-gray-100 shadow-sm active:bg-gray-50 transition-colors text-left"
                        >
                            <div className={cn("w-12 h-12 rounded-xl flex items-center justify-center shrink-0", report.color)}>
                                <report.icon className="w-6 h-6" />
                            </div>
                            <div className="flex-1 min-w-0">
                                <p className="font-bold text-gray-900">{report.title}</p>
                                <p className="text-xs text-gray-500 truncate">{report.desc}</p>
                            </div>
                            <ChevronRight className="w-5 h-5 text-gray-300" />
                        </button>
                    ))}
                </div>
            </div>

            {/* Config Sheet */}
            <BottomSheet
                open={!!selectedType}
                onOpenChange={(open) => !open && setSelectedType(null)}
                title={reportCards.find(r => r.type === selectedType)?.title || 'Configure Report'}
                footer={
                    <div className="grid grid-cols-2 gap-3">
                        <Button 
                            className="bg-gray-900 hover:bg-black font-bold h-12 rounded-xl"
                            onClick={() => handleAction('print')}
                        >
                            <Printer className="w-4 h-4 mr-2" />
                            PDF
                        </Button>
                        <Button 
                            variant="outline" 
                            className="font-bold h-12 rounded-xl"
                            onClick={() => handleAction('excel')}
                        >
                            <Download className="w-4 h-4 mr-2" />
                            Excel
                        </Button>
                    </div>
                }
            >
                <div className="space-y-5 pb-6">
                    <div className="grid grid-cols-2 gap-4">
                        <FormField label="Start Date">
                            <MInput 
                                type="date" 
                                value={config.dateFrom} 
                                onChange={(e) => setConfig({ ...config, dateFrom: e.target.value })} 
                            />
                        </FormField>
                        <FormField label="End Date">
                            <MInput 
                                type="date" 
                                value={config.dateTo} 
                                onChange={(e) => setConfig({ ...config, dateTo: e.target.value })} 
                            />
                        </FormField>
                    </div>
                    
                    <p className="text-[10px] font-black uppercase tracking-widest text-gray-400">Settings</p>
                    <div className="space-y-3 p-4 bg-gray-50 rounded-2xl border border-gray-100">
                        <div className="flex items-center justify-between">
                            <span className="text-sm font-bold text-gray-700">Confidential Watermark</span>
                            <input 
                                type="checkbox" 
                                checked={config.includeWatermark} 
                                onChange={(e) => setConfig({ ...config, includeWatermark: e.target.checked })}
                                className="w-5 h-5 rounded-md border-gray-300 text-red-600 focus:ring-red-500"
                            />
                        </div>
                    </div>
                </div>
            </BottomSheet>
        </div>
    )
}
