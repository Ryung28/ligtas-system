'use client'

import { useState, useTransition, useEffect } from 'react'
import { useRouter } from 'next/navigation'
import { ClipboardList, Loader2, RotateCcw, Package } from 'lucide-react'
import { toast } from 'sonner'

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
import { Label } from '@/components/ui/label'
import { Combobox } from '@/components/ui/combobox'
import {
    Select,
    SelectContent,
    SelectItem,
    SelectTrigger,
    SelectValue,
} from '@/components/ui/select'
import { borrowItem, returnItem, getAvailableItems } from '@/app/actions/inventory'
import { useBorrowLogs } from '@/hooks/use-borrow-logs'

interface AvailableItem {
    id: number
    item_name: string
    stock_available: number
    category: string
}

export function BorrowItemDialog() {
    const [open, setOpen] = useState(false)
    const [isPending, startTransition] = useTransition()
    const [availableItems, setAvailableItems] = useState<AvailableItem[]>([])
    const [isLoadingItems, setIsLoadingItems] = useState(false)
    const [selectedItem, setSelectedItem] = useState<AvailableItem | null>(null)
    const [borrowerName, setBorrowerName] = useState('')
    const [returnType, setReturnType] = useState<'anytime' | 'date'>('anytime')
    const { logs, refresh: refreshLogs } = useBorrowLogs()

    // Condition assessment for smart-return
    const [returnCondition, setReturnCondition] = useState('Good')
    const [returnNotes, setReturnNotes] = useState('')

    const router = useRouter()

    // DETECT: Is this actually a return?
    const existingBorrow = logs.find(l =>
        l.status === 'borrowed' &&
        l.inventory_id === selectedItem?.id &&
        l.borrower_name.toLowerCase() === borrowerName.toLowerCase().trim()
    )

    const isSmartReturn = !!existingBorrow

    // Fetch available items when dialog opens
    useEffect(() => {
        let mounted = true

        const loadItems = async () => {
            if (!open) return

            setIsLoadingItems(true)
            try {
                const result = await getAvailableItems() as any

                if (mounted) {
                    if (result.success && result.data) {
                        setAvailableItems(result.data)
                    } else {
                        toast.error(result.error || 'Failed to load available items')
                        setAvailableItems([])
                    }
                }
            } catch (error) {
                if (mounted) {
                    console.error('Failed to load items:', error)
                    toast.error('Could not load inventory items.')
                    setAvailableItems([])
                }
            } finally {
                if (mounted) {
                    setIsLoadingItems(false)
                }
            }
        }

        loadItems()

        return () => {
            mounted = false
        }
    }, [open])

    const handleSubmit = async (event: React.FormEvent<HTMLFormElement>) => {
        event.preventDefault()

        const formData = new FormData(event.currentTarget)

        startTransition(async () => {
            let result;

            if (isSmartReturn) {
                // If the system detected this as a return, use returnItem action
                result = await returnItem(existingBorrow.id, returnCondition, returnNotes)
            } else {
                // Otherwise process as normal borrow
                result = await borrowItem(formData)
            }

            if (result.success) {
                toast.success(result.message || 'Transaction logged successfully!')
                setOpen(false)
                refreshLogs()
                router.refresh()
                setSelectedItem(null)
                setBorrowerName('')
            } else {
                toast.error(result.error || 'Failed to log transaction')
            }
        })
    }

    const handleItemSelect = (itemId: string) => {
        const item = availableItems.find((i) => i.id.toString() === itemId)
        setSelectedItem(item || null)
    }

    return (
        <Dialog open={open} onOpenChange={setOpen}>
            <DialogTrigger asChild>
                <Button className="h-10 bg-blue-600 hover:bg-blue-700 text-white shadow-xl shadow-blue-600/20 text-xs font-semibold tracking-wide transition-all active:scale-95 px-5 rounded-xl gap-2">
                    <ClipboardList className="h-4 w-4" />
                    Borrow Item
                </Button>
            </DialogTrigger>
            <DialogContent className="sm:max-w-[700px] max-h-[90vh] overflow-y-auto">
                <form onSubmit={handleSubmit}>
                    <DialogHeader className={isSmartReturn ? "bg-orange-50 -mx-6 -mt-6 p-6 border-b border-orange-100 rounded-t-lg" : ""}>
                        <DialogTitle className="text-xl font-heading font-bold text-gray-900 tracking-tight">
                            {isSmartReturn ? "🔄 Process Item Return" : "📦 Dispatch Item"}
                        </DialogTitle>
                        <DialogDescription className={isSmartReturn ? "text-orange-700 font-medium" : "text-slate-500 font-medium"}>
                            {isSmartReturn
                                ? `System detected that ${borrowerName} already has this item. Switching to Return Assessment.`
                                : "Assign inventory items to operational personnel and update registry levels."}
                        </DialogDescription>
                    </DialogHeader>

                    <div className="grid gap-6 py-4">
                        <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
                            {/* Borrower Name */}
                            <div className="grid gap-2">
                                <Label htmlFor="borrower_name" className="text-sm font-semibold text-gray-700">
                                    Borrower Name <span className="text-red-500">*</span>
                                </Label>
                                <Input
                                    id="borrower_name"
                                    name="borrower_name"
                                    placeholder="Full name of borrower"
                                    required
                                    disabled={isPending}
                                    value={borrowerName}
                                    onChange={(e) => setBorrowerName(e.target.value)}
                                    className="rounded-lg border-gray-300"
                                />
                            </div>

                            {/* Contact Number - Optional if returning */}
                            <div className="grid gap-2">
                                <Label htmlFor="contact_number" className="text-sm font-semibold text-gray-700">
                                    Contact Number {!isSmartReturn && <span className="text-red-500">*</span>}
                                    <span className="text-xs font-normal text-gray-400 ml-2">(09XXXXXXXXX)</span>
                                </Label>
                                <Input
                                    id="contact_number"
                                    name="contact_number"
                                    type="tel"
                                    placeholder="09XXXXXXXXX"
                                    pattern="^09\d{9}$"
                                    title="Philippine mobile number (09XXXXXXXXX)"
                                    required={!isSmartReturn}
                                    disabled={isPending || isSmartReturn}
                                    defaultValue={isSmartReturn ? existingBorrow.borrower_contact : ""}
                                    className={`rounded-lg border-gray-300 ${isSmartReturn ? 'bg-gray-50/50' : ''}`}
                                />
                            </div>
                        </div>

                        {/* Item Selection & Quantity Row */}
                        <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
                            <div className="grid gap-2">
                                <Label className="text-sm font-semibold text-gray-700">
                                    Select Item <span className="text-red-500">*</span>
                                </Label>

                                {/* Hidden input for form submission */}
                                <input type="hidden" name="item_id" value={selectedItem?.id || ''} />

                                <Combobox
                                    options={availableItems.map(item => ({
                                        value: item.id.toString(),
                                        label: item.item_name,
                                        description: `${item.stock_available} available • ${item.category}`,
                                    }))}
                                    value={selectedItem?.id.toString()}
                                    onValueChange={handleItemSelect}
                                    placeholder={isLoadingItems ? "Loading items..." : "Search for an item..."}
                                    searchPlaceholder="Search by name or scan QR..."
                                    emptyText="No items found."
                                    disabled={isPending || isLoadingItems}
                                    // ADDED: Handle raw QR scans into the search box
                                    onSearchChange={(query) => {
                                        try {
                                            if (query.startsWith('{')) {
                                                const data = JSON.parse(query)
                                                if (data.itemId) handleItemSelect(data.itemId.toString())
                                            } else if (/^\d+$/.test(query)) {
                                                // If it's a raw numeric ID, try to find and select it
                                                const exists = availableItems.some(i => i.id.toString() === query)
                                                if (exists) handleItemSelect(query)
                                            }
                                        } catch (e) { }
                                    }}
                                />

                                {selectedItem && (
                                    <div className="space-y-2 mt-2">
                                        <p className="text-xs text-blue-600 font-bold uppercase tracking-widest flex items-center gap-1">
                                            <Package className="h-3 w-3" />
                                            Active Holders
                                        </p>
                                        <div className="flex flex-wrap gap-1">
                                            {logs.filter(l => l.inventory_id === selectedItem.id && l.status === 'borrowed').length === 0 ? (
                                                <p className="text-[10px] text-gray-400 italic">No active borrows for this item.</p>
                                            ) : (
                                                logs.filter(l => l.inventory_id === selectedItem.id && l.status === 'borrowed').map((log, i) => (
                                                    <button
                                                        key={i}
                                                        type="button"
                                                        onClick={() => setBorrowerName(log.borrower_name)}
                                                        className={`text-[10px] px-2 py-0.5 rounded-full border transition-all ${borrowerName.toLowerCase().trim() === log.borrower_name.toLowerCase().trim()
                                                            ? 'bg-orange-500 border-orange-600 text-white font-bold'
                                                            : 'bg-gray-50 border-gray-200 text-gray-600 hover:border-gray-400'
                                                            }`}
                                                    >
                                                        {log.borrower_name}
                                                    </button>
                                                ))
                                            )}
                                        </div>
                                    </div>
                                )}
                            </div>

                            {/* Quantity */}
                            <div className="grid gap-2">
                                <Label htmlFor="quantity" className="text-sm font-semibold text-gray-700">
                                    Quantity <span className="text-red-500">*</span>
                                </Label>
                                <Input
                                    id="quantity"
                                    name="quantity"
                                    type="number"
                                    placeholder="Qty"
                                    value={isSmartReturn ? existingBorrow.quantity : undefined}
                                    readOnly={isSmartReturn}
                                    required
                                    min={1}
                                    max={selectedItem?.stock_available || 999}
                                    disabled={isPending || !selectedItem}
                                    className={`rounded-lg border-gray-300 ${isSmartReturn ? 'bg-orange-50 font-bold border-orange-200' : ''}`}
                                />
                                {selectedItem && !isSmartReturn && (
                                    <p className="text-xs text-gray-500">
                                        Maximum: {selectedItem.stock_available} unit(s)
                                    </p>
                                )}
                            </div>
                        </div>

                        {/* SMART SWITCH: RETURN ASSESSMENT OR BORROW SCHEDULE */}
                        {isSmartReturn ? (
                            <div className="space-y-4 animate-in zoom-in-95 duration-200 p-6 bg-orange-50/50 rounded-xl border border-orange-100">
                                <div className="flex items-center gap-2 text-orange-800 font-bold mb-2">
                                    <RotateCcw className="h-5 w-5" />
                                    Return Assessment
                                </div>
                                <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
                                    <div className="grid gap-2">
                                        <Label className="text-[10px] font-black text-gray-400 uppercase tracking-widest">Item Condition</Label>
                                        <Select value={returnCondition} onValueChange={setReturnCondition}>
                                            <SelectTrigger className="bg-white border-orange-200 h-11">
                                                <SelectValue />
                                            </SelectTrigger>
                                            <SelectContent>
                                                <SelectItem value="Good" className="text-green-600 font-bold">Good Condition</SelectItem>
                                                <SelectItem value="Maintenance" className="text-orange-600 font-bold">Needs Maintenance</SelectItem>
                                                <SelectItem value="Damaged" className="text-red-600 font-bold">Damaged / Broken</SelectItem>
                                                <SelectItem value="Lost" className="text-gray-600 font-bold">Lost / Missing</SelectItem>
                                            </SelectContent>
                                        </Select>
                                    </div>
                                    <div className="grid gap-2">
                                        <Label className="text-[10px] font-black text-gray-400 uppercase tracking-widest">Remarks</Label>
                                        <Input
                                            placeholder="Note any issues..."
                                            className="bg-white border-orange-200 h-11"
                                            value={returnNotes}
                                            onChange={(e) => setReturnNotes(e.target.value)}
                                        />
                                    </div>
                                </div>
                            </div>
                        ) : (
                            <>
                                {/* Office/Department (Only for Borrowing) */}
                                <div className="grid gap-2">
                                    <Label htmlFor="office_department" className="text-sm font-semibold text-gray-700">
                                        Office/Department <span className="text-red-500">*</span>
                                    </Label>
                                    <Input
                                        id="office_department"
                                        name="office_department"
                                        placeholder="E.g., CDRRMO Team Alpha, Barangay San Jose"
                                        required
                                        disabled={isPending}
                                        className="rounded-lg border-gray-300"
                                    />
                                </div>

                                {/* Return Schedule Section */}
                                <div className="grid grid-cols-1 md:grid-cols-2 gap-4 p-4 bg-gray-50 rounded-lg border border-gray-200">
                                    <div className="grid gap-2">
                                        <Label className="text-sm font-semibold text-gray-700">
                                            Return Schedule <span className="text-red-500">*</span>
                                        </Label>
                                        <Select
                                            value={returnType}
                                            onValueChange={(val: 'anytime' | 'date') => setReturnType(val)}
                                            disabled={isPending}
                                        >
                                            <SelectTrigger className="bg-white border-gray-300">
                                                <SelectValue />
                                            </SelectTrigger>
                                            <SelectContent>
                                                <SelectItem value="anytime">Return Anytime / Open-ended</SelectItem>
                                                <SelectItem value="date">Specific Return Date</SelectItem>
                                            </SelectContent>
                                        </Select>
                                    </div>

                                    {returnType === 'date' && (
                                        <div className="grid gap-2 animate-in fade-in slide-in-from-top-2 duration-200">
                                            <Label htmlFor="expected_return_date" className="text-sm font-semibold text-gray-700">
                                                Expected Return Date <span className="text-red-500">*</span>
                                            </Label>
                                            <Input
                                                id="expected_return_date"
                                                name="expected_return_date"
                                                type="date"
                                                required={returnType === 'date'}
                                                disabled={isPending}
                                                min={new Date().toISOString().split('T')[0]}
                                                className="bg-white border-gray-300"
                                            />
                                        </div>
                                    )}
                                </div>

                                {/* Purpose (Optional) */}
                                <div className="grid gap-2">
                                    <Label htmlFor="purpose" className="text-sm font-semibold text-gray-700">
                                        Purpose <span className="text-gray-400">(Optional)</span>
                                    </Label>
                                    <Input
                                        id="purpose"
                                        name="purpose"
                                        placeholder="E.g., Emergency Response Training, Community Event"
                                        disabled={isPending}
                                        className="rounded-lg border-gray-300"
                                    />
                                </div>
                            </>
                        )}
                    </div>

                    <DialogFooter className="gap-2 pt-4 border-t border-gray-100 -mx-6 px-6">
                        <Button
                            type="button"
                            variant="ghost"
                            onClick={() => setOpen(false)}
                            disabled={isPending}
                        >
                            Cancel
                        </Button>
                        <Button
                            type="submit"
                            disabled={isPending || !selectedItem}
                            className={`gap-2 rounded-xl min-w-[160px] font-bold shadow-lg transition-all ${isSmartReturn ? 'bg-orange-600 hover:bg-orange-700 text-white' : 'bg-blue-600 hover:bg-blue-700 text-white'}`}
                        >
                            {isPending ? (
                                <Loader2 className="h-4 w-4 animate-spin" />
                            ) : isSmartReturn ? (
                                <>
                                    <RotateCcw className="h-4 w-4" />
                                    Confirm Return
                                </>
                            ) : (
                                <>
                                    <ClipboardList className="h-4 w-4" />
                                    Confirm Dispatch
                                </>
                            )}
                        </Button>
                    </DialogFooter>
                </form>
            </DialogContent>
        </Dialog>
    )
}
