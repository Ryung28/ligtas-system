import * as XLSX from 'xlsx'
import type { ReportType, ReportConfig } from './types'

export async function exportToExcel(type: ReportType, data: any[], config: ReportConfig) {
    const { headers, rows } = prepareExcelData(type, data)
    const reportName = type.toUpperCase().replace('-', '_')
    const filename = `CDRRMO_${reportName}_${new Date().toISOString().split('T')[0]}.xlsx`
    
    const headerRows = [
        ['REPUBLIC OF THE PHILIPPINES'],
        ['OROQUIETA CITY'],
        ['CITY DISASTER RISK REDUCTION & MANAGEMENT OFFICE'],
        [],
        [reportName.replace('_', ' ') + ' REPORT'],
        [`Generated: ${new Date().toLocaleString()}`],
        [],
        headers,
        ...rows
    ]
    
    const worksheet = XLSX.utils.aoa_to_sheet(headerRows)
    const workbook = XLSX.utils.book_new()
    XLSX.utils.book_append_sheet(workbook, worksheet, 'Data')
    
    // Auto-width
    const wscols = headers.map((h, i) => ({ wch: Math.max(h.length, 20) }))
    worksheet['!cols'] = wscols
    
    XLSX.writeFile(workbook, filename)
}

function prepareExcelData(type: ReportType, data: any[]): { headers: string[], rows: any[][] } {
    const registryCols = [
        { key: 'item_name', label: 'Item Name' },
        { key: 'category', label: 'Category' },
        { key: 'stock_available', label: 'Available Stock' },
        { key: 'storage_location', label: 'Storage Location' },
        { key: 'status', label: 'Status' }
    ]

    const logsCols = [
        { key: 'borrow_date', label: 'Date' },
        { key: 'borrower_name', label: 'Borrower Name' },
        { key: 'item_name', label: 'Equipment' },
        { key: 'quantity', label: 'Quantity' },
        { key: 'status', label: 'Status' }
    ]
    
    const columnMaps: Record<string, { key: string, label: string }[]> = {
        'inventory': registryCols,
        'low-stock': registryCols,
        'summary': registryCols,
        'expiry-alert': [
            { key: 'item_name', label: 'Item Name' },
            { key: 'brand', label: 'Brand' },
            { key: 'expiry_date', label: 'Expiry Date' }
        ],
        'logs': logsCols,
        'overdue': logsCols,
        'borrower-activity': logsCols
    }
    
    const columns = columnMaps[type] || registryCols
    const headers = columns.map(c => c.label)
    const rows = data.map(row => columns.map(col => {
        const val = row[col.key]
        if (col.key.includes('date') && val) return new Date(val).toLocaleDateString()
        return val || '—'
    }))
    
    return { headers, rows }
}
