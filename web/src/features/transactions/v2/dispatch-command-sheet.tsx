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
import { LogisticsPreviewCard } from '../_components/logistics-preview-card'
import { cn } from '@/lib/utils'

// V3 API Bridge (Mapped to exactly what the old file expected)
import { createBatchBorrow as batchBorrowItems, createBorrowRecord as borrowItem } from '../api/transaction-repository'
import { useAvailableCatalog } from '../hooks/use-available-catalog'
import { useBorrowCart } from '../hooks/use-borrow-cart'

interface AvailableItem {
    id: number
    item_name: string
    category: string
    item_type?: 'equipment' | 'consumable'
    primary_location?: string
    primary_stock_available: number
    aggregate_available: number
    stock_pending: number
    image_url?: string
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

export function DispatchCommandSheet() {
    const [open, setOpen] = useState(false)
    const [isPending, startTransition] = useTransition()
    const { items: availableItems, isLoading: isLoadingItems } = useAvailableCatalog(open)
    const { cart: v3Cart, addToCart: v3AddToCart, removeFromCart: v3RemoveFromCart, clearCart: v3ClearCart } = useBorrowCart()
    
    // Sync Legacy State with V3 Cart
    const [cart, setCart] = useState<CartItem[]>([])
    const [selectedItem, setSelectedItem] = useState<AvailableItem | null>(null)
    const [selectedVariantId, setSelectedVariantId] = useState<string | null>(null)
    const [selectedQuantity, setSelectedQuantity] = useState<number | "">(1)
    const [borrowerName, setBorrowerName] = useState('')
    const [contactNumber, setContactNumber] = useState('')
    const [intakeMode, setIntakeMode] = useState<'immediate' | 'scheduled'>('immediate')
    const [pickupDate, setPickupDate] = useState<string>('')
    const [returnType, setReturnType] = useState<'anytime' | 'date'>('anytime')
    const [releasedBy, setReleasedBy] = useState('Brandon James C. Galabin')
    const [approvedBy, setApprovedBy] = useState('')

    const supabase = createClient()
    const router = useRouter()

    const isConsumable = selectedItem?.item_type === 'consumable'

    // Monolith logic for releasedBy sync
    useEffect(() => {
        if (!open) return
        const syncSession = async () => {
            const { data: { user } } = await supabase.auth.getUser()
            if (user) {
                const name = user.user_metadata?.full_name || user.email?.split('@')[0] || 'Brandon James C. Galabin'
                setReleasedBy(name)
            }
        }
        syncSession()
    }, [open, supabase])

    const handleSubmit = async (event: React.FormEvent<HTMLFormElement>) => {
        event.preventDefault()

        const formData = new FormData(event.currentTarget)
        const bName = formData.get('borrower_name') as string || borrowerName
        const cNumber = formData.get('contact_number') as string
        const oDept = formData.get('office_department') as string
        const purpose = formData.get('purpose') as string
        const expectedReturnDate = formData.get('expected_return_date') as string
        const approvedByVal = formData.get('approved_by') as string
        const releasedByInput = formData.get('released_by') as string

        // Common Validations
        if (!bName.trim()) { toast.error('Please enter borrower name'); return; }
        if (!/^09\d{9}$/.test(cNumber)) { 
            toast.error('CONTACT ERROR: Number must be 11 digits and start with 09 (e.g., 09123456789)'); 
            return; 
        }

        if (intakeMode === 'scheduled') {
            if (!pickupDate) { toast.error('Please specify a pickup date'); return; }
            // Add a 1-minute grace buffer to allow "Now" selection
            const fiveMinutesAgo = new Date(Date.now() - 60000);
            if (new Date(pickupDate) < fiveMinutesAgo) { 
                toast.error('SCHEDULE ERROR: Cannot schedule pickups in the past'); 
                return; 
            }
        }

        startTransition(async () => {
            let result;

            if (cart.length > 0) {
                const logs = cart.map(c => ({
                    inventory_id: c.item.id,
                    item_name: c.item.item_name,
                    quantity: c.quantity,
                    borrower_name: bName,
                    borrower_contact: cNumber,
                    borrower_organization: oDept,
                    purpose: purpose,
                    released_by_name: releasedByInput,
                    approved_by_name: approvedByVal,
                    transaction_type: 'borrow' as const,
                    status: (intakeMode === 'scheduled' ? 'reserved' : 'borrowed') as any,
                    pickup_scheduled_at: intakeMode === 'scheduled' ? pickupDate : null,
                    expected_return_date: returnType === 'date' ? expectedReturnDate : null
                }));
                result = await batchBorrowItems(logs);
            } else if (selectedItem) {
                const log = {
                    inventory_id: selectedItem.id,
                    item_name: selectedItem.item_name,
                    quantity: Number(selectedQuantity) || 1,
                    borrower_name: bName,
                    borrower_contact: cNumber,
                    borrower_organization: oDept,
                    purpose: purpose,
                    released_by_name: releasedByInput,
                    approved_by_name: approvedByVal,
                    transaction_type: 'borrow' as const,
                    status: (intakeMode === 'scheduled' ? 'reserved' : 'borrowed') as any,
                    pickup_scheduled_at: intakeMode === 'scheduled' ? pickupDate : null,
                    expected_return_date: returnType === 'date' ? expectedReturnDate : null
                };
                result = await borrowItem(log);
            } else {
                toast.error('No items selected for dispatch');
                return;
            }

            if (result.success) {
                toast.success('Dispatch successful!')
                setOpen(false)
                v3ClearCart()
                setCart([])
                setSelectedItem(null)
                setBorrowerName('')
                setContactNumber('')
                router.refresh()
            } else {
                toast.error(result.error || 'Failed to process dispatch')
            }
        })
    }

    const handleItemSelect = (itemId: string) => {
        const item = availableItems.find((i) => i.id.toString() === itemId)
        setSelectedItem(item as any || null)
        setSelectedVariantId(null)
    }

    const handleAddToCart = () => {
        if (!selectedItem) return;
        if (selectedItem.variants?.length > 0 && !selectedVariantId) {
            toast.error('Please select a pickup location');
            return;
        }

        let maxAvailable = selectedItem.aggregate_available || selectedItem.primary_stock_available
        let targetId = selectedItem.id

        if (selectedVariantId) {
            if (selectedVariantId === 'primary') {
                maxAvailable = selectedItem.primary_stock_available
            } else {
                const variant = selectedItem.variants.find(v => v.id.toString() === selectedVariantId)
                if (variant) {
                    maxAvailable = variant.stock_available
                    targetId = variant.id
                }
            }
        }

        const selectedQuantityNumber = Number(selectedQuantity) || 0
        if (selectedQuantityNumber > maxAvailable) {
            toast.error(`Only ${maxAvailable} units available`);
            return;
        }

        const cartItem: AvailableItem = {
            ...selectedItem,
            id: targetId,
            item_name: selectedVariantId && selectedVariantId !== 'primary' 
                ? `${selectedItem.item_name} (${selectedItem.variants.find(v => v.id.toString() === selectedVariantId)?.location})`
                : selectedItem.item_name
        }

        const quantity = Number(selectedQuantity) || 1
        setCart([...cart, { item: cartItem, quantity }])
        setSelectedItem(null)
        setSelectedVariantId(null)
        setSelectedQuantity(1)
        toast.success(`Added ${cartItem.item_name} to cart`)
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
                    <DialogHeader>
                        <DialogTitle className="text-xl font-heading font-bold text-gray-900 tracking-tight">
                            {isConsumable ? "💊 Dispense Consumable" : "📦 Dispatch Item"}
                        </DialogTitle>
                        <DialogDescription className="text-slate-500 font-medium">
                            {isConsumable
                                ? "Dispense one-time use items. No return required."
                                : "Assign inventory items to operational personnel and update registry levels."}
                        </DialogDescription>
                    </DialogHeader>

                    <div className="grid gap-6 py-4">
                        {/* 🚀 TACTICAL MODE TOGGLE */}
                        {!isConsumable && (
                            <Tabs value={intakeMode} onValueChange={(val: any) => setIntakeMode(val)} className="w-full">
                                <TabsList className="grid w-full grid-cols-2 h-12 p-1.5 bg-slate-100 rounded-xl">
                                    <TabsTrigger value="immediate" className="rounded-lg font-bold text-[10px] uppercase tracking-widest data-[state=active]:bg-white data-[state=active]:text-blue-600 data-[state=active]:shadow-sm">
                                        <Package className="h-3.5 w-3.5 mr-2" /> Issue Now (Real-time)
                                    </TabsTrigger>
                                    <TabsTrigger value="scheduled" className="rounded-lg font-bold text-[10px] uppercase tracking-widest data-[state=active]:bg-white data-[state=active]:text-amber-600 data-[state=active]:shadow-sm">
                                        <Clock className="h-3.5 w-3.5 mr-2" /> Schedule Reserve
                                    </TabsTrigger>
                                </TabsList>
                            </Tabs>
                        )}

                        {intakeMode === 'scheduled' && !isConsumable && (
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
                                        min={new Date(Date.now() - new Date().getTimezoneOffset() * 60000).toISOString().slice(0, 16)}
                                        value={pickupDate}
                                        onChange={(e) => setPickupDate(e.target.value)}
                                        className="h-11 bg-white border-amber-200 rounded-xl shadow-sm focus:ring-amber-500"
                                    />
                                    <p className="text-[9px] text-amber-600 font-medium">* Assets will be moved to the Command Queue.</p>
                                </div>
                            </div>
                        )}

                        <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
                            <div className="grid gap-2">
                                <Label htmlFor="borrower_name" className="text-sm font-semibold text-gray-700 flex items-center h-6">
                                    <span>Borrower Name <span className="text-red-500">*</span></span>
                                </Label>
                                <Input id="borrower_name" name="borrower_name" placeholder="Full name of borrower" required disabled={isPending} value={borrowerName} onChange={(e) => setBorrowerName(e.target.value)} className="rounded-lg border-gray-300" />
                            </div>
                            <div className="grid gap-2">
                                <Label htmlFor="contact_number" className="text-sm font-semibold text-gray-700 flex justify-between items-center h-6">
                                    <span>Contact Number <span className="text-red-500">*</span></span>
                                    {contactNumber.length > 0 && (
                                        <span className={cn(
                                            "text-[9px] font-bold uppercase py-0.5 px-2 rounded-full transition-all",
                                            contactNumber.length < 11 ? "bg-amber-100 text-amber-700 animate-pulse" :
                                            contactNumber.length === 11 ? "bg-emerald-100 text-emerald-700" :
                                            "bg-red-100 text-red-700"
                                        )}>
                                            {contactNumber.length < 11 
                                                ? `${11 - contactNumber.length} ${11 - contactNumber.length === 1 ? 'number' : 'numbers'} left`
                                                : contactNumber.length === 11 ? "Verified" : "Too long"}
                                        </span>
                                    )}
                                </Label>
                                <Input 
                                    id="contact_number" 
                                    name="contact_number" 
                                    type="tel" 
                                    placeholder="09XXXXXXXXX" 
                                    required 
                                    disabled={isPending} 
                                    value={contactNumber}
                                    onChange={(e) => {
                                        let val = e.target.value.replace(/\D/g, '');
                                        // Auto-normalize 639 to 09
                                        if (val.startsWith('639')) {
                                            val = '0' + val.slice(2);
                                        }
                                        setContactNumber(val.slice(0, 11));
                                    }}
                                    className="rounded-lg border-gray-300" 
                                />
                            </div>
                        </div>

                        <div className="grid grid-cols-12 gap-4 items-start">
                            <div className="col-span-12 md:col-span-8 flex flex-col gap-2">
                                <Label className="text-sm font-semibold text-slate-700">Select Item <span className="text-red-500">*</span></Label>
                                <Combobox
                                    options={availableItems.map(item => ({
                                        value: item.id.toString(),
                                        label: item.item_name,
                                        imageUrl: getInventoryImageUrl(item.image_url) || undefined,
                                        description: `${item.aggregate_available} units City-wide • ${item.category}`,
                                    }))}
                                    value={selectedItem?.id.toString()}
                                    onValueChange={handleItemSelect}
                                    placeholder={isLoadingItems ? "Loading items..." : "Search for an item..."}
                                    disabled={isPending || isLoadingItems}
                                />
                                
                                {/* 🎯 Equipment Verification Reveal */}
                                {selectedItem && (
                                    <div className="mt-1 animate-in zoom-in-95 fade-in duration-300">
                                        <LogisticsPreviewCard item={selectedItem as any} />
                                    </div>
                                )}
                            </div>

                            {selectedItem && selectedItem.variants && selectedItem.variants.length > 0 && (
                                <div className="col-span-12 animate-in slide-in-from-left-2 duration-300">
                                    <div className="p-4 bg-blue-50/50 rounded-xl border border-blue-100 flex flex-col md:flex-row md:items-center gap-4">
                                        <div className="flex items-center gap-2 text-blue-900 shrink-0">
                                            <Warehouse className="h-4 w-4" />
                                            <span className="text-xs font-bold uppercase tracking-wider">Pickup Site <span className="text-red-500">*</span></span>
                                        </div>
                                        <Select value={selectedVariantId || ''} onValueChange={setSelectedVariantId}>
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

                            <div className="col-span-6 md:col-span-2 space-y-2">
                                <Label htmlFor="quantity" className="text-sm font-semibold text-slate-700">Quantity <span className="text-red-500">*</span></Label>
                                <Input 
                                    id="quantity" 
                                    name="quantity" 
                                    type="number" 
                                    value={selectedQuantity === "" ? "" : selectedQuantity} 
                                    onChange={(e) => {
                                        const val = e.target.value;
                                        if (val === "") {
                                            setSelectedQuantity("");
                                        } else {
                                            setSelectedQuantity(parseInt(val) || 1);
                                        }
                                    }} 
                                    required 
                                    min={1} 
                                    disabled={isPending || !selectedItem} 
                                    className="h-11 rounded-lg border-slate-300 shadow-inner" 
                                />
                            </div>

                            <div className="col-span-6 md:col-span-2 space-y-2">
                                <Label className="text-sm font-semibold text-slate-700 opacity-0 pointer-events-none">Add</Label>
                                <Button type="button" onClick={handleAddToCart} disabled={!selectedItem || isPending} className="h-11 w-full bg-gradient-to-br from-blue-500 to-blue-600 hover:from-blue-600 hover:to-blue-700 text-white rounded-lg gap-2 font-semibold shadow-lg transition-all active:scale-[0.98]">
                                    <Plus className="h-4 w-4" /> Add
                                </Button>
                            </div>
                        </div>

                        {/* Cart Display */}
                        {cart.length > 0 && (
                            <div className="relative overflow-hidden rounded-2xl border border-blue-200/60 bg-gradient-to-br from-blue-50 via-white to-blue-50/30 p-5 shadow-lg animate-in fade-in duration-300">
                                <div className="relative space-y-4">
                                    <div className="flex items-center justify-between">
                                        <div className="flex items-center gap-2.5">
                                            <div className="flex h-9 w-9 items-center justify-center rounded-xl bg-gradient-to-br from-blue-500 to-blue-600 shadow-lg shadow-blue-500/25">
                                                <ShoppingCart className="h-4.5 w-4.5 text-white" />
                                            </div>
                                            <div>
                                                <h3 className="text-sm font-bold text-slate-800">Dispatch Cart</h3>
                                                <p className="text-xs text-slate-500">{cart.length} items ready</p>
                                            </div>
                                        </div>
                                    </div>
                                    <div className="space-y-2">
                                        {cart.map((cartItem) => (
                                            <div key={cartItem.item.id} className="flex items-center justify-between rounded-xl border border-slate-200/60 bg-white p-3.5 shadow-sm">
                                                <div className="flex-1 min-w-0 pr-3">
                                                    <h4 className="font-semibold text-slate-900 text-sm truncate">{cartItem.item.item_name}</h4>
                                                    <div className="flex items-center gap-2 text-xs text-slate-500">
                                                        <span className="font-medium text-slate-700">{cartItem.quantity}x</span> • <span>{cartItem.item.category}</span>
                                                    </div>
                                                </div>
                                                <Button type="button" variant="ghost" size="sm" onClick={() => setCart(cart.filter(c => c.item.id !== cartItem.item.id))} className="h-8 w-8 text-slate-400 hover:text-red-600">
                                                    <X className="h-4 w-4" />
                                                </Button>
                                            </div>
                                        ))}
                                    </div>
                                </div>
                            </div>
                        )}

                        {!isConsumable && (
                            <div className="grid gap-2">
                                <Label htmlFor="office_department" className="text-sm font-semibold text-gray-700">Office/Department <span className="text-red-500">*</span></Label>
                                <Input id="office_department" name="office_department" placeholder="E.g., CDRRMO Team Alpha" required disabled={isPending} className="rounded-lg border-gray-300" />
                            </div>
                        )}

                        {!isConsumable && (
                            <div className="grid grid-cols-1 md:grid-cols-2 gap-4 p-4 bg-gray-50 rounded-lg border border-gray-200">
                                <div className="grid gap-2">
                                    <Label className="text-sm font-semibold text-gray-700">Return Schedule <span className="text-red-500">*</span></Label>
                                    <Select value={returnType} onValueChange={(val: any) => setReturnType(val)} disabled={isPending}>
                                        <SelectTrigger className="bg-white border-gray-300"><SelectValue /></SelectTrigger>
                                        <SelectContent>
                                            <SelectItem value="anytime">Return Anytime / Open-ended</SelectItem>
                                            <SelectItem value="date">Specific Return Date</SelectItem>
                                        </SelectContent>
                                    </Select>
                                </div>
                                {returnType === 'date' && (
                                    <div className="grid gap-2 animate-in fade-in slide-in-from-top-2">
                                        <Label htmlFor="expected_return_date" className="text-sm font-semibold text-gray-700">Expected Return Date <span className="text-red-500">*</span></Label>
                                        <Input id="expected_return_date" name="expected_return_date" type="date" required={returnType === 'date'} disabled={isPending} min={new Date(Date.now() - new Date().getTimezoneOffset() * 60000).toISOString().split('T')[0]} className="bg-white border-gray-300" />
                                    </div>
                                )}
                            </div>
                        )}

                        <div className="grid gap-2">
                            <Label htmlFor="purpose" className="text-sm font-semibold text-gray-700">Purpose <span className="text-gray-400">(Optional)</span></Label>
                            <Input id="purpose" name="purpose" placeholder="Specific mission or task details..." disabled={isPending} className="rounded-lg border-gray-300 focus:border-blue-400" />
                        </div>

                        <div className="group/audit relative mt-2 overflow-hidden rounded-xl border border-slate-200 bg-white p-5 hover:border-blue-200">
                            <div className="relative space-y-4">
                                <div className="flex items-center gap-2 mb-1">
                                    <ShieldCheck className="h-4 w-4 text-blue-500" />
                                    <h4 className="text-[11px] font-bold text-slate-500 uppercase tracking-wider">Dispatch Sign-off</h4>
                                </div>
                                <div className="grid grid-cols-1 md:grid-cols-2 gap-5">
                                    <div className="grid gap-2">
                                        <Label htmlFor="approved_by" className="text-xs font-semibold text-slate-700 flex items-center gap-1.5"><UserCheck className="h-3.5 w-3.5 text-blue-500" /> Approved By <span className="text-red-500">*</span></Label>
                                        <div className="relative flex items-center">
                                            <Input id="approved_by" name="approved_by" placeholder="Name of approver" required value={approvedBy} onChange={(e) => setApprovedBy(e.target.value)} disabled={isPending} className="h-10 rounded-lg border-slate-200 bg-white px-3 text-sm focus:ring-2 focus:ring-blue-500/10 focus:border-blue-400 w-full pr-24" />
                                            <Button type="button" variant="ghost" size="sm" onClick={() => setApprovedBy(releasedBy)} className="absolute right-1 h-8 px-2 text-[10px] font-bold text-blue-600 hover:text-blue-700 rounded-md transition-colors">USE MY NAME</Button>
                                        </div>
                                    </div>
                                    <div className="grid gap-2">
                                        <Label htmlFor="released_by" className="text-xs font-semibold text-slate-700 flex items-center gap-1.5"><Package className="h-3.5 w-3.5 text-emerald-500" /> Released By <span className="text-red-500">*</span></Label>
                                        <Input id="released_by" name="released_by" required defaultValue={releasedBy} onChange={(e) => setReleasedBy(e.target.value)} disabled={isPending} placeholder="Staff releasing items" className="h-10 rounded-lg border-slate-200 bg-slate-50/50 px-3 text-sm transition-all" />
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>

                    <DialogFooter className="gap-2 pt-4 border-t border-gray-100 -mx-6 px-6">
                        <Button type="button" variant="ghost" onClick={() => setOpen(false)} disabled={isPending}>Cancel</Button>
                        <Button type="submit" disabled={isPending || (cart.length === 0 && !selectedItem)} className={`gap-2 rounded-xl min-w-[160px] font-bold shadow-lg transition-all ${cart.length > 0 ? 'bg-blue-600 hover:bg-blue-700 text-white' : 'bg-blue-600 hover:bg-blue-700 text-white'}`}>
                            {isPending ? <Loader2 className="h-4 w-4 animate-spin" /> : cart.length > 0 ? <><ShoppingCart className="h-4 w-4" /> Borrow {cart.length} Items</> : <><ClipboardList className="h-4 w-4" /> Confirm Dispatch</>}
                        </Button>
                    </DialogFooter>
                </form>
            </DialogContent>
        </Dialog>
    )
}
