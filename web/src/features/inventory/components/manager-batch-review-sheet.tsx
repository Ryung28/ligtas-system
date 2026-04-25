'use client'

import React, { useState, useMemo, useTransition, useEffect } from 'react'
import { 
    Package, 
    User, 
    ArrowRight, 
    AlertCircle, 
    Calendar, 
    CheckCircle2, 
    ChevronRight,
    Search,
    ShieldCheck,
    Contact,
    Building2,
    FileText,
    Loader2,
    X,
    Plus
} from 'lucide-react'
import { BottomSheet } from '@/components/mobile/primitives/bottom-sheet'
import { Input } from '@/components/ui/input'
import { Label } from '@/components/ui/label'
import { Button } from '@/components/ui/button'
import { Badge } from '@/components/ui/badge'
import { useDebounce } from '@/hooks/use-debounce'
import { useBorrowerRegistry } from '@/hooks/use-borrower-registry'
import { BatchLine, BatchMode } from '../types'
import { cn } from '@/lib/utils'
import { mFocus } from '@/lib/mobile/tokens'
import { batchBorrowItems } from '@/src/features/transactions/actions/transaction.actions'
import { toast } from 'sonner'
import { useRouter } from 'next/navigation'
import { useUser } from '@/providers/auth-provider'
import { TacticalAssetImage } from '@/src/shared/ui/tactical-asset-image'
import { getInventoryImageUrl } from '@/lib/supabase'

interface ManagerBatchReviewSheetProps {
    open: boolean
    onOpenChange: (open: boolean) => void
    mode: BatchMode
    items: BatchLine[]
    onComplete: () => void
    onImagePreview?: (url: string, name: string) => void
}

/**
 * 📋 Manager Batch Review Sheet (Logistics Edition)
 * 🏛️ ARCHITECTURE: Final Audit & Handoff
 * Handles personnel attribution, purpose, and final atomic dispatch.
 */
/**
 * 🔍 Borrower Search Section
 * 🏛️ ARCHITECTURE: Isolated search component to prevent sheet-wide lag
 */
const BorrowerSearchSection = ({ 
    borrowerName, 
    setBorrowerName, 
    isSearching, 
    borrowers, 
    handleSelectBorrower 
}: { 
    borrowerName: string;
    setBorrowerName: (val: string) => void;
    isSearching: boolean;
    borrowers: any[];
    handleSelectBorrower: (b: any) => void;
}) => {
    const [showSuggestions, setShowSuggestions] = useState(true)

    return (
        <div className="relative group">
            <Search className="absolute left-4 top-4 w-4 h-4 text-slate-400" />
            <Input 
                placeholder="Search or enter borrower name"
                value={borrowerName}
                onChange={(e) => {
                    setBorrowerName(e.target.value)
                    setShowSuggestions(true)
                }}
                onFocus={() => setShowSuggestions(true)}
                className="h-12 pl-11 bg-white border-slate-200 rounded-2xl font-bold shadow-sm"
            />
            {showSuggestions && borrowerName.length > 0 && (isSearching || borrowers.length > 0) && (
                <div className="absolute top-full left-0 right-0 mt-2 bg-white border border-slate-100 rounded-2xl shadow-2xl z-50 overflow-hidden py-1">
                    {isSearching ? (
                        <div className="px-4 py-6 flex flex-col items-center justify-center gap-2 text-slate-400">
                            <Loader2 className="w-5 h-5 animate-spin" />
                            <span className="text-[10px] font-black uppercase tracking-widest">Searching Registry...</span>
                        </div>
                    ) : (
                        borrowers.map((b: any) => (
                            <button
                                key={b.borrower_user_id || b.borrower_name}
                                onClick={() => {
                                    handleSelectBorrower(b)
                                    setShowSuggestions(false)
                                }}
                                className="w-full px-4 py-3 flex items-center gap-3 hover:bg-slate-50 text-left transition-colors border-b border-slate-50 last:border-0"
                            >
                                <div className="w-9 h-9 rounded-xl bg-slate-950 flex items-center justify-center shadow-lg shadow-slate-200 shrink-0">
                                    <User className="w-4 h-4 text-white" />
                                </div>
                                <div className="flex-1 min-w-0">
                                    <div className="flex items-center justify-between gap-2">
                                        <div className="flex items-center gap-1.5 min-w-0">
                                            <p className="text-sm font-bold text-slate-950 truncate tracking-tight">{b.borrower_name}</p>
                                            {b.is_verified_user && (
                                                <ShieldCheck className="w-3.5 h-3.5 text-blue-500 fill-blue-50" />
                                            )}
                                        </div>
                                        {b.active_items > 0 && (
                                            <Badge variant="outline" className="h-4 px-1.5 text-[8px] border-amber-200 bg-amber-50 text-amber-700 font-black shrink-0">
                                                {b.active_items} ACTIVE
                                            </Badge>
                                        )}
                                    </div>
                                    <div className="flex items-center gap-2">
                                        <p className="text-[10px] font-semibold text-slate-500 truncate">{b.last_organization || 'External Personnel'}</p>
                                    </div>
                                </div>
                            </button>
                        ))
                    )}
                </div>
            )}
        </div>
    )
}

const AuditList = React.memo(({ items, onImagePreview }: { items: BatchLine[], onImagePreview?: any }) => (
    <div className="space-y-6">
        <div className="space-y-4">
            <h3 className="text-[11px] font-black text-slate-950 uppercase tracking-[0.2em] px-1">ITEM LIST</h3>
            <div className="space-y-2.5">
                {items.map((item) => (
                    <div key={`${item.id}-${item.variant_id}`} className="flex items-center justify-between p-1 bg-white border border-slate-200 rounded-[24px] shadow-sm overflow-hidden">
                        <div className="flex items-center gap-4">
                            <div 
                                onClick={() => {
                                    const fullUrl = item.image_url ? getInventoryImageUrl(item.image_url) : null
                                    if (fullUrl && onImagePreview) onImagePreview(fullUrl, item.item_name)
                                }}
                                className="w-[76px] h-[76px] rounded-[20px] overflow-hidden flex items-center justify-center shrink-0 bg-slate-50 border border-slate-50 active:scale-95 transition-transform cursor-pointer"
                            >
                                <TacticalAssetImage 
                                    url={item.image_url} 
                                    alt={item.item_name}
                                    size="full"
                                    className="object-cover"
                                />
                            </div>
                            <div className="space-y-1">
                                <p className="text-[17px] font-bold text-slate-950 truncate max-w-[150px] tracking-tight">{item.item_name}</p>
                                <div className="flex items-center gap-2">
                                    <Badge variant="secondary" className="text-[9px] font-black uppercase py-0 px-1.5 h-4 bg-slate-100 text-slate-950 border-none">
                                        {item.location || 'Primary'}
                                    </Badge>
                                </div>
                            </div>
                        </div>
                        <div className="pr-6 text-right">
                            <p className="text-xl font-black text-slate-950 tabular-nums leading-none">{item.quantity}</p>
                            <p className="text-[9px] font-black text-slate-950 uppercase mt-0.5 tracking-tighter">Units</p>
                        </div>
                    </div>
                ))}
            </div>
        </div>
    </div>
))

export function ManagerBatchReviewSheet({
    open,
    onOpenChange,
    mode,
    items,
    onComplete,
    onImagePreview
}: ManagerBatchReviewSheetProps) {
    const router = useRouter()
    const { user } = useUser()
    const [step, setStep] = useState<'audit' | 'personnel'>('audit')
    const [isPending, startTransition] = useTransition()
    
    const [isScheduled, setIsScheduled] = useState(mode === 'reserve')
    const [borrowerName, setBorrowerName] = useState('')
    const [contactNumber, setContactNumber] = useState('')
    const [department, setDepartment] = useState('')
    const [purpose, setPurpose] = useState('')
    const [approvedBy, setApprovedBy] = useState('')
    const [returnDate, setReturnDate] = useState<string>('')
    const [pickupDate, setPickupDate] = useState<string>('')

    const debouncedSearch = useDebounce(borrowerName, 250)

    // Sync isScheduled with mode
    useEffect(() => {
        setIsScheduled(mode === 'reserve')
    }, [mode])

    // 🚀 TACTICAL SEARCH ENGINE: Reusing web-parity personnel registry
    const { borrowers, isLoading: isSearching } = useBorrowerRegistry({ 
        search: debouncedSearch, 
        page: 1, 
        limit: 5 
    })

    const handleSelectBorrower = (b: any) => {
        setBorrowerName(b.borrower_name)
        setContactNumber(b.last_contact || '')
        setDepartment(b.last_organization || '')
    }

    const isValid = useMemo(() => {
        const basic = borrowerName && contactNumber && department && purpose && approvedBy
        if (isScheduled) return basic && pickupDate
        return basic
    }, [borrowerName, contactNumber, department, purpose, approvedBy, isScheduled, pickupDate])

    const handleDispatch = () => {
        if (!isValid) return

        startTransition(async () => {
            try {
                const result = await batchBorrowItems({
                    borrower_name: borrowerName,
                    contact_number: contactNumber,
                    office_department: department,
                    purpose,
                    approved_by: approvedBy,
                    released_by: user?.user_metadata?.full_name || user?.email || 'Authorized Staff',
                    expected_return_date: returnDate || null,
                    pickup_scheduled_at: isScheduled ? pickupDate : null,
                    items: items.map(item => ({
                        item_id: item.id,
                        quantity: item.quantity,
                        item_type: item.item_type || 'equipment',
                        inventory_variant_id: item.variant_id
                    }))
                })

                if (result.success) {
                    toast.success(
                        mode === 'reserve' ? 'Reservation Staged' : 'Dispatch Complete', 
                        { description: result.message }
                    )
                    onComplete()
                    onOpenChange(false)
                    router.push('/m/inventory')
                } else {
                    toast.error('Dispatch Failed', { description: result.error })
                }
            } catch (err: any) {
                toast.error('Tactical Error', { description: err.message || 'Atomic transaction failed.' })
            }
        })
    }

    const title = mode === 'reserve' ? 'Finalize Reservation' : 'Finalize Hand Borrow'
    const description = `Reviewing ${items.length} unique items for ${mode === 'reserve' ? 'staging' : 'immediate handoff'}.`

    return (
        <BottomSheet 
            open={open} 
            onOpenChange={onOpenChange} 
            title={title}
            description={description}
            size="full"
            className="[&_h2]:text-[19px] [&_p]:text-[15px] [&_h2]:tracking-tight [&_p]:leading-relaxed"
            footer={
                <div className="flex gap-3">
                    {step === 'personnel' && (
                        <Button 
                            variant="outline" 
                            className="flex-1 h-12 rounded-2xl font-bold"
                            onClick={() => setStep('audit')}
                        >
                            Back
                        </Button>
                    )}
                    <Button 
                        className={cn(
                            "flex-[2] h-12 rounded-2xl font-bold gap-2",
                            mode === 'reserve' ? "bg-slate-900" : "bg-emerald-600"
                        )}
                        disabled={step === 'personnel' ? !isValid || isPending : false}
                        onClick={() => {
                            if (step === 'audit') setStep('personnel')
                            else handleDispatch()
                        }}
                    >
                        {isPending ? <Loader2 className="w-4 h-4 animate-spin" /> : (
                            <>
                                {step === 'audit' ? (
                                    <>
                                        Next: Personnel Info
                                        <ChevronRight className="w-4 h-4" />
                                    </>
                                ) : (
                                    <>
                                        {mode === 'reserve' ? 'Confirm Reservation' : 'Confirm & Dispatch'}
                                        <CheckCircle2 className="w-4 h-4" />
                                    </>
                                )}
                            </>
                        )}
                    </Button>
                </div>
            }
        >
            {step === 'audit' ? (
                <AuditList items={items} onImagePreview={onImagePreview} />
            ) : (
                <div className="space-y-8 animate-in slide-in-from-right-4 duration-300">
                    {/* 👤 Personnel Identity Form */}
                    <div className="space-y-6">
                            <div className="space-y-3 p-4 bg-slate-50 border border-slate-100 rounded-2xl">
                                <Label className="text-[10px] font-black text-slate-950 uppercase tracking-widest px-1">Logistics Timing</Label>
                                <div className="flex gap-2 p-1 bg-slate-200/50 rounded-xl">
                                    <button 
                                        type="button"
                                        onClick={() => setIsScheduled(false)}
                                        className={cn(
                                            "flex-1 py-2 text-[10px] font-black uppercase rounded-lg transition-all",
                                            !isScheduled ? "bg-white text-slate-950 shadow-sm" : "text-slate-400"
                                        )}
                                    >
                                        Immediate
                                    </button>
                                    <button 
                                        type="button"
                                        onClick={() => setIsScheduled(true)}
                                        className={cn(
                                            "flex-1 py-2 text-[10px] font-black uppercase rounded-lg transition-all",
                                            isScheduled ? "bg-white text-slate-950 shadow-sm" : "text-slate-400"
                                        )}
                                    >
                                        Scheduled
                                    </button>
                                </div>

                                {isScheduled && (
                                    <div className="pt-2 space-y-1.5 animate-in slide-in-from-top-2 duration-300">
                                        <div className="flex items-center gap-1.5 px-1 text-slate-500">
                                            <Calendar className="w-3 h-3 text-blue-600" />
                                            <span className="text-[10px] font-black uppercase">Pickup Date</span>
                                        </div>
                                        <Input 
                                            type="date"
                                            value={pickupDate}
                                            onChange={(e) => setPickupDate(e.target.value)}
                                            className="h-11 bg-white border-slate-100 rounded-xl font-bold text-sm"
                                        />
                                    </div>
                                )}
                            </div>

                            <div className="space-y-3">
                                <Label className="text-[11px] font-black text-slate-400 uppercase tracking-widest px-1">Borrower Attribution</Label>
                                <BorrowerSearchSection 
                                    borrowerName={borrowerName}
                                    setBorrowerName={setBorrowerName}
                                    isSearching={isSearching}
                                    borrowers={borrowers}
                                    handleSelectBorrower={handleSelectBorrower}
                                />
                            </div>

                            <div className="grid grid-cols-2 gap-3">
                                <div className="space-y-1.5">
                                    <div className="flex items-center gap-1.5 px-1 text-slate-500">
                                        <Contact className="w-3 h-3" />
                                        <span className="text-[10px] font-black uppercase">Contact</span>
                                    </div>
                                    <Input 
                                        placeholder="09XXXXXXXXX"
                                        value={contactNumber}
                                        onChange={(e) => setContactNumber(e.target.value)}
                                        className="h-11 bg-white border-slate-100 rounded-xl font-bold text-sm"
                                    />
                                </div>
                                <div className="space-y-1.5">
                                    <div className="flex items-center gap-1.5 px-1 text-slate-500">
                                        <Building2 className="w-3 h-3" />
                                        <span className="text-[10px] font-black uppercase">Unit/Dept</span>
                                    </div>
                                    <Input 
                                        placeholder="Office name"
                                        value={department}
                                        onChange={(e) => setDepartment(e.target.value)}
                                        className="h-11 bg-white border-slate-100 rounded-xl font-bold text-sm"
                                    />
                                </div>
                            </div>
                        </div>

                        <div className="space-y-3">
                            <Label className="text-[11px] font-black text-slate-400 uppercase tracking-widest px-1">Tactical Metadata</Label>
                            <div className="space-y-4">
                                <div className="space-y-1.5">
                                    <div className="flex items-center gap-1.5 px-1 text-slate-500">
                                        <FileText className="w-3 h-3" />
                                        <span className="text-[10px] font-black uppercase">Mission Purpose</span>
                                    </div>
                                    <Input 
                                        placeholder="Deployment or training details"
                                        value={purpose}
                                        onChange={(e) => setPurpose(e.target.value)}
                                        className="h-11 bg-white border-slate-100 rounded-xl font-bold text-sm"
                                    />
                                </div>

                                <div className="space-y-1.5">
                                    <div className="flex items-center gap-1.5 px-1 text-slate-500">
                                        <ShieldCheck className="w-3 h-3 text-emerald-600" />
                                        <span className="text-[10px] font-black uppercase">Authorized By</span>
                                    </div>
                                    <div className="relative">
                                        <Input 
                                            placeholder="Name of approving officer"
                                            value={approvedBy}
                                            onChange={(e) => setApprovedBy(e.target.value)}
                                            className="h-11 bg-white border-slate-100 rounded-xl font-bold text-sm pr-12"
                                        />
                                        <button 
                                            onClick={() => setApprovedBy(user?.user_metadata?.full_name || '')}
                                            className="absolute right-3 top-2.5 text-[9px] font-black text-blue-600 uppercase"
                                        >
                                            Self
                                        </button>
                                    </div>
                                </div>
                            </div>
                        </div>

                        <div className="space-y-3 p-5 bg-slate-50 border border-slate-100 rounded-2xl">
                            <div className="flex items-center justify-between">
                                <Label className="text-[11px] font-black text-slate-950 uppercase">Return Schedule</Label>
                                <Badge variant="outline" className="text-[9px] font-black uppercase h-5 bg-white">Optional</Badge>
                            </div>
                            <div className="relative">
                                <Calendar className="absolute left-3 top-3 w-4 h-4 text-slate-400" />
                                <Input 
                                    type="date"
                                    value={returnDate}
                                    onChange={(e) => setReturnDate(e.target.value)}
                                    className="h-11 pl-10 bg-white border-slate-100 rounded-xl font-bold text-sm"
                                />
                            </div>
                        </div>

                </div>
            )}
        </BottomSheet>
    )
}
