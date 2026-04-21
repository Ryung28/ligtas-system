'use client'

import { useState, useTransition, useEffect, useMemo } from 'react'
import { useRouter } from 'next/navigation'
import { ClipboardList, Loader2, RotateCcw, Package, Plus, X, ShoppingCart, Clock, ShieldCheck, UserCheck, UserPlus, Warehouse, Search, Info, MapPin, Box, Calendar } from 'lucide-react'
import { motion, AnimatePresence } from 'framer-motion'
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
import { BatchSelector } from '../_components/batch-selector'
import { BorrowerNameField } from '../_components/borrower-name-field'
import { BorrowerStats } from '@/hooks/use-borrower-registry'
import { cn } from '@/lib/utils'
import { TacticalAssetPreview } from '@/src/shared/ui/tactical-asset-preview'

// V3 API Bridge (Mapped to domain actions for atomic stock management)
import { batchBorrowItems, borrowItem } from '../actions/transaction.actions'
import { useAvailableCatalog } from '../hooks/use-available-catalog'
import { useBorrowCart } from '../hooks/use-borrow-cart'

interface AvailableItem {
    id: number
    item_name: string
    category: string
    item_type?: 'equipment' | 'consumable'
    storage_location?: string
    primary_location?: string
    primary_stock_available: number
    aggregate_available: number
    stock_pending: number
    image_url?: string
    variants: Array<{
        id: number
        storage_location: string
        stock_available: number
        stock_total: number
    }>
    status: string
}

interface CartItem {
    cart_key: string;
    item: AvailableItem;
    quantity: number;
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
    const [selectedBatchId, setSelectedBatchId] = useState<string | null>(null)
    const [borrowerName, setBorrowerName] = useState('')
    const [borrowerManualEntry, setBorrowerManualEntry] = useState(false)
    const [contactNumber, setContactNumber] = useState('')
    const [intakeMode, setIntakeMode] = useState<'immediate' | 'scheduled'>('immediate')
    const [pickupDate, setPickupDate] = useState<string>('')
    const [returnType, setReturnType] = useState<'anytime' | 'date'>('anytime')
    const [releasedBy, setReleasedBy] = useState('Brandon James C. Galabin')
    const [approvedBy, setApprovedBy] = useState('')
    const [officeDepartment, setOfficeDepartment] = useState('')

    const handleBorrowerSelect = (borrower: BorrowerStats) => {
        if (borrower.last_contact) {
            setContactNumber(borrower.last_contact);
        }
        if (borrower.last_organization) {
            setOfficeDepartment(borrower.last_organization);
        }
    };

    const supabase = createClient()
    const router = useRouter()
    const [mounted, setMounted] = useState(false)

    useEffect(() => {
        setMounted(true)
    }, [])

    useEffect(() => {
        if (!open) setBorrowerManualEntry(false)
    }, [open])

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
            
            const commonData = {
                borrower_name: bName,
                contact_number: cNumber,
                office_department: oDept,
                purpose: purpose,
                released_by: releasedByInput,
                approved_by: approvedByVal,
                expected_return_date: returnType === 'date' ? expectedReturnDate : null,
                pickup_scheduled_at: intakeMode === 'scheduled' ? pickupDate : null,
            };

            if (cart.length > 0) {
                const items = cart.map(c => ({
                    item_id: c.item.id,
                    quantity: c.quantity,
                    item_type: c.item.item_type || 'equipment',
                    source_batch: (c.item as any).source_batch || null
                }));
                
                result = await batchBorrowItems({
                    ...commonData,
                    items
                });
            } else if (selectedItem) {
                result = await borrowItem({
                    ...commonData,
                    item_id: selectedItem.id,
                    quantity: Number(selectedQuantity) || 1,
                    source_batch: selectedBatchId ? { batch_id: selectedBatchId, label: selectedItem.packaging_json?.batches?.find((b: any) => b.id === selectedBatchId)?.label } : null
                });
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
                setBorrowerManualEntry(false)
                setContactNumber('')
                setOfficeDepartment('')
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
        setSelectedBatchId(null)
    }

    const handleAddToCart = () => {
        if (!selectedItem) return;
        if (selectedItem.variants?.length > 0 && !selectedVariantId) {
            toast.error('Please select a pickup location');
            return;
        }

        let maxAvailable = selectedItem.primary_stock_available
        let targetId = selectedItem.id

        if (selectedVariantId) {
            const variant = selectedItem.variants?.find(v => String(v.id) === selectedVariantId)
            if (variant) {
                maxAvailable = variant.stock_available
                targetId = variant.id
            }
        }

        const selectedQuantityNumber = Number(selectedQuantity) || 0
        if (selectedQuantityNumber > maxAvailable) {
            toast.error(`Only ${maxAvailable} units available`);
            return;
        }

        const cartItem: any = {
            ...selectedItem,
            id: targetId,
            item_name: selectedVariantId 
                ? `${selectedItem.item_name} (${selectedItem.variants?.find(v => String(v.id) === selectedVariantId)?.storage_location || 'Distributed'})`
                : selectedItem.item_name,
            source_batch: selectedBatchId ? { batch_id: selectedBatchId, label: (selectedItem as any).packaging_json?.batches?.find((b: any) => b.id === selectedBatchId)?.label } : null
        }

        const quantity = Number(selectedQuantity) || 1
        const cart_key = `${targetId}-${selectedBatchId || 'none'}`
        
        // Remove existing entry for same key if any to prevent duplicates in list
        const filteredCart = cart.filter(c => c.cart_key !== cart_key)
        setCart([...filteredCart, { cart_key, item: cartItem, quantity }])
        
        setSelectedItem(null)
        setSelectedVariantId(null)
        setSelectedBatchId(null)
        setSelectedQuantity(1)
        toast.success(`Added ${cartItem.item_name} to cart`)
    }

    const handleRemoveFromCart = (cartKey: string) => {
        setCart(cart.filter(c => c.cart_key !== cartKey))
    }

    if (!mounted) return null

    return (
        <Dialog open={open} onOpenChange={setOpen}>
            <DialogTrigger asChild>
                <Button className="h-10 bg-blue-600 hover:bg-blue-700 text-white shadow-xl shadow-blue-600/20 text-xs font-semibold tracking-wide transition-all active:scale-95 px-5 rounded-xl gap-2">
                    <ClipboardList className="h-4 w-4" />
                    Borrow Item
                </Button>
            </DialogTrigger>
            <DialogContent className="sm:max-w-[850px] w-[95vw] h-[90vh] p-0 overflow-hidden flex flex-col border-none shadow-2xl bg-white">
                <form onSubmit={handleSubmit} className="flex flex-col h-full overflow-hidden">
                    <div className="px-8 pt-8 pb-4 shrink-0 bg-white border-b border-slate-100">
                        <DialogHeader>
                            <DialogTitle className="text-xl font-bold text-gray-900 tracking-tight flex items-center gap-2">
                                <ClipboardList className="h-5 w-5 text-blue-600" />
                                {isConsumable ? "💊 Dispense Consumable" : "📦 Tactical Dispatch Ledger"}
                            </DialogTitle>
                            <DialogDescription className="text-slate-500 font-medium">
                                {isConsumable
                                    ? "Dispense one-time use items from regional stockpiles."
                                    : "Execute rapid inventory issuance to personnel. Traceability is guaranteed via batch logs."}
                            </DialogDescription>
                        </DialogHeader>
                    </div>

                    <div className="flex-1 overflow-y-auto px-8 py-6 space-y-8">
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

                        <div className="flex flex-col gap-2">
                            <div className="grid grid-cols-1 md:grid-cols-2 gap-x-4 gap-y-1">
                                <Label htmlFor="borrower_name" className="text-sm font-semibold text-gray-700 flex items-center min-h-6">
                                    <span>Borrower Name <span className="text-red-500">*</span></span>
                                </Label>
                                <Label htmlFor="contact_number" className="text-sm font-semibold text-gray-700 flex justify-between items-center gap-2 min-h-6">
                                    <span>Contact Number <span className="text-red-500">*</span></span>
                                    {contactNumber.length > 0 && (
                                        <span className={cn(
                                            "shrink-0 text-[9px] font-bold uppercase py-0.5 px-2 rounded-full transition-all",
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
                            </div>
                            <div className="grid grid-cols-1 md:grid-cols-2 gap-x-4 gap-y-2 md:items-start">
                                <BorrowerNameField
                                    id="borrower_name"
                                    value={borrowerName}
                                    onChange={setBorrowerName}
                                    onSelect={handleBorrowerSelect}
                                    disabled={isPending}
                                    dialogOpen={open}
                                    manual={borrowerManualEntry}
                                    onManualChange={setBorrowerManualEntry}
                                />
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
                                        if (val.startsWith('639')) {
                                            val = '0' + val.slice(2);
                                        }
                                        setContactNumber(val.slice(0, 11));
                                    }}
                                    className="h-11 rounded-lg border-gray-300"
                                />
                            </div>
                            <div className="min-h-[22px]">
                                {borrowerManualEntry ? (
                                    <button
                                        type="button"
                                        disabled={isPending}
                                        onClick={() => setBorrowerManualEntry(false)}
                                        className="text-[11px] font-semibold text-blue-600 hover:text-blue-700 hover:underline"
                                    >
                                        Search registry instead
                                    </button>
                                ) : (
                                    <button
                                        type="button"
                                        disabled={isPending}
                                        onClick={() => setBorrowerManualEntry(true)}
                                        className="flex items-center gap-1.5 text-[11px] font-semibold text-blue-600 hover:text-blue-700 hover:underline"
                                    >
                                        <UserPlus className="h-3.5 w-3.5 shrink-0" />
                                        New borrower (manual entry)
                                    </button>
                                )}
                            </div>
                        </div>

                        {/* 🎯 THE DISPATCH ENGINE (PICK & LIST) */}
                        <div className="grid grid-cols-1 lg:grid-cols-5 gap-6 border-t border-slate-100 pt-6">
                            
                            {/* LEFT SIDE: SELECTOR */}
                            <div className="lg:col-span-3 space-y-5">
                                <div className="space-y-3">
                                    <Label className="text-[10px] font-bold uppercase tracking-widest text-slate-400">1. Select Equipment</Label>
                                    <Combobox
                                        options={availableItems.map(item => ({
                                            value: item.id.toString(),
                                            label: item.item_name,
                                            imageUrl: getInventoryImageUrl(item.image_url) || undefined,
                                            description: `${item.aggregate_available} units City-wide • ${item.category}`,
                                        }))}
                                        value={selectedItem?.id.toString()}
                                        onValueChange={handleItemSelect}
                                        placeholder={isLoadingItems ? "Loading..." : "Search equipment name..."}
                                        disabled={isPending || isLoadingItems}
                                    />
                                </div>
                                    <AnimatePresence mode="wait">
                                        {selectedItem && (
                                            <motion.div 
                                                key="preview"
                                                initial={{ opacity: 0, height: 0 }}
                                                animate={{ opacity: 1, height: 'auto' }}
                                                exit={{ opacity: 0, height: 0 }}
                                                transition={{ duration: 0.2 }}
                                            >
                                                <TacticalAssetPreview 
                                                    item={{
                                                        item_name: selectedItem.item_name,
                                                        category: selectedItem.category,
                                                        image_url: selectedItem.image_url,
                                                        item_type: selectedItem.item_type,
                                                        storage_location: selectedItem.storage_location,
                                                        aggregate_available: selectedItem.aggregate_available
                                                    }} 
                                                    className="border-blue-100 bg-blue-50/20"
                                                />
                                            </motion.div>
                                        )}
                                    </AnimatePresence>

                                <AnimatePresence>
                                    {selectedItem && (
                                        <motion.div 
                                            key="config-panel"
                                            initial={{ opacity: 0, y: -10 }}
                                            animate={{ opacity: 1, y: 0 }}
                                            exit={{ opacity: 0, y: -10 }}
                                            className="space-y-4"
                                        >
                                            {/* LOCATION PICKER */}
                                            <div className="space-y-3">
                                                <Label className="text-[10px] font-bold uppercase tracking-widest text-slate-400">2. Take from where?</Label>
                                                <div className="flex flex-wrap gap-2">
                                                    <button 
                                                        type="button"
                                                        onClick={() => setSelectedVariantId(null)}
                                                        className={cn(
                                                            "flex-1 min-w-[140px] px-4 py-3 rounded-xl border-2 transition-all text-left",
                                                            selectedVariantId === null 
                                                                ? "bg-blue-50 border-blue-500 ring-4 ring-blue-50" 
                                                                : "bg-white border-slate-100 hover:border-slate-200"
                                                        )}
                                                    >
                                                        <p className={cn("text-[11px] font-bold", selectedVariantId === null ? "text-blue-700" : "text-slate-600")}>
                                                            {selectedItem.storage_location || 'Main Hub'}
                                                        </p>
                                                        <p className="text-[9px] text-slate-400 font-medium">Ready: {selectedItem.primary_stock_available}</p>
                                                    </button>

                                                    {selectedItem.variants?.map(v => (
                                                        <button
                                                            key={v.id}
                                                            type="button"
                                                            onClick={() => setSelectedVariantId(String(v.id))}
                                                            disabled={v.stock_available <= 0}
                                                            className={cn(
                                                                "flex-1 min-w-[140px] px-4 py-3 rounded-xl border-2 transition-all text-left",
                                                                selectedVariantId === String(v.id) 
                                                                    ? "bg-blue-50 border-blue-500 ring-4 ring-blue-50" 
                                                                    : v.stock_available <= 0
                                                                        ? "bg-slate-50 border-slate-50 opacity-40 cursor-not-allowed"
                                                                        : "bg-white border-slate-100 hover:border-slate-200"
                                                            )}
                                                        >
                                                            <p className={cn("text-[11px] font-bold", selectedVariantId === String(v.id) ? "text-blue-700" : "text-slate-600")}>
                                                                {v.storage_location}
                                                            </p>
                                                            <p className="text-[9px] text-slate-400 font-medium">Ready: {v.stock_available}</p>
                                                        </button>
                                                    ))}
                                                </div>
                                            </div>

                                            {/* 📦 BATCH PICKER (Shared Component) */}
                                            <BatchSelector 
                                                packagingJson={selectedItem.packaging_json}
                                                selectedBatchId={selectedBatchId}
                                                onSelectBatch={setSelectedBatchId}
                                                unitLabel={selectedItem.unit}
                                            />

                                            {/* QTY & ACTION */}
                                            <div className="flex items-end gap-3 pt-2">
                                                <div className="flex-1 space-y-2">
                                                    <Label className="text-[10px] font-bold uppercase tracking-widest text-slate-400">3. How many?</Label>
                                                    <Input 
                                                        type="number" 
                                                        value={selectedQuantity} 
                                                        onChange={e => setSelectedQuantity(e.target.value === "" ? "" : Number(e.target.value))}
                                                        className="h-12 text-lg font-bold rounded-xl"
                                                    />
                                                </div>
                                                <Button 
                                                    type="button" 
                                                    onClick={handleAddToCart}
                                                    className="h-12 px-8 bg-blue-600 hover:bg-blue-700 text-white font-bold rounded-xl shadow-lg shadow-blue-200 transition-all active:scale-95"
                                                >
                                                    Add to list
                                                </Button>
                                            </div>
                                        </motion.div>
                                    )}
                                </AnimatePresence>
                            </div>

                            {/* RIGHT SIDE: THE LIST (MANIFEST) */}
                            <div className="lg:col-span-2">
                                <div className="h-full min-h-[200px] bg-slate-50/50 rounded-2xl border-2 border-dashed border-slate-200 p-4 flex flex-col">
                                    <div className="flex items-center justify-between mb-4">
                                        <Label className="text-[11px] font-black uppercase tracking-widest text-slate-500">Items for Respondent</Label>
                                        {cart.length > 0 && <span className="text-[11px] font-bold px-2 py-0.5 bg-blue-100 text-blue-700 rounded-full">{cart.length} items</span>}
                                    </div>

                                    {cart.length === 0 ? (
                                        <div className="flex-1 flex flex-col items-center justify-center text-center p-6 space-y-2 opacity-40">
                                            <ShoppingCart className="w-8 h-8 text-slate-400" />
                                            <p className="text-[11px] font-bold text-slate-500">No items added yet</p>
                                        </div>
                                    ) : (
                                        <div className="space-y-2 flex-1 overflow-y-auto max-h-[300px] pr-1">
                                            {cart.map((c) => (
                                                <div key={c.cart_key} className="group bg-white border border-slate-200 p-3 rounded-xl flex items-center justify-between shadow-sm hover:border-blue-200 transition-all">
                                                    <div className="min-w-0 pr-2">
                                                        <p className="text-[13px] font-bold text-slate-900 truncate">{c.item.item_name}</p>
                                                        <p className="text-[10px] text-slate-400 font-medium uppercase">{c.quantity}x • From {c.item.item_name.split('(')[1]?.replace(')', '') || 'Main Hub'}</p>
                                                    </div>
                                                    <button 
                                                        type="button"
                                                        onClick={() => handleRemoveFromCart(c.cart_key)}
                                                        className="w-7 h-7 flex items-center justify-center rounded-lg text-slate-300 hover:bg-red-50 hover:text-red-500 transition-all"
                                                    >
                                                        <X className="w-4 h-4" />
                                                    </button>
                                                </div>
                                            ))}
                                        </div>
                                    )}

                                    {cart.length > 0 && (
                                        <Button 
                                            variant="ghost" 
                                            onClick={() => {v3ClearCart(); setCart([]);}}
                                            className="mt-4 text-[11px] font-bold text-slate-400 hover:text-red-600 transition-colors uppercase tracking-widest"
                                        >
                                            Clear All
                                        </Button>
                                    )}
                                </div>
                            </div>
                        </div>

                        {!isConsumable && (
                            <div className="grid gap-2">
                                <Label htmlFor="office_department" className="text-sm font-semibold text-gray-700">Office/Department <span className="text-red-500">*</span></Label>
                                <Input id="office_department" name="office_department" placeholder="E.g., CDRRMO Team Alpha" required disabled={isPending} value={officeDepartment} onChange={(e) => setOfficeDepartment(e.target.value)} className="rounded-lg border-gray-300" />
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

                    <DialogFooter className="px-8 py-6 bg-white border-t border-slate-100 shrink-0">
                        <Button
                            type="button"
                            variant="ghost"
                            onClick={() => setOpen(false)}
                            disabled={isPending}
                            className="rounded-xl h-12 px-6 font-bold text-slate-500 hover:bg-slate-50 transition-all"
                        >
                            Cancel Operation
                        </Button>
                        <Button
                            type="submit"
                            disabled={isPending || (cart.length === 0 && !selectedItem)}
                            className="bg-blue-600 hover:bg-blue-700 h-12 text-white gap-2 flex-1 md:flex-none md:min-w-[200px] rounded-xl font-black shadow-xl shadow-blue-200 transition-all active:scale-[0.98] text-sm uppercase tracking-wider"
                        >
                            {isPending ? (
                                <Loader2 className="h-5 w-5 animate-spin" />
                            ) : cart.length > 0 ? (
                                <>
                                    <ShoppingCart className="h-5 w-5" />
                                    Finalize Dispatch ({cart.length})
                                </>
                            ) : (
                                <>
                                    <ShieldCheck className="h-5 w-5" />
                                    Confirm Single Issuance
                                </>
                            )}
                        </Button>
                    </DialogFooter>
                </form>
            </DialogContent>
        </Dialog>
    )
}
