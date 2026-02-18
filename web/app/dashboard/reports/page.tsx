'use client'

import { useState, useCallback } from 'react'
import { supabase } from '@/lib/supabase'
import { Card, CardContent } from '@/components/ui/card'
import { Button } from '@/components/ui/button'
import { Printer, Package, ClipboardList, TrendingDown, BarChart3, RefreshCw } from 'lucide-react'

type ReportType = 'inventory' | 'logs' | 'low-stock' | 'summary'

export default function PrintReports() {
    const [isGenerating, setIsGenerating] = useState(false)
    const [selectedReport, setSelectedReport] = useState<ReportType | null>(null)

    const generateReport = useCallback(async (type: ReportType) => {
        setIsGenerating(true)
        setSelectedReport(type)

        try {
            let reportData: any = null
            let reportTitle = ''

            switch (type) {
                case 'inventory':
                    const { data: inv } = await supabase.from('inventory').select('*').order('item_name')
                    reportData = inv
                    reportTitle = 'Complete Inventory Registry'
                    break

                case 'logs':
                    const { data: logs } = await supabase.from('borrow_logs').select('*').order('created_at', { ascending: false })
                    reportData = logs
                    reportTitle = 'Borrow/Return Transaction History'
                    break

                case 'low-stock':
                    const { data: low } = await supabase.from('inventory').select('*').lt('stock_available', 5).order('stock_available')
                    reportData = low
                    reportTitle = 'Critical Low-Stock Monitoring Report'
                    break

                case 'summary':
                    const { data: inventory } = await supabase.from('inventory').select('stock_available, category')
                    const { data: borrowed } = await supabase.from('borrow_logs').select('quantity').eq('status', 'borrowed')

                    const catMap: Record<string, number> = {}
                    inventory?.forEach(i => { catMap[i.category] = (catMap[i.category] || 0) + i.stock_available })

                    reportData = {
                        totalTypes: inventory?.length || 0,
                        totalUnits: inventory?.reduce((sum, i) => sum + i.stock_available, 0) || 0,
                        unitsLent: borrowed?.reduce((sum, b) => sum + b.quantity, 0) || 0,
                        categories: Object.entries(catMap).map(([name, count]) => ({ name, count }))
                    }
                    reportTitle = 'Executive System Status Summary'
                    break
            }

            const reportHTML = generateReportHTML(reportTitle, reportData, type)
            const printWindow = window.open('', '_blank')
            if (printWindow) {
                printWindow.document.write(reportHTML)
                printWindow.document.close()
                setTimeout(() => printWindow.print(), 500)
            }
        } catch (error) {
            console.error('Report Error:', error)
            alert('Failed to generate official report.')
        } finally {
            setIsGenerating(false)
            setSelectedReport(null)
        }
    }, [])

    const generateReportHTML = (title: string, data: any, type: ReportType) => {
        const currentDate = new Date().toLocaleDateString('en-US', {
            year: 'numeric', month: 'long', day: 'numeric',
            hour: '2-digit', minute: '2-digit'
        })

        let tableContent = ''

        if (type === 'inventory') {
            tableContent = `
                <table>
                    <thead>
                        <tr><th>Asset Name</th><th>Category</th><th>Stock</th><th>Readiness</th></tr>
                    </thead>
                    <tbody>
                        ${data.map((item: any) => `
                            <tr>
                                <td style="font-weight: 600;">${item.item_name}</td>
                                <td>${item.category}</td>
                                <td>${item.stock_available}</td>
                                <td><span class="badge ${item.stock_available === 0 ? 'bg-red' : item.stock_available < 5 ? 'bg-orange' : 'bg-green'}">
                                    ${item.stock_available === 0 ? 'Out' : item.stock_available < 5 ? 'Low' : 'Ready'}
                                </span></td>
                            </tr>
                        `).join('')}
                    </tbody>
                </table>`
        } else if (type === 'logs') {
            tableContent = `
                <table>
                    <thead>
                        <tr><th>Date</th><th>Borrower</th><th>Item</th><th>Qty</th><th>Status</th></tr>
                    </thead>
                    <tbody>
                        ${data.map((log: any) => `
                            <tr>
                                <td style="font-size: 11px;">${new Date(log.created_at).toLocaleDateString()}</td>
                                <td style="font-weight: 600;">${log.borrower_name}</td>
                                <td>${log.item_name}</td>
                                <td>${log.quantity}</td>
                                <td><span class="badge ${log.status === 'borrowed' ? 'bg-orange' : 'bg-green'}">${log.status}</span></td>
                            </tr>
                        `).join('')}
                    </tbody>
                </table>`
        } else if (type === 'low-stock') {
            tableContent = `
                <div style="background: #fff5f5; border: 1px solid #feb2b2; padding: 15px; border-radius: 8px; margin-bottom: 20px; color: #c53030; font-weight: 600;">
                    LOGISTICS WARNING: The following items are below operational thresholds.
                </div>
                <table>
                    <thead>
                        <tr><th>Critical Item</th><th>Available</th><th>Requirement</th></tr>
                    </thead>
                    <tbody>
                        ${data.map((item: any) => `
                            <tr>
                                <td style="font-weight: 600;">${item.item_name}</td>
                                <td style="color:red; font-weight:700;">${item.stock_available}</td>
                                <td>Immediate Procurement</td>
                            </tr>
                        `).join('')}
                    </tbody>
                </table>`
        } else if (type === 'summary') {
            tableContent = `
                <div class="summary-grid">
                    <div class="card"><div class="label">Item types</div><div class="val">${data.totalTypes}</div></div>
                    <div class="card"><div class="label">Units on-hand</div><div class="val">${data.totalUnits}</div></div>
                    <div class="card"><div class="label">Units lent</div><div class="val">${data.unitsLent}</div></div>
                </div>
                <h3 style="margin: 30px 0 15px 0;">Readiness by Category</h3>
                <table>
                    <thead><tr><th>Category</th><th>Available Units</th></tr></thead>
                    <tbody>
                        ${data.categories.map((cat: any) => `<tr><td style="font-weight:600;">${cat.name}</td><td>${cat.count}</td></tr>`).join('')}
                    </tbody>
                </table>`
        }

        return `
            <!DOCTYPE html>
            <html>
            <head>
                <meta charset="UTF-8">
                <style>
                    body { font-family: -apple-system, system-ui, sans-serif; color: #2d3748; padding: 40px; }
                    .header { display: flex; justify-content: space-between; align-items: flex-end; border-bottom: 3px solid #1e40af; padding-bottom: 20px; margin-bottom: 30px; }
                    .header h1 { font-size: 26px; color: #1e40af; font-weight: 700; margin: 0; letter-spacing: -0.5px; }
                    .header p { font-size: 11px; font-weight: 600; color: #64748b; text-transform: uppercase; margin: 5px 0 0 0; letter-spacing: 0.5px; }
                    .summary-grid { display: grid; grid-template-columns: repeat(3, 1fr); gap: 20px; margin-bottom: 30px; }
                    .summary-grid .card { background: #f8fafc; padding: 20px; border-radius: 10px; border: 1px solid #e2e8f0; }
                    .card .label { font-size: 10px; font-weight: 700; color: #64748b; text-transform: uppercase; margin-bottom: 5px; letter-spacing: 0.5px; }
                    .card .val { font-size: 28px; font-weight: 700; color: #1e293b; }
                    table { width: 100%; border-collapse: collapse; margin-top: 20px; }
                    th { text-align: left; padding: 12px; background: #f8fafc; border-bottom: 2px solid #e2e8f0; font-size: 10px; font-weight: 700; text-transform: uppercase; color: #64748b; letter-spacing: 0.5px; }
                    td { padding: 12px; border-bottom: 1px solid #f1f5f9; font-size: 13px; }
                    .badge { padding: 4px 10px; border-radius: 6px; font-size: 10px; font-weight: 700; color: white; text-transform: uppercase; display: inline-block; letter-spacing: 0.3px; }
                    .bg-red { background: #dc2626; } .bg-orange { background: #ea580c; } .bg-green { background: #16a34a; }
                    .footer { margin-top: 50px; padding-top: 20px; border-top: 1px solid #e2e8f0; text-align: center; font-size: 10px; color: #94a3b8; font-weight: 600; letter-spacing: 0.5px; }
                    @media print { .no-print { display: none; } }
                </style>
            </head>
            <body>
                <div class="header">
                    <div><h1>LIGTAS System</h1><p>CDRRMO Operational Command</p></div>
                    <div style="text-align:right; font-size:11px; font-weight:600; color:#64748b;">GEN: ${currentDate}</div>
                </div>
                <h2 style="font-size: 18px; margin-bottom: 20px; color: #1e293b; font-weight: 600;">${title}</h2>
                ${tableContent}
                <div class="footer">OFFICIAL CDRRMO RECORD - COPIES UNAUTHORIZED WITHOUT ADMIN CLEARANCE</div>
            </body>
            </html>
        `
    }

    const reportTypes = [
        {
            type: 'inventory' as ReportType,
            title: 'Inventory Report',
            subtitle: 'Complete asset registry',
            icon: Package,
            color: 'blue',
        },
        {
            type: 'logs' as ReportType,
            title: 'Transaction Logs',
            subtitle: 'Borrow & return history',
            icon: ClipboardList,
            color: 'emerald',
        },
        {
            type: 'low-stock' as ReportType,
            title: 'Low Stock Alert',
            subtitle: 'Critical inventory levels',
            icon: TrendingDown,
            color: 'orange',
        },
        {
            type: 'summary' as ReportType,
            title: 'System Summary',
            subtitle: 'Executive overview',
            icon: BarChart3,
            color: 'violet',
        },
    ]

    return (
        <div className="max-w-screen-2xl mx-auto space-y-6 p-1 14in:p-2 animate-in fade-in duration-500">
            {/* Page Header */}
            <div className="flex flex-col gap-4 md:flex-row md:items-center md:justify-between bg-white/80 backdrop-blur-md p-3 14in:p-4 rounded-xl border border-slate-100 shadow-sm">
                <div>
                    <h1 className="text-xl 14in:text-2xl font-bold tracking-tight text-slate-900 font-heading">Print Reports</h1>
                    <p className="text-[10px] font-bold text-slate-400 uppercase tracking-[0.15em] mt-1">Document Generation & Export</p>
                </div>
                <div className="flex items-center gap-1.5 px-3 py-1.5 bg-slate-50 rounded-lg border border-slate-100">
                    <Printer className="h-3.5 w-3.5 text-slate-400" />
                    <p className="text-[9px] font-bold text-slate-500 uppercase tracking-widest">Ready to Print</p>
                </div>
            </div>

            {/* Report Grid */}
            <div className="grid gap-4 md:grid-cols-2 lg:grid-cols-4">
                {reportTypes.map((report) => {
                    const Icon = report.icon
                    const colorClasses = {
                        blue: 'bg-blue-500/10 text-blue-600 hover:bg-blue-500/20 border-blue-500/20',
                        emerald: 'bg-emerald-500/10 text-emerald-600 hover:bg-emerald-500/20 border-emerald-500/20',
                        orange: 'bg-orange-500/10 text-orange-600 hover:bg-orange-500/20 border-orange-500/20',
                        violet: 'bg-violet-500/10 text-violet-600 hover:bg-violet-500/20 border-violet-500/20',
                    }[report.color as 'blue' | 'emerald' | 'orange' | 'violet']

                    const buttonClasses = {
                        blue: 'bg-blue-600 hover:bg-blue-700 shadow-blue-600/20',
                        emerald: 'bg-emerald-600 hover:bg-emerald-700 shadow-emerald-600/20',
                        orange: 'bg-orange-600 hover:bg-orange-700 shadow-orange-600/20',
                        violet: 'bg-violet-600 hover:bg-violet-700 shadow-violet-600/20',
                    }[report.color as 'blue' | 'emerald' | 'orange' | 'violet']

                    return (
                        <Card
                            key={report.type}
                            className="bg-white/90 backdrop-blur-xl border-slate-100 hover:shadow-xl transition-all duration-300 hover:-translate-y-0.5 overflow-hidden group"
                        >
                            <CardContent className="p-5 space-y-4">
                                {/* Icon & Title */}
                                <div className="space-y-3">
                                    <div className={`inline-flex p-3 rounded-xl border transition-all duration-300 ${colorClasses}`}>
                                        <Icon className="h-5 w-5" />
                                    </div>
                                    <div className="space-y-1">
                                        <h3 className="font-heading font-bold text-sm text-slate-900 tracking-tight">{report.title}</h3>
                                        <p className="text-[10px] font-medium text-slate-400 uppercase tracking-wide">{report.subtitle}</p>
                                    </div>
                                </div>

                                {/* Action Button */}
                                <Button
                                    onClick={() => generateReport(report.type)}
                                    disabled={isGenerating && selectedReport === report.type}
                                    className={`w-full h-9 ${buttonClasses} text-white text-xs font-semibold tracking-wide shadow-lg transition-all active:scale-95 rounded-lg`}
                                >
                                    {isGenerating && selectedReport === report.type ? (
                                        <>
                                            <RefreshCw className="h-3.5 w-3.5 animate-spin mr-2" />
                                            Generating...
                                        </>
                                    ) : (
                                        <>
                                            <Printer className="h-3.5 w-3.5 mr-2" />
                                            Print
                                        </>
                                    )}
                                </Button>
                            </CardContent>
                        </Card>
                    )
                })}
            </div>
        </div>
    )
}
