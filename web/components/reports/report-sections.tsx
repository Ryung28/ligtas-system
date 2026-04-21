import { Package, ClipboardList, TrendingDown, BarChart3, Clock, Pill } from 'lucide-react'
import { ReportCard } from './report-card'
import type { ReportType, ReportDefinition } from './types'

interface ReportSectionsProps {
    onConfigure: (type: ReportType) => void
}

export function ReportSections({ onConfigure }: ReportSectionsProps) {
    const reports: ReportDefinition[] = [
        // Inventory Reports
        { 
            type: 'inventory', 
            title: 'Inventory Report', 
            subtitle: 'Complete asset registry', 
            description: 'Full list of all equipment and consumables with stock levels', 
            includes: ['Item name', 'Category', 'Stock levels', 'Storage location', 'Status'], 
            icon: Package, 
            color: 'blue', 
            category: 'inventory' 
        },
        { 
            type: 'low-stock', 
            title: 'Low Stock Alert', 
            subtitle: 'Critical inventory levels', 
            description: 'Items below minimum threshold requiring procurement', 
            includes: ['Item name', 'Current stock', 'Minimum required', 'Category', 'Priority level'], 
            icon: TrendingDown, 
            color: 'orange', 
            category: 'inventory' 
        },
        { 
            type: 'expiry-alert', 
            title: 'Expiry Alert', 
            subtitle: 'Consumables expiring soon', 
            description: 'Track expiration dates for medicines and consumables', 
            includes: ['Item name', 'Brand', 'Expiry date', 'Days remaining', 'Storage location'], 
            icon: Pill, 
            color: 'red', 
            category: 'inventory' 
        },
        
        // Transaction Reports
        { 
            type: 'logs', 
            title: 'Transaction Logs', 
            subtitle: 'Borrow & return history', 
            description: 'Complete audit trail with chain of custody',
            includes: ['Borrow date/time', 'Borrower', 'Approved by', 'Handed by', 'Return date/time', 'Physically returned by', 'Received by', 'Status'],
            icon: ClipboardList,
            color: 'emerald', 
            category: 'activity' 
        },
        { 
            type: 'overdue', 
            title: 'Overdue Items', 
            subtitle: 'Items past return date', 
            description: 'Track accountability and follow up on late returns', 
            includes: ['Item name', 'Borrower', 'Days overdue', 'Expected return', 'Contact info', 'Priority'], 
            icon: Clock, 
            color: 'red', 
            category: 'activity' 
        },
        { 
            type: 'summary', 
            title: 'System Summary', 
            subtitle: 'Executive overview', 
            description: 'High-level statistics for management reporting', 
            includes: ['Total items', 'Units on-hand', 'Units lent', 'Category breakdown', 'Readiness status'], 
            icon: BarChart3, 
            color: 'violet', 
            category: 'activity' 
        },
    ]

    const sections = [
        { title: 'Inventory Registry & Alerts', category: 'inventory' },
        { title: 'Operational Logs & System Analytics', category: 'activity' },
    ]

    return (
        <div className="space-y-8">
            {sections.map((section) => (
                <div key={section.category}>
                    <h2 className="text-sm font-bold text-slate-700 uppercase tracking-wider mb-4 border-l-4 border-slate-300 pl-3">
                        {section.title}
                    </h2>
                    <div className="grid gap-4 md:grid-cols-2 lg:grid-cols-3">
                        {reports.filter(r => r.category === section.category).map((report) => (
                            <ReportCard
                                key={report.type}
                                report={report}
                                onConfigure={() => onConfigure(report.type)}
                            />
                        ))}
                    </div>
                </div>
            ))}
        </div>
    )
}
