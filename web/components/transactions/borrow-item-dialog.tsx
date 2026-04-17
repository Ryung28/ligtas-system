'use client'

import { useState, useTransition, useEffect, useMemo } from 'react'
import { useRouter } from 'next/navigation'
import { ClipboardList, Loader2, RotateCcw, Package, Plus, X, ShoppingCart, Clock, ShieldCheck, UserCheck, Warehouse } from 'lucide-react'
import { createClient } from '@/lib/supabase-browser'
import { toast } from 'sonner'
import { STORAGE_LOCATION_LABELS, StorageLocation, getInventoryImageUrl } from '@/lib/supabase'

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
import { Tabs, TabsList, TabsTrigger } from '@/components/ui/tabs'
import { borrowItem, returnItem, batchBorrowItems } from '@/src/features/transactions'
import { getAvailableItems } from '@/src/features/catalog'
import { useBorrowLogs } from '@/hooks/use-borrow-logs'

interface AvailableItem {
    id: number
    item_name: string
    category: string
    image_url?: string | null
    item_type?: 'equipment' | 'consumable'
    primary_location?: string
    primary_stock_available: number
    aggregate_available: number
    stock_pending: number
    variants: Array<{
        id: number
        location: string
        stock_available: number
        stock_total: number
    }>
}

interface CartItem {
    item: AvailableItem
    quantity: number
}

export function BorrowItemDialog() {
    const [open, setOpen] = useState(false)
    const [isPending, startTransition] = useTransition()
    const [availableItems, setAvailableItems] = useState<AvailableItem[]>([])
    const [isLoadingItems, setIsLoadingItems] = useState(false)
    const [selectedItem, setSelectedItem] = useState<AvailableItem | null>(null)
    const [selectedVariantId, setSelectedVariantId] = useState<string | null>(null)
    const [selectedQuantity, setSelectedQuantity] = useState(1)
    const [borrowerName, setBorrowerName] = useState('')
    const [intakeMode, setIntakeMode] = useState<'immediate' | 'scheduled'>('immediate')
    const [pickupDate, setPickupDate] = useState<string>('')
    const [returnType, setReturnType] = useState<'anytime' | 'date'>('anytime')
    const { logs, refresh: refreshLogs } = useBorrowLogs()

    // Cart state for multi-item borrowing
    const [cart, setCart] = useState<CartItem[]>([])

    // Condition assessment for smart-return
    const [returnCondition, setReturnCondition] = useState('Good')
    const [returnNotes, setReturnNotes] = useState('')
    const [releasedBy, setReleasedBy] = useState('')
    const [approvedBy, setApprovedBy] = useState('')

    const supabase = createClient()
    const router = useRouter()

    // Check if selected item is consumable
    const isConsumable = selectedItem?.item_type === 'consumable'

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
                        toast.error(result.error || 'Failed to load available items', {
                            className: 'rounded-tl-none rounded-tr-2xl rounded-bl-2xl rounded-br-2xl bg-white border-red-200 text-red-900 shadow-[0_12px_24px_-12px_rgba(239,68,68,0.06)]'
                        })
                        setAvailableItems([])
                    }
                }
            } catch (error) {
                console.error('Available items load error:', error)
            } finally {
                if (mounted) setIsLoadingItems(false)
            }
        }

        loadItems()

        // Sync Current User for Handed By field
        const syncSession = async () => {
            const { data: { user } } = await supabase.auth.getUser()
            if (user && mounted) {
                const name = user.user_metadata?.full_name || user.email?.split('@')[0] || ''
                setReleasedBy(name)
            }
        }
        syncSession()

        return () => {
            mounted = false
        }
    }, [open, supabase])

    const handleSubmit = async (event: React.FormEvent<HTMLFormElement>) => {
        event.preventDefault()

        // If cart has items, use batch borrow
        if (cart.length > 0) {
            const formData = new FormData(event.currentTarget)
            const bName = formData.get('borrower_name') as string || borrowerName
            const cNumber = formData.get('contact_number') as string
            const oDept = formData.get('office_department') as string
            const purpose = formData.get('purpose') as string
            const expectedReturnDate = formData.get('expected_return_date') as string
            const approvedBy = formData.get('approved_by') as string
            const releasedByInput = formData.get('released_by') as string

            if (!bName.trim()) {
                toast.error('Please enter borrower name', {
                    className: 'rounded-tl-none rounded-tr-2xl rounded-bl-2xl rounded-br-2xl bg-white border-red-200 text-red-900 shadow-[0_12px_24px_-12px_rgba(239,68,68,0.06)] ring-1 ring-red-50'
                })
                return
            }

            // Validate Philippine phone number
            const phoneRegex = /^09\d{9}$/
            if (!cNumber || !phoneRegex.test(cNumber)) {
                toast.error('Please enter a valid Philippine mobile number (09XXXXXXXXX)', {
                    className: 'rounded-tl-none rounded-tr-2xl rounded-bl-2xl rounded-br-2xl bg-white border-red-200 text-red-900 shadow-[0_12px_24px_-12px_rgba(239,68,68,0.06)] ring-1 ring-red-50'
                })
                return
            }

            startTransition(async () => {
                const result = await batchBorrowItems({
                    borrower_name: bName,
                    contact_number: cNumber,
                    office_department: oDept,
                    purpose: purpose,
                    approved_by: approvedBy,
                    released_by: releasedByInput,
                    expected_return_date: expectedReturnDate || null,
                    pickup_scheduled_at: intakeMode === 'scheduled' ? pickupDate : null,
                    items: cart.map(c => ({
                        item_id: c.item.id,
                        quantity: c.quantity,
                        item_type: c.item.item_type || 'equipment'
                    }))
                })

                if (result.success) {
                    toast.success(result.message || 'Items borrowed successfully!')
                    setOpen(false)
                    refreshLogs()
                    router.refresh()
                    setCart([])
                    setSelectedItem(null)
                    setBorrowerName('')
                } else {
                    console.error('Batch borrow error:', result.error)
                    toast.error(result.error || 'Failed to borrow items', {
                        className: 'rounded-tl-none rounded-tr-2xl rounded-bl-2xl rounded-br-2xl bg-white border-red-200 text-red-900 shadow-[0_12px_24px_-12px_rgba(239,68,68,0.06)] ring-1 ring-red-50'
                    })
                }
            })
            return
        }

        // Original single-item logic
        if (!selectedItem) {
            toast.error('Please select an item', {
                className: 'rounded-tl-none rounded-tr-2xl rounded-bl-2xl rounded-br-2xl bg-white border-red-200 text-red-900 shadow-[0_12px_24px_-12px_rgba(239,68,68,0.06)] ring-1 ring-red-50'
            })
            return
        }

        if (!borrowerName.trim()) {
            toast.error('Please enter borrower name', {
                className: 'rounded-tl-none rounded-tr-2xl rounded-bl-2xl rounded-br-2xl bg-white border-red-200 text-red-900 shadow-[0_12px_24px_-12px_rgba(239,68,68,0.06)] ring-1 ring-red-50'
            })
            return
        }

        const formData = new FormData(event.currentTarget)

        // Validate Philippine phone number for non-return transactions
        if (!isSmartReturn) {
            const cNumber = formData.get('contact_number') as string
            const phoneRegex = /^09\d{9}$/
            if (!cNumber || !phoneRegex.test(cNumber)) {
                toast.error('Please enter a valid Philippine mobile number (09XXXXXXXXX)', {
                    className: 'rounded-tl-none rounded-tr-2xl rounded-bl-2xl rounded-br-2xl bg-white border-red-200 text-red-900 shadow-[0_12px_24px_-12px_rgba(239,68,68,0.06)] ring-1 ring-red-50'
                })
                return
            }
        }

        startTransition(async () => {
            let result;

            if (isSmartReturn) {
                result = await returnItem(existingBorrow.id, {
                    receivedByName: '',
                    returnCondition: returnCondition.toLowerCase() as any,
                    returnNotes: returnNotes
                })
            } else {
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
                console.error('Transaction error:', result.error)
                toast.error(result.error || 'Failed to log transaction', {
                    className: 'rounded-tl-none rounded-tr-2xl rounded-bl-2xl rounded-br-2xl bg-white border-red-200 text-red-900 shadow-[0_12px_24px_-12px_rgba(239,68,68,0.06)] ring-1 ring-red-50'
                })
            }
        })
    }

    const handleItemSelect = (itemId: string) => {
        const item = availableItems.find((i) => i.id.toString() === itemId)
        setSelectedItem(item || null)
        setSelectedVariantId(null) // Reset variant when item changes
    }

    const handleAddToCart = () => {
        if (!selectedItem) {
            toast.error('Please select an item first')
            return
        }

        // If item has variants, a location MUST be selected
        if (selectedItem.variants && selectedItem.variants.length > 0 && !selectedVariantId) {
            toast.error('Please select a pickup location')
            return
        }

        if (selectedQuantity < 1) {
            toast.error('Quantity must be at least 1')
            return
        }

        // Get the truly available stock for the chosen location
        let maxAvailable = selectedItem.aggregate_available || selectedItem.primary_stock_available
        let targetId = selectedItem.id

        if (selectedVariantId) {
            if (selectedVariantId === 'primary') {
                maxAvailable = selectedItem.primary_stock_available
                targetId = selectedItem.id
            } else {
                const variant = selectedItem.variants.find(v => v.id.toString() === selectedVariantId)
                if (variant) {
                    maxAvailable = variant.stock_available
                    targetId = variant.id
                }
            }
        }

        if (selectedQuantity > maxAvailable) {
            toast.error(`Only ${maxAvailable} units available at this location`)
            return
        }

        // Check if item already in cart
        const existingIndex = cart.findIndex(c => c.item.id === targetId)
        if (existingIndex >= 0) {
            toast.error('Item already in cart. Remove it first to change quantity.')
            return
        }

        // Create a localized item object for the cart
        const cartItem: AvailableItem = {
            ...selectedItem,
            id: targetId,
            item_name: selectedVariantId && selectedVariantId !== 'primary' 
                ? `${selectedItem.item_name} (${selectedItem.variants.find(v => v.id.toString() === selectedVariantId)?.location})`
                : selectedItem.item_name
        }

        setCart([...cart, { item: cartItem, quantity: selectedQuantity }])
        setSelectedItem(null)
        setSelectedVariantId(null)
        setSelectedQuantity(1)
        toast.success(`Added ${cartItem.item_name} to cart`)
    }

    const handleRemoveFromCart = (itemId: number) => {
        setCart(cart.filter(c => c.item.id !== itemId))
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
                            {isSmartReturn ? "🔄 Process Item Return" : isConsumable ? "💊 Dispense Consumable" : "📦 Dispatch Item"}
                        </DialogTitle>
                        <DialogDescription className={isSmartReturn ? "text-orange-700 font-medium" : "text-slate-500 font-medium"}>
                            {isSmartReturn
                                ? `System detected that ${borrowerName} already has this item. Switching to Return Assessment.`
                                : isConsumable
                                ? "Dispense one-time use items. No return required."
                                : "Assign inventory items to operational personnel and update registry levels."}
                        </DialogDescription>
                    </DialogHeader>

                    <div className="grid gap-6 py-4">
                        {/* 🚀 TACTICAL MODE TOGGLE: Immediate vs Scheduled */}
                        {!isSmartReturn && !isConsumable && (
                            <Tabs 
                                value={intakeMode} 
                                onValueChange={(val: any) => setIntakeMode(val)} 
                                className="w-full"
                            >
                                <TabsList className="grid w-full grid-cols-2 h-12 p-1.5 bg-slate-100 rounded-xl">
                                    <TabsTrigger 
                                        value="immediate" 
                                        className="rounded-lg font-bold text-[10px] uppercase tracking-widest data-[state=active]:bg-white data-[state=active]:text-blue-600 data-[state=active]:shadow-sm"
                                    >
                                        <Package className="h-3.5 w-3.5 mr-2" />
                                        Issue Now (Real-time)
                                    </TabsTrigger>
                                    <TabsTrigger 
                                        value="scheduled" 
                                        className="rounded-lg font-bold text-[10px] uppercase tracking-widest data-[state=active]:bg-white data-[state=active]:text-amber-600 data-[state=active]:shadow-sm"
                                    >
                                        <Clock className="h-3.5 w-3.5 mr-2" />
                                        Schedule Reserve
                                    </TabsTrigger>
                                </TabsList>
                            </Tabs>
                        )}

                        {/* Pickup Schedule (Only if Scheduled mode is active) */}
                        {intakeMode === 'scheduled' && !isSmartReturn && !isConsumable && (
                            <div className="grid gap-3 p-4 bg-amber-50/50 rounded-2xl border border-amber-100 animate-in slide-in-from-top-2 duration-300">
                                <div className="flex items-center gap-2 text-amber-800">
                                    <Clock className="h-4 w-4" />
                                    <span className="text-[10px] font-black uppercase tracking-widest">Target Pickup Schedule</span>
                                </div>
                                <div className="grid gap-2">
                                    <Label htmlFor="pickup_scheduled_at" className="text-xs font-semibold text-amber-900">
                                        When will the responder collect this equipment? <span className="text-red-500">*</span>
                                    </Label>
                                    <Input
                                        id="pickup_scheduled_at"
                                        name="pickup_scheduled_at"
                                        type="datetime-local"
                                        required={intakeMode === 'scheduled'}
                                        value={pickupDate}
                                        onChange={(e) => setPickupDate(e.target.value)}
                                        min={new Date().toISOString().slice(0, 16)}
                                        className="h-11 bg-white border-amber-200 rounded-xl shadow-sm focus:ring-amber-500 focus:border-amber-500"
                                    />
                                    <p className="text-[9px] text-amber-600 font-medium">
                                        * Choosing a future date will move this request to the <b>Command Queue</b> instead of issuing it immediately.
                                    </p>
                                </div>
                            </div>
                        )}

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

                            {/* Contact Number - Always Required */}
                            <div className="grid gap-2">
                                <Label htmlFor="contact_number" className="text-sm font-semibold text-gray-700">
                                    Contact Number <span className="text-red-500">*</span>
                                    <span className="text-xs font-normal text-gray-400 ml-2">(09XXXXXXXXX)</span>
                                </Label>
                                <Input
                                    id="contact_number"
                                    name="contact_number"
                                    type="tel"
                                    placeholder="09XXXXXXXXX"
                                    pattern="^09\d{9}$"
                                    title="Must be a valid Philippine mobile number starting with 09 followed by 9 digits"
                                    required
                                    disabled={isPending || isSmartReturn}
                                    defaultValue={isSmartReturn ? existingBorrow.borrower_contact : ""}
                                    className={`rounded-lg border-gray-300 ${isSmartReturn ? 'bg-gray-50/50' : ''}`}
                                />
                            </div>
                        </div>

                        {/* Item Selection & Quantity Row - Symmetric Grid */}
                        <div className="grid grid-cols-12 gap-4 items-start">
                            {/* Select Item - 8 columns */}
                            <div className="col-span-12 md:col-span-8 space-y-2">
                                <Label className="text-sm font-semibold text-slate-700">
                                    Select Item <span className="text-red-500">*</span>
                                </Label>

                                {/* Hidden input for form submission */}
                                <input type="hidden" name="item_id" value={selectedItem?.id || ''} />

                                <Combobox
                                    options={availableItems.map(item => ({
                                        value: item.id.toString(),
                                        label: item.item_name,
                                        imageUrl: getInventoryImageUrl(item.image_url) || undefined,
                                        description: `${item.aggregate_available} units City-wide • ${item.category}${item.variants?.length ? ` • [${item.variants.length + 1} Sites]` : ''}`,
                                    }))}
                                    value={selectedItem?.id.toString()}
                                    onValueChange={handleItemSelect}
                                    placeholder={isLoadingItems ? "Loading items..." : "Search for an item..."}
                                    searchPlaceholder="Search by name or scan QR..."
                                    emptyText="No items found."
                                    disabled={isPending || isLoadingItems}
                                    onSearchChange={(query) => {
                                        try {
                                            if (query.startsWith('{')) {
                                                const data = JSON.parse(query)
                                                if (data.itemId) handleItemSelect(data.itemId.toString())
                                            } else if (/^\d+$/.test(query)) {
                                                const exists = availableItems.some(i => i.id.toString() === query)
                                                if (exists) handleItemSelect(query)
                                            }
                                        } catch (e) { }
                                    }}
                                />
                            </div>

                            {/* Location Selection (Conditional) */}
                            {selectedItem && selectedItem.variants && selectedItem.variants.length > 0 && (
                                <div className="col-span-12 animate-in slide-in-from-left-2 duration-300">
                                    <div className="p-4 bg-blue-50/50 rounded-xl border border-blue-100 flex flex-col md:flex-row md:items-center gap-4">
                                        <div className="flex items-center gap-2 text-blue-900 shrink-0">
                                            <Warehouse className="h-4 w-4" />
                                            <span className="text-xs font-bold uppercase tracking-wider">Pickup Site <span className="text-red-500">*</span></span>
                                        </div>
                                        <Select 
                                            value={selectedVariantId || ''} 
                                            onValueChange={setSelectedVariantId}
                                        >
                                            <SelectTrigger className="bg-white border-blue-200 h-10 flex-1">
                                                <SelectValue placeholder="Select warehouse or satellite location..." />
                                            </SelectTrigger>
                                            <SelectContent className="rounded-xl border-blue-100 shadow-xl">
                                                <SelectItem value="primary" className="py-2">
                                                    <div className="flex justify-between items-center w-full gap-8">
                                                        <span className="font-bold text-slate-900 uppercase text-[11px]">{STORAGE_LOCATION_LABELS[selectedItem.primary_location as StorageLocation] || selectedItem.primary_location || 'Main Hub'}</span>
                                                        <span className="text-[10px] font-black text-blue-600 bg-blue-50 px-1.5 py-0.5 rounded">{selectedItem.primary_stock_available} READY</span>
                                                    </div>
                                                </SelectItem>
                                                {selectedItem.variants.map(variant => (
                                                    <SelectItem key={variant.id} value={variant.id.toString()} className="py-2">
                                                        <div className="flex justify-between items-center w-full gap-8">
                                                            <span className="font-bold text-slate-900 uppercase text-[11px]">{STORAGE_LOCATION_LABELS[variant.location as StorageLocation] || variant.location}</span>
                                                            <span className="text-[10px] font-black text-blue-600 bg-blue-50 px-1.5 py-0.5 rounded">{variant.stock_available} READY</span>
                                                        </div>
                                                    </SelectItem>
                                                ))}
                                            </SelectContent>
                                        </Select>
                                    </div>
                                </div>
                            )}

                            {/* Quantity - 2 columns */}
                            <div className="col-span-6 md:col-span-2 space-y-2">
                                <Label htmlFor="quantity" className="text-sm font-semibold text-slate-700">
                                    Quantity <span className="text-red-500">*</span>
                                </Label>
                                <Input
                                    id="quantity"
                                    name="quantity"
                                    type="number"
                                    placeholder="Qty"
                                    value={isSmartReturn ? existingBorrow.quantity : selectedQuantity}
                                    onChange={(e) => setSelectedQuantity(parseInt(e.target.value) || 1)}
                                    readOnly={isSmartReturn}
                                    required
                                    min={1}
                                    max={selectedVariantId 
                                        ? (selectedVariantId === 'primary' 
                                            ? selectedItem?.primary_stock_available 
                                            : selectedItem?.variants.find(v => v.id.toString() === selectedVariantId)?.stock_available || 0)
                                        : selectedItem?.aggregate_available || 999
                                    }
                                    disabled={isPending || !selectedItem}
                                    className={`h-11 rounded-lg border-slate-300 shadow-inner ${
                                        isSmartReturn 
                                            ? 'bg-orange-50 font-bold border-orange-200' 
                                            : (selectedItem?.stock_pending ?? 0) > 0 
                                            ? 'border-amber-300 bg-amber-50/30' 
                                            : ''
                                    }`}
                                />
                            </div>

                            {/* Add Button - 2 columns */}
                            {!isSmartReturn && (
                                <div className="col-span-6 md:col-span-2 space-y-2">
                                    <Label className="text-sm font-semibold text-slate-700 opacity-0 pointer-events-none">
                                        Add
                                    </Label>
                                    <Button
                                        type="button"
                                        onClick={handleAddToCart}
                                        disabled={!selectedItem || isPending}
                                        className="h-11 w-full bg-gradient-to-br from-blue-500 to-blue-600 hover:from-blue-600 hover:to-blue-700 text-white rounded-lg gap-2 font-semibold shadow-lg shadow-blue-500/25 hover:shadow-xl hover:shadow-blue-500/30 transition-all duration-200 active:scale-[0.98] disabled:opacity-50 disabled:cursor-not-allowed disabled:shadow-none"
                                    >
                                        <Plus className="h-4 w-4" />
                                        Add to Cart
                                    </Button>
                                </div>
                            )}
                        </div>

                        {/* Metadata Row - Below inputs to prevent layout shift */}
                        <div className="grid grid-cols-12 gap-4">
                            {/* Combined Status Section - Aligned with Select Item column */}
                            <div className="col-span-12 md:col-span-8">
                                {selectedItem && (
                                    <div className="space-y-3 animate-in fade-in slide-in-from-top-1 duration-200">
                                        
                                        {/* Pending Approvals Warning (if any) */}
                                        {selectedItem.stock_pending > 0 && (
                                            <div className="flex items-start gap-2 p-3 bg-amber-50 rounded-lg border border-amber-200">
                                                <Clock className="h-4 w-4 text-amber-600 mt-0.5 shrink-0" />
                                                <div>
                                                    <p className="text-xs font-bold text-amber-900">
                                                        {selectedItem.stock_pending} unit{selectedItem.stock_pending > 1 ? 's' : ''} pending approval
                                                    </p>
                                                    <p className="text-[10px] text-amber-700 mt-0.5">
                                                        Reserved by pending requests. Available stock already accounts for this.
                                                    </p>
                                                </div>
                                            </div>
                                        )}

                                        {/* Active Holders */}
                                        <div>
                                            <p className="text-xs text-blue-600 font-bold uppercase tracking-widest flex items-center gap-1">
                                                <Package className="h-3 w-3" />
                                                Active Holders
                                            </p>
                                            <div className="flex flex-wrap gap-1 mt-2">
                                                {logs.filter(l => l.inventory_id === selectedItem.id && l.status === 'borrowed').length === 0 ? (
                                                    <p className="text-[10px] text-gray-400 italic">No active borrows for this item.</p>
                                                ) : (
                                                    logs.filter(l => l.inventory_id === selectedItem.id && l.status === 'borrowed').map((log, i) => (
                                                        <button
                                                            key={i}
                                                            type="button"
                                                            onClick={() => setBorrowerName(log.borrower_name)}
                                                            className={`text-[10px] px-2 py-0.5 rounded-full border transition-all ${
                                                                borrowerName.toLowerCase().trim() === log.borrower_name.toLowerCase().trim()
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
                                    </div>
                                )}
                            </div>

                            {/* Maximum units helper - Aligned with Quantity column */}
                            <div className="col-span-6 md:col-span-2">
                                {selectedItem && !isSmartReturn && (
                                    <p className="text-xs text-gray-500 animate-in fade-in duration-200">
                                        Maximum: {selectedVariantId 
                                            ? (selectedVariantId === 'primary' 
                                                ? selectedItem.primary_stock_available 
                                                : selectedItem.variants.find(v => v.id.toString() === selectedVariantId)?.stock_available || 0)
                                            : selectedItem.aggregate_available
                                        } unit(s)
                                    </p>
                                )}
                            </div>
                        </div>

                        {/* Cart Display */}
                        {cart.length > 0 && (
                            <div className="relative overflow-hidden rounded-2xl border border-blue-200/60 bg-gradient-to-br from-blue-50 via-white to-blue-50/30 p-5 shadow-lg shadow-blue-500/5 animate-in fade-in slide-in-from-top-2 duration-300">
                                {/* Subtle background pattern */}
                                <div className="absolute inset-0 bg-[radial-gradient(circle_at_30%_20%,rgba(59,130,246,0.03),transparent_50%)]" />
                                
                                <div className="relative space-y-4">
                                    {/* Header */}
                                    <div className="flex items-center justify-between">
                                        <div className="flex items-center gap-2.5">
                                            <div className="flex h-9 w-9 items-center justify-center rounded-xl bg-gradient-to-br from-blue-500 to-blue-600 shadow-lg shadow-blue-500/25">
                                                <ShoppingCart className="h-4.5 w-4.5 text-white" />
                                            </div>
                                            <div>
                                                <h3 className="text-sm font-bold text-slate-800">Dispatch Cart</h3>
                                                <p className="text-xs text-slate-500">
                                                    {cart.length} {cart.length === 1 ? 'item' : 'items'} ready
                                                </p>
                                            </div>
                                        </div>
                                        <div className="flex items-center gap-1.5 rounded-full bg-blue-100 px-3 py-1 text-xs font-bold text-blue-700">
                                            <span>{cart.reduce((sum, item) => sum + item.quantity, 0)}</span>
                                            <span className="text-blue-500">units</span>
                                        </div>
                                    </div>

                                    {/* Cart Items */}
                                    <div className="space-y-2">
                                        {cart.map((cartItem, index) => (
                                            <div
                                                key={cartItem.item.id}
                                                className="group relative flex items-center justify-between rounded-xl border border-slate-200/60 bg-white p-3.5 shadow-sm transition-all duration-200 hover:border-slate-300 hover:shadow-md"
                                                style={{
                                                    animationDelay: `${index * 50}ms`,
                                                }}
                                            >
                                                {/* Item Info */}
                                                <div className="flex-1 min-w-0 pr-3">
                                                    <div className="flex items-center gap-2 mb-1">
                                                        <h4 className="font-semibold text-slate-900 text-sm truncate">
                                                            {cartItem.item.item_name}
                                                        </h4>
                                                        {cartItem.item.item_type === 'consumable' && (
                                                            <span className="inline-flex items-center rounded-md bg-purple-50 px-2 py-0.5 text-[10px] font-bold text-purple-700 ring-1 ring-inset ring-purple-600/20">
                                                                CONSUMABLE
                                                            </span>
                                                        )}
                                                    </div>
                                                    <div className="flex items-center gap-2 text-xs text-slate-500">
                                                        <span className="inline-flex items-center gap-1 font-medium text-slate-700">
                                                            <Package className="h-3 w-3" />
                                                            {cartItem.quantity}x
                                                        </span>
                                                        <span className="text-slate-400">•</span>
                                                        <span>{cartItem.item.category}</span>
                                                    </div>
                                                </div>

                                                {/* Remove Button */}
                                                <Button
                                                    type="button"
                                                    variant="ghost"
                                                    size="sm"
                                                    onClick={() => handleRemoveFromCart(cartItem.item.id)}
                                                    className="h-8 w-8 shrink-0 rounded-lg p-0 text-slate-400 transition-all hover:bg-red-50 hover:text-red-600 group-hover:opacity-100 md:opacity-0"
                                                >
                                                    <X className="h-4 w-4" />
                                                </Button>
                                            </div>
                                        ))}
                                    </div>
                                </div>
                            </div>
                        )}

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
                                {!isConsumable && (
                                    <div className="grid gap-2">
                                        <Label htmlFor="office_department" className="text-sm font-semibold text-gray-700">
                                            Office/Department <span className="text-red-500">*</span>
                                        </Label>
                                        <Input
                                            id="office_department"
                                            name="office_department"
                                            placeholder="E.g., CDRRMO Team Alpha, Barangay San Jose"
                                            required={!isConsumable}
                                            disabled={isPending}
                                            className="rounded-lg border-gray-300"
                                        />
                                    </div>
                                )}

                                {/* Return Schedule Section - Hide for consumables */}
                                {!isConsumable && (
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
                                )}

                                {/* Purpose */}
                                <div className="grid gap-2">
                                    <Label htmlFor="purpose" className="text-sm font-semibold text-gray-700">
                                        Purpose <span className="text-gray-400">(Optional)</span>
                                    </Label>
                                    <Input
                                        id="purpose"
                                        name="purpose"
                                        placeholder={isConsumable ? "E.g., Emergency Response, Medical Aid" : "E.g., Emergency Response Training, Community Event"}
                                        disabled={isPending}
                                        className="rounded-lg border-gray-300 transition-all focus:border-blue-400"
                                    />
                                </div>

                                {/* Dispatch Sign-off Details */}
                                <div className="group/audit relative mt-2 overflow-hidden rounded-xl border border-slate-200 bg-white p-5 transition-all duration-300 hover:border-blue-200">
                                    <div className="relative space-y-4">
                                        <div className="flex items-center gap-2 mb-1">
                                            <ShieldCheck className="h-4 w-4 text-blue-500" />
                                            <h4 className="text-[11px] font-bold text-slate-500 uppercase tracking-wider">Dispatch Sign-off</h4>
                                        </div>

                                        <div className="grid grid-cols-1 md:grid-cols-2 gap-5">
                                            {/* Approved By Field */}
                                            <div className="grid gap-2">
                                                <Label htmlFor="approved_by" className="text-xs font-semibold text-slate-700 flex items-center gap-1.5">
                                                    <UserCheck className="h-3.5 w-3.5 text-blue-500" />
                                                    Approved By <span className="text-red-500">*</span>
                                                </Label>
                                                <div className="relative flex items-center">
                                                    <Input
                                                        id="approved_by"
                                                        name="approved_by"
                                                        placeholder="Name of approver"
                                                        required
                                                        value={approvedBy}
                                                        onChange={(e) => setApprovedBy(e.target.value)}
                                                        disabled={isPending}
                                                        autoComplete="off"
                                                        className="h-10 rounded-lg border-slate-200 bg-white px-3 text-sm transition-all focus:ring-2 focus:ring-blue-500/10 focus:border-blue-400 w-full pr-24"
                                                    />
                                                    <Button
                                                        type="button"
                                                        variant="ghost"
                                                        size="sm"
                                                        onClick={() => setApprovedBy(releasedBy)}
                                                        className="absolute right-1 h-8 px-2 text-[10px] font-bold text-blue-600 hover:text-blue-700 hover:bg-blue-50 rounded-md transition-colors"
                                                    >
                                                        USE MY NAME
                                                    </Button>
                                                </div>
                                            </div>

                                            {/* Released By Field */}
                                            <div className="grid gap-2">
                                                <Label htmlFor="released_by" className="text-xs font-semibold text-slate-700 flex items-center gap-1.5">
                                                    <Package className="h-3.5 w-3.5 text-emerald-500" />
                                                    Released By <span className="text-red-500">*</span>
                                                </Label>
                                                <div className="relative">
                                                    <Input
                                                        id="released_by"
                                                        name="released_by"
                                                        required
                                                        defaultValue={releasedBy}
                                                        onChange={(e) => setReleasedBy(e.target.value)}
                                                        disabled={isPending}
                                                        placeholder="Staff releasing items"
                                                        className="h-10 rounded-lg border-slate-200 bg-slate-50/50 px-3 text-sm transition-all"
                                                    />
                                                </div>
                                            </div>
                                        </div>
                                        
                                        <p className="text-[10px] text-slate-400 font-medium">
                                            * Permanent record: These names will be linked to this dispatch for audit purposes.
                                        </p>
                                    </div>
                                </div>

                                {/* Consumable Notice */}
                                {isConsumable && (
                                    <div className="p-4 bg-purple-50 rounded-lg border border-purple-200">
                                        <p className="text-sm text-purple-800 font-medium">
                                            ℹ️ This is a consumable item. It will be marked as dispensed and no return is required.
                                        </p>
                                    </div>
                                )}
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
                            disabled={isPending || (cart.length === 0 && !selectedItem)}
                            className={`gap-2 rounded-xl min-w-[160px] font-bold shadow-lg transition-all ${
                                isSmartReturn 
                                    ? 'bg-orange-600 hover:bg-orange-700 text-white' 
                                    : cart.length > 0
                                    ? 'bg-blue-600 hover:bg-blue-700 text-white'
                                    : isConsumable
                                    ? 'bg-purple-600 hover:bg-purple-700 text-white'
                                    : 'bg-blue-600 hover:bg-blue-700 text-white'
                            }`}
                        >
                            {isPending ? (
                                <Loader2 className="h-4 w-4 animate-spin" />
                            ) : isSmartReturn ? (
                                <>
                                    <RotateCcw className="h-4 w-4" />
                                    Confirm Return
                                </>
                            ) : cart.length > 0 ? (
                                <>
                                    <ShoppingCart className="h-4 w-4" />
                                    Borrow {cart.length} Item{cart.length > 1 ? 's' : ''}
                                </>
                            ) : isConsumable ? (
                                <>
                                    <Package className="h-4 w-4" />
                                    Dispense Item
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
