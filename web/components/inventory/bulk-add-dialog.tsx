'use client'

import { useState, useEffect } from 'react'
import {
    Plus, ListPlus, Save, Trash2, ChevronDown, Package,
    MapPin, Calendar, Bell, ShoppingBag, AlertCircle, CheckCircle2,
    Hash, Layers, Warehouse, PenLine,
} from 'lucide-react'
import { Button } from '@/components/ui/button'
import {
    Dialog, DialogContent, DialogDescription,
    DialogFooter, DialogHeader, DialogTitle, DialogTrigger,
} from '@/components/ui/dialog'
import { Input } from '@/components/ui/input'
import { Label } from '@/components/ui/label'
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from '@/components/ui/select'
import { bulkAddItems, getCategories } from '@/src/features/catalog'
import { getStorageLocations } from '@/app/actions/storage-locations'
import { resolveCategoryIcon } from '@/lib/category-icons'
import { cn } from '@/lib/utils'
import { toast } from 'sonner'

// ─── Types ────────────────────────────────────────────────────────────────────

type ItemType = 'equipment' | 'consumable'

interface StorageLocationRecord {
    id: number
    location_name: string
}

interface BulkItemRow {
    id: string
    name: string
    category: string
    item_type: ItemType
    qty: string
    location: string        // selected location_name or 'custom'
    customLocation: string  // text when location === 'custom'
    serial_number: string
    model_number: string
    brand: string
    expiry_date: string
    expiry_alert_days: string
    expanded: boolean
    error?: string
}

// ─── Helpers ──────────────────────────────────────────────────────────────────

const uid = () => Math.random().toString(36).slice(2, 9)

const BLANK = (category = ''): BulkItemRow => ({
    id: uid(),
    name: '',
    category,
    item_type: 'equipment',
    qty: '1',
    location: '',
    customLocation: '',
    serial_number: '',
    model_number: '',
    brand: '',
    expiry_date: '',
    expiry_alert_days: '15',
    expanded: false,
})

/** Goods category OR consumable type → show expiry/brand fields (mirrors main dialog logic). */
const needsExpiryFields = (row: BulkItemRow) =>
    row.item_type === 'consumable' || row.category.trim().toLowerCase() === 'goods'

// ─── Component ────────────────────────────────────────────────────────────────

interface BulkAddDialogProps {
    trigger?: React.ReactNode
    onSuccess?: () => void
}

export function BulkAddDialog({ trigger, onSuccess }: BulkAddDialogProps) {
    const [open, setOpen]               = useState(false)
    const [isSubmitting, setIsSub]      = useState(false)
    const [categories, setCategories]   = useState<string[]>([])
    const [locations, setLocations]     = useState<StorageLocationRecord[]>([])
    const [rows, setRows]               = useState<BulkItemRow[]>([BLANK(), BLANK(), BLANK()])

    // ── fetch categories + locations on open ───────────────────────────────────
    useEffect(() => {
        if (!open) return
        getCategories().then(res => {
            const cats: string[] = res.data || []
            setCategories(cats)
            if (cats.length > 0) {
                setRows(prev => prev.map(r => ({ ...r, category: r.category || cats[0] })))
            }
        })
        getStorageLocations().then(res => {
            setLocations((res.data as StorageLocationRecord[]) || [])
        })
    }, [open])

    // ── row helpers ────────────────────────────────────────────────────────────
    const update = <K extends keyof BulkItemRow>(id: string, k: K, v: BulkItemRow[K]) =>
        setRows(prev => prev.map(r => r.id === id ? { ...r, [k]: v, error: undefined } : r))

    const toggle = (id: string) =>
        setRows(prev => prev.map(r => r.id === id ? { ...r, expanded: !r.expanded } : r))

    const addRow = () => {
        const lastCat = rows.at(-1)?.category || categories[0] || ''
        setRows(prev => [...prev, BLANK(lastCat)])
    }

    const removeRow = (id: string) => {
        if (rows.length === 1) return
        setRows(prev => prev.filter(r => r.id !== id))
    }

    // ── validation ─────────────────────────────────────────────────────────────
    const validate = (): boolean => {
        let ok = true
        setRows(prev => prev.map(r => {
            if (!r.name.trim()) return r // empty rows are skipped, not invalid
            let error: string | undefined
            
            if (r.name.trim().length < 2) { error = 'Name must be at least 2 characters.'; ok = false }
            else if (!r.category)         { error = 'Select a category.'; ok = false }
            else if (!r.location)         { error = 'Select a stock location.'; ok = false }
            else if (r.location === 'custom' && !r.customLocation.trim()) { 
                error = 'Enter custom location.'; ok = false 
            }
            
            const qty = parseInt(r.qty) || 0
            if (!error && qty < 1) { error = 'Quantity must be ≥ 1.'; ok = false }
            
            // Auto-expand rows with errors so the user sees what's wrong
            return { ...r, error, expanded: error ? true : r.expanded }
        }))
        return ok
    }

    // ── submit ─────────────────────────────────────────────────────────────────
    const handleSubmit = async () => {
        const namedRows = rows.filter(r => r.name.trim())
        if (!namedRows.length) { toast.error('Enter at least one item name.'); return }
        if (!validate()) { toast.error('Fix the highlighted rows before saving.'); return }

        setIsSub(true)
        const payload = namedRows.map(r => {
            const qty = Math.max(1, parseInt(r.qty) || 1)
            const showExpiry = needsExpiryFields(r)
            return {
                name:             r.name.trim(),
                category:         r.category,
                item_type:        r.item_type,
                stock_total:      qty,
                stock_available:  qty,
                qty_good:         qty,
                status:           'Good',
                storage_location: r.location === 'custom'
                    ? (r.customLocation.trim() || undefined)
                    : (r.location || undefined),
                serial_number:    r.item_type === 'equipment' && r.serial_number.trim() ? r.serial_number.trim() : undefined,
                model_number:     r.item_type === 'equipment' && r.model_number.trim() ? r.model_number.trim() : undefined,
                brand:            showExpiry && r.brand.trim() ? r.brand.trim() : undefined,
                expiry_date:      showExpiry && r.expiry_date ? r.expiry_date : undefined,
                expiry_alert_days: showExpiry && r.expiry_date
                    ? Math.max(1, parseInt(r.expiry_alert_days) || 15)
                    : undefined,
            }
        })

        const result = await bulkAddItems(payload as any)
        setIsSub(false)

        if (result.success) {
            toast.success(result.message)
            setOpen(false)
            onSuccess?.()
            setRows([BLANK(), BLANK(), BLANK()])
        } else {
            toast.error(result.error)
        }
    }

    // ── derived ────────────────────────────────────────────────────────────────
    const readyCount  = rows.filter(r => r.name.trim()).length
    const errorCount  = rows.filter(r => r.name.trim() && r.error).length
    const expandedAny = rows.some(r => r.expanded)

    // ── render ─────────────────────────────────────────────────────────────────
    return (
        <Dialog open={open} onOpenChange={setOpen}>
            <DialogTrigger asChild>
                {trigger ?? (
                    <Button variant="outline" className="gap-2 border-dashed border-gray-300 hover:border-blue-400 hover:bg-blue-50 text-blue-600">
                        <ListPlus className="h-4 w-4" />
                        Bulk Add
                    </Button>
                )}
            </DialogTrigger>

            <DialogContent className="sm:max-w-[780px] max-h-[90vh] flex flex-col p-0 gap-0 overflow-hidden rounded-2xl">

                {/* ── Header ── */}
                <DialogHeader className="px-6 pt-6 pb-4 border-b border-gray-100">
                    <div className="flex items-center gap-3">
                        <div className="h-10 w-10 rounded-2xl bg-blue-600 flex items-center justify-center shrink-0">
                            <ListPlus className="h-5 w-5 text-white" />
                        </div>
                        <div>
                            <DialogTitle className="text-[18px] font-black tracking-tight text-gray-950">
                                Bulk Item Entry
                            </DialogTitle>
                            <DialogDescription className="text-[13px] font-medium text-gray-400 mt-0.5">
                                Fill names &amp; quantities — expand any row for advanced details.
                            </DialogDescription>
                        </div>
                    </div>
                </DialogHeader>

                {/* ── Column headers (sticky) ── */}
                <div className="px-6 pt-3 pb-1 bg-white shrink-0">
                    <div className="grid grid-cols-12 text-[11px] font-black uppercase tracking-widest text-gray-400 px-3">
                        <div className="col-span-1 text-center">#</div>
                        <div className="col-span-5">Item Name <span className="text-red-400">*</span></div>
                        <div className="col-span-3">Category</div>
                        <div className="col-span-1 text-center">Qty</div>
                        <div className="col-span-2" />
                    </div>
                </div>

                {/* ── Rows ── */}
                <div className="flex-1 overflow-y-auto px-6 pb-4 space-y-1.5 pt-1">
                    {rows.map((row, index) => {
                        const showExpiry  = needsExpiryFields(row)
                        const isExpanded  = row.expanded

                        return (
                            <div
                                key={row.id}
                                className={cn(
                                    'rounded-xl border bg-white transition-all',
                                    row.error
                                        ? 'border-red-300 shadow-sm shadow-red-100'
                                        : isExpanded
                                            ? 'border-slate-300 shadow-xl shadow-slate-200/50'
                                            : 'border-gray-100 hover:border-gray-200',
                                )}
                            >
                                {/* ── Collapsed row ── */}
                                <div className="grid grid-cols-12 items-center px-3 py-2 gap-1">

                                    {/* # */}
                                    <div className="col-span-1 text-center text-[12px] text-blue-300 font-mono font-bold shrink-0">
                                        {index + 1}
                                    </div>

                                    {/* Name */}
                                    <div className="col-span-5">
                                        <Input
                                            value={row.name}
                                            onChange={e => update(row.id, 'name', e.target.value)}
                                            onKeyDown={e => { if (e.key === 'Enter') { e.preventDefault(); addRow() } }}
                                            placeholder="Item name…"
                                            className={cn(
                                                'h-9 border-transparent hover:border-gray-200 focus:border-blue-400 bg-transparent text-[13px] font-semibold text-gray-900 px-2 rounded-lg',
                                                row.error && 'focus:border-red-400',
                                            )}
                                        />
                                        {row.error && (
                                            <p className="text-[11px] font-bold text-red-500 px-2 pt-0.5">{row.error}</p>
                                        )}
                                    </div>

                                    {/* Category */}
                                    <div className="col-span-3">
                                        <Select value={row.category} onValueChange={v => update(row.id, 'category', v)}>
                                            <SelectTrigger className="h-9 border-transparent hover:border-gray-200 focus:border-blue-400 bg-transparent text-[12px] font-bold rounded-lg pl-2">
                                                <SelectValue />
                                            </SelectTrigger>
                                            <SelectContent className="rounded-xl">
                                                {categories.map(c => {
                                                    const Icon = resolveCategoryIcon(c)
                                                    return (
                                                        <SelectItem key={c} value={c} textValue={c} className="text-[12px] font-bold py-2.5">
                                                            <span className="flex items-center gap-2">
                                                                <Icon className="h-3.5 w-3.5 text-slate-500" strokeWidth={2} />
                                                                {c}
                                                            </span>
                                                        </SelectItem>
                                                    )
                                                })}
                                            </SelectContent>
                                        </Select>
                                    </div>

                                    {/* Qty */}
                                    <div className="col-span-1">
                                        <Input
                                            type="number"
                                            min="1"
                                            value={row.qty}
                                            onChange={e => update(row.id, 'qty', e.target.value)}
                                            className="h-9 border-transparent hover:border-gray-200 focus:border-blue-400 bg-transparent text-right text-[13px] font-black text-gray-900 px-2 rounded-lg"
                                        />
                                    </div>

                                    {/* Expand + Delete */}
                                    <div className="col-span-2 flex items-center justify-end gap-1">
                                        <button
                                            type="button"
                                            onClick={() => toggle(row.id)}
                                            className={cn(
                                                'inline-flex items-center gap-1 px-2.5 py-1 rounded-lg text-[11px] font-black uppercase tracking-wide transition-colors',
                                                isExpanded
                                                    ? 'bg-slate-900 text-white border border-slate-950 shadow-sm'
                                                    : 'text-gray-400 hover:text-slate-900 hover:bg-slate-50 border border-transparent',
                                            )}
                                        >
                                            Details
                                            <ChevronDown className={cn('h-3 w-3 transition-transform', isExpanded && 'rotate-180')} />
                                        </button>
                                        <button
                                            type="button"
                                            onClick={() => removeRow(row.id)}
                                            disabled={rows.length === 1}
                                            className="h-7 w-7 flex items-center justify-center rounded-lg text-gray-200 hover:text-red-400 hover:bg-red-50 transition-colors disabled:pointer-events-none"
                                        >
                                            <Trash2 className="h-3.5 w-3.5" />
                                        </button>
                                    </div>
                                </div>

                                {/* ── Expanded panel ── */}
                                {isExpanded && (
                                    <div className="px-4 pb-4 pt-1 border-t border-slate-100 bg-slate-50/30 rounded-b-xl space-y-4 relative overflow-hidden">
                                        {/* Left accent stripe */}
                                        <div className="absolute left-0 top-0 bottom-0 w-1 bg-slate-900 rounded-bl-xl" />

                                        {/* Type */}
                                        <div className="flex items-center gap-3 pt-2 pl-2">
                                            <Label className="text-[11px] font-black uppercase tracking-widest text-slate-600 w-20 shrink-0">
                                                Item type
                                            </Label>
                                            <div className="inline-flex rounded-xl border border-gray-200 overflow-hidden text-[12px] font-black shadow-sm">
                                                <button
                                                    type="button"
                                                    onClick={() => update(row.id, 'item_type', 'equipment')}
                                                    className={cn(
                                                        'px-4 py-2 flex items-center gap-1.5 transition-colors',
                                                        row.item_type === 'equipment'
                                                            ? 'bg-slate-900 text-white'
                                                            : 'bg-white text-gray-500 hover:bg-gray-50',
                                                    )}
                                                >
                                                    <Package className="h-3 w-3" />
                                                    Equipment
                                                </button>
                                                <button
                                                    type="button"
                                                    onClick={() => update(row.id, 'item_type', 'consumable')}
                                                    className={cn(
                                                        'px-4 py-2 flex items-center gap-1.5 border-l border-gray-200 transition-colors',
                                                        row.item_type === 'consumable'
                                                            ? 'bg-rose-600 text-white'
                                                            : 'bg-white text-gray-500 hover:bg-gray-50',
                                                    )}
                                                >
                                                    <ShoppingBag className="h-3 w-3" />
                                                    Consumable
                                                </button>
                                            </div>
                                        </div>

                                        {/* Location */}
                                        <div className="flex items-start gap-3 pl-2">
                                            <Label className="text-[11px] font-black uppercase tracking-widest text-slate-600 w-20 shrink-0 pt-2.5">
                                                Location <span className="text-red-500">*</span>
                                            </Label>
                                            <div className="flex-1 space-y-1.5">
                                                <div className="relative">
                                                    <Warehouse className="absolute left-2.5 top-1/2 -translate-y-1/2 h-3.5 w-3.5 text-gray-400 z-10 pointer-events-none" />
                                                    <Select
                                                        value={row.location}
                                                        onValueChange={v => update(row.id, 'location', v)}
                                                    >
                                                        <SelectTrigger className="h-9 pl-8 rounded-xl border-gray-200 bg-white text-[12px] font-semibold hover:border-blue-300 focus:border-blue-400">
                                                            <SelectValue placeholder="Select a location…" />
                                                        </SelectTrigger>
                                                        <SelectContent className="rounded-xl">
                                                            {locations.length === 0 ? (
                                                                <div className="px-3 py-2 text-[12px] text-gray-400">No locations saved yet</div>
                                                            ) : (
                                                                locations.map(loc => (
                                                                    <SelectItem key={loc.id} value={loc.location_name} className="text-[12px] font-semibold py-2">
                                                                        <span className="flex items-center gap-2">
                                                                            <MapPin className="h-3.5 w-3.5 text-slate-400" />
                                                                            {loc.location_name}
                                                                        </span>
                                                                    </SelectItem>
                                                                ))
                                                            )}
                                                            <SelectItem value="custom" className="text-[12px] font-bold text-blue-600 py-2">
                                                                <span className="flex items-center gap-2">
                                                                    <PenLine className="h-3.5 w-3.5" />
                                                                    Custom location…
                                                                </span>
                                                            </SelectItem>
                                                        </SelectContent>
                                                    </Select>
                                                </div>
                                                {row.location === 'custom' && (
                                                    <Input
                                                        value={row.customLocation}
                                                        onChange={e => update(row.id, 'customLocation', e.target.value)}
                                                        placeholder="e.g. Hub A, Vehicle Bay…"
                                                        className="h-9 rounded-xl border-blue-200 bg-blue-50/30 text-[12px] font-semibold focus:border-blue-400"
                                                        autoFocus
                                                    />
                                                )}
                                            </div>
                                        </div>

                                        {/* Serial + Model — Equipment only */}
                                        {row.item_type === 'equipment' && (
                                            <div className="grid grid-cols-2 gap-3 pl-2">
                                                <div className="flex flex-col gap-1.5">
                                                    <Label className="text-[11px] font-black uppercase tracking-widest text-slate-600">
                                                        Serial / Tag #
                                                    </Label>
                                                    <div className="relative">
                                                        <Hash className="absolute left-2.5 top-1/2 -translate-y-1/2 h-3.5 w-3.5 text-gray-300" />
                                                        <Input
                                                            value={row.serial_number}
                                                            onChange={e => update(row.id, 'serial_number', e.target.value)}
                                                            placeholder="SN-0000"
                                                            className="h-9 pl-8 rounded-xl border-gray-200 bg-white text-[12px] font-semibold"
                                                        />
                                                    </div>
                                                </div>
                                                <div className="flex flex-col gap-1.5">
                                                    <Label className="text-[11px] font-black uppercase tracking-widest text-slate-600">
                                                        Model name
                                                    </Label>
                                                    <div className="relative">
                                                        <Layers className="absolute left-2.5 top-1/2 -translate-y-1/2 h-3.5 w-3.5 text-gray-300" />
                                                        <Input
                                                            value={row.model_number}
                                                            onChange={e => update(row.id, 'model_number', e.target.value)}
                                                            placeholder="X-Series"
                                                            className="h-9 pl-8 rounded-xl border-gray-200 bg-white text-[12px] font-semibold"
                                                        />
                                                    </div>
                                                </div>
                                            </div>
                                        )}

                                        {/* Expiry fields — shown for Goods or Consumable */}
                                        {showExpiry ? (
                                            <>
                                                <div className="flex items-center gap-3 pl-2">
                                                    <Label className="text-[11px] font-black uppercase tracking-widest text-slate-600 w-20 shrink-0">
                                                        Brand
                                                    </Label>
                                                    <div className="relative flex-1">
                                                        <ShoppingBag className="absolute left-2.5 top-1/2 -translate-y-1/2 h-3.5 w-3.5 text-gray-300" />
                                                        <Input
                                                            value={row.brand}
                                                            onChange={e => update(row.id, 'brand', e.target.value)}
                                                            placeholder="e.g. 3M, Philips…"
                                                            className="h-9 pl-8 rounded-xl border-gray-200 bg-white text-[12px] font-semibold"
                                                        />
                                                    </div>
                                                </div>

                                                <div className="flex items-start gap-3 pl-2">
                                                    <Label className="text-[11px] font-black uppercase tracking-widest text-slate-600 w-20 shrink-0 pt-2.5">
                                                        Expiry
                                                    </Label>
                                                    <div className="flex-1 space-y-2">
                                                        <div className="relative">
                                                            <Calendar className="absolute left-2.5 top-1/2 -translate-y-1/2 h-3.5 w-3.5 text-gray-300" />
                                                            <Input
                                                                type="date"
                                                                value={row.expiry_date}
                                                                onChange={e => update(row.id, 'expiry_date', e.target.value)}
                                                                className="h-9 pl-8 rounded-xl border-gray-200 bg-white text-[12px] font-semibold"
                                                            />
                                                        </div>
                                                        {row.expiry_date && (
                                                            <div className="relative">
                                                                <Bell className="absolute left-2.5 top-1/2 -translate-y-1/2 h-3.5 w-3.5 text-amber-400" />
                                                                <Input
                                                                    type="number"
                                                                    min="1"
                                                                    value={row.expiry_alert_days}
                                                                    onChange={e => update(row.id, 'expiry_alert_days', e.target.value)}
                                                                    placeholder="15"
                                                                    className="h-9 pl-8 rounded-xl border-amber-200 bg-amber-50/30 text-[12px] font-semibold"
                                                                />
                                                                <span className="absolute right-3 top-1/2 -translate-y-1/2 text-[11px] font-bold text-gray-400 pointer-events-none">
                                                                    days before alert
                                                                </span>
                                                            </div>
                                                        )}
                                                    </div>
                                                </div>
                                            </>
                                        ) : (
                                            <div className="mt-2 ml-[100px] p-3 rounded-xl border border-dashed border-slate-200 bg-white/50">
                                                <p className="text-[12px] font-medium text-slate-600 flex items-center gap-2">
                                                    <AlertCircle className="h-3.5 w-3.5 text-slate-400" />
                                                    <span>Switch to <strong className="text-slate-900">Consumable</strong> or choose <strong className="text-slate-900">Goods</strong> to unlock brand &amp; expiry.</span>
                                                </p>
                                            </div>
                                        )}
                                    </div>
                                )}
                            </div>
                        )
                    })}

                    {/* Add row */}
                    <button
                        type="button"
                        onClick={addRow}
                        className="w-full flex items-center justify-center gap-2 py-3 rounded-xl border border-dashed border-gray-200 text-[12px] font-bold text-gray-400 hover:border-blue-300 hover:text-blue-500 hover:bg-blue-50/30 transition-all mt-1"
                    >
                        <Plus className="h-4 w-4" />
                        Add row
                    </button>
                </div>

                {/* ── Footer ── */}
                <DialogFooter className="px-6 py-4 border-t border-gray-100 bg-gray-50/60 flex items-center justify-between sm:justify-between w-full rounded-b-2xl shrink-0">
                    <div className="flex items-center gap-2 text-[13px] font-bold">
                        {errorCount > 0 ? (
                            <span className="flex items-center gap-1.5 text-red-500">
                                <AlertCircle className="h-4 w-4" />
                                {errorCount} row{errorCount !== 1 ? 's' : ''} need attention
                            </span>
                        ) : readyCount > 0 ? (
                            <span className="flex items-center gap-1.5 text-emerald-600">
                                <CheckCircle2 className="h-4 w-4" />
                                {readyCount} item{readyCount !== 1 ? 's' : ''} ready
                            </span>
                        ) : (
                            <span className="text-gray-400">No items yet — type a name to start.</span>
                        )}
                        {expandedAny && (
                            <span className="ml-2 text-gray-400 font-medium hidden sm:inline">
                                · Advanced fields active on some rows
                            </span>
                        )}
                    </div>
                    <div className="flex gap-2">
                        <Button variant="outline" onClick={() => setOpen(false)} className="rounded-xl font-bold">
                            Cancel
                        </Button>
                        <Button
                            onClick={handleSubmit}
                            disabled={isSubmitting || readyCount === 0}
                            className="bg-blue-600 hover:bg-blue-700 text-white gap-2 px-6 rounded-xl font-black"
                        >
                            {isSubmitting ? (
                                <span className="flex items-center gap-2">
                                    <span className="h-3.5 w-3.5 rounded-full border-2 border-white border-t-transparent animate-spin" />
                                    Saving…
                                </span>
                            ) : (
                                <>
                                    <Save className="h-4 w-4" />
                                    Save {readyCount > 0 ? readyCount : ''} Item{readyCount !== 1 ? 's' : ''}
                                </>
                            )}
                        </Button>
                    </div>
                </DialogFooter>

            </DialogContent>
        </Dialog>
    )
}
