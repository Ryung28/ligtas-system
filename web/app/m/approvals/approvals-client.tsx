'use client'

import { useState, useEffect } from 'react'
import { usePendingRequests } from '@/hooks/use-pending-requests'
import { ApprovalCard } from '@/components/mobile/approval-card'
import { MobileHeader } from '@/components/mobile/mobile-header'
import { approveRequest, rejectRequest, completeHandoff } from '@/src/features/approvals'
import { toast } from 'sonner'
import { createBrowserClient } from '@supabase/ssr'
import { ShieldCheck, RefreshCw, CheckCircle2 } from 'lucide-react'
import { Button } from '@/components/ui/button'
import { cn } from '@/lib/utils'

import { useSearchParams } from 'next/navigation'
 
 /**
  * ✅ ApprovalsClient
  * Dedicated client logic for the mobile approval queue.
  */
 export function ApprovalsClient() {
     const { requests, isLoading, refresh } = usePendingRequests()
     const [processingId, setProcessingId] = useState<number | null>(null)
     const [staffName, setStaffName] = useState('')
     const [activeFilter, setActiveFilter] = useState<'all' | 'pending' | 'staged'>('all')
 
     const searchParams = useSearchParams()
     const targetId = searchParams.get('id')
 
     // 🎯 MISSION TRIAGE: If deep-linked, ensure the target is visible
    useEffect(() => {
        if (targetId && requests.length > 0) {
            setActiveFilter('all')
            
            // Allow render cycle to complete, then anchor focus
            const timer = setTimeout(() => {
                const element = document.getElementById(`request-${targetId}`)
                if (element) {
                    element.scrollIntoView({ behavior: 'smooth', block: 'center' })
                    // We use the CSS :target pseudo-class if we navigated via hash, 
                    // but since this is searchParams, we can manually trigger a highlight or pulse
                }
            }, 600)
            return () => clearTimeout(timer)
        }
    }, [targetId, requests.length])

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
            toast.error('Checking your profile...')
            return
        }
        setProcessingId(id)
        try {
            const result = await approveRequest(id, staffName, false)
            if (result.success) {
                toast.success('Approved! Ready for pickup.')
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
            toast.error('Checking your profile...')
            return
        }
        setProcessingId(id)
        try {
            const result = await completeHandoff(id, staffName)
            if (result.success) {
                toast.success('Gear Handed Over')
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
        if (!confirm('Cancel this request?')) return
        setProcessingId(id)
        try {
            const result = await rejectRequest(id)
            if (result.success) {
                toast.warning('Request Cancelled')
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

    const filteredRequests = requests.filter(r => {
        if (activeFilter === 'all') return true
        if (activeFilter === 'pending') return r.status === 'pending' || r.status === 'reserved'
        if (activeFilter === 'staged') return r.status === 'staged'
        return true
    })

    return (
        <div className="space-y-4 pb-24">
            <MobileHeader title="Logistics Queue" onRefresh={refresh} isLoading={isLoading} />

            <div className="px-4 space-y-4">
                {/* Tactical Filter Row — Mirrors Flutter Terminal */}
                <div className="flex gap-2 overflow-x-auto no-scrollbar py-1">
                    {['all', 'pending', 'staged'].map((f) => (
                        <button
                            key={f}
                            onClick={() => setActiveFilter(f as any)}
                            className={cn(
                                "px-4 py-2 rounded-xl text-[10px] font-black uppercase tracking-widest transition-all whitespace-nowrap",
                                activeFilter === f 
                                    ? "bg-slate-900 text-white shadow-lg shadow-slate-100 scale-105" 
                                    : "bg-slate-100 text-slate-500"
                            )}
                        >
                            {f === 'all' ? `All (${requests.length})` : 
                             f === 'pending' ? `Pending (${requests.filter(r => r.status === 'pending' || r.status === 'reserved').length})` : 
                             `Ready (${requests.filter(r => r.status === 'staged').length})`}
                        </button>
                    ))}
                </div>

                <div className="space-y-4">
                    {isLoading && requests.length === 0 ? (
                        Array(3).fill(0).map((_, i) => (
                            <div key={i} className="h-32 bg-gray-100 rounded-2xl animate-pulse" />
                        ))
                    ) : filteredRequests.length > 0 ? (
                        filteredRequests.map((request) => (
                            <ApprovalCard 
                                key={request.id} 
                                request={request} 
                                onApprove={() => handleApprove(request.id)}
                                onHandoff={() => handleHandoff(request.id)}
                                onReject={() => handleReject(request.id)}
                                isProcessing={processingId === request.id}
                            />
                        ))
                    ) : (
                        <div className="py-20 text-center space-y-4">
                            <div className="w-16 h-16 bg-gray-100 rounded-3xl flex items-center justify-center mx-auto">
                                <CheckCircle2 className="w-8 h-8 text-gray-300" />
                            </div>
                            <div>
                                <h3 className="font-bold text-gray-900 text-base">Sector Clear</h3>
                                <p className="text-[10px] font-bold text-gray-400 uppercase tracking-widest mt-1">No logistical actions required.</p>
                            </div>
                        </div>
                    )}
                </div>
            </div>
        </div>
    )
}
