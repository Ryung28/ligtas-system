'use client'

import { useState, useEffect } from 'react'
import { 
    Sheet, 
    SheetContent, 
    SheetHeader, 
    SheetTitle,
    SheetDescription
} from '@/components/ui/sheet'
import { Button } from '@/components/ui/button'
import { Input } from '@/components/ui/input'
import { Label } from '@/components/ui/label'
import { TacticalAssetImage } from '@/src/shared/ui/tactical-asset-image'
import { borrowItem } from '@/src/features/transactions/actions/transaction.actions'
import { Minus, Plus, Search, User, Phone, Building2, CheckCircle2, Loader2, AlertCircle } from 'lucide-react'
import { toast } from 'sonner'
import { cn } from '@/lib/utils'
import { getCurrentUser } from '@/lib/auth'

interface DirectBorrowSheetProps {
    isOpen: boolean
    onOpenChange: (open: boolean) => void
    item: {
        id: number
        name: string
        image_url?: string | null
        stock_available: number
        item_type: 'equipment' | 'consumable'
    }
    onSuccess?: () => void
}

export function DirectBorrowSheet({ isOpen, onOpenChange, item, onSuccess }: DirectBorrowSheetProps) {
    const [quantity, setQuantity] = useState(1)
    const [borrowerName, setBorrowerName] = useState('')
    const [contactNo, setContactNo] = useState('')
    const [office, setOffice] = useState('')
    const [approvedBy, setApprovedBy] = useState('')
    const [issuerName, setIssuerName] = useState('')
    const [isSubmitting, setIsSubmitting] = useState(false)

    // Hydrate from User Profile on open
    useEffect(() => {
        const hydrateProfile = async () => {
            if (isOpen) {
                setQuantity(1)
                setIsSubmitting(false)
                
                // 🔐 Fetch session profile for default autofill
                const user = await getCurrentUser()
                if (user) {
                    setBorrowerName(user.full_name || '')
                    setContactNo(user.phone || '') // From auth metadata or profile
                    setOffice(user.department || '')
                    setIssuerName(user.full_name || 'System')
                }
            }
        }
        hydrateProfile()
    }, [isOpen, item.id])


    const handleSubmit = async () => {
        if (!borrowerName || !contactNo) {
            toast.error('Name and Contact Number are required')
            return
        }

        if (!/^09\d{9}$/.test(contactNo)) {
            toast.error('Contact must be a valid PH mobile number (09XXXXXXXXX)')
            return
        }

        setIsSubmitting(true)
        try {
            const res = await borrowItem({
                item_id: item.id,
                quantity,
                borrower_name: borrowerName,
                contact_number: contactNo,
                office_department: office,
                approved_by: approvedBy,
                purpose: 'Borrow Equipment (QR Scan)',
            })

            if (res.success) {
                toast.success(res.message)
                onOpenChange(false)
                onSuccess?.()
            } else {
                toast.error(res.error || 'Failed to borrow item')
            }
        } catch (err) {
            toast.error('An unexpected error occurred')
        } finally {
            setIsSubmitting(false)
        }
    }

    return (
        <Sheet open={isOpen} onOpenChange={onOpenChange}>
            <SheetContent side="bottom" className="h-[94vh] sm:h-auto sm:max-h-[90vh] rounded-t-[32px] p-0 overflow-hidden border-none shadow-2xl transition-all duration-300">
                <div className="flex flex-col h-full bg-slate-50">
                    {/* Header: Hero Area */}
                    <SheetHeader className="bg-white p-6 pb-4 shadow-sm text-left">
                        <div className="w-12 h-1.5 bg-slate-200 rounded-full mx-auto mb-6" />
                        
                        <div className="flex items-center gap-5">
                            <TacticalAssetImage 
                                url={item.image_url} 
                                alt={item.name} 
                                size="xl"
                                className="rounded-2xl border-slate-100 bg-slate-50"
                            />
                            <div className="flex-1 min-w-0">
                                <SheetTitle className="text-2xl font-black italic uppercase tracking-tight leading-tight text-slate-950 truncate">
                                    {item.name}
                                </SheetTitle>
                                <SheetDescription className="flex items-center gap-2 mt-1">
                                    <span className={cn(
                                        "w-2 h-2 rounded-full",
                                        item.stock_available > 0 ? "bg-emerald-500" : "bg-red-500"
                                    )} />
                                    <span className="text-[13px] font-bold text-slate-500 uppercase tracking-wide">
                                        {item.stock_available} Units Available
                                    </span>
                                </SheetDescription>
                            </div>
                        </div>
                    </SheetHeader>

                    <div className="flex-1 overflow-y-auto p-6 space-y-8 pb-32">
                        {/* 🚫 OUT OF STOCK GUARD */}
                        {item.stock_available <= 0 && (
                            <div className="bg-red-50 border border-red-100 p-6 rounded-3xl flex flex-col items-center text-center space-y-3 animate-in fade-in zoom-in-95">
                                <div className="w-12 h-12 bg-white rounded-2xl flex items-center justify-center shadow-sm">
                                    <AlertCircle className="w-6 h-6 text-red-500" />
                                </div>
                                <div>
                                    <h3 className="font-black text-red-900 uppercase italic tracking-tight">Resource Depleted</h3>
                                    <p className="text-[12px] text-red-700 font-bold mt-1 uppercase tracking-tight">
                                        This item is currently out of stock and cannot be issued.
                                    </p>
                                </div>
                                <Button 
                                    variant="outline" 
                                    className="w-full border-red-200 text-red-700 hover:bg-red-100 rounded-xl font-black uppercase tracking-widest text-[11px]"
                                    onClick={() => onOpenChange(false)}
                                >
                                    Return to Scanner
                                </Button>
                            </div>
                        )}

                        {item.stock_available > 0 && (
                            <>
                                {/* 1. Quantity Selector */}
                        <section className="space-y-4">
                            <Label className="text-[11px] font-black text-slate-400 uppercase tracking-widest px-1">Select Quantity</Label>
                            <div className="bg-white border border-slate-200 p-4 rounded-3xl flex items-center justify-between shadow-sm">
                                <div className="flex flex-col">
                                    <span className="text-[10px] font-black text-slate-400 uppercase tracking-wider">Units to Borrow</span>
                                    <span className="text-2xl font-black text-slate-950">{quantity} Unit{quantity > 1 ? 's' : ''}</span>
                                </div>
                                <div className="flex items-center gap-2">
                                    <Button 
                                        variant="outline" 
                                        size="icon" 
                                        className="rounded-xl h-12 w-12 border-slate-200"
                                        onClick={() => setQuantity(Math.max(1, quantity - 1))}
                                        disabled={quantity <= 1}
                                    >
                                        <Minus className="w-5 h-5" />
                                    </Button>
                                    <Button 
                                        variant="outline" 
                                        size="icon" 
                                        className="rounded-xl h-12 w-12 border-slate-200"
                                        onClick={() => setQuantity(Math.min(item.stock_available, quantity + 1))}
                                        disabled={quantity >= item.stock_available}
                                    >
                                        <Plus className="w-5 h-5" />
                                    </Button>
                                </div>
                            </div>
                        </section>

                        {/* 2. Personnel Data */}
                        <section className="space-y-6">
                            <div className="flex items-center justify-between px-1">
                                <Label className="text-[11px] font-black text-slate-400 uppercase tracking-widest">Borrower Details</Label>
                                <span className="text-[10px] font-bold text-white bg-slate-900 px-2 py-0.5 rounded-full uppercase tracking-wider">Auto Fill</span>
                            </div>
                            
                            <div className="space-y-4">
                                {/* Name Input Field */}
                                <div className="relative">
                                    <div className="absolute left-4 top-1/2 -translate-y-1/2 text-slate-400">
                                        <User className="w-5 h-5" />
                                    </div>
                                    <Input 
                                        placeholder="Enter Borrower Name"
                                        value={borrowerName}
                                        onChange={(e) => setBorrowerName(e.target.value)}
                                        className="pl-12 h-14 rounded-2xl border-slate-200 bg-white font-bold placeholder:text-slate-300 focus:ring-blue-500"
                                    />
                                </div>

                                <div className="grid grid-cols-2 gap-4">
                                    <div className="relative">
                                        <div className="absolute left-4 top-1/2 -translate-y-1/2 text-slate-400">
                                            <Phone className="w-4 h-4" />
                                        </div>
                                        <Input 
                                            placeholder="09XXXXXXXXX"
                                            value={contactNo}
                                            onChange={(e) => {
                                                const value = e.target.value.replace(/[^0-9]/g, '').slice(0, 11)
                                                setContactNo(value)
                                            }}
                                            className="pl-10 h-14 rounded-2xl border-slate-200 bg-white font-bold placeholder:text-slate-300"
                                            maxLength={11}
                                            type="tel"
                                        />
                                    </div>
                                    <div className="relative">
                                        <div className="absolute left-4 top-1/2 -translate-y-1/2 text-slate-400">
                                            <Building2 className="w-4 h-4" />
                                        </div>
                                        <Input 
                                            placeholder="Office / Unit"
                                            value={office}
                                            onChange={(e) => setOffice(e.target.value)}
                                            className="pl-10 h-14 rounded-2xl border-slate-200 bg-white font-bold placeholder:text-slate-300"
                                        />
                                    </div>
                                </div>
                            </div>
                        </section>

                        {/* 3. Authorization */}
                        <section className="space-y-4">
                            <Label className="text-[11px] font-black text-slate-400 uppercase tracking-widest px-1">Approval</Label>
                            <div className="bg-white border-2 border-slate-200 border-dashed p-6 rounded-[32px] text-center space-y-4">
                                <p className="text-[10px] font-black text-slate-400 uppercase tracking-[0.15em]">Approved By</p>
                                <Input 
                                    placeholder="Approver Full Name"
                                    value={approvedBy}
                                    onChange={(e) => setApprovedBy(e.target.value)}
                                    className="border-none bg-transparent text-xl font-black text-slate-900 text-center placeholder:text-slate-200 h-auto p-0 focus:ring-0"
                                />
                                <div className="h-[1px] w-full bg-slate-100" />
                                <div className="flex flex-col items-center gap-1">
                                    <div className="flex items-center gap-2">
                                        <CheckCircle2 className="w-4 h-4 text-emerald-500" />
                                        <span className="text-[11px] font-black text-slate-400 uppercase tracking-wider">Verified & Logged</span>
                                    </div>
                                    <span className="text-[10px] font-bold text-slate-400/60 uppercase tracking-tight italic">
                                        Issued by: {issuerName}
                                    </span>
                                </div>
                            </div>
                        </section>
                            </>
                        )}
                    </div>

                    {/* Footer: Action Button */}
                    <div className="absolute bottom-0 left-0 right-0 p-6 bg-gradient-to-t from-slate-50 via-slate-50 to-transparent">
                        <Button 
                            className="w-full h-14 rounded-2xl bg-slate-950 hover:bg-slate-900 text-white font-black italic uppercase tracking-widest text-base shadow-xl disabled:opacity-50"
                            onClick={handleSubmit}
                            disabled={isSubmitting || !borrowerName || contactNo.length !== 11}
                        >
                            {isSubmitting ? (
                                <Loader2 className="w-6 h-6 animate-spin" />
                            ) : (
                                "Confirm Borrow"
                            )}
                        </Button>
                    </div>
                </div>
            </SheetContent>
        </Sheet>
    )
}
