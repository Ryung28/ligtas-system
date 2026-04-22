'use client'

import React, { useState, useEffect } from 'react'
import Image from 'next/image'
import { Table, TableBody, TableCell, TableHead, TableHeader, TableRow } from '@/components/ui/table'
import { Button } from '@/components/ui/button'
import { Check, X, Clock, Package, MessageSquare, ShieldCheck, User, Building, Info, ChevronRight, Phone, Zap, Calendar } from 'lucide-react'
import { BorrowLog } from '@/lib/types/inventory'
import { approveRequest, rejectRequest, completeHandoff } from '@/src/features/approvals'
import { toast } from 'sonner'
import { formatDistanceToNow } from 'date-fns'
import { createBrowserClient } from '@supabase/ssr'
import { UserAvatar } from '@/components/ui/user-avatar'
import { getInventoryImageUrl } from '@/lib/supabase'
import { 
    Sheet, 
    SheetContent, 
    SheetHeader, 
    SheetTitle, 
    SheetFooter,
    SheetDescription
} from '@/components/ui/sheet'
import { Badge } from '@/components/ui/badge'
import { ScrollArea } from '@/components/ui/scroll-area'
import { Separator } from '@/components/ui/separator'

interface PendingRequestsTableProps {
    requests: BorrowLog[]
    onRefresh: () => void
    isReservationView?: boolean
}

export function PendingRequestsTable({ requests, onRefresh, isReservationView }: PendingRequestsTableProps) {
    const [processingId, setProcessingId] = useState<number | null>(null)
    const [staffName, setStaffName] = useState('')
    const [selectedRequest, setSelectedRequest] = useState<BorrowLog | null>(null)

    useEffect(() => {
        async function loadStaffName() {
            const supabase = createBrowserClient(
                process.env.NEXT_PUBLIC_SUPABASE_URL!,
                process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY!
            )
            const { data: { user } } = await supabase.auth.getUser()
            if (user) {
                const { data: profile } = await supabase
                    .from('user_profiles')
                    .select('full_name')
                    .eq('id', user.id)
                    .single()
                
                if (profile?.full_name) setStaffName(profile.full_name)
            }
        }
        loadStaffName()
    }, [])

    const handleApprove = async (id: number, isInstant: boolean = false) => {
        if (!staffName) {
            toast.error('Unable to identify staff member')
            return
        }
        setProcessingId(id)
        try {
            const result = await approveRequest(id, staffName, isInstant)
            if (result.success) {
                toast.success(isReservationView ? 'Reservation Confirmed!' : 'Approved! Item moved to Dispatch Queue.')
                setSelectedRequest(null)
                onRefresh()
            } else {
                toast.error(result.error || 'Failed to approve')
            }
        } catch (err) {
            toast.error('An unexpected error occurred')
        } finally {
            setProcessingId(null)
        }
    }

    const handleReject = async (id: number) => {
        setProcessingId(id)
        try {
            const result = await rejectRequest(id)
            if (result.success) {
                toast.warning('Request rejected and stock restored')
                setSelectedRequest(null)
                onRefresh()
            } else {
                toast.error(result.error || 'Failed to reject')
            }
        } catch (err) {
            toast.error('An unexpected error occurred')
        } finally {
            setProcessingId(null)
        }
    }

    if (requests.length === 0) return null

    return (
        <>
            <div className="bg-white/90 backdrop-blur-xl shadow-2xl shadow-slate-200/50 border-none rounded-[2.5rem] ring-1 ring-slate-100 overflow-hidden">
                <div className="overflow-x-auto">
                    <Table>
                        <TableHeader>
                            <TableRow className="bg-slate-50/50 hover:bg-slate-50/50 border-b border-slate-100">
                                <TableHead className="px-6 py-4 font-black text-slate-400 text-[10px] uppercase tracking-[0.2em]">Borrower Dossier</TableHead>
                                <TableHead className="px-6 py-4 font-black text-slate-400 text-[10px] uppercase tracking-[0.2em]">Equipment Health</TableHead>
                                <TableHead className="px-6 py-4 font-black text-slate-400 text-[10px] uppercase tracking-[0.2em] text-right">Intelligence</TableHead>
                            </TableRow>
                        </TableHeader>
                        <TableBody>
                            {requests.map((request) => (
                                <TableRow 
                                    key={request.id} 
                                    className="hover:bg-blue-50/30 transition-colors border-b border-slate-50/80 group cursor-pointer"
                                    onClick={() => setSelectedRequest(request)}
                                >
                                    <TableCell className="px-6 py-4 align-middle">
                                        <div className="flex items-center gap-4">
                                            <UserAvatar fullName={request.borrower_name} className="h-10 w-10 14in:h-9 14in:w-9 ring-2 ring-white shadow-sm" />
                                            <div className="flex flex-col min-w-0">
                                                <span className="text-sm font-black text-slate-900 truncate font-heading uppercase tracking-wide leading-none">{request.borrower_name}</span>
                                                <span className="text-[10px] font-bold text-slate-400 uppercase tracking-widest mt-1">{request.borrower_organization || 'EXTERNAL AGENT'}</span>
                                            </div>
                                        </div>
                                    </TableCell>
                                    <TableCell className="px-6 py-4 align-middle">
                                        <div className="flex items-center gap-4">
                                            <div className="relative h-12 w-12 rounded-xl bg-slate-100 border border-slate-200 overflow-hidden flex-shrink-0 flex items-center justify-center">
                                                {getInventoryImageUrl((request as any).inventory?.image_url) ? (
                                                    <Image 
                                                        src={getInventoryImageUrl((request as any).inventory.image_url)!} 
                                                        alt={request.item_name} 
                                                        fill 
                                                        className="object-contain p-1.5" 
                                                        unoptimized 
                                                    />
                                                ) : (
                                                    <Package className="h-6 w-6 text-slate-300" />
                                                )}
                                                <div className="absolute -top-1 -right-1 px-1.5 py-0.5 bg-blue-600 text-white text-[9px] font-black italic rounded-bl-lg shadow-sm">
                                                    x{request.quantity}
                                                </div>
                                            </div>
                                            <div className="flex flex-col min-w-0">
                                                <span className="text-sm font-black text-slate-900 truncate leading-none uppercase tracking-tight">{request.item_name}</span>
                                                <span className="text-[10px] font-mono font-bold text-slate-400 mt-1 uppercase">ID: {request.inventory_id}</span>
                                            </div>
                                        </div>
                                    </TableCell>
                                    <TableCell className="px-6 py-4 text-right align-middle">
                                        <Button 
                                            variant="ghost" 
                                            size="sm" 
                                            className="h-9 px-4 rounded-xl font-black text-[10px] uppercase tracking-widest text-blue-600 hover:bg-blue-50 group-hover:bg-blue-600 group-hover:text-white transition-all transform active:scale-95"
                                        >
                                            View Intel <ChevronRight className="ml-2 h-3.5 w-3.5" />
                                        </Button>
                                    </TableCell>
                                </TableRow>
                            ))}
                        </TableBody>
                    </Table>
                </div>
            </div>

            {/* Intelligence HUD (Master-Detail Sidebar) */}
            <Sheet open={!!selectedRequest} onOpenChange={(open) => !open && setSelectedRequest(null)}>
                <SheetContent side="right" className="w-full sm:max-w-md 14in:max-w-lg p-0 bg-white border-none shadow-2xl flex flex-col overflow-hidden rounded-l-[3rem]">
                    <SheetHeader className="p-8 bg-slate-900 text-white relative h-64 shrink-0 flex flex-col justify-end">
                        <div className="absolute top-8 right-8 h-12 w-12 bg-white/10 backdrop-blur-md rounded-2xl flex items-center justify-center">
                            <ShieldCheck className="h-6 w-6 text-blue-400" />
                        </div>
                        
                        <div className="relative z-10 flex flex-col gap-4">
                            <UserAvatar fullName={selectedRequest?.borrower_name || ''} className="h-16 w-16 border-4 border-slate-800 shadow-2xl" />
                            <div>
                                <SheetTitle className="text-2xl font-black text-white uppercase italic tracking-tighter leading-none">
                                    {selectedRequest?.borrower_name}
                                </SheetTitle>
                                <SheetDescription className="text-blue-300 font-bold text-xs uppercase tracking-[0.2em] mt-2">
                                    Personnel Clearance: Lvl 3 Authorized
                                </SheetDescription>
                            </div>
                        </div>
                    </SheetHeader>

                    <ScrollArea className="flex-1">
                        <div className="p-8 space-y-8">
                            {/* Personnel Dossier */}
                            <section className="space-y-4">
                                <h4 className="text-[10px] font-black text-slate-400 uppercase tracking-[0.25em]">Personnel Dossier</h4>
                                <div className="grid grid-cols-2 gap-4">
                                    <div className="bg-slate-50 p-4 rounded-2xl border border-slate-100">
                                        <Building className="h-4 w-4 text-slate-400 mb-2" />
                                        <p className="text-[9px] font-black text-slate-400 uppercase tracking-widest">Office / Unit</p>
                                        <p className="text-xs font-bold text-slate-900 mt-1">{selectedRequest?.borrower_organization || 'General Field Team'}</p>
                                    </div>
                                    <div className="bg-slate-50 p-4 rounded-2xl border border-slate-100">
                                        <Phone className="h-4 w-4 text-slate-400 mb-2" />
                                        <p className="text-[9px] font-black text-slate-400 uppercase tracking-widest">Field Contact</p>
                                        <p className="text-xs font-bold text-slate-900 mt-1">{selectedRequest?.borrower_contact || 'N/A'}</p>
                                    </div>
                                </div>
                                <div className="bg-blue-50/50 p-4 rounded-2xl border border-blue-100/50">
                                    <p className="text-[9px] font-black text-blue-400 uppercase tracking-widest mb-2 italic">Mission Intent / Reason</p>
                                    <p className="text-sm font-medium text-slate-700 leading-relaxed italic">&quot;{selectedRequest?.purpose || 'No strategic reason provided entry.'}&quot;</p>
                                </div>
                            </section>

                            <Separator className="bg-slate-100" />

                            {/* Equipment Intel */}
                            <section className="space-y-4">
                                <h4 className="text-[10px] font-black text-slate-400 uppercase tracking-[0.25em]">Equipment Hardware</h4>
                                <div className="flex gap-6 items-start">
                                    <div className="h-24 w-24 rounded-3xl bg-slate-50 border border-slate-200 flex-shrink-0 relative overflow-hidden flex items-center justify-center">
                                        {getInventoryImageUrl((selectedRequest as any)?.inventory?.image_url) ? (
                                            <Image 
                                                src={getInventoryImageUrl((selectedRequest as any).inventory.image_url)!} 
                                                alt="Equipment" 
                                                fill 
                                                className="object-contain p-2" 
                                                unoptimized 
                                            />
                                        ) : (
                                            <Package className="h-10 w-10 text-slate-200" />
                                        )}
                                    </div>
                                    <div className="flex-1 space-y-2">
                                        <div>
                                            <p className="text-[9px] font-black text-slate-400 uppercase tracking-widest">Standard Name</p>
                                            <p className="text-sm font-black text-slate-900 uppercase">{selectedRequest?.item_name}</p>
                                        </div>
                                        <div className="flex gap-4">
                                            <div>
                                                <p className="text-[8px] font-black text-slate-400 uppercase tracking-widest text-[7px]">Stock ID</p>
                                                <p className="text-[10px] font-mono font-bold text-slate-900">{selectedRequest?.inventory_id}</p>
                                            </div>
                                            <div>
                                                <p className="text-[8px] font-black text-slate-400 uppercase tracking-widest text-[7px]">Hardware Model</p>
                                                <p className="text-[10px] font-mono font-bold text-slate-900">{(selectedRequest as any)?.inventory?.model_number || 'N/A'}</p>
                                            </div>
                                        </div>
                                        <div className="inline-flex items-center gap-1.5 px-2 py-1 rounded-lg bg-emerald-50 text-emerald-700 text-[9px] font-black uppercase tracking-tighter border border-emerald-100">
                                            <ShieldCheck className="h-3 w-3" /> Integrity: Good
                                        </div>
                                    </div>
                                </div>
                            </section>
                        </div>
                    </ScrollArea>

                    <SheetFooter className="p-8 bg-slate-50/80 border-t border-slate-100 sm:flex-row gap-3">
                        <Button 
                            variant="ghost" 
                            disabled={processingId !== null}
                            onClick={() => handleReject(selectedRequest?.id!)}
                            className="flex-1 rounded-2xl font-black text-[11px] uppercase tracking-[0.15em] text-slate-500 hover:text-red-600 hover:bg-red-50 h-12"
                        >
                            <X className="h-4 w-4 mr-2" /> Reject Entry
                        </Button>
                        <Button 
                            disabled={processingId !== null}
                            onClick={() => handleApprove(selectedRequest?.id!)}
                            className={`flex-[2] rounded-2xl font-black text-[11px] uppercase tracking-[0.2em] text-white h-12 shadow-xl shadow-blue-200 transition-all active:scale-95 ${isReservationView ? 'bg-amber-600 hover:bg-amber-700' : 'bg-blue-600 hover:bg-blue-700'}`}
                        >
                            {isReservationView ? <Calendar className="h-4 w-4 mr-2" /> : <Zap className="h-4 w-4 mr-2" />}
                            {processingId !== null ? 'Syncing...' : isReservationView ? 'Confirm Reservation' : 'Approve & Stage'}
                        </Button>
                    </SheetFooter>
                </SheetContent>
            </Sheet>
        </>
    )
}
