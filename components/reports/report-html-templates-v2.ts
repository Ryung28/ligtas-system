import type { ReportType, ReportConfig } from './types'

type ReportRenderer = (data: any[], density?: string) => string

/** 🏛️ UTILITY: Prevents XSS */
function e(str: unknown): string {
    if (str == null) return '—'
    return String(str)
        .replace(/&/g, '&amp;')
        .replace(/</g, '&lt;')
        .replace(/>/g, '&gt;')
        .replace(/"/g, '&quot;')
        .replace(/'/g, '&#39;')
}

function formatDate(value: string | null | undefined): string {
    if (!value) return '—'
    const d = new Date(value)
    if (Number.isNaN(d.getTime())) return '—'
    return d.toLocaleDateString('en-US', { month: 'short', day: 'numeric', year: 'numeric' })
}

function formatDateTime(value: string | null | undefined): string {
    if (!value) return '—'
    const d = new Date(value)
    if (Number.isNaN(d.getTime())) return '—'
    return d.toLocaleString('en-US', { month: 'short', day: 'numeric', year: 'numeric', hour: '2-digit', minute: '2-digit' })
}

/** 🏷️ TACTICAL STATUS BADGE */
function statusBadge(status: string): string {
    const s = String(status || '').trim().toLowerCase()
    let bgColor = '#64748b' 
    
    if (s === 'borrowed' || s === 'low') bgColor = '#ea580c'
    else if (s === 'returned' || s === 'ready' || s === 'ok') bgColor = '#16a34a'
    else if (s === 'overdue' || s === 'expired') bgColor = '#dc2626'
    else if (s === 'pending' || s === 'reserved') bgColor = '#2563eb'

    return `<span class="badge" style="background-color:${bgColor} !important; color: white !important;">${e(status).toUpperCase()}</span>`
}

/** 📂 RENDERING SLOT: Inventory / Low Stock (CATEGORY GROUPING) */
function renderInventoryLikeTable(data: any[]): string {
    const sorted = [...data].sort((a, b) => 
        String(a.category || "").localeCompare(b.category || "") || String(a.item_name).localeCompare(b.item_name)
    )

    let rows = ""
    let currentCategory = ""

    sorted.forEach(i => {
        if (String(i.category || "UNSPECIFIED").toUpperCase() !== currentCategory) {
            currentCategory = String(i.category || "UNSPECIFIED").toUpperCase()
            rows += `
                <tr class="category-row">
                    <td colspan="5" style="background:#f1f5f9; font-weight:900; color:#475569; padding: 10px 12px; font-size: 8pt; letter-spacing: 0.5px; border-bottom: 2px solid #e2e8f0;">
                        📂 ${currentCategory}
                    </td>
                </tr>`
        }

        const target = Number(i.target_stock ?? 0)
        const threshold = Number(i.low_stock_threshold ?? 0)
        const available = i.stock_available ?? 0
        const alertEnabled = i.restock_alert_enabled !== false
        
        const isLow = alertEnabled && target > 0 && threshold > 0 
            ? available <= Math.ceil((target * threshold) / 100)
            : false
        
        rows += `<tr>
            <td style="font-weight:700;">${e(i.item_name)}</td>
            <td style="color:#64748b;">${e(i.category)}</td>
            <td style="font-weight:900; text-align: center;">${i.stock_available ?? 0}</td>
            <td style="text-align: center;">
                <div style="display: flex; justify-content: center; width: 100%;">
                    ${statusBadge(isLow ? 'LOW' : 'READY')}
                </div>
            </td>
            <td style="color:#64748b;">${e(i.storage_location)}</td>
        </tr>`
    })

    return `
    <table>
        <colgroup>
            <col style="width: 32%;">
            <col style="width: 15%;">
            <col style="width: 10%;">
            <col style="width: 15%;">
            <col style="width: 28%;">
        </colgroup>
        <thead>
            <tr>
                <th>Asset Name</th>
                <th>Category</th>
                <th style="text-align: center;">Stock</th>
                <th style="text-align: center;">Status</th>
                <th>Location</th>
            </tr>
        </thead>
        <tbody>
            ${rows}
        </tbody>
    </table>`
}

function renderExpiryAlertTable(data: any[]): string {
    return `<table><thead><tr><th style="width:40%">Consumable Item</th><th>Brand</th><th>Expiry Date</th><th style="width:15%; text-align:center;">Status</th></tr></thead><tbody>
        ${data
            .map((i) => {
                const days = Math.floor((new Date(i.expiry_date).getTime() - Date.now()) / (1000 * 60 * 60 * 24))
                const isExpired = days < 0
                return `<tr>
                    <td style="font-weight:600;">${e(i.item_name)}</td>
                    <td>${e(i.brand)}</td>
                    <td style="color:${isExpired ? '#dc2626' : 'inherit'}; font-weight:${isExpired ? '700' : '400'}">${formatDate(i.expiry_date)}</td>
                    <td style="text-align:center;">${statusBadge(isExpired ? 'EXPIRED' : days < 30 ? 'SOON' : 'VALID')}</td>
                </tr>`
            })
            .join('')}
    </tbody></table>`
}

function renderLogsTable(data: any[]): string {
    return `
    <table>
        <colgroup>
            <col style="width: 8%;">
            <col style="width: 9%;">
            <col style="width: 10%;">
            <col style="width: 3%;">
            <col style="width: 8%;">
            <col style="width: 8%;">
            <col style="width: 8%;">
            <col style="width: 8%;">
            <col style="width: 8%;">
            <col style="width: 9%;">
            <col style="width: 8%;">
            <col style="width: 13%;">
        </colgroup>
        <thead>
            <tr>
                <th>DATE/TIME</th><th>BORROWER</th><th>ITEM</th><th style="text-align:center;">QTY</th><th>AUTH</th><th>ISSUED</th><th>TAKEN BY</th><th>RETURN</th><th>RETURNER</th><th>STAFF RCVR</th><th style="text-align:center;">STATUS</th><th>AUDIT</th>
            </tr>
        </thead>
        <tbody>
            ${data.map((l) => `<tr>
                <td style="font-size: 7.5pt;">${formatDateTime(l.borrow_date || l.created_at)}</td>
                <td style="font-weight:700;">${e(l.borrower_name)}</td>
                <td>${e(l.item_name)}</td>
                <td style="font-weight:800; text-align:center;">${l.quantity ?? '—'}</td>
                <td>${e(l.approved_by_name || l.released_by_name || l.handed_by)}</td>
                <td>${e(l.handed_by || l.released_by_name)}</td>
                <td style="font-weight:600; color:#1e293b;">${e(l.physically_received_by || l.borrower_name)}</td>
                <td style="font-size: 7.5pt; color: ${!l.actual_return_date ? '#64748b' : 'inherit'}">
                    ${l.actual_return_date 
                        ? formatDateTime(l.actual_return_date) 
                        : (l.expected_return_date ? `DUE: ${formatDate(l.expected_return_date)}` : '—')}
                </td>
                <td>${e(l.returned_by_name)}</td>
                <td>${e(l.received_by_name)}</td>
                <td style="text-align:center;">${statusBadge(l.status)}</td>
                <td style="font-size:6.5pt; font-style:italic; color:#64748b; line-height: 1;">${l.status === 'returned' ? `"${e(l.return_condition || 'GOOD')}"` : 'AWAITS'}</td>
            </tr>`).join('')}
        </tbody>
    </table>`
}

function renderOverdueTable(data: any[]): string {
    return `
    <table>
        <colgroup>
            <col style="width: 25%;">
            <col style="width: 20%;">
            <col style="width: 15%;">
            <col style="width: 15%;">
            <col style="width: 15%;">
            <col style="width: 10%;">
        </colgroup>
        <thead>
            <tr>
                <th>Item Name</th>
                <th>Borrower</th>
                <th>Expected Date</th>
                <th>Return Date</th>
                <th style="text-align:center;">Days Overdue</th>
                <th style="text-align:center;">Status</th>
            </tr>
        </thead>
        <tbody>
            ${data.map((l) => {
                const expected = new Date(l.expected_return_date)
                const actual = l.actual_return_date ? new Date(l.actual_return_date) : new Date()
                const diffTime = actual.getTime() - expected.getTime()
                const diffDaysRaw = Math.ceil(diffTime / (1000 * 60 * 60 * 24))
                const diffDays = diffDaysRaw > 0 ? diffDaysRaw : 0
                
                const isStillOut = ['borrowed', 'overdue'].includes(l.status)
                const isLateReturn = l.status === 'returned' && diffDays > 0
                
                let displayStatus = 'OVERDUE'
                let statusColor = '#dc2626' // Red
                
                if (isLateReturn) {
                    displayStatus = 'LATE RETURN'
                    statusColor = '#ea580c' // Orange
                }

                return `<tr>
                    <td style="font-weight:700;">${e(l.item_name)}</td>
                    <td>
                        <div style="font-weight:600;">${e(l.borrower_name)}</div>
                        <div style="font-size:7pt; color:#64748b;">${e(l.borrower_contact)}</div>
                    </td>
                    <td>${formatDate(l.expected_return_date)}</td>
                    <td style="color:${isStillOut ? '#ef4444' : 'inherit'}; font-weight:${isStillOut ? '700' : '400'}">
                        ${isStillOut ? `DUE: ${formatDate(l.expected_return_date)}` : formatDate(l.actual_return_date)}
                    </td>
                    <td style="text-align:center; font-weight:900; color:#dc2626;">${diffDays} DAYS</td>
                    <td style="text-align:center;">
                        <span class="badge" style="background-color:${statusColor} !important; color: white !important; width: 85px;">${displayStatus}</span>
                    </td>
                </tr>`
            }).join('')}
        </tbody>
    </table>`
}

function renderSimpleBorrowTable(data: any[]): string {
    return `<table><thead><tr><th>Date</th><th>Borrower</th><th>Item</th><th>Qty</th><th style="text-align:center;">Status</th><th>Signature</th></tr></thead><tbody>
        ${data
            .map((l) => `<tr>
                <td>${formatDate(l.borrow_date || l.created_at)}</td>
                <td style="font-weight:600;">${e(l.borrower_name)}</td>
                <td>${e(l.item_name)}</td>
                <td style="font-weight:700;">${l.quantity ?? 0}</td>
                <td style="text-align:center;">${statusBadge(l.status)}</td>
                <td style="border-bottom: 1.5px solid #cbd5e1; width: 80px;"></td>
            </tr>`)
            .join('')}
    </tbody></table>`
}

const RENDERERS: Record<ReportType, ReportRenderer> = {
    inventory: renderInventoryLikeTable,
    'low-stock': renderInventoryLikeTable,
    summary: renderInventoryLikeTable,
    'expiry-alert': renderExpiryAlertTable,
    logs: renderLogsTable,
    overdue: renderOverdueTable,
    'borrower-activity': renderSimpleBorrowTable,
}

function renderReportShell(args: {
    title: string
    reportId: string
    generatedAt: string
    orientation: 'portrait' | 'landscape'
    tableHtml: string
}): string {
    const { title, reportId, generatedAt, orientation, tableHtml } = args

    return `<!DOCTYPE html><html><head><meta charset="UTF-8"><style>
        @page { size: A4 ${orientation}; margin: 8mm; }
        body { font-family: 'Segoe UI', sans-serif; font-size: 10pt; color: #0f172a; padding: 5mm; line-height: 1.3; }
        
        .header { display: flex; align-items: center; border-bottom: 3px solid #dc2626; padding-bottom: 12px; margin-bottom: 20px; }
        .header img { width: 50px; margin-right: 15px; }
        h1 { text-transform: uppercase; font-size: 16pt; font-weight: 900; margin: 0 0 4px 0; color: #0f172a; }
        .subtitle { font-size: 8.5pt; color: #64748b; font-weight: 600; text-transform: uppercase; letter-spacing: 1px; margin-bottom: 12px; }
        
        table { width: 100%; border-collapse: collapse; margin-top: 5px; table-layout: fixed; }
        th { background: #f8fafc; padding: 8px 10px; text-align: left; font-size: 7.5pt; text-transform: uppercase; border-bottom: 2px solid #e2e8f0; color: #475569; font-weight: 800; }
        td { padding: 9px 10px; border-bottom: 1px solid #f1f5f9; font-size: 8pt; color: #1e293b; vertical-align: middle; }
        
        .badge { 
            padding: 3px 0; 
            border-radius: 4px; 
            font-weight: 900; 
            font-size: 6.5pt; 
            display: inline-block; 
            text-align: center;
            width: 68px;
            -webkit-print-color-adjust: exact; 
            print-color-adjust: exact; 
        }

        .footer { margin-top: 40px; text-align: center; font-size: 7pt; color: #94a3b8; border-top: 1px solid #f1f5f9; padding-top: 15px; font-weight: 700; letter-spacing: 0.5px; }
    </style></head><body>
        <div class="header">
            <img src="/resqtrack-logo.jpg" alt="Logo" />
            <div>
                <div style="font-weight:bold; font-size: 7.5pt; color: #475569;">REPUBLIC OF THE PHILIPPINES</div>
                <div style="font-size:15pt; font-weight:900; color: #0f172a;">CDRRMO OROQUIETA</div>
            </div>
        </div>
        <div style="display: flex; justify-content: space-between; font-size: 7.5pt; color: #64748b; margin-bottom: 15px; background: #f8fafc; padding: 6px 10px; border-radius: 4px; border: 1px solid #e2e8f0;">
            <div><strong style="color:#0f172a">REPORT ID:</strong> ${reportId}</div>
            <div><strong style="color:#0f172a">GENERATED:</strong> ${generatedAt}</div>
        </div>
        <h1>${title}</h1>
        <div class="subtitle">Official Operational Asset Records</div>
        ${tableHtml}
        <div class="footer">OFFICIAL CDRRMO RECORD • CONFIDENTIAL • SYSTEM GENERATED</div>
    </body></html>`
}

export function generateReportHTMLV2(type: ReportType, data: any[], config: ReportConfig): string {
    const reportId = `RPT-${new Date().getFullYear()}-${type.substring(0, 3).toUpperCase()}-${Math.random().toString(36).substring(7).toUpperCase()}`
    const currentDate = new Date().toLocaleString('en-US', { month: 'short', day: 'numeric', year: 'numeric', hour: '2-digit', minute: '2-digit' })
    const orientation = config.orientation === 'landscape' ? 'landscape' : 'portrait'

    const renderer = RENDERERS[type]
    const tableHtml = renderer ? renderer(data, config.density) : `<p>No template configured for ${type}</p>`

    return renderReportShell({
        title: `${type.replace('-', ' ').toUpperCase()} REPORT`,
        reportId,
        generatedAt: currentDate,
        orientation,
        tableHtml,
    })
}
