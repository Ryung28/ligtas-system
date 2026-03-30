'use client'

import React, { useState, useEffect } from 'react'
import { Table, TableBody, TableCell, TableHead, TableHeader, TableRow } from '@/components/ui/table'
import { Button } from '@/components/ui/button'
import { Check, X, Clock, User, Building, Package, ExternalLink, MessageSquare } from 'lucide-react'
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

    const handleApprove = async (id: number) => {
        if (!staffName) {
            toast.error('Unable to identify staff member')
            return
        }
        setProcessingId(id)
        try {
            const result = await approveRequest(id, staffName)
            if (result.success) {
                toast.success('Approved! Item moved to Dispatch Queue.')
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
                            <TableHead className="px-4 py-3 font-bold text-slate-400 text-[10px] uppercase tracking-[0.15em]">Borrower Info</TableHead>
                            <TableHead className="px-4 py-3 font-bold text-slate-400 text-[10px] uppercase tracking-[0.15em]">Equipment Requested</TableHead>
                            <TableHead className="px-4 py-3 font-bold text-slate-400 text-[10px] uppercase tracking-[0.15em]">Purpose & Notes</TableHead>
                            <TableHead className="px-4 py-3 font-bold text-slate-400 text-[10px] uppercase tracking-[0.15em]">Request Time</TableHead>
                            <TableHead className="px-4 py-3 font-bold text-slate-400 text-[10px] uppercase tracking-[0.15em] text-right">Decision</TableHead>
                        </TableRow>
                    </TableHeader>
                    <TableBody>
                        {requests.map((request) => (
                            <TableRow key={request.id} className="hover:bg-blue-50/30 transition-colors border-b border-slate-50/80 group">
                                <TableCell className="px-4 py-2.5">
                                    <div className="flex items-center gap-3">
                                        <UserAvatar fullName={request.borrower_name} />
                                        <div className="flex flex-col min-w-0">
                                            <span className="text-sm font-bold text-slate-900 truncate font-heading uppercase tracking-wide">{request.borrower_name}</span>
                                            <div className="flex items-center gap-1.5 mt-0.5">
                                                <Building className="h-3 w-3 text-slate-400" />
                                                <span className="text-[10px] font-semibold text-slate-500 uppercase tracking-tight">{request.borrower_organization || 'External Personnel'}</span>
                                            </div>
                                        </div>
                                    </div>
                                </TableCell>
                                <TableCell className="px-4 py-2.5">
                                    <div className="flex items-center gap-2.5">
                                        <div className="h-8 w-8 rounded-lg bg-slate-50 border border-slate-100 flex items-center justify-center flex-shrink-0">
                                            <Package className="h-4 w-4 text-slate-600" />
                                        </div>
                                        <div className="flex flex-col min-w-0">
                                            <div className="flex items-center gap-2">
                                                <span className="text-sm font-bold text-slate-900 truncate">{request.item_name}</span>
                                                <span className="px-1.5 py-0.5 rounded-md bg-blue-100 text-blue-700 text-[10px] font-black italic">x{request.quantity}</span>
                                            </div>
                                            <span className="text-[10px] text-slate-400 font-mono mt-0.5 tracking-tight">REG-ID: {request.inventory_id}</span>
                                        </div>
                                    </div>
                                </TableCell>
                                <TableCell className="px-4 py-2.5 max-w-[250px]">
                                    <div className="flex flex-col gap-1">
                                        <p className="text-xs text-slate-700 italic font-medium line-clamp-2">
                                            &quot;{request.purpose || 'No purpose specified'}&quot;
                                        </p>
                                        {request.notes && (
                                            <p className="text-[10px] text-slate-400 truncate">
                                                Note: {request.notes}
                                            </p>
                                        )}
                                    </div>
                                </TableCell>
                                <TableCell className="px-4 py-2.5">
                                    <div className="flex items-center gap-2">
                                        <div className="flex flex-col">
                                            <span className="text-xs font-semibold text-slate-600">
                                                {new Date(request.created_at).toLocaleString('en-US', {
                                                    month: 'short',
                                                    day: 'numeric',
                                                    year: 'numeric',
                                                    hour: 'numeric',
                                                    minute: '2-digit',
                                                    hour12: true
                                                })}
                                            </span>
                                            <span className="text-[10px] text-slate-400">
                                                {formatDistanceToNow(new Date(request.created_at), { addSuffix: true })}
                                            </span>
                                        </div>
                                    </div>
                                </TableCell>
                                <TableCell className="px-4 py-2.5 text-right">
                                    <div className="flex items-center justify-end gap-2">
                                        <Button
                                            size="icon"
                                            variant="ghost"
                                            onClick={() => {
                                                const event = new CustomEvent('ligtas:open_chat', {
                                                    detail: { id: request.id, name: request.borrower_name }
                                                });
                                                window.dispatchEvent(event);
                                            }}
                                            className="h-8 w-8 rounded-lg hover:bg-blue-50 text-blue-600 transition-all opacity-0 group-hover:opacity-100"
                                            title="Open Coordination Chat"
                                        >
                                            <MessageSquare className="h-4 w-4" />
                                        </Button>
                                        <Button
                                            size="sm"
                                            variant="outline"
                                            disabled={processingId !== null}
                                            onClick={() => handleReject(request.id)}
                                            className="h-8 px-3 rounded-lg border-slate-200 text-slate-600 hover:bg-red-50 hover:text-red-600 hover:border-red-100 transition-all font-bold text-[10px] uppercase tracking-wider"
                                        >
                                            <X className="h-3 w-3 mr-1" /> {request.status === 'staged' ? 'Cancel' : 'Reject'}
                                        </Button>
                                        
                                        {request.status === 'staged' ? (
                                            <Button
                                                size="sm"
                                                disabled={processingId !== null}
                                                onClick={() => handleHandoff(request.id)}
                                                className="h-8 px-3 rounded-lg bg-emerald-600 hover:bg-emerald-700 text-white shadow-md hover:shadow-emerald-200/50 transition-all font-bold text-[10px] uppercase tracking-wider"
                                            >
                                                <Check className="h-3 w-3 mr-1" /> Complete Dispatch
                                            </Button>
                                        ) : (
                                            <Button
                                                size="sm"
                                                disabled={processingId !== null}
                                                onClick={() => handleApprove(request.id)}
                                                className="h-8 px-3 rounded-lg bg-blue-600 hover:bg-blue-700 text-white shadow-md hover:shadow-blue-200/50 transition-all font-bold text-[10px] uppercase tracking-wider"
                                            >
                                                <Check className="h-3 w-3 mr-1" /> Approve
                                            </Button>
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
