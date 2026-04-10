import { supabase } from '@/lib/supabase'
import * as XLSX from 'xlsx'
import type { ReportType, ReportConfig } from './types'

export async function generateReport(
    type: ReportType,
    config: ReportConfig,
    format: 'print' | 'excel'
) {
    let printWindow: Window | null = null;
    
    // SENIOR FIX: Open window immediately if printing to bypass popup blockers
    if (format === 'print') {
        printWindow = window.open('', '_blank');
        if (printWindow) {
            printWindow.document.write(`
                <html>
                    <body style="display:flex; flex-direction:column; align-items:center; justify-content:center; height:100vh; font-family:sans-serif; color:#64748b; background:#f8fafc;">
                        <div style="width:32px; height:32px; border:2px solid #f1f5f9; border-top-color:#dc2626; border-radius:50%; animation:spin 1s linear infinite;"></div>
                        <p style="margin-top:16px; font-weight:600; font-size:12px; letter-spacing:0.05em;">GENERATING SECURE REPORT...</p>
                        <style>@keyframes spin { to { transform: rotate(360deg); } }</style>
                    </body>
                </html>
            `);
        }
    }

    try {
        const data = await fetchReportData(type, config)
        
        if (format === 'print') {
            if (printWindow) {
                const html = generateReportHTML(type, data, config)
                printWindow.document.open()
                printWindow.document.write(html)
                printWindow.document.close()
                // Small buffer for styles/images to settle
                setTimeout(() => {
                    if (printWindow) printWindow.print();
                }, 500)
            }
        } else {
            exportToExcel(type, data, config)
        }
    } catch (error) {
        console.error('Report generation failed:', error)
        if (printWindow) printWindow.close();
        throw error
    }
}

export async function fetchReportData(type: ReportType, config: ReportConfig) {
    let query = supabase.from(getTableName(type)).select('*')
    
    if (config.dateFrom) {
        query = query.gte('created_at', config.dateFrom)
    }
    if (config.dateTo) {
        query = query.lte('created_at', config.dateTo)
    }
    if (config.category && config.category !== 'all') {
        query = query.eq('category', config.category)
    }
    if (config.borrower && type === 'logs') {
        query = query.ilike('borrower_name', `%${config.borrower}%`)
    }
    if (config.status && config.status.length > 0 && type === 'logs') {
        query = query.in('status', config.status)
    }

    // SENIOR FIX: Apply sorting based on primary temporal column
    const sortColumn = type === 'logs' || type === 'borrower-activity' ? 'created_at' : 'item_name';
    query = query.order(sortColumn, { ascending: config.sortOrder === 'oldest' });
    
    const { data, error } = await query
    if (error) throw error
    return data || []
}

function getTableName(type: ReportType): string {
    if (type === 'logs' || type === 'overdue' || type === 'borrower-activity') return 'borrow_logs'
    return 'inventory'
}

export function generateReportHTML(type: ReportType, data: any[], config: ReportConfig): string {
    const reportId = `RPT-${new Date().getFullYear()}-${String(new Date().getMonth() + 1).padStart(2, '0')}${String(new Date().getDate()).padStart(2, '0')}-${type.substring(0, 3).toUpperCase()}`
    const currentDate = new Date().toLocaleString('en-US', { year: 'numeric', month: 'long', day: 'numeric', hour: '2-digit', minute: '2-digit' })
    
    return `<!DOCTYPE html><html><head><meta charset="UTF-8"><title>${type} Report</title><style>
        :root {
            --color-primary: #dc2626;
            --color-text-primary: #0f172a;
            --color-text-secondary: #475569;
            --color-text-muted: #64748b;
            --color-border: #e2e8f0;
            --color-bg-subtle: #f8fafc;
            --color-bg-muted: #f1f5f9;
            --spacing-xs: 4px;
            --spacing-sm: 8px;
            --spacing-md: 12px;
            --spacing-lg: 16px;
            --spacing-xl: 24px;
            --spacing-2xl: 32px;
        }
        
        * { 
            margin: 0; 
            padding: 0; 
            box-sizing: border-box; 
        }
        
        body { 
            font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, 'Helvetica Neue', Arial, sans-serif;
            font-size: 10pt;
            line-height: 1.5;
            color: var(--color-text-primary);
            padding: 15mm;
            font-feature-settings: 'tnum' 1; /* Tabular numbers */
        }
        
        .header { 
            display: grid;
            grid-template-columns: 80px 1fr;
            gap: var(--spacing-lg);
            padding-bottom: var(--spacing-lg);
            border-bottom: 3px solid var(--color-primary);
            margin-bottom: var(--spacing-2xl);
            align-items: center;
        }
        
        .header img { 
            width: 80px; 
            height: 80px;
            object-fit: contain;
        }
        
        .header-text { 
            text-align: center;
            line-height: 1.4;
        }
        
        .header-text .republic { 
            font-size: 11pt; 
            font-weight: 600;
            letter-spacing: 0.3px;
        }
        
        .header-text .city { 
            font-size: 16pt; 
            font-weight: 900; 
            letter-spacing: 1.2px;
            margin: var(--spacing-xs) 0;
        }
        
        .header-text .office { 
            font-size: 11pt; 
            font-weight: 700; 
            color: var(--color-primary);
            text-transform: uppercase;
            letter-spacing: 0.5px;
            margin-top: var(--spacing-sm);
        }
        
        .meta-info {
            background: var(--color-bg-subtle);
            padding: var(--spacing-md);
            margin-bottom: var(--spacing-xl);
            border-radius: 6px;
            border: 1px solid var(--color-border);
            font-size: 9pt;
            display: grid;
            grid-template-columns: auto 1fr;
            gap: var(--spacing-lg);
        }
        
        .meta-info strong {
            font-weight: 600;
            color: var(--color-text-secondary);
        }
        
        h1 {
            font-size: 16pt;
            font-weight: 700;
            margin-bottom: var(--spacing-xl);
            text-transform: uppercase;
            letter-spacing: 0.8px;
            color: var(--color-text-primary);
        }
        
        table { 
            width: 100%; 
            border-collapse: collapse;
            margin-top: var(--spacing-xl);
            table-layout: fixed;
            box-shadow: 0 1px 3px rgba(0, 0, 0, 0.05);
        }
        
        th { 
            padding: var(--spacing-sm) 6px;
            background: var(--color-bg-muted);
            border-bottom: 2px solid var(--color-border);
            font-size: 7.5pt;
            font-weight: 700;
            text-transform: uppercase;
            letter-spacing: 0.3px;
            text-align: left;
            color: var(--color-text-secondary);
            vertical-align: middle;
            line-height: 1.2;
        }
        
        th:has(+ th) {
            border-right: 1px solid var(--color-border);
        }
        
        td { 
            padding: var(--spacing-sm) 6px;
            border-bottom: 1px solid var(--color-border);
            font-size: 8.5pt;
            vertical-align: middle;
            line-height: 1.3;
            overflow: hidden;
            text-overflow: ellipsis;
        }
        
        tbody tr:nth-child(even) {
            background: var(--color-bg-subtle);
        }
        
        tbody tr:hover {
            background: #fef3f2;
        }
        
        td.number {
            text-align: right;
            font-variant-numeric: tabular-nums;
        }
        
        td.center {
            text-align: center;
        }
        
        td.date {
            font-size: 8pt;
            color: var(--color-text-secondary);
            line-height: 1.3;
        }
        
        .badge {
            padding: 3px 8px;
            border-radius: 4px;
            font-size: 7.5pt;
            font-weight: 700;
            text-transform: uppercase;
            letter-spacing: 0.3px;
            white-space: nowrap;
            display: inline-block;
        }
        
        .alert-box {
            background: #fff5f5;
            border: 1px solid #feb2b2;
            padding: var(--spacing-lg);
            border-radius: 6px;
            margin-bottom: var(--spacing-xl);
            color: #c53030;
            font-weight: 600;
            font-size: 9pt;
            line-height: 1.6;
        }
        
        .stat-grid {
            display: grid;
            grid-template-columns: repeat(3, 1fr);
            gap: var(--spacing-xl);
            margin-bottom: var(--spacing-2xl);
        }
        
        .stat-card {
            background: var(--color-bg-subtle);
            padding: var(--spacing-xl);
            border-radius: 8px;
            border: 1px solid var(--color-border);
        }
        
        .stat-label {
            font-size: 8pt;
            font-weight: 700;
            color: var(--color-text-muted);
            text-transform: uppercase;
            letter-spacing: 0.5px;
            margin-bottom: var(--spacing-sm);
        }
        
        .stat-value {
            font-size: 28pt;
            font-weight: 700;
            color: var(--color-text-primary);
            font-variant-numeric: tabular-nums;
        }
        
        ${config.includeSignatures ? `.signatures { 
            margin-top: 40px; 
            padding-top: var(--spacing-xl); 
            border-top: 2px solid var(--color-border);
        }
        .signatures h3 {
            font-size: 11pt;
            font-weight: 700;
            margin-bottom: var(--spacing-lg);
            text-transform: uppercase;
            letter-spacing: 0.5px;
        }
        .sig-grid {
            display: grid;
            grid-template-columns: repeat(3, 1fr);
            gap: var(--spacing-2xl);
            margin-top: var(--spacing-lg);
        }
        .sig-box {
            text-align: center;
        }
        .sig-line {
            border-bottom: 1px solid #000;
            height: 40px;
            margin-bottom: var(--spacing-sm);
        }
        .sig-label {
            font-size: 8pt;
            font-weight: 700;
            text-transform: uppercase;
            letter-spacing: 0.5px;
        }` : ''}
        
        .footer {
            margin-top: 40px;
            text-align: center;
            font-size: 7.5pt;
            color: var(--color-text-muted);
        }
        
        .footer-title {
            color: var(--color-primary);
            font-weight: 700;
            text-transform: uppercase;
            letter-spacing: 0.5px;
            margin-bottom: var(--spacing-xs);
        }
        
        @media print { 
            @page { 
                size: A4; 
                margin: 10mm; 
            }
            body {
                print-color-adjust: exact;
                -webkit-print-color-adjust: exact;
            }
            tbody tr:hover {
                background: transparent;
            }
        }
    </style></head><body>
        <div class="header">
            <img src="/oro-cervo.png" alt="CDRRMO Logo" />
            <div class="header-text">
                <div class="republic">REPUBLIC OF THE PHILIPPINES</div>
                <div>REGION 10</div>
                <div class="city">OROQUIETA CITY</div>
                <div style="font-style: italic; font-size: 9pt;">Capital of Misamis Occidental</div>
                <div class="office">City Disaster Risk Reduction & Management Office</div>
            </div>
        </div>
        <div class="meta-info">
            <div><strong>Report ID:</strong> ${reportId}</div>
            <div><strong>Generated:</strong> ${currentDate}</div>
        </div>
        <h1>${type.replace('-', ' ')}</h1>
        ${generateTableContent(type, data)}
        ${config.includeSignatures ? `<div class="signatures"><h3>Document Certification</h3><div class="sig-grid"><div class="sig-box"><div class="sig-line"></div><div class="sig-label">PREPARED BY</div></div><div class="sig-box"><div class="sig-line"></div><div class="sig-label">REVIEWED BY</div></div><div class="sig-box"><div class="sig-line"></div><div class="sig-label">APPROVED BY</div></div></div></div>` : ''}
        <div class="footer">
            <div class="footer-title">OFFICIAL CDRRMO RECORD - CONFIDENTIAL</div>
            <div>Document ID: ${reportId}</div>
        </div>
    </body></html>`
}

function generateTableContent(type: ReportType, data: any[]): string {
    switch (type) {
        case 'inventory':
            return `<table><thead><tr><th style="width: 40%;">Item Name</th><th style="width: 25%;">Category</th><th style="width: 15%; text-align: right;">Stock</th><th style="width: 20%; text-align: center;">Status</th></tr></thead><tbody>${data.map(item => `<tr><td style="font-weight: 600;">${item.item_name}</td><td>${item.category}</td><td class="number">${item.stock_available}</td><td class="center"><span class="badge" style="color: white; background: ${item.stock_available === 0 ? '#dc2626' : item.stock_available < 5 ? '#ea580c' : '#16a34a'};">${item.stock_available === 0 ? 'OUT' : item.stock_available < 5 ? 'LOW' : 'READY'}</span></td></tr>`).join('')}</tbody></table>`
        
        case 'logs':
            return `<table><thead><tr><th style="width: 10%;">Borrow Date</th><th style="width: 10%;">Borrower</th><th style="width: 15%;">Item</th><th style="width: 5%; text-align: center;">Qty</th><th style="width: 10%;">Authorized By</th><th style="width: 10%;">Issued By</th><th style="width: 10%;">Return Date</th><th style="width: 8%; text-align: center;">Status</th><th style="width: 22%;">Return Verification</th></tr></thead><tbody>${data.map(log => {
                const borrowDate = new Date(log.borrow_date || log.created_at).toLocaleString('en-US', { month: 'short', day: 'numeric', year: 'numeric', hour: '2-digit', minute: '2-digit' })
                const returnDate = log.actual_return_date ? new Date(log.actual_return_date).toLocaleString('en-US', { month: 'short', day: 'numeric', year: 'numeric', hour: '2-digit', minute: '2-digit' }) : '—'
                
                // 🏛️ IDENTITY SEPARATION: Authorized (Who Said Yes) vs Issued (Who Handed Gear)
                const authority = `<div style="font-weight: 600; font-size: 7.5pt;">${log.approved_by_name || '—'}</div>`
                const releaseAgent = `<div style="font-weight: 600; font-size: 7.5pt;">${log.released_by_name || '—'}</div>`
                
                // 🛡️ EXCEPTION-ONLY AUDIT: Hide [GOOD] to reduce signal noise
                const isException = log.return_condition && log.return_condition.toLowerCase() !== 'good'
                const conditionBadge = isException ? `<span style="font-size: 7.5pt; font-weight: 900; color: ${log.return_condition === 'damaged' ? '#dc2626' : '#ea580c'}; text-transform: uppercase;">[${log.return_condition}]</span>` : ''
                const receiverName = log.received_by_name ? `<span style="font-size: 7.5pt; font-weight: 700; color: #0f172a; margin-left: 4px;">(${log.received_by_name})</span>` : ''
                const noteContent = log.return_notes ? `<div style="font-size: 7.5pt; color: #64748b; margin-top: 2px; font-style: italic; line-height: 1.1;">"${log.return_notes}"</div>` : ''
                
                const auditTrail = log.status === 'returned' 
                    ? `<div>${conditionBadge}${receiverName}</div>${noteContent}` 
                    : '<span style="color:#cbd5e1; font-size:7pt;">AWAITS RETURN</span>'

                return `<tr><td class="date">${borrowDate}</td><td style="font-weight: 600;">${log.borrower_name || '—'}</td><td>${log.item_name || '—'}</td><td class="center">${log.quantity || 0}</td><td>${authority}</td><td>${releaseAgent}</td><td class="date">${returnDate}</td><td class="center"><span class="badge" style="color: white; background: ${log.status === 'borrowed' ? '#ea580c' : log.status === 'returned' ? '#16a34a' : '#dc2626'};">${log.status.toUpperCase()}</span></td><td>${auditTrail}</td></tr>`
            }).join('')}</tbody></table>`
        
        case 'low-stock':
            return `<div class="alert-box">⚠️ LOGISTICS WARNING: The following items are below operational thresholds.</div><table><thead><tr><th style="width: 50%;">Critical Item</th><th style="width: 20%; text-align: right;">Available</th><th style="width: 30%;">Requirement</th></tr></thead><tbody>${data.filter(item => item.stock_available < 5).map(item => `<tr><td style="font-weight: 600;">${item.item_name}</td><td class="number" style="color: #dc2626; font-weight: 700;">${item.stock_available}</td><td>Immediate Procurement</td></tr>`).join('')}</tbody></table>`
        
        case 'overdue':
            return `<table><thead><tr><th style="width: 30%;">Item</th><th style="width: 25%;">Borrower</th><th style="width: 15%; text-align: right;">Days Overdue</th><th style="width: 15%;">Expected Return</th><th style="width: 15%; text-align: center;">Priority</th></tr></thead><tbody>${data.filter(log => log.status === 'borrowed' && new Date(log.expected_return_date) < new Date()).map(log => {
                const daysOverdue = Math.floor((Date.now() - new Date(log.expected_return_date).getTime()) / (1000 * 60 * 60 * 24))
                const priority = daysOverdue > 14 ? 'HIGH' : daysOverdue > 7 ? 'MEDIUM' : 'LOW'
                const color = daysOverdue > 14 ? '#dc2626' : daysOverdue > 7 ? '#ea580c' : '#eab308'
                return `<tr><td style="font-weight: 600;">${log.item_name}</td><td>${log.borrower_name}</td><td class="number" style="color: #dc2626; font-weight: 700;">${daysOverdue}</td><td class="date">${new Date(log.expected_return_date).toLocaleDateString()}</td><td class="center"><span class="badge" style="color: white; background: ${color};">${priority}</span></td></tr>`
            }).join('')}</tbody></table>`
        
        case 'summary':
            const totalTypes = data.length
            const totalUnits = data.reduce((sum, i) => sum + i.stock_available, 0)
            const catMap: Record<string, number> = {}
            data.forEach(i => { catMap[i.category] = (catMap[i.category] || 0) + i.stock_available })
            return `<div class="stat-grid"><div class="stat-card"><div class="stat-label">Item Types</div><div class="stat-value">${totalTypes}</div></div><div class="stat-card"><div class="stat-label">Units On-Hand</div><div class="stat-value">${totalUnits}</div></div><div class="stat-card"><div class="stat-label">Categories</div><div class="stat-value">${Object.keys(catMap).length}</div></div></div><h3 style="margin: 30px 0 15px 0; font-size: 12pt; font-weight: 700; text-transform: uppercase; letter-spacing: 0.5px;">Readiness by Category</h3><table><thead><tr><th style="width: 60%;">Category</th><th style="width: 40%; text-align: right;">Available Units</th></tr></thead><tbody>${Object.entries(catMap).map(([name, count]) => `<tr><td style="font-weight: 600;">${name}</td><td class="number">${count}</td></tr>`).join('')}</tbody></table>`
        
        case 'expiry-alert':
            const now = Date.now()
            return `<div class="alert-box">⚠️ SAFETY ALERT: The following consumables require immediate attention.</div><table><thead><tr><th style="width: 22%;">Item Name</th><th style="width: 15%;">Brand</th><th style="width: 13%;">Expiry Date</th><th style="width: 13%; text-align: right;">Days Remaining</th><th style="width: 15%; text-align: center;">Status</th><th style="width: 22%;">Location</th></tr></thead><tbody>${data.filter(item => item.expiry_date).map(item => {
                const expiryDate = new Date(item.expiry_date)
                const daysRemaining = Math.floor((expiryDate.getTime() - now) / (1000 * 60 * 60 * 24))
                const status = daysRemaining < 0 ? 'EXPIRED' : daysRemaining <= 7 ? 'URGENT' : daysRemaining <= 30 ? 'WARNING' : 'OK'
                const color = daysRemaining < 0 ? '#dc2626' : daysRemaining <= 7 ? '#dc2626' : daysRemaining <= 30 ? '#ea580c' : '#eab308'
                return `<tr><td style="font-weight: 600;">${item.item_name}</td><td>${item.brand || '—'}</td><td class="date">${expiryDate.toLocaleDateString()}</td><td class="number" style="font-weight: 700; color: ${daysRemaining < 0 ? '#dc2626' : 'inherit'};">${daysRemaining}</td><td class="center"><span class="badge" style="color: white; background: ${color};">${status}</span></td><td>${item.storage_location || '—'}</td></tr>`
            }).join('')}</tbody></table>`

        case 'borrower-activity':
            return `<table><thead><tr><th style="width: 15%;">Date</th><th style="width: 35%;">Equipment</th><th style="width: 10%; text-align: center;">Qty</th><th style="width: 20%; text-align: center;">Action</th><th style="width: 20%;">Condition</th></tr></thead><tbody>${data.map(log => {
                const logDate = new Date(log.created_at).toLocaleString('en-US', { month: 'short', day: 'numeric', year: 'numeric', hour: '2-digit', minute: '2-digit' })
                const statusColor = log.status === 'borrowed' ? '#ea580c' : '#16a34a'
                return `<tr><td class="date">${logDate}</td><td style="font-weight: 600;">${log.item_name}</td><td class="center">${log.quantity}</td><td class="center"><span class="badge" style="color: white; background: ${statusColor};">${log.status.toUpperCase()}</span></td><td>${log.return_condition || '—'}</td></tr>`
            }).join('')}</tbody></table>`
        
        default:
            return `<table><thead><tr><th>Data</th></tr></thead><tbody>${data.map(item => `<tr><td>${item.item_name || item.borrower_name || 'N/A'}</td></tr>`).join('')}</tbody></table>`
    }
}

async function exportToExcel(type: ReportType, data: any[], config: ReportConfig) {
    const { headers, rows } = prepareExcelData(type, data)
    
    // Generate professional filename
    const timestamp = new Date()
    const dateStr = timestamp.toISOString().split('T')[0] // YYYY-MM-DD
    const timeStr = timestamp.toTimeString().split(' ')[0].replace(/:/g, '') // HHMMSS
    
    // Map report types to professional names
    const reportNames: Record<ReportType, string> = {
        'inventory': 'Inventory_Catalog',
        'logs': 'Transaction_Logs',
        'low-stock': 'Low_Stock_Alert',
        'overdue': 'Overdue_Items',
        'summary': 'Inventory_Summary',
        'expiry-alert': 'Expiry_Alert',
        'borrower-activity': 'Borrower_History'
    }
    
    const reportName = reportNames[type] || type
    const filename = `CDRRMO_${reportName}_${dateStr}_${timeStr}.xlsx`
    
    // Create workbook with CDRRMO text header (no logo)
    const reportId = `RPT-${timestamp.getFullYear()}-${String(timestamp.getMonth() + 1).padStart(2, '0')}${String(timestamp.getDate()).padStart(2, '0')}-${type.substring(0, 3).toUpperCase()}`
    const currentDate = timestamp.toLocaleString('en-US', { year: 'numeric', month: 'long', day: 'numeric', hour: '2-digit', minute: '2-digit' })
    
    // Build header rows
    const headerRows = [
        ['REPUBLIC OF THE PHILIPPINES'],
        ['REGION 10'],
        ['OROQUIETA CITY'],
        ['Capital of Misamis Occidental'],
        ['CITY DISASTER RISK REDUCTION & MANAGEMENT OFFICE'],
        [],
        [type.replace('-', ' ').toUpperCase()],
        [`Report ID: ${reportId}`, '', '', '', `Generated: ${currentDate}`],
        [],
        headers,
        ...rows
    ]
    
    const worksheet = XLSX.utils.aoa_to_sheet(headerRows)
    const workbook = XLSX.utils.book_new()
    XLSX.utils.book_append_sheet(workbook, worksheet, reportName.substring(0, 31))
    
    // Auto-width columns
    const colWidths = headers.map((h, i) => {
        const maxLen = Math.max(
            h.length,
            ...rows.map(r => String(r[i] || '').length)
        )
        return { wch: Math.min(maxLen + 2, 50) }
    })
    worksheet['!cols'] = colWidths
    
    // Download with professional filename
    XLSX.writeFile(workbook, filename)
}

function prepareExcelData(type: ReportType, data: any[]): { headers: string[], rows: any[][] } {
    // Define ONLY user-facing columns (no database IDs)
    const columnMaps: Record<ReportType, { key: string, label: string }[]> = {
        'inventory': [
            { key: 'item_name', label: 'Item Name' },
            { key: 'category', label: 'Category' },
            { key: 'stock_available', label: 'Available Stock' },
            { key: 'stock_total', label: 'Total Stock' },
            { key: 'status', label: 'Status' }
        ],
        'logs': [
            { key: 'borrow_date', label: 'Borrow Date/Time' },
            { key: 'borrower_name', label: 'Borrower' },
            { key: 'item_name', label: 'Item' },
            { key: 'quantity', label: 'Qty' },
            { key: 'approved_by_name', label: 'Approved By' },
            { key: 'actual_return_date', label: 'Return Date/Time' },
            { key: 'status', label: 'Status' },
            { key: 'return_condition', label: 'Return Condition' },
            { key: 'return_notes', label: 'Return Notes' }
        ],
        'low-stock': [
            { key: 'item_name', label: 'Item Name' },
            { key: 'category', label: 'Category' },
            { key: 'stock_available', label: 'Current Stock' }
        ],
        'overdue': [
            { key: 'item_name', label: 'Item' },
            { key: 'borrower_name', label: 'Borrower' },
            { key: 'expected_return_date', label: 'Expected Return' },
            { key: 'status', label: 'Status' }
        ],
        'summary': [
            { key: 'category', label: 'Category' },
            { key: 'stock_available', label: 'Available Units' }
        ],
        'expiry-alert': [
            { key: 'item_name', label: 'Item Name' },
            { key: 'brand', label: 'Brand' },
            { key: 'expiry_date', label: 'Expiry Date' },
            { key: 'storage_location', label: 'Location' }
        ],
        'borrower-activity': [
            { key: 'borrow_date', label: 'Date' },
            { key: 'item_name', label: 'Equipment' },
            { key: 'quantity', label: 'Qty' },
            { key: 'status', label: 'Action' },
            { key: 'return_condition', label: 'Return Condition' },
            { key: 'return_notes', label: 'Return Notes' }
        ],
    }
    
    const columns = columnMaps[type] || []
    const headers = columns.map(c => c.label)
    
    // Map ONLY the defined columns (filters out id, user_id, item_id, etc.)
    const rows = data.map(row => 
        columns.map(col => {
            const value = row[col.key]
            // Format dates
            if (col.key.includes('date') && value) {
                return new Date(value).toLocaleString('en-US', { 
                    month: 'short', 
                    day: 'numeric', 
                    year: 'numeric',
                    hour: col.key.includes('_date') ? '2-digit' : undefined,
                    minute: col.key.includes('_date') ? '2-digit' : undefined
                })
            }
            return value || '—'
        })
    )
    
    return { headers, rows }
}

function convertToCSV(data: any[]): string {
    if (!data.length) return ''
    const headers = Object.keys(data[0]).join(',')
    const rows = data.map(row => Object.values(row).join(','))
    return [headers, ...rows].join('\n')
}
