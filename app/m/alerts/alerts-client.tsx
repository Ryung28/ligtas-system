'use client'

import React, { useState, useEffect } from 'react'
import { useDashboardStats } from '@/hooks/use-dashboard-stats'
import { usePendingRequests } from '@/hooks/use-pending-requests'
import { MobileHeader } from '@/components/mobile/mobile-header'
import { ApprovalCard } from '@/components/mobile/approval-card'
import { approveRequest, rejectRequest, completeHandoff } from '@/src/features/approvals'
import { isLowStock } from '@/src/features/inventory/utils'
import { toast } from 'sonner'
import { createBrowserClient } from '@supabase/ssr'
import { 
    CheckCircle2
} from 'lucide-react'
import { useSearchParams } from 'next/navigation'
import { AlertFilters, FilterType } from './_components/alert-filters'
import { AnomalyCard } from './_components/anomaly-card'
import { useAlertTriage } from './hooks/use-alert-triage'
import { InventoryImagePreviewDialog } from '@/components/ui/inventory-image-preview-dialog'

export function AlertsClient() {
    const { data: dashboardData, isLoading: statsLoading, refresh: refreshStats } = useDashboardStats()
    const { requests: pendingRequests, isLoading: pendingLoading, refresh: refreshRequests } = usePendingRequests()
    const [activeFilter, setActiveFilter] = useState<FilterType>('all')
    const [processingId, setProcessingId] = useState<number | null>(null)
    const [staffName, setStaffName] = useState('ANALYST')
    const [previewImage, setPreviewImage] = useState<{ url: string; name: string } | null>(null)

    const searchParams = useSearchParams()
    const targetId = searchParams.get('id')

    const isLoading = statsLoading || pendingLoading
    const { filteredAnomalies, inventoryAnomalies, stats: anomalyStats } = useAlertTriage(dashboardData?.inventory, activeFilter)

    // 🛡️ PROFILE HYDRATION
    useEffect(() => {
        async function loadProfile() {
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
        loadProfile()
    }, [])

    // 🎯 MISSION TRIAGE: If deep-linked, ensure the target is visible
    useEffect(() => {
        if (targetId && pendingRequests.length > 0) {
            setActiveFilter('all')
            
            const timer = setTimeout(() => {
                const element = document.getElementById(`request-${targetId}`)
                if (element) {
                    element.scrollIntoView({ behavior: 'smooth', block: 'center' })
                }
            }, 600)
            return () => clearTimeout(timer)
        }
    }, [targetId, pendingRequests.length])

    const handleRefresh = async () => {
        await Promise.all([refreshStats(), refreshRequests()])
    }

    const handleApprove = async (id: number) => {
        setProcessingId(id)
        try {
            const result = await approveRequest(id, staffName, false)
            if (result.success) {
                toast.success('Approved')
                refreshRequests()
            }
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
                toast.warning('Cancelled')
                refreshRequests()
            }
        } finally {
            setProcessingId(null)
        }
    }

    const handleHandoff = async (id: number) => {
        setProcessingId(id)
        try {
            const result = await completeHandoff(id, staffName)
            if (result.success) {
                toast.success('Handoff Complete')
                refreshRequests()
            }
        } finally {
            setProcessingId(null)
        }
    }

    const showRequests = activeFilter === 'all' || activeFilter === 'requests'
    const totalCount = inventoryAnomalies.length + pendingRequests.length

    return (
        <div className="space-y-4 pb-24">
            <MobileHeader title="Alert Center" onRefresh={handleRefresh} isLoading={isLoading} />

            <div className="px-4 space-y-6">
                <AlertFilters 
                    activeFilter={activeFilter}
                    setActiveFilter={setActiveFilter}
                    totalCount={totalCount}
                    criticalCount={anomalyStats.critical}
                    requestsCount={pendingRequests.length}
                    healthCount={anomalyStats.health}
                />

                <div className="space-y-6">
                    {/* 📦 INVENTORY ANOMALIES */}
                    {filteredAnomalies.length > 0 && (
                        <div className="space-y-3">
                            <h3 className="text-[10px] font-black text-slate-400 uppercase tracking-[0.2em] px-1">Inventory Anomalies</h3>
                            <div className="space-y-3">
                                {filteredAnomalies.map((item) => (
                                    <AnomalyCard 
                                        key={item.id} 
                                        item={item as any} 
                                        onImageClick={(url, name) => setPreviewImage({ url, name })}
                                    />
                                ))}
                            </div>
                        </div>
                    )}

                    {/* 📋 PENDING REQUESTS */}
                    {showRequests && pendingRequests.length > 0 && (
                        <div className="space-y-3">
                            <h3 className="text-[10px] font-black text-slate-400 uppercase tracking-[0.2em] px-1">Logistics Queue</h3>
                            <div className="space-y-4">
                                {pendingRequests.map((request) => (
                                    <ApprovalCard 
                                        key={request.id} 
                                        request={request} 
                                        onApprove={() => handleApprove(request.id)}
                                        onHandoff={() => handleHandoff(request.id)}
                                        onReject={() => handleReject(request.id)}
                                        isProcessing={processingId === request.id}
                                    />
                                ))}
                            </div>
                        </div>
                    )}

                    {totalCount === 0 && !isLoading && (
                        <div className="py-20 text-center space-y-4">
                            <div className="w-16 h-16 bg-emerald-50 rounded-3xl flex items-center justify-center mx-auto">
                                <CheckCircle2 className="w-8 h-8 text-emerald-500" />
                            </div>
                            <div>
                                <h3 className="font-bold text-gray-900 text-base">Sector Clear</h3>
                                <p className="text-[10px] font-bold text-gray-400 uppercase tracking-widest mt-1">No tactical alerts detected.</p>
                            </div>
                        </div>
                    )}
                </div>
            </div>

            <InventoryImagePreviewDialog 
                image={previewImage}
                onOpenChange={(open) => !open && setPreviewImage(null)}
            />
        </div>
    )
}
