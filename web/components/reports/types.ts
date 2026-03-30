export type ReportType = 
    | 'inventory' 
    | 'logs' 
    | 'low-stock' 
    | 'summary'
    | 'overdue'
    | 'expiry-alert'
    | 'borrower-activity'

export interface ReportStats {
    totalItems: number
    lowStock: number
    borrowed: number
    overdue: number
    expiringSoon: number
}

export interface ReportConfig {
    dateFrom?: string
    dateTo?: string
    category?: string
    status?: string[]
    borrower?: string
    includeSignatures?: boolean
    includePageNumbers?: boolean
    includeWatermark?: boolean
}

export interface ReportDefinition {
    type: ReportType
    title: string
    subtitle: string
    description: string
    includes: string[]
    icon: any
    color: 'blue' | 'emerald' | 'orange' | 'violet' | 'red' | 'indigo'
    category: 'inventory' | 'transaction' | 'management'
}
