'use client'

import React, { useTransition } from 'react'
import { 
    Clock, 
    ShieldCheck, 
    CheckCircle2, 
    Package, 
    History,
    Building,
    Phone,
    UserCircle2,
    Calendar,
    ArrowUpRight,
    Loader2,
    RotateCcw,
    MessageSquare,
    Check,
    ClipboardCheck,
    AlertTriangle
} from 'lucide-react'
import { formatDistanceToNow, format } from 'date-fns'
import { InitialsAvatar } from '@/components/logs/log-avatar'
import { TacticalAssetImage } from '@/src/shared/ui/tactical-asset-image'
import { MBadge } from '@/components/mobile/primitives/badge'
import { cn } from '@/lib/utils'
import { BorrowLog } from '@/lib/types/inventory'
import { returnItem } from '../actions/transaction.actions'
import { toast } from 'sonner'
import { Button } from '@/components/ui/button'
import { useUser } from '@/providers/auth-provider'

interface TransactionDetailBodyProps {
    log: BorrowLog
    onActionSuccess?: () => void
    isMobile?: boolean
}

/**
 * 🏛️ ARCHITECTURE: Transaction Detail Body
 * Shared component for Web Expanded Row and Mobile BottomSheet.
 * Focuses on high-fidelity audit data and equipment tracking.
 */
export function TransactionDetailBody({ log, onActionSuccess, isMobile = false }: TransactionDetailBodyProps) {
    const { user } = useUser()
    const [isPending, startTransition] = useTransition()
    const [isReturning, setIsReturning] = React.useState(false)

    // Form State (Parity with Web ReturnCommandSheet)
    const [returnedBy, setReturnedBy] = React.useState(log.borrower_name)
    const [receivedBy, setReceivedBy] = React.useState('')
    const [returnCondition, setReturnCondition] = React.useState<'good' | 'fair' | 'damaged' | 'maintenance' | 'lost'>('good')
    const [returnNotes, setReturnNotes] = React.useState('')

    // Set default receiving officer on load
    React.useEffect(() => {
        if (isReturning && !receivedBy) {
            const fullName = user?.full_name || user?.user_metadata?.full_name || user?.email?.split('@')[0] || ''
            setReceivedBy(fullName)
        }
    }, [isReturning, user, receivedBy])

    const isReturned = log.status === 'returned' || log.status === 'dispensed'
    const isOverdue = log.status === 'borrowed' && log.expected_return_date && new Date(log.expected_return_date) < new Date()
    const isPendingStatus = log.status === 'pending'
    const isDamaged = returnCondition === 'damaged' || returnCondition === 'lost'
    
    const handleReturn = () => {
        startTransition(async () => {
            const res = await returnItem(log.id, {
                receivedByName: receivedBy,
                returnedByName: returnedBy,
                returnCondition: returnCondition,
                returnNotes: returnNotes || `Returned via mobile triage`
            })
            if (res.success) {
                toast.success(res.message)
                onActionSuccess?.()
            } else {
                toast.error(res.error)
            }
        })
    }

    const renderReturnForm = () => (
        <div className="space-y-5 animate-in slide-in-from-right-4 duration-300">
            <div className="flex items-center gap-2 pb-2 border-b border-gray-100">
                <ClipboardCheck className="w-4 h-4 text-blue-600" />
                <span className="text-[10px] font-black text-gray-500 uppercase tracking-widest">Audit Confirmation</span>
            </div>

            <div className="space-y-4">
                {/* 🛡️ Accountability: Who is returning it? */}
                <div className="space-y-1.5">
                    <label className="text-[11px] font-bold text-gray-900 uppercase tracking-tight">Physically Returned By</label>
                    <div className="relative">
                        <input 
                            value={returnedBy}
                            onChange={(e) => setReturnedBy(e.target.value)}
                            className="w-full h-12 bg-white border border-gray-200 rounded-2xl px-4 text-sm focus:ring-2 focus:ring-blue-500/20 outline-none"
                            placeholder="Full Name"
                        />
                        <button 
                            onClick={() => setReturnedBy(log.borrower_name)}
                            className="absolute right-3 top-1/2 -translate-y-1/2 text-[9px] font-bold text-blue-600 uppercase"
                        >
                            Reset
                        </button>
                    </div>
                </div>

                {/* 🛡️ Custody: Who is receiving it? */}
                <div className="space-y-1.5">
                    <label className="text-[11px] font-bold text-gray-900 uppercase tracking-tight">Receiving Officer</label>
                    <input 
                        value={receivedBy}
                        onChange={(e) => setReceivedBy(e.target.value)}
                        className="w-full h-12 bg-gray-50 border border-gray-100 rounded-2xl px-4 text-sm focus:ring-2 focus:ring-blue-500/20 outline-none"
                        placeholder="Officer Name"
                    />
                </div>

                {/* 🛠️ Condition Toggle */}
                <div className="space-y-1.5">
                    <label className="text-[11px] font-bold text-gray-900 uppercase tracking-tight">Condition State</label>
                    <div className="grid grid-cols-2 gap-2">
                        {(['good', 'fair', 'damaged', 'maintenance', 'lost'] as const).map((c) => (
                            <button
                                key={c}
                                type="button"
                                onClick={() => setReturnCondition(c)}
                                className={cn(
                                    "h-10 rounded-xl text-[10px] font-black uppercase tracking-wider border transition-all text-center",
                                    returnCondition === c 
                                        ? "bg-blue-600 text-white border-blue-600 shadow-sm" 
                                        : "bg-white text-gray-500 border-gray-100"
                                )}
                            >
                                {c}
                            </button>
                        ))}
                    </div>
                </div>

                {/* 📝 Field Notes */}
                <div className="space-y-1.5">
                    <label className="text-[11px] font-bold text-gray-900 uppercase tracking-tight">Audit Notes</label>
                    <textarea 
                        value={returnNotes}
                        onChange={(e) => setReturnNotes(e.target.value)}
                        className="w-full min-h-[80px] bg-white border border-gray-200 rounded-2xl p-4 text-sm focus:ring-2 focus:ring-blue-500/20 outline-none resize-none"
                        placeholder="Optional condition details..."
                    />
                </div>

                {/* ⚠️ Property Alert */}
                {isDamaged && (
                    <div className="p-3 bg-red-50 border border-red-100 rounded-xl flex items-center gap-3 animate-in fade-in zoom-in-95">
                        <AlertTriangle className="w-5 h-5 text-red-600 shrink-0" />
                        <p className="text-[9px] font-bold text-red-800 uppercase leading-tight">
                            Resource will be flagged for maintenance and quarantine.
                        </p>
                    </div>
                )}
            </div>

            <div className="flex gap-3 pt-2">
                <Button 
                    variant="ghost"
                    onClick={() => setIsReturning(false)}
                    className="flex-1 h-12 rounded-2xl font-bold uppercase text-[11px] text-gray-900"
                >
                    Back
                </Button>
                <Button 
                    onClick={handleReturn}
                    disabled={isPending || !receivedBy || !returnedBy}
                    className="flex-[2] h-12 bg-blue-600 hover:bg-blue-700 text-white rounded-2xl font-black uppercase tracking-widest text-[11px] gap-2 shadow-lg shadow-blue-200"
                >
                    {isPending ? <Loader2 className="w-4 h-4 animate-spin" /> : <ClipboardCheck className="w-4 h-4" />}
                    Confirm Recovery
                </Button>
            </div>
        </div>
    )

    return (
        <div className={cn("space-y-6 animate-in fade-in slide-in-from-bottom-2 duration-300", isMobile ? "pb-6" : "p-2")}>
            
            {isReturning ? renderReturnForm() : (
                <>
                {/* 1. Personnel Context */}
                <section className="space-y-3">
                    <p className="text-[10px] font-black text-gray-400 uppercase tracking-[0.2em]">Personnel Details</p>
                    <div className="bg-gray-50/50 rounded-2xl p-4 border border-gray-100 flex items-center gap-4">
                        <InitialsAvatar name={log.borrower_name} size={9} />
                        <div className="flex-1 min-w-0">
                            <div className="flex items-center gap-2">
                                <h3 className="text-sm font-bold text-gray-900 truncate">{log.borrower_name}</h3>
                                <MBadge tone="neutral" size="xs">{log.platform_origin || 'system'}</MBadge>
                            </div>
                            <div className="flex flex-wrap gap-x-3 gap-y-1 mt-1">
                                <span className="text-xs text-gray-500 flex items-center gap-1">
                                    <Building className="w-3 h-3 opacity-60" />
                                    {log.borrower_organization || 'External'}
                                </span>
                                {log.borrower_contact && (
                                    <span className="text-xs text-gray-500 flex items-center gap-1">
                                        <Phone className="w-3 h-3 opacity-60" />
                                        {log.borrower_contact}
                                    </span>
                                )}
                            </div>
                        </div>
                    </div>
                </section>

                {/* 2. Equipment Verification (Enterprise Ledger View) */}
                <section className="space-y-3">
                    <p className="text-[10px] font-black text-gray-400 uppercase tracking-[0.2em]">Equipment Verification</p>
                    <div className="bg-white rounded-2xl border border-gray-100 p-4 shadow-sm space-y-5">
                        {/* Header: Identity */}
                        <div className="flex gap-4">
                            <TacticalAssetImage 
                                url={(log as any).inventory?.image_url} 
                                alt={log.item_name}
                                size="lg"
                                className="rounded-xl"
                            />
                            <div className="flex-1 min-w-0 flex flex-col justify-center">
                                <h4 className="text-base font-black text-gray-900 uppercase tracking-tight leading-tight truncate">
                                    {log.item_name}
                                </h4>
                                <div className="mt-1 flex items-center gap-2">
                                    <span className="text-[10px] font-bold text-gray-500 uppercase tracking-widest border border-gray-200 px-2 py-0.5 rounded-md truncate max-w-[120px]">
                                        {(log as any).inventory?.category || 'General'}
                                    </span>
                                    <span className="text-gray-300">•</span>
                                    <MBadge 
                                        tone={isReturned ? 'success' : isOverdue ? 'danger' : 'info'} 
                                        size="xs"
                                    >
                                        {(log.inventory as any)?.item_type === 'consumable' && log.status === 'borrowed' ? 'dispensed' : log.status}
                                    </MBadge>
                                </div>
                            </div>
                        </div>

                        {/* Specs Matrix */}
                        <div className="space-y-4">
                            <div className="space-y-2">
                                <h5 className="text-[10px] font-black text-gray-400 uppercase tracking-widest border-b border-gray-100 pb-1">Identification</h5>
                                <div className="grid grid-cols-2 gap-3">
                                    {((log as any).inventory?.item_type === 'equipment' || !(log as any).inventory?.item_type) ? (
                                        <>
                                            <div className="flex flex-col">
                                                <span className="text-[9px] font-bold text-gray-400 uppercase tracking-widest">Serial</span>
                                                <span className="text-xs font-black text-gray-900 truncate">{(log as any).inventory?.serial_number || 'N/A'}</span>
                                            </div>
                                            <div className="flex flex-col">
                                                <span className="text-[9px] font-bold text-gray-400 uppercase tracking-widest">Model</span>
                                                <span className="text-xs font-black text-gray-900 truncate">{(log as any).inventory?.model_number || 'N/A'}</span>
                                            </div>
                                        </>
                                    ) : (
                                        <>
                                            <div className="flex flex-col">
                                                <span className="text-[9px] font-bold text-gray-400 uppercase tracking-widest">Brand</span>
                                                <span className="text-xs font-black text-gray-900 truncate">{(log as any).inventory?.brand || 'N/A'}</span>
                                            </div>
                                            <div className="flex flex-col">
                                                <span className="text-[9px] font-bold text-gray-400 uppercase tracking-widest">Expiry</span>
                                                <span className="text-xs font-black text-gray-900 truncate">
                                                    {(log as any).inventory?.expiry_date ? format(new Date((log as any).inventory.expiry_date), 'MMM yyyy') : 'N/A'}
                                                </span>
                                            </div>
                                        </>
                                    )}
                                </div>
                            </div>

                            <div className="space-y-2">
                                <h5 className="text-[10px] font-black text-gray-400 uppercase tracking-widest border-b border-gray-100 pb-1">Logistics</h5>
                                <div className="grid grid-cols-2 gap-3">
                                    <div className="flex flex-col">
                                        <span className="text-[9px] font-bold text-gray-400 uppercase tracking-widest">Location</span>
                                        <span className="text-xs font-black text-gray-900 truncate">{(log as any).borrowed_from_warehouse || (log as any).inventory?.storage_location || 'Depot'}</span>
                                    </div>
                                    <div className="flex flex-col">
                                        <span className="text-[9px] font-bold text-gray-400 uppercase tracking-widest">Quantity</span>
                                        <span className="text-xs font-black text-blue-600 tabular-nums">{log.quantity} units</span>
                                    </div>
                                </div>
                            </div>
                        </div>

                        {/* Minimal Timeline */}
                        <div className="flex items-center justify-between pt-3 border-t border-gray-50 bg-gray-50/50 -mx-4 -mb-4 px-4 py-3 rounded-b-2xl">
                            <div className="flex items-center gap-1.5">
                                <Calendar className="w-3.5 h-3.5 text-gray-400" />
                                <span className="text-[10px] font-bold text-gray-500 uppercase tracking-widest">
                                {(log.inventory as any)?.item_type === 'consumable' ? 'Dispensed:' : 'Borrowed:'} {format(new Date(log.borrow_date || log.created_at), 'MMM dd, yyyy • hh:mm a')}
                                </span>
                            </div>
                            {isOverdue && !isReturned && (
                                 <div className="flex items-center gap-1.5 text-red-600">
                                     <History className="w-3.5 h-3.5" />
                                     <span className="text-[10px] font-black uppercase tracking-widest">Overdue</span>
                                 </div>
                            )}
                        </div>
                    </div>
                </section>
                {/* 3. Audit Trail */}
                <section className="space-y-3">
                    <p className="text-[10px] font-black text-gray-400 uppercase tracking-[0.2em]">Personnel Verification</p>
                    <div className="grid grid-cols-2 gap-3">
                        <div className="bg-gray-50/50 rounded-xl p-3 border border-gray-100 space-y-2">
                            <div className="flex items-center gap-1.5 opacity-60">
                                <ShieldCheck className="w-3 h-3 text-blue-500" />
                                <span className="text-[9px] font-black text-gray-500 uppercase tracking-widest">Authorized</span>
                            </div>
                            <p className="text-[11px] font-black text-gray-900">{log.approved_by_name || 'System'}</p>
                        </div>
                        <div className="bg-gray-50/50 rounded-xl p-3 border border-gray-100 space-y-2">
                            <div className="flex items-center gap-1.5 opacity-60">
                                <CheckCircle2 className="w-3 h-3 text-emerald-500" />
                                <span className="text-[9px] font-black text-gray-500 uppercase tracking-widest">Released</span>
                            </div>
                            <p className="text-[11px] font-black text-gray-900">{log.released_by_name || 'Handoff'}</p>
                        </div>
                    </div>
                </section>

                {/* 4. Declarations (Notes/Purpose) */}
                {(log.purpose || log.notes) && (
                    <section className="space-y-3">
                        <p className="text-[10px] font-black text-gray-400 uppercase tracking-[0.2em]">Declarations</p>
                        <div className="bg-blue-50/30 rounded-2xl p-4 border border-blue-100/50">
                            <div className="flex items-center gap-2 mb-2">
                                <MessageSquare className="w-3.5 h-3.5 text-blue-500" />
                                <span className="text-[10px] font-bold text-blue-600 uppercase">Field Purpose</span>
                            </div>
                            <p className="text-xs text-gray-700 italic leading-relaxed">
                                &ldquo;{log.purpose || log.notes}&rdquo;
                            </p>
                        </div>
                    </section>
                )}

                {/* 5. Strategic Actions */}
                {!isReturned && !isPendingStatus && (log.inventory as any)?.item_type !== 'consumable' && (
                    <section className="pt-4">
                        <Button 
                            onClick={() => setIsReturning(true)}
                            className={cn(
                                "w-full h-12 rounded-2xl font-black uppercase tracking-widest text-[11px] gap-2 shadow-lg transition-all active:scale-[0.98]",
                                isOverdue 
                                    ? "bg-red-600 hover:bg-red-700 text-white shadow-red-200" 
                                    : "bg-gray-900 hover:bg-black text-white"
                            )}
                        >
                            <RotateCcw className="w-4 h-4" />
                            Process Return
                        </Button>
                    </section>
                )}

                {isReturned && (
                    <div className="bg-emerald-50 border border-emerald-100 rounded-2xl p-4 flex items-center justify-center gap-2">
                        <Check className="w-4 h-4 text-emerald-600" />
                        <span className="text-xs font-black text-emerald-700 uppercase tracking-widest">Transaction Completed</span>
                    </div>
                )}
                </>
            )}
        </div>
    )
}
