'use client'

import { useState, useCallback } from 'react'
import { supabase } from '@/lib/supabase'
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from '@/components/ui/card'
import { Button } from '@/components/ui/button'
import { Printer, FileText, Download, Calendar, Package, ClipboardList } from 'lucide-react'

type ReportType = 'inventory' | 'logs' | 'low-stock' | 'summary'

export default function PrintReports() {
    const [isGenerating, setIsGenerating] = useState(false)
    const [selectedReport, setSelectedReport] = useState<ReportType | null>(null)

    const generateReport = useCallback(async (type: ReportType) => {
        setIsGenerating(true)
        setSelectedReport(type)

        try {
            let reportData: any = {}
            let reportTitle = ''

            switch (type) {
                case 'inventory':
                    const { data: inventoryData } = await supabase
                        .from('inventory')
                        .select('*')
                        .order('item_name')
                    reportData = inventoryData
                    reportTitle = 'Complete Inventory Report'
                    break

                case 'logs':
                    const { data: logsData } = await supabase
                        .from('borrow_logs')
                        .select('*')
                        .order('created_at', { ascending: false })
                    reportData = logsData
                    reportTitle = 'Borrow/Return Logs Report'
                    break

                case 'low-stock':
                    const { data: lowStockData } = await supabase
                        .from('inventory')
                        .select('*')
                        .lt('stock_available', 5)
                        .order('stock_available')
                    reportData = lowStockData
                    reportTitle = 'Low Stock Items Report'
                    break

                case 'summary':
                    reportTitle = 'System Summary Report'
                    break
            }

            // Generate HTML report
            const reportHTML = generateReportHTML(reportTitle, reportData, type)

            // Open print dialog
            const printWindow = window.open('', '_blank')
            if (printWindow) {
                printWindow.document.write(reportHTML)
                printWindow.document.close()
                setTimeout(() => {
                    printWindow.print()
                }, 500)
            }
        } catch (error) {
            console.error('Error generating report:', error)
            alert('Failed to generate report. Please try again.')
        } finally {
            setIsGenerating(false)
            setSelectedReport(null)
        }
    }, [])

    const generateReportHTML = (title: string, data: any[], type: ReportType) => {
        const currentDate = new Date().toLocaleDateString('en-US', {
            year: 'numeric',
            month: 'long',
            day: 'numeric'
        })

        let tableContent = ''

        if (type === 'inventory') {
            tableContent = `
                <table>
                    <thead>
                        <tr>
                            <th>Item Name</th>
                            <th>Category</th>
                            <th>Available Stock</th>
                            <th>Status</th>
                        </tr>
                    </thead>
                    <tbody>
                        ${data.map(item => `
                            <tr>
                                <td>${item.item_name}</td>
                                <td>${item.category}</td>
                                <td>${item.stock_available}</td>
                                <td>${item.stock_available === 0 ? 'Out of Stock' : item.stock_available < 5 ? 'Low Stock' : 'In Stock'}</td>
                            </tr>
                        `).join('')}
                    </tbody>
                </table>
            `
        } else if (type === 'logs') {
            tableContent = `
                <table>
                    <thead>
                        <tr>
                            <th>Item</th>
                            <th>Quantity</th>
                            <th>Borrower</th>
                            <th>Organization</th>
                            <th>Borrow Date</th>
                            <th>Status</th>
                        </tr>
                    </thead>
                    <tbody>
                        ${data.map(log => `
                            <tr>
                                <td>${log.item_name}</td>
                                <td>${log.quantity}</td>
                                <td>${log.borrower_name}</td>
                                <td>${log.borrower_organization || 'N/A'}</td>
                                <td>${new Date(log.borrow_date).toLocaleDateString()}</td>
                                <td>${log.status}</td>
                            </tr>
                        `).join('')}
                    </tbody>
                </table>
            `
        } else if (type === 'low-stock') {
            tableContent = `
                <table>
                    <thead>
                        <tr>
                            <th>Item Name</th>
                            <th>Category</th>
                            <th>Available Stock</th>
                            <th>Action Required</th>
                        </tr>
                    </thead>
                    <tbody>
                        ${data.map(item => `
                            <tr>
                                <td>${item.item_name}</td>
                                <td>${item.category}</td>
                                <td style="color: ${item.stock_available === 0 ? 'red' : 'orange'}; font-weight: bold;">${item.stock_available}</td>
                                <td>${item.stock_available === 0 ? 'Immediate Restocking' : 'Monitor & Restock'}</td>
                            </tr>
                        `).join('')}
                    </tbody>
                </table>
            `
        }

        return `
            <!DOCTYPE html>
            <html>
            <head>
                <meta charset="UTF-8">
                <title>${title}</title>
                <style>
                    @media print {
                        @page { margin: 1cm; }
                    }
                    body {
                        font-family: Arial, sans-serif;
                        padding: 20px;
                        max-width: 1200px;
                        margin: 0 auto;
                    }
                    .header {
                        text-align: center;
                        margin-bottom: 30px;
                        border-bottom: 3px solid #2563eb;
                        padding-bottom: 20px;
                    }
                    .header h1 {
                        color: #1e40af;
                        margin: 0;
                        font-size: 28px;
                    }
                    .header p {
                        color: #64748b;
                        margin: 10px 0 0 0;
                    }
                    .report-info {
                        display: flex;
                        justify-content: space-between;
                        margin-bottom: 20px;
                        padding: 15px;
                        background: #f8fafc;
                        border-radius: 8px;
                    }
                    table {
                        width: 100%;
                        border-collapse: collapse;
                        margin-top: 20px;
                    }
                    th {
                        background: #2563eb;
                        color: white;
                        padding: 12px;
                        text-align: left;
                        font-weight: 600;
                    }
                    td {
                        padding: 10px;
                        border-bottom: 1px solid #e2e8f0;
                    }
                    tr:nth-child(even) {
                        background: #f8fafc;
                    }
                    .footer {
                        margin-top: 40px;
                        text-align: center;
                        color: #64748b;
                        font-size: 12px;
                        border-top: 1px solid #e2e8f0;
                        padding-top: 20px;
                    }
                    .print-button {
                        background: #2563eb;
                        color: white;
                        padding: 10px 20px;
                        border: none;
                        border-radius: 6px;
                        cursor: pointer;
                        margin-bottom: 20px;
                    }
                    @media print {
                        .print-button { display: none; }
                    }
                </style>
            </head>
            <body>
                <button class="print-button" onclick="window.print()">🖨️ Print Report</button>
                
                <div class="header">
                    <h1>LIGTAS CDRRMO System</h1>
                    <p>City Disaster Risk Reduction & Management Office</p>
                </div>

                <div class="report-info">
                    <div>
                        <strong>Report Type:</strong> ${title}
                    </div>
                    <div>
                        <strong>Generated:</strong> ${currentDate}
                    </div>
                    <div>
                        <strong>Total Records:</strong> ${data.length}
                    </div>
                </div>

                ${tableContent}

                <div class="footer">
                    <p>This is an official report generated by the LIGTAS CDRRMO System</p>
                    <p>© ${new Date().getFullYear()} CDRRMO. All rights reserved.</p>
                </div>
            </body>
            </html>
        `
    }

    const reportTypes = [
        {
            type: 'inventory' as ReportType,
            title: 'Complete Inventory Report',
            description: 'Full list of all items in the inventory system',
            icon: Package,
            color: 'blue',
        },
        {
            type: 'logs' as ReportType,
            title: 'Borrow/Return Logs Report',
            description: 'Transaction history of borrowed and returned items',
            icon: ClipboardList,
            color: 'green',
        },
        {
            type: 'low-stock' as ReportType,
            title: 'Low Stock Alert Report',
            description: 'Items with stock levels below threshold',
            icon: FileText,
            color: 'orange',
        },
        {
            type: 'summary' as ReportType,
            title: 'System Summary Report',
            description: 'Overview of system statistics and analytics',
            icon: Calendar,
            color: 'purple',
        },
    ]

    return (
        <div className="space-y-6">
            {/* Page Header */}
            <div>
                <h1 className="text-3xl font-bold text-gray-900">Print Reports</h1>
                <p className="text-gray-600 mt-1">Generate and print system reports for record keeping</p>
            </div>

            {/* Report Cards */}
            <div className="grid gap-4 md:grid-cols-2">
                {reportTypes.map((report) => {
                    const Icon = report.icon
                    const colors = {
                        blue: 'from-blue-600 to-blue-500 border-blue-100 bg-blue-50',
                        green: 'from-green-600 to-green-500 border-green-100 bg-green-50',
                        orange: 'from-orange-600 to-orange-500 border-orange-100 bg-orange-50',
                        purple: 'from-purple-600 to-purple-500 border-purple-100 bg-purple-50',
                    }

                    return (
                        <Card key={report.type} className="bg-white rounded-2xl shadow-lg border-2 overflow-hidden hover:shadow-xl transition-all">
                            <div className={`h-1.5 bg-gradient-to-r ${colors[report.color as keyof typeof colors].split(' ')[0]} ${colors[report.color as keyof typeof colors].split(' ')[1]}`}></div>
                            <CardHeader className={`${colors[report.color as keyof typeof colors].split(' ')[3]}`}>
                                <div className="flex items-start gap-3">
                                    <div className={`p-3 rounded-xl bg-white border-2 ${colors[report.color as keyof typeof colors].split(' ')[2]}`}>
                                        <Icon className={`h-6 w-6 text-${report.color}-600`} />
                                    </div>
                                    <div className="flex-1">
                                        <CardTitle className="text-lg">{report.title}</CardTitle>
                                        <CardDescription className="mt-1">{report.description}</CardDescription>
                                    </div>
                                </div>
                            </CardHeader>
                            <CardContent>
                                <Button
                                    onClick={() => generateReport(report.type)}
                                    disabled={isGenerating && selectedReport === report.type}
                                    className={`w-full gap-2 bg-${report.color}-600 hover:bg-${report.color}-700 rounded-xl`}
                                >
                                    {isGenerating && selectedReport === report.type ? (
                                        <>
                                            <div className="w-4 h-4 border-2 border-white border-t-transparent rounded-full animate-spin"></div>
                                            Generating...
                                        </>
                                    ) : (
                                        <>
                                            <Printer className="h-4 w-4" />
                                            Generate & Print
                                        </>
                                    )}
                                </Button>
                            </CardContent>
                        </Card>
                    )
                })}
            </div>

            {/* Instructions */}
            <Card className="bg-gradient-to-r from-blue-50 to-white rounded-2xl shadow-md border-l-4 border-blue-500">
                <CardHeader>
                    <CardTitle className="flex items-center gap-2 text-blue-900">
                        <FileText className="h-5 w-5" />
                        How to Use
                    </CardTitle>
                </CardHeader>
                <CardContent className="text-gray-700">
                    <ol className="list-decimal list-inside space-y-2">
                        <li>Select the type of report you want to generate</li>
                        <li>Click "Generate & Print" button</li>
                        <li>A new window will open with the formatted report</li>
                        <li>Use your browser's print function (Ctrl+P or Cmd+P) or click the print button</li>
                        <li>Configure your printer settings and print</li>
                    </ol>
                </CardContent>
            </Card>
        </div>
    )
}
