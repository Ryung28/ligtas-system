'use client'

import { useState } from 'react'
import { Plus, Upload, Save, Trash2, AlertCircle } from 'lucide-react'
import { Button } from '@/components/ui/button'
import {
    Dialog,
    DialogContent,
    DialogDescription,
    DialogFooter,
    DialogHeader,
    DialogTitle,
    DialogTrigger,
} from '@/components/ui/dialog'
import { Input } from '@/components/ui/input'
import {
    Select,
    SelectContent,
    SelectItem,
    SelectTrigger,
    SelectValue,
} from '@/components/ui/select'
import { bulkAddItems } from '@/app/actions/inventory'
import { toast } from 'sonner'

interface BulkItemRow {
    id: string // internal render key
    name: string
    category: string
    stock_total: string
    status: string
}

const CATEGORIES = ['Rescue', 'Medical', 'Comms', 'Vehicles', 'Office', 'Tools', 'PPE', 'Logistics']

export function BulkAddDialog() {
    const [open, setOpen] = useState(false)
    const [isSubmitting, setIsSubmitting] = useState(false)
    const [rows, setRows] = useState<BulkItemRow[]>([
        { id: '1', name: '', category: 'Rescue', stock_total: '1', status: 'Good' },
        { id: '2', name: '', category: 'Rescue', stock_total: '1', status: 'Good' },
        { id: '3', name: '', category: 'Rescue', stock_total: '1', status: 'Good' },
    ])

    const addRow = () => {
        const lastCategory = rows.length > 0 ? rows[rows.length - 1].category : 'Rescue'
        setRows(prev => [
            ...prev,
            { id: Math.random().toString(36).substr(2, 9), name: '', category: lastCategory, stock_total: '1', status: 'Good' }
        ])
    }

    const removeRow = (id: string) => {
        if (rows.length === 1) return // Don't remove last row
        setRows(prev => prev.filter(r => r.id !== id))
    }

    const updateRow = (id: string, field: keyof BulkItemRow, value: string) => {
        setRows(prev => prev.map(row =>
            row.id === id ? { ...row, [field]: value } : row
        ))
    }

    const handleSubmit = async () => {
        // Filter out empty rows
        const validRows = rows.filter(r => r.name.trim() !== '')
        if (validRows.length === 0) {
            toast.error("Please enter at least one item name.")
            return
        }

        setIsSubmitting(true)

        // Convert types
        const payload = validRows.map(r => ({
            name: r.name,
            category: r.category,
            stock_total: parseInt(r.stock_total) || 0,
            status: r.status
        }))

        const result = await bulkAddItems(payload)

        setIsSubmitting(false)

        if (result.success) {
            toast.success(result.message)
            setOpen(false)
            // Reset form
            setRows([
                { id: '1', name: '', category: 'Rescue', stock_total: '1', status: 'Good' },
                { id: '2', name: '', category: 'Rescue', stock_total: '1', status: 'Good' },
                { id: '3', name: '', category: 'Rescue', stock_total: '1', status: 'Good' },
            ])
        } else {
            toast.error(result.error)
        }
    }

    return (
        <Dialog open={open} onOpenChange={setOpen}>
            <DialogTrigger asChild>
                <Button variant="outline" className="gap-2 border-dashed border-gray-300 hover:border-blue-400 hover:bg-blue-50 text-blue-600">
                    <Upload className="h-4 w-4" />
                    Batch Entry
                </Button>
            </DialogTrigger>
            <DialogContent className="sm:max-w-[900px] h-[80vh] flex flex-col p-0 gap-0 overflow-hidden">
                <DialogHeader className="p-6 pb-2">
                    <DialogTitle className="flex items-center gap-2 text-xl font-heading">
                        <Upload className="h-5 w-5 text-blue-600" />
                        Batch Item Entry
                    </DialogTitle>
                    <DialogDescription>
                        Quickly add multiple items to inventory. Empty name rows will be ignored.
                    </DialogDescription>
                </DialogHeader>

                {/* Scrollable Grid Area */}
                <div className="flex-1 overflow-y-auto p-6 pt-0">
                    <div className="border rounded-lg overflow-hidden shadow-sm">
                        <div className="grid grid-cols-12 gap-0 bg-gray-50 border-b text-xs font-semibold text-gray-500 uppercase tracking-wider">
                            <div className="col-span-1 p-3 text-center">#</div>
                            <div className="col-span-4 p-3">Item Name <span className="text-red-500">*</span></div>
                            <div className="col-span-3 p-3">Category</div>
                            <div className="col-span-2 p-3">Stock</div>
                            <div className="col-span-1 p-3">Status</div>
                            <div className="col-span-1 p-3 text-center">Action</div>
                        </div>

                        <div className="divide-y divide-gray-100 bg-white">
                            {rows.map((row, index) => (
                                <div key={row.id} className="grid grid-cols-12 gap-0 items-center hover:bg-gray-50/50 transition-colors group">
                                    <div className="col-span-1 p-2 text-center text-xs text-gray-400 font-mono">
                                        {index + 1}
                                    </div>
                                    <div className="col-span-4 p-2">
                                        <Input
                                            value={row.name}
                                            onChange={(e) => updateRow(row.id, 'name', e.target.value)}
                                            placeholder="Item Name"
                                            className="h-8 border-transparent hover:border-gray-200 focus:border-blue-500 bg-transparent px-2"
                                        />
                                    </div>
                                    <div className="col-span-3 p-2">
                                        <Select value={row.category} onValueChange={(val) => updateRow(row.id, 'category', val)}>
                                            <SelectTrigger className="h-8 border-transparent hover:border-gray-200 focus:border-blue-500 bg-transparent">
                                                <SelectValue />
                                            </SelectTrigger>
                                            <SelectContent>
                                                {CATEGORIES.map(c => <SelectItem key={c} value={c}>{c}</SelectItem>)}
                                            </SelectContent>
                                        </Select>
                                    </div>
                                    <div className="col-span-2 p-2">
                                        <Input
                                            type="number"
                                            min="1"
                                            value={row.stock_total}
                                            onChange={(e) => updateRow(row.id, 'stock_total', e.target.value)}
                                            onKeyDown={(e) => {
                                                if (e.key === 'Enter') {
                                                    e.preventDefault()
                                                    addRow()
                                                }
                                            }}
                                            className="h-8 border-transparent hover:border-gray-200 focus:border-blue-500 bg-transparent text-right px-2"
                                        />
                                    </div>
                                    <div className="col-span-1 p-2">
                                        <Select value={row.status} onValueChange={(val) => updateRow(row.id, 'status', val)}>
                                            <SelectTrigger className="h-8 border-transparent hover:border-gray-200 focus:border-blue-500 bg-transparent">
                                                <SelectValue />
                                            </SelectTrigger>
                                            <SelectContent>
                                                <SelectItem value="Good">Good</SelectItem>
                                                <SelectItem value="Damaged">Damaged</SelectItem>
                                                <SelectItem value="Maintenance">Maint.</SelectItem>
                                            </SelectContent>
                                        </Select>
                                    </div>
                                    <div className="col-span-1 p-2 text-center opacity-0 group-hover:opacity-100 transition-opacity">
                                        <Button
                                            variant="ghost"
                                            size="icon"
                                            className="h-7 w-7 text-gray-400 hover:text-red-600"
                                            onClick={() => removeRow(row.id)}
                                            disabled={rows.length === 1}
                                        >
                                            <Trash2 className="h-4 w-4" />
                                        </Button>
                                    </div>
                                </div>
                            ))}
                        </div>
                    </div>

                    <div className="mt-4 flex justify-center">
                        <Button variant="outline" onClick={addRow} className="border-dashed gap-2 text-gray-600 w-full sm:w-auto">
                            <Plus className="h-4 w-4" />
                            Add Row
                        </Button>
                    </div>
                </div>

                <DialogFooter className="p-6 border-t bg-gray-50 flex justify-between items-center sm:justify-between w-full">
                    <div className="flex items-center text-sm text-gray-500 gap-2">
                        <AlertCircle className="h-4 w-4" />
                        <span>{rows.filter(r => r.name).length} items ready to save</span>
                    </div>
                    <div className="flex gap-2">
                        <Button variant="outline" onClick={() => setOpen(false)}>Cancel</Button>
                        <Button onClick={handleSubmit} disabled={isSubmitting || rows.filter(r => r.name).length === 0} className="bg-blue-600 gap-2">
                            {isSubmitting ? (
                                <>Saving...</>
                            ) : (
                                <>
                                    <Save className="h-4 w-4" />
                                    Save All Items
                                </>
                            )}
                        </Button>
                    </div>
                </DialogFooter>
            </DialogContent>
        </Dialog>
    )
}
