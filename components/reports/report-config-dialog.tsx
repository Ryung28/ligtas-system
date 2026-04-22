import { useState } from 'react'
import { Dialog, DialogContent, DialogHeader, DialogTitle } from '@/components/ui/dialog'
import { Button } from '@/components/ui/button'
import { Label } from '@/components/ui/label'
import { Input } from '@/components/ui/input'
import { Checkbox } from '@/components/ui/checkbox'
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from '@/components/ui/select'
import { Loader2, Printer, Eye, Download } from 'lucide-react'
import type { ReportType, ReportConfig } from './types'
import { generateReport } from './report-generator'
import { toast } from 'sonner'

interface ReportConfigDialogProps {
    reportType: ReportType
    onClose: () => void
    onGenerate: () => void
}

export function ReportConfigDialog({ reportType, onClose, onGenerate }: ReportConfigDialogProps) {
    // SENIOR FIX: Get YYYY-MM-DD in local time without UTC rollover bugs
    const getLocalISODate = (offsetDays = 0) => {
        const date = new Date(Date.now() + offsetDays * 24 * 60 * 60 * 1000);
        return date.toLocaleDateString('en-CA');
    };

    const isHorizontalNeeded = ['logs', 'overdue', 'borrower-activity'].includes(reportType);

    const [config, setConfig] = useState<ReportConfig>({
        dateFrom: getLocalISODate(-30),
        dateTo: getLocalISODate(),
        category: 'all',
        sortOrder: 'latest',
        orientation: isHorizontalNeeded ? 'landscape' : 'portrait',
        status: ['borrowed', 'returned', 'overdue'],
        includeSignatures: true,
        includePageNumbers: true,
        includeWatermark: true,
        density: 'standard',
    })
    const [isLoading, setIsLoading] = useState(false)

    const handlePrint = async () => {
        setIsLoading(true)
        try {
            await generateReport(reportType, config, 'print')
            onGenerate()
        } catch (error) {
            console.error('Failed to generate report:', error)
            toast.error('Failed to generate report. Check your connection.')
        } finally {
            setIsLoading(false)
        }
    }

    const handleExport = async () => {
        setIsLoading(true)
        try {
            await generateReport(reportType, config, 'excel')
            onGenerate()
        } catch (error) {
            console.error('Failed to export report:', error)
            toast.error('Failed to export report. Check your connection.')
        } finally {
            setIsLoading(false)
        }
    }

    return (
        <Dialog open onOpenChange={onClose}>
            <DialogContent className="max-w-md max-h-[95vh] overflow-y-auto">
                <DialogHeader className="pb-2">
                    <DialogTitle>Configure Report</DialogTitle>
                </DialogHeader>
                
                <div className="space-y-4">
                    <div className="grid grid-cols-2 gap-3">
                        <div>
                            <Label className="text-[10px] uppercase font-bold text-slate-500">From Date</Label>
                            <Input
                                type="date"
                                value={config.dateFrom}
                                onChange={(e) => setConfig({ ...config, dateFrom: e.target.value })}
                                className="h-8 text-sm mt-1"
                            />
                        </div>
                        <div>
                            <Label className="text-[10px] uppercase font-bold text-slate-500">To Date</Label>
                            <Input
                                type="date"
                                value={config.dateTo}
                                onChange={(e) => setConfig({ ...config, dateTo: e.target.value })}
                                className="h-8 text-sm mt-1"
                            />
                        </div>
                    </div>

                    {reportType === 'logs' && (
                        <div className="bg-slate-50/50 p-2.5 rounded-lg border border-slate-100">
                            <Label className="text-[10px] uppercase font-bold text-slate-500 mb-2 block">Filters</Label>
                            <div className="grid grid-cols-2 gap-x-4 gap-y-1">
                                {['borrowed', 'returned', 'overdue', 'pending'].map((status) => (
                                    <div key={status} className="flex items-center gap-2">
                                        <Checkbox
                                            checked={config.status?.includes(status)}
                                            onCheckedChange={(checked) => {
                                                const newStatus = checked
                                                    ? [...(config.status || []), status]
                                                    : config.status?.filter(s => s !== status) || []
                                                setConfig({ ...config, status: newStatus })
                                            }}
                                        />
                                        <span className="text-xs capitalize">{status}</span>
                                    </div>
                                ))}
                            </div>
                            
                            <div className="mt-3">
                                <Input
                                    placeholder="Search borrower name..."
                                    value={config.borrower || ''}
                                    onChange={(e) => setConfig({ ...config, borrower: e.target.value })}
                                    className="h-8 text-xs bg-white"
                                />
                            </div>
                        </div>
                    )}

                    <div className="grid grid-cols-2 gap-3">
                        <div>
                            <Label className="text-[10px] uppercase font-bold text-slate-500">Category</Label>
                            <Select value={config.category} onValueChange={(value) => setConfig({ ...config, category: value })}>
                                <SelectTrigger className="h-8 text-sm mt-1">
                                    <SelectValue />
                                </SelectTrigger>
                                <SelectContent>
                                    <SelectItem value="all">All</SelectItem>
                                    <SelectItem value="medical">Medical</SelectItem>
                                    <SelectItem value="rescue">Rescue</SelectItem>
                                    <SelectItem value="communication">Comm</SelectItem>
                                </SelectContent>
                            </Select>
                        </div>
                        <div>
                            <Label className="text-[10px] uppercase font-bold text-slate-500">Sort Order</Label>
                            <Select 
                                value={config.sortOrder} 
                                onValueChange={(value: 'latest' | 'oldest') => setConfig({ ...config, sortOrder: value as any })}
                            >
                                <SelectTrigger className="h-8 text-sm mt-1">
                                    <SelectValue />
                                </SelectTrigger>
                                <SelectContent>
                                    <SelectItem value="latest">Latest</SelectItem>
                                    <SelectItem value="oldest">Oldest</SelectItem>
                                </SelectContent>
                            </Select>
                        </div>
                    </div>

                    <div className="grid grid-cols-2 gap-3">
                        <div>
                            <Label className="text-[10px] uppercase font-bold text-slate-500">Orientation</Label>
                            <Select
                                value={config.orientation}
                                onValueChange={(value: 'portrait' | 'landscape') =>
                                    setConfig({ ...config, orientation: value })
                                }
                            >
                                <SelectTrigger className="h-8 text-sm mt-1">
                                    <SelectValue />
                                </SelectTrigger>
                                <SelectContent>
                                    <SelectItem value="portrait">Portrait</SelectItem>
                                    <SelectItem value="landscape">Landscape</SelectItem>
                                </SelectContent>
                            </Select>
                        </div>
                        <div>
                            <Label className="text-[10px] uppercase font-bold text-slate-500">Density</Label>
                            <Select
                                value={config.density ?? 'standard'}
                                onValueChange={(value: 'compact' | 'standard' | 'tactical') =>
                                    setConfig({ ...config, density: value })
                                }
                            >
                                <SelectTrigger className="h-8 text-sm mt-1">
                                    <SelectValue />
                                </SelectTrigger>
                                <SelectContent>
                                    <SelectItem value="compact">Compact</SelectItem>
                                    <SelectItem value="standard">Standard</SelectItem>
                                    <SelectItem value="tactical">Tactical</SelectItem>
                                </SelectContent>
                            </Select>
                        </div>
                    </div>

                    <div className="space-y-1.5 pt-2 border-t border-slate-100">
                        <Label className="text-[10px] uppercase font-bold text-slate-500">Document Settings</Label>
                        <div className="grid grid-cols-1 gap-1">
                            {[
                                { id: 'includeSignatures', label: 'Include Certification' },
                                { id: 'includePageNumbers', label: 'Page Numbers' },
                                { id: 'includeWatermark', label: 'Confidential Watermark' },
                            ].map((item) => (
                                <div key={item.id} className="flex items-center gap-2">
                                    <Checkbox
                                        checked={(config as any)[item.id]}
                                        onCheckedChange={(checked) => setConfig({ ...config, [item.id]: !!checked })}
                                    />
                                    <span className="text-xs">{item.label}</span>
                                </div>
                            ))}
                        </div>
                    </div>

                    <div className="flex gap-2 pt-3">
                        <Button onClick={handlePrint} disabled={isLoading} className="flex-1 h-9 font-bold bg-blue-600 hover:bg-blue-700">
                            {isLoading ? <Loader2 className="h-4 w-4 mr-2 animate-spin" /> : <Printer className="h-4 w-4 mr-2" />}
                            {isLoading ? 'GENERATING...' : 'PRINT REPORT'}
                        </Button>
                        <Button onClick={handleExport} disabled={isLoading} variant="outline" className="flex-1 h-9 font-bold border-slate-200">
                            {isLoading ? <Loader2 className="h-4 w-4 mr-2 animate-spin" /> : <Download className="h-4 w-4 mr-2" />}
                            EXCEL
                        </Button>
                    </div>
                </div>
            </DialogContent>
        </Dialog>
    )
}
