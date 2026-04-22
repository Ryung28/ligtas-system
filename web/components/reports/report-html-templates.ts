import type { ReportType, ReportConfig } from './types'

/** 🏛️ UTILITY: Prevents XSS when injecting user data */
function e(str: unknown): string {
    if (str == null) return '—'
    return String(str).replace(/&/g, '&amp;').replace(/</g, '&lt;').replace(/>/g, '&gt;').replace(/"/g, '&quot;').replace(/'/g, '&#39;');
}

/** 🏛️ THE SHELL: Centralized Branding, CSS, and Layout */
export function generateReportHTML(type: ReportType, data: any[], config: ReportConfig): string {
    const reportId = `RPT-${new Date().getFullYear()}-${new Date().getMonth()+1}${new Date().getDate()}-${type.substring(0,3).toUpperCase()}`
    const currentDate = new Date().toLocaleString('en-US', { month: 'short', day: 'numeric', year: 'numeric', hour: 'numeric', minute: 'numeric', hour12: true })
    
    // 🧮 DENSITY SCALING
    const density = config.density || 'standard';
    const s = {
        compact: { base: '10px', table: '9px', pad: '4px', logo: '45px', h1: '14px', bar: '2.5px' },
        standard: { base: '12px', table: '11px', pad: '6px', logo: '55px', h1: '16px', bar: '3.5px' },
        tactical: { base: '14px', table: '12px', pad: '10px', logo: '65px', h1: '20px', bar: '4.5px' }
    }[density];

    const tableHTML = generateTableContent(type, data, s);

    return `<!DOCTYPE html><html><head><meta charset="UTF-8"><style>
        @page { margin: 8mm; }
        body { font-family: 'Segoe UI', Tahoma, sans-serif; font-size: ${s.base}; color: #0f172a; padding: 0; line-height: 1.4; }
        
        /* 🏛️ OFFICIAL HEADER */
        .official-header { text-align: center; position: relative; margin-bottom: 10px; }
        .official-header img { position: absolute; left: 0; top: 10px; width: ${s.logo}; height: auto; }
        .city-text { font-size: ${s.h1}; font-weight: 900; color: #0f172a; text-transform: uppercase; margin-bottom: 1px; }
        .office-text { font-size: ${s.base}; font-weight: 700; color: #dc2626; text-transform: uppercase; margin-bottom: 8px; }
        .red-bar { border-bottom: ${s.bar} solid #dc2626; width: 100%; margin-bottom: 15px; }
        
        /* 📊 COMMON ELEMENTS */
        .meta-box { background: #f1f5f9; border: 1px solid #e2e8f0; border-radius: 6px; padding: 8px 12px; display: flex; gap: 20px; color: #475569; font-size: calc(${s.base} - 1px); margin-bottom: 15px; }
        .meta-label { font-weight: 800; color: #1e293b; }
        h1.report-title { font-size: ${s.h1}; font-weight: 900; text-transform: uppercase; color: #0f172a; margin: 15px 0 10px 0; border-left: 5px solid #dc2626; padding-left: 10px; }
        
        /* 📅 TABLE CORE */
        table { width: 100%; border-collapse: collapse; table-layout: fixed; }
        th { background: #f1f5f9; padding: ${s.pad}; text-align: left; font-size: calc(${s.base} - 3px); text-transform: uppercase; border-bottom: 2px solid #cbd5e1; color: #334155; font-weight: 900; }
        td { padding: ${s.pad}; border-bottom: 1px solid #e2e8f0; font-size: calc(${s.table} - 1px); color: #1e293b; vertical-align: middle; overflow: hidden; text-overflow: ellipsis; }
        
        /* 🏷️ SUB-HEADERS (CATEGORY GROUPING) */
        .category-row { background: #f8fafc; }
        .category-row td { font-weight: 900; color: #64748b; text-transform: uppercase; font-size: calc(${s.base} - 2px); letter-spacing: 1px; border-bottom: 2px solid #e2e8f0; background: #f1f5f9; }

        /* 🛡️ STATUS BADGES */
        .status-badge { 
            padding: 4px 6px; 
            border-radius: 4px; 
            font-weight: 900; 
            font-size: calc(${s.base} - 4px); 
            color: #ffffff !important; 
            -webkit-print-color-adjust: exact;
            display: inline-block; 
            width: 100%; 
            max-width: 80px;
            text-align: center; 
            text-transform: uppercase;
        }

        /* ✍️ SIGNATURES */
        .certification { margin-top: 50px; page-break-inside: avoid; }
        .cert-header { font-size: ${s.base}; font-weight: 900; text-transform: uppercase; color: #1f2937; margin-bottom: 30px; border-bottom: 1px solid #e5e7eb; padding-bottom: 5px; }
        .sig-row { display: flex; flex-direction: row; width: 100%; gap: 40px; }
        .sig-block { flex: 1; text-align: center; }
        .sig-line { border-top: 1.5px solid #1f2937; width: 100%; margin-bottom: 8px; }
        .sig-label { font-size: calc(${s.base} - 2px); font-weight: 700; text-transform: uppercase; color: #374151; }

    </style></head><body>
        <div class="official-header">
            <img src="/resqtrack-logo.jpg" alt="Seal" />
            <div style="font-size:calc(${s.base} - 2px); font-weight:600; color:#475569; text-transform:uppercase;">Republic of the Philippines</div>
            <div class="city-text">Oroquieta City</div>
            <div class="office-text">City Disaster Risk Reduction & Management Office</div>
        </div>
        <div class="red-bar"></div>
        <div class="meta-box">
            <div><span class="meta-label">ID:</span> ${reportId}</div>
            <div><span class="meta-label">DATE:</span> ${currentDate}</div>
        </div>
        <h1 class="report-title">${type.replace('-', ' ')}</h1>
        ${tableHTML}
        ${config.includeSignatures ? `
        <div class="certification">
            <div class="cert-header">Document Certification</div>
            <div class="sig-row">
                <div class="sig-block"><div style="height:40px;"></div><div class="sig-line"></div><div class="sig-label">Prepared By</div></div>
                <div class="sig-block"><div style="height:40px;"></div><div class="sig-line"></div><div class="sig-label">Reviewed By</div></div>
                <div class="sig-block"><div style="height:40px;"></div><div class="sig-line"></div><div class="sig-label">Approved By</div></div>
            </div>
        </div>` : ''}
    </body></html>`
}

/** 📊 SLOT DISPATCHER: Renders data based on report type */
function generateTableContent(type: ReportType, data: any[], s: any): string {
    const fD = (d: string) => d ? new Date(d).toLocaleString('en-US', { month: 'short', day: 'numeric', year: 'numeric', hour: '2-digit', minute: '2-digit' }) : '—'

    switch (type) {
        case 'logs':
        case 'borrower-activity':
            return renderLogsTable(data, s, fD);
        case 'inventory':
        case 'summary':
        case 'low-stock':
            return renderInventoryTable(data, s);
        case 'expiry-alert':
            return renderExpiryTable(data, s);
        case 'overdue':
            return renderOverdueTable(data, s, fD);
        default:
            return `<p>Template not found.</p>`;
    }
}

/** 📂 SLOT: Inventory / Low Stock (GROUPED BY CATEGORY) */
function renderInventoryTable(data: any[], s: any): string {
    // Sort logic: Category First, then Item Name
    const sorted = [...data].sort((a, b) => 
        String(a.category || "").localeCompare(b.category || "") || String(a.item_name).localeCompare(b.item_name)
    );

    let rows = "";
    let currentCategory = "";

    sorted.forEach(i => {
        if (i.category !== currentCategory) {
            currentCategory = i.category;
            rows += `<tr class="category-row"><td colspan="5">${e(currentCategory || "UNSPECIFIED CATEGORY")}</td></tr>`;
        }
        
        const isLow = i.stock_available <= (i.low_stock_threshold || 10);
        rows += `<tr>
            <td style="font-weight:700; width:35%;">${e(i.item_name)}</td>
            <td style="width:20%; color:#64748b;">${e(i.category)}</td>
            <td style="font-weight:800; width:10%;">${i.stock_available}</td>
            <td style="width:15%;">
                <span class="status-badge" style="background-color:${isLow ? '#ea580c' : '#16a34a'} !important;">
                    ${isLow ? 'LOW' : 'OK'}
                </span>
            </td>
            <td>${e(i.storage_location)}</td>
        </tr>`;
    });

    return `<table><thead><tr>
        <th style="width:35%">Asset Name</th>
        <th style="width:20%">Category</th>
        <th style="width:10%">Stock</th>
        <th style="width:15%">Status</th>
        <th style="width:20%">Location</th>
    </tr></thead><tbody>${rows}</tbody></table>`;
}

/** 📂 SLOT: Transaction Logs (11 Columns, High Intensity) */
function renderLogsTable(data: any[], s: any, fD: Function): string {
    return `<table><thead><tr>
        <th style="width:9%">BORROW DATE</th><th style="width:10%">BORROWER</th><th style="width:12%">ITEM</th><th style="width:4%">QTY</th><th style="width:10%">AUTH</th><th style="width:10%">ISSUED</th><th style="width:9%">RETURN DATE</th><th style="width:10%">RETURNED BY</th><th style="width:10%">RECEIVED BY</th><th style="width:7%">STATUS</th><th style="width:9%">AUDIT</th>
    </tr></thead><tbody>
        ${data.map(l => `<tr>
            <td>${fD(l.borrow_date || l.created_at)}</td>
            <td style="font-weight:700;">${e(l.borrower_name)}</td>
            <td>${e(l.item_name)}</td>
            <td style="font-weight:800; text-align:center;">${l.quantity}</td>
            <td>${e(l.approved_by_name)}</td>
            <td>${e(l.released_by_name)}</td>
            <td>${fD(l.actual_return_date)}</td>
            <td>${e(l.returned_by_name)}</td>
            <td>${e(l.received_by_name)}</td>
            <td><span class="status-badge" style="background-color:${l.status === 'borrowed' ? '#ea580c' : l.status === 'returned' ? '#16a34a' : '#dc2626'} !important;">${e(l.status)}</span></td>
            <td style="font-size:calc(${s.table} - 2px); font-style:italic; color:#475569;">
                ${l.status === 'returned' ? `"${e(l.return_condition || 'GOOD')}"` : 'AWAITS RETURN'}
            </td>
        </tr>`).join('')}
    </tbody></table>`;
}

/** 📂 SLOT: Expiry Alerts */
function renderExpiryTable(data: any[], s: any): string {
    return `<table><thead><tr><th style="width:35%">Item Name</th><th style="width:20%">Brand</th><th>Stock</th><th>Expiry</th><th style="text-align:center;">Days</th><th style="text-align:center;">Status</th></tr></thead><tbody>
        ${data.map(i => {
            const days = Math.floor((new Date(i.expiry_date).getTime() - Date.now()) / (1000 * 60 * 60 * 24));
            return `<tr>
                <td style="font-weight:700;">${e(i.item_name)}</td><td>${e(i.brand)}</td><td style="font-weight:800;">${i.stock_available}</td><td style="font-weight:700;">${new Date(i.expiry_date).toLocaleDateString()}</td><td style="text-align:center; font-weight:900;">${days}</td><td style="text-align:center;"><span class="status-badge" style="background-color:${days < 0 ? '#991b1b' : '#dc2626'} !important;">${days < 0 ? 'EXPIRED' : 'ALERT'}</span></td>
            </tr>`;
        }).join('')}
    </tbody></table>`;
}

/** 📂 SLOT: Overdue Reports */
function renderOverdueTable(data: any[], s: any, fD: Function): string {
    return `<table><thead><tr><th style="width:25%">Item Name</th><th style="width:20%">Borrower</th><th style="width:15%">Contact</th><th style="width:20%">Expected Return</th><th style="text-align:center;">Days</th><th style="text-align:center;">Status</th></tr></thead><tbody>
        ${data.map(l => {
            const days = Math.floor((Date.now() - new Date(l.expected_return_date).getTime()) / (1000 * 60 * 60 * 24));
            return `<tr>
                <td style="font-weight:700;">${e(l.item_name)}</td><td style="font-weight:700;">${e(l.borrower_name)}</td><td>${e(l.borrower_contact)}</td><td style="color:#b91c1c; font-weight:700;">${fD(l.expected_return_date)}</td><td style="text-align:center; font-weight:900; color:#b91c1c;">${days}</td><td style="text-align:center;"><span class="status-badge" style="background-color:#dc2626 !important;">OVERDUE</span></td>
            </tr>`;
        }).join('')}
    </tbody></table>`;
}
