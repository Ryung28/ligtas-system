'use client'

import { useState, useEffect } from 'react'
import { usePendingRequests } from '@/hooks/use-pending-requests'
import { ApprovalCard } from '@/components/mobile/approval-card'
import { MobileHeader } from '@/components/mobile/mobile-header'
import { approveRequest, rejectRequest, completeHandoff } from '@/src/features/approvals'
import { toast } from 'sonner'
import { createBrowserClient } from '@supabase/ssr'
import { ShieldCheck, RefreshCw } from 'lucide-react'
import { Button } from '@/components/ui/button'

/**
 * ✅ ApprovalsClient
 * Dedicated client logic for the mobile approval queue.
 */
export function ApprovalsClient() {
    const { requests, isLoading, refresh } = usePendingRequests()
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
            toast.error('Identifying staff member...')
            return
        }
        setProcessingId(id)
        try {
            const result = await approveRequest(id, staffName, false)
            if (result.success) {
                toast.success('Approved! Moved to staging.')
                refresh()
            } else {
                toast.error(result.error || 'Approval failed')
            }
        } catch (err) {
            toast.error('Unexpected error during approval')
        } finally {
            setProcessingId(null)
        }
    }

    const handleHandoff = async (id: number) => {
        if (!staffName) {
            toast.error('Identifying staff member...')
            return
        }
        setProcessingId(id)
        try {
            const result = await completeHandoff(id, staffName)
            if (result.success) {
                toast.success('Equipment Dispatched')
                refresh()
            } else {
                toast.error(result.error || 'Handoff failed')
            }
        } catch (err) {
            toast.error('Unexpected error during handoff')
        } finally {
            setProcessingId(null)
        }
    }

    const handleReject = async (id: number) => {
        if (!confirm('Are you sure you want to reject this request?')) return
        setProcessingId(id)
        try {
            const result = await rejectRequest(id)
            if (result.success) {
                toast.warning('Request rejected')
                refresh()
            } else {
                toast.error(result.error || 'Rejection failed')
            }
        } catch (err) {
            toast.error('Unexpected error during rejection')
        } finally {
            setProcessingId(null)
        }
    }

    return (
        <div className="flex flex-col h-full bg-slate-50 px-4 pt-4">
            <MobileHeader 
                title="Approvals" 
                onRefresh={() => refresh()} 
                isLoading={isLoading} 
            />

            <div className="flex-1 overflow-y-auto pt-4 pb-24">
                <div className="bg-blue-900 rounded-3xl p-5 mb-6 shadow-xl shadow-blue-900/20 relative overflow-hidden">
                    <ShieldCheck className="absolute top-1/2 -right-4 -translate-y-1/2 h-24 w-24 text-white/5 rotate-12" />
                    <div className="relative z-10">
                        <h2 className="text-white font-black text-xl uppercase italic tracking-tight mb-1">Command Queue</h2>
                        <p className="text-blue-100/70 text-[10px] font-bold uppercase tracking-widest">
                            {requests.length} Pending Commands
                        </p>
                    </div>
                </div>

                {isLoading && requests.length === 0 ? (
                    <div className="space-y-4">
                        {[1, 2, 3].map(i => (
                            <div key={i} className="h-40 bg-white rounded-2xl animate-pulse" />
                        ))}
                    </div>
                ) : requests.length === 0 ? (
                    <div className="flex flex-col items-center justify-center py-20 text-center">
                        <div className="bg-white p-6 rounded-3xl shadow-sm mb-4">
                            <ShieldCheck className="h-12 w-12 text-slate-200" />
                        </div>
                        <h3 className="text-slate-900 font-black text-lg uppercase tracking-tight">Queue Clear</h3>
                        <p className="text-slate-500 text-xs mt-1">No pending equipment requests.</p>
                        <Button
                            variant="ghost"
                            size="sm"
                            onClick={() => refresh()}
                            className="mt-6 text-blue-600 font-bold text-[10px] uppercase tracking-widest"
                        >
                            <RefreshCw className="h-3 w-3 mr-2" /> Check for updates
                        </Button>
                    </div>
                ) : (
                    <div className="space-y-4">
                        {requests.map(request => (
                            <ApprovalCard
                                key={request.id}
                                request={request}
                                onApprove={handleApprove}
                                onReject={handleReject}
                                onHandoff={handleHandoff}
                                isProcessing={processingId === request.id}
                            />
                        ))}
                    </div>
                )}
            </div>
        </div>
    )
}
