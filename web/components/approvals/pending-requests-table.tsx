'use client'

import React, { useState, useEffect } from 'react'
import { Table, TableBody, TableCell, TableHead, TableHeader, TableRow } from '@/components/ui/table'
import { Button } from '@/components/ui/button'
import { Popover, PopoverContent, PopoverTrigger } from '@/components/ui/popover'
import { Check, X, Clock, User, Building, Package, ExternalLink, MessageSquare, MoreHorizontal } from 'lucide-react'
import { BorrowLog } from '@/lib/types/inventory'
import { approveRequest, rejectRequest, completeHandoff } from '@/src/features/approvals'
import { toast } from 'sonner'
import { formatDistanceToNow } from 'date-fns'
import { createBrowserClient } from '@supabase/ssr'
import { UserAvatar } from '@/components/ui/user-avatar'

interface PendingRequestsTableProps {
    requests: BorrowLog[]
    onRefresh: () => void
}

export function PendingRequestsTable({ requests, onRefresh }: PendingRequestsTableProps) {
    const [processingId, setProcessingId] = useState<number | null>(null)
    const [staffName, setStaffName] = useState('')

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
                
                if (profile?.full_name) {
                    setStaffName(profile.full_name)
                }
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
                toast.success(isInstant ? 'Handoff Complete!' : 'Approved! Item moved to Dispatch Queue.')
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

    const handleHandoff = async (id: number) => {
        if (!staffName) {
            toast.error('Unable to identify staff member')
            return
        }
        setProcessingId(id)
        try {
            const result = await completeHandoff(id, staffName)
            if (result.success) {
                toast.success('Handoff Complete. Transaction moved to history.')
                onRefresh()
            } else {
                toast.error(result.error || 'Failed to complete handoff')
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

    if (requests.length === 0) {
        return (
            <div className="flex flex-col items-center justify-center py-24 text-center bg-white/50 backdrop-blur-sm rounded-[2rem] border border-dashed border-slate-200">
                <div className="bg-blue-50 h-16 w-16 rounded-2xl flex items-center justify-center mb-4 shadow-inner ring-1 ring-blue-100">
                    <Check className="h-8 w-8 text-blue-400" />
                </div>
                <h3 className="text-xl font-bold text-slate-900 font-heading">All Clear!</h3>
                <p className="text-sm text-slate-500 mt-2 max-w-xs mx-auto">
                    No pending borrow requests at the moment.
                </p>
            </div>
        )
    }

    return (
        <div className="bg-white/90 backdrop-blur-xl shadow-2xl shadow-slate-200/50 border-none rounded-[2.5rem] ring-1 ring-slate-100 overflow-hidden">
            <div className="overflow-x-auto">
                <Table>
                    <TableHeader>
                        <TableRow className="bg-slate-50/50 hover:bg-slate-50/50 border-b border-slate-100">
                            <TableHead className="px-4 py-3 14in:px-4 14in:py-3 font-bold text-slate-400 text-[10px] uppercase tracking-[0.15em]">Borrower & Mission</TableHead>
                            <TableHead className="px-4 py-3 14in:px-4 14in:py-3 font-bold text-slate-400 text-[10px] uppercase tracking-[0.15em]">Equipment & Logistics</TableHead>
                            <TableHead className="px-4 py-3 14in:px-4 14in:py-3 font-bold text-slate-400 text-[10px] uppercase tracking-[0.15em] text-right">Status & Action</TableHead>
                        </TableRow>
                    </TableHeader>
                    <TableBody>
                        {requests.map((request) => (
                            <TableRow key={request.id} className="hover:bg-blue-50/30 transition-colors border-b border-slate-50/80 group">
                                <TableCell className="px-4 py-3 14in:px-4 14in:py-2.5 align-top w-[40%]">
                                    <div className="flex gap-3">
                                        <UserAvatar fullName={request.borrower_name} className="mt-0.5 h-8 w-8 14in:h-7 14in:w-7" />
                                        <div className="flex flex-col min-w-0 flex-1">
                                            <div className="flex items-center gap-1.5 flex-wrap">
                                                <span className="text-sm 14in:text-xs font-bold text-slate-900 truncate font-heading uppercase tracking-wide leading-tight">{request.borrower_name}</span>
                                                <span className="text-[10px] 14in:text-[9px] font-bold text-slate-400 uppercase tracking-tight border-l border-slate-200 pl-1.5">{request.borrower_organization || 'External'}</span>
                                            </div>
                                            <p className="text-xs 14in:text-[11px] text-slate-600 italic font-medium line-clamp-1 mt-1 14in:mt-0.5">
                                                &quot;{request.purpose || 'No purpose specified'}&quot;
                                                {request.notes && <span className="text-slate-400 not-italic ml-1">({request.notes})</span>}
                                            </p>
                                        </div>
                                    </div>
                                </TableCell>
                                <TableCell className="px-4 py-3 14in:px-4 14in:py-2.5 align-top w-[35%]">
                                    <div className="flex flex-col min-w-0">
                                        <div className="flex items-center gap-2">
                                            <span className="text-sm 14in:text-xs font-bold text-slate-900 truncate leading-tight">{request.item_name}</span>
                                            <span className="px-1.5 py-0.5 rounded-md bg-blue-100 text-blue-700 text-[10px] 14in:text-[9px] font-black italic shrink-0">x{request.quantity}</span>
                                        </div>
                                        <div className="flex flex-col gap-1 mt-1 14in:mt-0.5">
                                            {request.pickup_scheduled_at ? (
                                                <div className="flex items-center gap-1.5 p-1.5 rounded-lg bg-amber-50/50 border border-amber-100/50 w-fit">
                                                    <Clock className="h-3 w-3 text-amber-600" />
                                                    <span className="text-[10px] 14in:text-[9px] font-black text-amber-700 uppercase tracking-tight">
                                                        Pickup: {new Date(request.pickup_scheduled_at).toLocaleString('en-US', {
                                                            month: 'short',
                                                            day: 'numeric',
                                                            hour: 'numeric',
                                                            minute: '2-digit',
                                                            hour12: true
                                                        })}
                                                    </span>
                                                </div>
                                            ) : (
                                                <div className="flex items-center gap-1 text-[10px] 14in:text-[9px] font-bold text-slate-400">
                                                    <Clock className="h-3 w-3" />
                                                    <span>Requested {formatDistanceToNow(new Date(request.created_at), { addSuffix: true })}</span>
                                                </div>
                                            )}
                                            <span className="text-[10px] 14in:text-[9px] text-slate-400 font-mono font-bold tracking-tight pl-1">ID: {request.inventory_id}</span>
                                        </div>
                                    </div>
                                </TableCell>
                                <TableCell className="px-4 py-3 14in:px-4 14in:py-2.5 text-right align-top w-[25%]">
                                    <div className="flex items-center justify-end gap-2">
                                        {request.status === 'staged' ? (
                                            <div className="flex items-center gap-2">
                                                <span className="px-2 py-1 rounded-md bg-amber-50 border border-amber-200 text-amber-700 text-[10px] font-black uppercase tracking-widest hidden sm:inline-block">Ready for Pickup</span>
                                                <Button
                                                    size="sm"
                                                    disabled={processingId !== null}
                                                    onClick={() => handleHandoff(request.id)}
                                                    className="h-8 px-4 14in:px-3 rounded-lg bg-emerald-600 hover:bg-emerald-700 text-white shadow-md font-bold text-[10px] uppercase tracking-wider"
                                                >
                                                    <Check className="h-3.5 w-3.5 mr-1.5 14in:mr-1" /> Dispatch
                                                </Button>
                                            </div>
                                        ) : (
                                            <div className="flex items-center gap-2">
                                                <Button
                                                    size="sm"
                                                    disabled={processingId !== null}
                                                    onClick={() => handleApprove(request.id, false)}
                                                    className="h-8 px-4 14in:px-3 rounded-lg bg-blue-600 hover:bg-blue-700 text-white shadow-md font-bold text-[10px] uppercase tracking-wider"
                                                >
                                                    Approve
                                                </Button>
                                                <Popover>
                                                    <PopoverTrigger asChild>
                                                        <Button size="icon" variant="outline" className="h-8 w-8 rounded-lg border-slate-200 text-slate-600 hover:bg-slate-50">
                                                            <MoreHorizontal className="h-4 w-4" />
                                                        </Button>
                                                    </PopoverTrigger>
                                                    <PopoverContent align="end" className="w-48 p-1 rounded-xl shadow-xl border border-slate-100">
                                                        <div className="flex flex-col space-y-0.5">
                                                            <Button
                                                                variant="ghost"
                                                                size="sm"
                                                                disabled={processingId !== null}
                                                                onClick={() => handleApprove(request.id, true)}
                                                                className="justify-start px-2 font-bold text-[11px] text-slate-700 hover:text-blue-700 hover:bg-blue-50 h-9"
                                                            >
                                                                <Package className="h-3.5 w-3.5 mr-2 text-blue-600" /> Direct Handoff
                                                            </Button>
                                                            <Button
                                                                variant="ghost"
                                                                size="sm"
                                                                onClick={() => {
                                                                    const event = new CustomEvent('ligtas:open_chat', {
                                                                        detail: { id: request.id, name: request.borrower_name }
                                                                    });
                                                                    window.dispatchEvent(event);
                                                                }}
                                                                className="justify-start px-2 font-bold text-[11px] text-slate-700 hover:text-blue-700 hover:bg-blue-50 h-9"
                                                            >
                                                                <MessageSquare className="h-3.5 w-3.5 mr-2 text-slate-500" /> Open Chat
                                                            </Button>
                                                            <div className="h-px bg-slate-100 my-1" />
                                                            <Button
                                                                variant="ghost"
                                                                size="sm"
                                                                disabled={processingId !== null}
                                                                onClick={() => handleReject(request.id)}
                                                                className="justify-start px-2 font-bold text-[11px] text-red-600 hover:text-red-700 hover:bg-red-50 h-9"
                                                            >
                                                                <X className="h-3.5 w-3.5 mr-2" /> Reject Request
                                                            </Button>
                                                        </div>
                                                    </PopoverContent>
                                                </Popover>
                                            </div>
                                        )}
                                    </div>
                                </TableCell>
                            </TableRow>
                        ))}
                    </TableBody>
                </Table>
            </div>
        </div>
    )
}
