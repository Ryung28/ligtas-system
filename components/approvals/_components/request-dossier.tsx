'use client'

import Image from 'next/image'
import { useState } from 'react'
import { Phone, Building, MessageSquare, Package, MapPin, ShieldCheck, Clock, Calendar, CheckCircle2, Loader2, X, Zap, ArrowRight, Maximize2 } from 'lucide-react'
import { Button } from '@/components/ui/button'
import {
    Dialog as ShadinDialog,
    DialogContent as ShadinDialogContent,
    DialogHeader as ShadinDialogHeader,
    DialogTitle as ShadinDialogTitle
} from '@/components/ui/dialog'
import { UserAvatar } from '@/components/ui/user-avatar'
import { Separator } from '@/components/ui/separator'
import { Badge } from '@/components/ui/badge'
import { BorrowLog } from '@/lib/types/inventory'
import { getInventoryImageUrl } from '@/lib/supabase'
import { rejectRequest, ApprovalCommandSheet } from '@/src/features/approvals'
import { toast } from 'sonner'
import { formatDistanceToNow, format } from 'date-fns'

interface RequestDossierProps {
    request: BorrowLog
    staffName: string
    userRole: string | null
    isReservationView: boolean
    onActionComplete: () => void
}


export function RequestDossier({ request, staffName, userRole, isReservationView, onActionComplete }: RequestDossierProps) {
    const [processingId, setProcessingId] = useState<number | null>(null)
    const [expandedImage, setExpandedImage] = useState<{ url: string, name: string } | null>(null)
    const isProcessing = processingId === request.id

    const isAdmin = userRole?.toLowerCase() === 'admin'

    const status = request.status
    const isStaged = status === 'staged'
    const isReserved = status === 'reserved'
    const isPending = status === 'pending'
    const isConsumable = (request as any).inventory?.item_type === 'consumable'

    const imageUrl = getInventoryImageUrl((request as any).inventory?.image_url)

    const pickupScheduledAt = request.pickup_scheduled_at
    const expectedReturnDate = request.expected_return_date

    // Lifecycle state
    const step1Done = !isPending // Approved/Staged/Reserved means step 1 is done? No — pending IS step 1.
    // Actually: REQUESTED = always done. READY = staged. DONE = borrowed.
    const lifecycleApproved = isStaged || isReserved
    const lifecycleDone = false // not yet handed off

    // Primary Action Handlers
    const handleReject = async () => {
        setProcessingId(request.id)
        try {
            const result = await rejectRequest(request.id)
            if (result.success) {
                toast.warning('Request rejected and stock restored.')
                onActionComplete()
            } else {
                toast.error(result.error || 'Failed to reject request')
            }
        } finally {
            setProcessingId(null)
        }
    }

    return (
        <div className="flex flex-col h-full">


            {/* ── Scrollable Body ── */}
            <div className="flex-1 overflow-y-auto">
                <div className="px-6 py-5 space-y-5">

                    {/* Section A: Borrower */}
                    <section>
                        <p className="text-[9px] font-black text-slate-400 uppercase tracking-[0.2em] mb-2.5">Borrower</p>
                        <div className="flex items-center gap-3 mb-3.5">
                            <UserAvatar fullName={request.borrower_name} className="h-10 w-10 ring-2 ring-white shadow-md" />
                            <div>
                                <p className="text-sm font-black text-slate-900 leading-tight">{request.borrower_name}</p>
                                <p className="text-[10px] font-semibold text-slate-500 mt-0.5">
                                    {formatDistanceToNow(new Date(request.created_at), { addSuffix: true })}
                                </p>
                            </div>
                        </div>
                        <div className="grid grid-cols-2 gap-2.5">
                            <div className="bg-slate-50 rounded-xl p-2.5 border border-slate-100">
                                <div className="flex items-center gap-1 mb-0.5">
                                    <Phone className="h-2.5 w-2.5 text-slate-400" />
                                    <p className="text-[8px] font-black text-slate-400 uppercase tracking-widest">Mobile</p>
                                </div>
                                <p className="text-[11px] font-bold text-slate-800">{request.borrower_contact || 'Not provided'}</p>
                            </div>
                            <div className="bg-slate-50 rounded-xl p-2.5 border border-slate-100">
                                <div className="flex items-center gap-1 mb-0.5">
                                    <Building className="h-2.5 w-2.5 text-slate-400" />
                                    <p className="text-[8px] font-black text-slate-400 uppercase tracking-widest">Office</p>
                                </div>
                                <p className="text-[11px] font-bold text-slate-800">{request.borrower_organization || 'Not specified'}</p>
                            </div>
                        </div>
                        {request.purpose && (
                            <div className="mt-2.5 bg-blue-50/60 rounded-xl p-2.5 border border-blue-100/60">
                                <div className="flex items-center gap-1 mb-0.5">
                                    <MessageSquare className="h-2.5 w-2.5 text-blue-400" />
                                    <p className="text-[8px] font-black text-blue-400 uppercase tracking-widest">Reason</p>
                                </div>
                                <p className="text-[11px] text-slate-700 leading-snug italic">&ldquo;{request.purpose}&rdquo;</p>
                            </div>
                        )}
                    </section>

                    <Separator className="bg-slate-100" />

                    {/* Section B: Equipment */}
                    <section>
                        <p className="text-[9px] font-black text-slate-400 uppercase tracking-[0.2em] mb-2.5">Equipment</p>
                        <div className="flex gap-3.5 items-start">
                            <div 
                                onClick={() => imageUrl && setExpandedImage({ url: imageUrl, name: request.item_name })}
                                className="h-16 w-16 rounded-xl bg-slate-50 border border-slate-200 flex-shrink-0 flex items-center justify-center overflow-hidden relative group cursor-pointer hover:border-blue-300 transition-all shadow-sm"
                            >
                                {imageUrl ? (
                                    <>
                                        <Image src={imageUrl} alt={request.item_name} fill className="object-contain p-1.5 transition-transform group-hover:scale-110" unoptimized />
                                        <div className="absolute inset-0 bg-black/5 opacity-0 group-hover:opacity-100 transition-opacity flex items-center justify-center">
                                            <Maximize2 className="h-3 w-3 text-blue-600" />
                                        </div>
                                    </>
                                ) : (
                                    <Package className="h-6 w-6 text-slate-200" strokeWidth={1} />
                                )}
                            </div>
                            <div className="flex-1 space-y-1.5 pt-0.5">
                                <div>
                                    <p className="text-xs font-black text-slate-900 uppercase tracking-tight">{request.item_name}</p>
                                    <p className="text-[9px] font-mono font-bold text-slate-400 mt-0.5">ID: {request.inventory_id}</p>
                                </div>
                                <div className="flex flex-wrap gap-1.5">
                                    <div className="inline-flex items-center gap-1 px-1.5 py-0.5 bg-slate-100 rounded text-[9px] font-black text-slate-600">
                                        Qty: {request.quantity}
                                    </div>
                                    <div className="inline-flex items-center gap-1 px-1.5 py-0.5 bg-emerald-50 rounded text-[9px] font-black text-emerald-600 border border-emerald-100">
                                        <ShieldCheck className="h-2.5 w-2.5" /> Good Condition
                                    </div>
                                </div>
                            </div>
                        </div>
                    </section>

                    <Separator className="bg-slate-100" />

                    {/* Section C: Schedule */}
                    <section>
                        <p className="text-[9px] font-black text-slate-400 uppercase tracking-[0.2em] mb-3">Schedule</p>
                        <div className="space-y-2">
                            <div className="flex items-center justify-between py-2">
                                <div className="flex items-center gap-2 text-slate-500">
                                    <Clock className="h-3.5 w-3.5" />
                                    <span className="text-xs font-semibold">Pickup</span>
                                </div>
                                <span className="text-xs font-bold text-slate-800">
                                    {pickupScheduledAt
                                        ? format(new Date(pickupScheduledAt), 'MMM d, yyyy · h:mm a')
                                        : 'Immediate'}
                                </span>
                            </div>
                            {!isConsumable && (
                                <div className="flex items-center justify-between py-2 border-t border-slate-100">
                                    <div className="flex items-center gap-2 text-slate-500">
                                        <Calendar className="h-3.5 w-3.5" />
                                        <span className="text-xs font-semibold">Expected Return</span>
                                    </div>
                                    <span className="text-xs font-bold text-slate-800">
                                        {expectedReturnDate
                                            ? format(new Date(expectedReturnDate), 'MMM d, yyyy')
                                            : 'Open-ended'}
                                    </span>
                                </div>
                            )}
                        </div>
                    </section>
                </div>
            </div>

            {/* ── Action Cluster (sticky bottom) ── */}
            <div className="border-t border-slate-100 p-3 bg-white/80 backdrop-blur-sm">
                {!isAdmin ? (
                    <div className="flex items-center justify-center p-2 bg-slate-50 rounded-xl border border-dashed border-slate-200">
                        <Shield className="h-3 w-3 text-slate-400 mr-2" />
                        <p className="text-[10px] font-bold text-slate-500 uppercase tracking-tight">
                            Only Administrators can authorize dispatches
                        </p>
                    </div>
                ) : (
                    <div className="flex gap-2">
                        <Button
                            variant="ghost"
                            disabled={isProcessing}
                            onClick={handleReject}
                            className="flex-1 h-9 rounded-xl font-bold text-[10px] uppercase tracking-widest text-slate-400 hover:text-red-600 hover:bg-red-50 transition-all border border-transparent hover:border-red-100"
                        >
                            <X className="h-3 w-3 mr-1.5" />
                            Reject
                        </Button>
                        <ApprovalCommandSheet
                            request={request}
                            isReservationView={isReservationView}
                            onActionSuccess={onActionComplete}
                            triggerClassName={`flex-[2.5] h-9 rounded-xl font-black text-[10px] uppercase tracking-widest text-white shadow-md transition-all active:scale-95 border-none ${
                                isStaged
                                    ? 'bg-emerald-600 hover:bg-emerald-700 shadow-emerald-200'
                                    : isReservationView
                                    ? 'bg-amber-500 hover:bg-amber-600 shadow-amber-200'
                                    : 'bg-blue-600 hover:bg-blue-700 shadow-blue-200'
                            }`}
                        />
                    </div>
                )}
            </div>

            {/* ── Image Preview Dialog ── */}
            <ShadinDialog open={!!expandedImage} onOpenChange={(open) => !open && setExpandedImage(null)}>
                <ShadinDialogContent className="max-w-3xl border-none bg-black/95 p-0 overflow-hidden rounded-2xl shadow-2xl [&>button]:text-white [&>button]:opacity-100">
                    <ShadinDialogHeader className="absolute top-4 left-4 z-50 pointer-events-none">
                        <ShadinDialogTitle className="text-white text-[10px] font-black uppercase tracking-widest bg-black/60 backdrop-blur-md px-3 py-1.5 rounded-lg border border-white/10">
                            {expandedImage?.name}
                        </ShadinDialogTitle>
                    </ShadinDialogHeader>
                    <div className="relative w-full aspect-square md:aspect-video flex items-center justify-center p-8">
                        {expandedImage && (
                            <Image
                                src={expandedImage.url}
                                alt={expandedImage.name}
                                fill
                                unoptimized
                                className="object-contain rounded-lg animate-in zoom-in-95 duration-300"
                            />
                        )}
                    </div>
                </ShadinDialogContent>
            </ShadinDialog>
        </div>
    )
}
