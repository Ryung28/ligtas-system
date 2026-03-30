import { useState } from 'react'
import { Dialog, DialogContent, DialogHeader, DialogTitle } from '@/components/ui/dialog'
import { Button } from '@/components/ui/button'
import { Label } from '@/components/ui/label'
import { Input } from '@/components/ui/input'
import { Checkbox } from '@/components/ui/checkbox'
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from '@/components/ui/select'
import { Printer, Eye, Download } from 'lucide-react'
import type { ReportType, ReportConfig } from './types'
import { generateReport } from './report-generator'

interface ReportConfigDialogProps {
    reportType: ReportType
    onClose: () => void
    onGenerate: () => void
}

export function ReportConfigDialog({ reportType, onClose, onGenerate }: ReportConfigDialogProps) {
    const [config, setConfig] = useState<ReportConfig>({
        dateFrom: new Date(Date.now() - 30 * 24 * 60 * 60 * 1000).toISOString().split('T')[0],
        dateTo: new Date().toISOString().split('T')[0],
        category: 'all',
        status: ['borrowed', 'returned', 'overdue'],
        includeSignatures: true,
        includePageNumbers: true,
        includeWatermark: true,
    })

    const handlePrint = async () => {
        try {
            await generateReport(reportType, config, 'print')
            onGenerate()
        } catch (error) {
            console.error('Failed to generate report:', error)
            alert('Failed to generate report')
        }
    }

    const handleExport = async () => {
        try {
            await generateReport(reportType, config, 'excel')
            onGenerate()
        } catch (error) {
            console.error('Failed to export report:', error)
            alert('Failed to export report')
        }
    }

    return (
        <Dialog open onOpenChange={onClose}>
            <DialogContent className="max-w-md">
                <DialogHeader>
                    <DialogTitle>Configure Report</DialogTitle>
                </DialogHeader>
                
                <div className="space-y-4">
                    <div className="grid grid-cols-2 gap-3">
                        <div>
                            <Label className="text-xs">From Date</Label>
                            <Input
                                type="date"
                                value={config.dateFrom}
                                onChange={(e) => setConfig({ ...config, dateFrom: e.target.value })}
                                className="h-9 text-sm"
                            />
                        </div>
                        <div>
                            <Label className="text-xs">To Date</Label>
                            <Input
                                type="date"
                                value={config.dateTo}
                                onChange={(e) => setConfig({ ...config, dateTo: e.target.value })}
                                className="h-9 text-sm"
                            />
                        </div>
                    </div>

                    {reportType === 'logs' && (
                        <>
                            <div>
                                <Label className="text-xs mb-2 block">Status Filter</Label>
                                <div className="space-y-2">
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
                                            <span className="text-sm capitalize">{status}</span>
                                        </div>
                                    ))}
                                </div>
                            </div>
                            
                            <div>
                                <Label className="text-xs">Filter by Borrower (Optional)</Label>
                                <Input
                                    placeholder="Enter borrower name..."
                                    value={config.borrower || ''}
                                    onChange={(e) => setConfig({ ...config, borrower: e.target.value })}
                                    className="h-9 text-sm"
                                />
                            </div>
                        </>
                    )}

                    <div>
                        <Label className="text-xs">Category</Label>
                        <Select value={config.category} onValueChange={(value) => setConfig({ ...config, category: value })}>
                            <SelectTrigger className="h-9 text-sm">
                                <SelectValue />
                            </SelectTrigger>
                            <SelectContent>
                                <SelectItem value="all">All Categories</SelectItem>
                                <SelectItem value="medical">Medical</SelectItem>
                                <SelectItem value="rescue">Rescue</SelectItem>
                                <SelectItem value="communication">Communication</SelectItem>
                            </SelectContent>
                        </Select>
                    </div>

                    <div className="space-y-2 pt-2 border-t">
                        <Label className="text-xs">Include</Label>
                        <div className="space-y-2">
                            <div className="flex items-center gap-2">
                                <Checkbox
                                    checked={config.includeSignatures}
                                    onCheckedChange={(checked) => setConfig({ ...config, includeSignatures: !!checked })}
                                />
                                <span className="text-sm">Signatures section</span>
                            </div>
                            <div className="flex items-center gap-2">
                                <Checkbox
                                    checked={config.includePageNumbers}
                                    onCheckedChange={(checked) => setConfig({ ...config, includePageNumbers: !!checked })}
                                />
                                <span className="text-sm">Page numbers</span>
                            </div>
                            <div className="flex items-center gap-2">
                                <Checkbox
                                    checked={config.includeWatermark}
                                    onCheckedChange={(checked) => setConfig({ ...config, includeWatermark: !!checked })}
                                />
                                <span className="text-sm">Confidential watermark</span>
                            </div>
                        </div>
                    </div>

                    <div className="flex gap-2 pt-4">
                        <Button onClick={handlePrint} className="flex-1 h-9 text-sm">
                            <Printer className="h-4 w-4 mr-2" />
                            Print
                        </Button>
                        <Button onClick={handleExport} variant="outline" className="flex-1 h-9 text-sm">
                            <Download className="h-4 w-4 mr-2" />
                            Excel
                        </Button>
                    </div>
                </div>
            </DialogContent>
        </Dialog>
    )
}
