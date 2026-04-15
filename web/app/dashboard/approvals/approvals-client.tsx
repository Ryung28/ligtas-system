'use client'

import { useState, useEffect, useCallback } from 'react'
import { usePendingRequests } from '@/hooks/use-pending-requests'
import { RefreshCw, Zap, Calendar, ClipboardList } from 'lucide-react'
import { Button } from '@/components/ui/button'
import { BorrowLog } from '@/lib/types/inventory'
import { Tabs, TabsList, TabsTrigger } from '@/components/ui/tabs'
import { createBrowserClient } from '@supabase/ssr'
import { RequestLedgerList } from '@/components/approvals/_components/request-ledger-list'
import { RequestDossier } from '@/components/approvals/_components/request-dossier'
import { ClipboardList as EmptyIcon } from 'lucide-react'

interface ApprovalsClientProps {
    initialRequests: BorrowLog[]
}

export function ApprovalsClient({ initialRequests }: ApprovalsClientProps) {
    const { requests: liveRequests, isLoading, error, refresh } = usePendingRequests()
    const [currentView, setCurrentView] = useState<'immediate' | 'reserved'>('immediate')
    const [selectedRequest, setSelectedRequest] = useState<BorrowLog | null>(null)
    const [staffName, setStaffName] = useState('')

    // Resolve current staff name once
    useEffect(() => {
        const supabase = createBrowserClient(
            process.env.NEXT_PUBLIC_SUPABASE_URL!,
            process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY!
        )
        const load = async () => {
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
        load()
    }, [])

    const requests = (isLoading && liveRequests.length === 0) ? initialRequests : liveRequests

    const now = new Date()
    const todayEnd = new Date(now.getFullYear(), now.getMonth(), now.getDate(), 23, 59, 59)

    // Partition: Today's action vs future planning
    const urgentRequests = requests.filter(r => {
        if (!r.pickup_scheduled_at) return r.status !== 'reserved'
        return new Date(r.pickup_scheduled_at) <= todayEnd
    })

    const futureReservations = requests.filter(r => {
        if (r.status === 'reserved') return true
        if (!r.pickup_scheduled_at) return false
        return new Date(r.pickup_scheduled_at) > todayEnd
    })

    const displayRequests = currentView === 'immediate' ? urgentRequests : futureReservations

    // Auto-select first item when tab or list changes
    useEffect(() => {
        if (displayRequests.length > 0) {
            // Keep current selection if it's still in the list
            const stillExists = displayRequests.find(r => r.id === selectedRequest?.id)
            if (!stillExists) {
                setSelectedRequest(displayRequests[0])
            }
        } else {
            setSelectedRequest(null)
        }
    }, [currentView, displayRequests.length])

    const handleActionComplete = useCallback(() => {
        setSelectedRequest(null)
        refresh()
    }, [refresh])

    return (
        <div className="flex flex-col h-[calc(100vh-105px)] animate-in fade-in duration-200">

            {/* ── Page Header ── */}
            <header className="flex items-center justify-between mb-5">
                <div>
                    <h1 className="text-xl font-black text-slate-900 tracking-tight">Request Queue</h1>
                    <p className="text-xs text-slate-500 mt-0.5">Review and approve equipment requests from your team.</p>
                </div>
                <div className="flex items-center gap-3">
                    <Tabs value={currentView} onValueChange={(v) => setCurrentView(v as any)} className="w-fit">
                        <TabsList className="bg-slate-100 p-1 rounded-xl h-10 border border-slate-200/50">
                            <TabsTrigger
                                value="immediate"
                                className="rounded-lg px-4 font-black text-[10px] uppercase tracking-widest data-[state=active]:bg-blue-600 data-[state=active]:text-white transition-all"
                            >
                                <Zap className="h-3 w-3 mr-1.5" />
                                Today ({urgentRequests.length})
                            </TabsTrigger>
                            <TabsTrigger
                                value="reserved"
                                className="rounded-lg px-4 font-black text-[10px] uppercase tracking-widest data-[state=active]:bg-amber-500 data-[state=active]:text-white transition-all"
                            >
                                <Calendar className="h-3 w-3 mr-1.5" />
                                Future ({futureReservations.length})
                            </TabsTrigger>
                        </TabsList>
                    </Tabs>
                    <Button
                        variant="outline"
                        size="sm"
                        onClick={() => refresh()}
                        disabled={isLoading}
                        className="h-10 w-10 p-0 rounded-xl border-slate-200 bg-white hover:bg-slate-50 text-slate-500"
                    >
                        <RefreshCw className={`h-3.5 w-3.5 ${isLoading ? 'animate-spin' : ''}`} />
                    </Button>
                </div>
            </header>

            {/* ── Error ── */}
            {error && (
                <div className="mb-4 p-4 rounded-2xl bg-red-50 border border-red-100 text-red-600 text-xs font-bold">
                    Failed to load requests: {error}
                </div>
            )}

            {/* ── Split-Pane Layout ── */}
            <div className="flex-1 overflow-hidden grid grid-cols-12 gap-6">

                {/* LEFT: Ledger List (5 cols) */}
                <div className="col-span-5 bg-white rounded-3xl border border-slate-100 shadow-sm overflow-hidden flex flex-col">
                    {/* Subheader */}
                    <div className="px-5 py-3.5 border-b border-slate-50 bg-slate-50/50 flex items-center gap-2">
                        <div className={`h-1.5 w-1.5 rounded-full ${currentView === 'immediate' ? 'bg-blue-500 animate-pulse' : 'bg-amber-500'}`} />
                        <span className="text-[10px] font-black text-slate-500 uppercase tracking-[0.18em]">
                            {currentView === 'immediate' ? 'Current Requests' : 'Future Reservations'}
                        </span>
                        <span className="ml-auto text-[10px] font-black text-slate-400">
                            {displayRequests.length} {displayRequests.length === 1 ? 'item' : 'items'}
                        </span>
                    </div>
                    {/* Scrollable list */}
                    <div className="flex-1 overflow-y-auto">
                        <RequestLedgerList
                            requests={displayRequests}
                            selectedId={selectedRequest?.id ?? null}
                            onSelect={setSelectedRequest}
                        />
                    </div>
                </div>

                {/* RIGHT: Dossier (7 cols) */}
                <div className="col-span-7 bg-white rounded-3xl border border-slate-100 shadow-sm overflow-hidden flex flex-col">
                    {selectedRequest ? (
                        <RequestDossier
                            key={selectedRequest.id}
                            request={selectedRequest}
                            staffName={staffName}
                            isReservationView={currentView === 'reserved'}
                            onActionComplete={handleActionComplete}
                        />
                    ) : (
                        <div className="flex flex-col items-center justify-center h-full text-center p-12">
                            <div className="h-16 w-16 rounded-3xl bg-slate-50 border border-slate-100 flex items-center justify-center mb-5 shadow-inner">
                                <ClipboardList className="h-8 w-8 text-slate-200" strokeWidth={1} />
                            </div>
                            <p className="text-sm font-bold text-slate-700 mb-1">Select a request</p>
                            <p className="text-xs text-slate-400 max-w-[220px]">
                                Click any item from the list on the left to view its full details here.
                            </p>
                        </div>
                    )}
                </div>
            </div>

        </div>
    )
}
