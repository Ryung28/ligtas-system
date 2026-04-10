'use client'

import { usePendingRequests } from '@/hooks/use-pending-requests'
import { PendingRequestsTable } from '@/components/approvals/pending-requests-table'
import { RefreshCw, ClipboardList, ShieldCheck } from 'lucide-react'
import { Button } from '@/components/ui/button'
import { BorrowLog } from '@/lib/types/inventory'

interface ApprovalsClientProps {
    initialRequests: BorrowLog[]
}

export function ApprovalsClient({ initialRequests }: ApprovalsClientProps) {
    const { requests: liveRequests, isLoading, error, refresh } = usePendingRequests()
    
    // Fallback to initial requests if loading
    const requests = (isLoading && liveRequests.length === 0) ? initialRequests : liveRequests

    // 🚀 TACTICAL GROUPING: Separate Urgent Deployments from Future Planning
    const now = new Date()
    const today = new Date(now.getFullYear(), now.getMonth(), now.getDate(), 23, 59, 59)

    const urgentRequests = requests.filter(r => {
        if (!r.pickup_scheduled_at) return true
        return new Date(r.pickup_scheduled_at) <= today
    })

    const futureReservations = requests.filter(r => {
        if (!r.pickup_scheduled_at) return false
        return new Date(r.pickup_scheduled_at) > today
    })

    return (
        <div className="space-y-6 14in:space-y-4 animate-in fade-in duration-500">
            {/* Header Section */}
            <header className="flex flex-col gap-4 sm:flex-row sm:items-center sm:justify-between bg-white/80 backdrop-blur-md p-4 14in:p-4 rounded-3xl border border-slate-100 shadow-sm relative overflow-hidden">
                <div className="absolute top-0 right-0 p-4 opacity-5">
                    <ShieldCheck className="h-24 w-24 text-blue-900" />
                </div>

                <div className="relative z-10">
                    <div className="flex items-center gap-2 mb-1">
                    </div>
                    <h1 className="text-2xl 14in:text-2xl font-black tracking-tight text-slate-900 font-heading uppercase italic">
                        Command Queue
                    </h1>
                    <p className="text-slate-500 text-xs 14in:text-[11px] mt-1 max-w-md">
                        Review equipment requests and finalize logistics dispatch.
                    </p>
                </div>

                <div className="flex items-center gap-4 relative z-10">
                    <div className="flex gap-4 px-4 py-2 bg-slate-50 rounded-2xl border border-slate-100">
                        <div className="text-center border-r border-slate-200 pr-4">
                            <p className="text-[10px] font-bold text-slate-400 uppercase tracking-widest">Active Today</p>
                            <p className="text-sm font-black text-blue-600">{urgentRequests.length}</p>
                        </div>
                        <div className="text-center pl-4">
                            <p className="text-[10px] font-bold text-slate-400 uppercase tracking-widest">Planned</p>
                            <p className="text-sm font-black text-amber-600">{futureReservations.length}</p>
                        </div>
                    </div>
                    <Button
                        variant="outline"
                        size="sm"
                        onClick={() => refresh()}
                        disabled={isLoading}
                        className="h-10 px-4 rounded-xl border-slate-200 bg-white/50 hover:bg-white text-slate-600 font-bold text-[10px] uppercase tracking-widest transition-all active:scale-95"
                    >
                        <RefreshCw className={`h-3.5 w-3.5 mr-2 ${isLoading ? 'animate-spin' : ''}`} />
                        {isLoading ? 'Syncing...' : 'Force Refresh'}
                    </Button>
                </div>
            </header>

            {/* Main Content Interface (Grouped Queue) */}
            {error ? (
                <div className="p-8 text-center bg-red-50 text-red-600 rounded-3xl border border-red-100 font-bold uppercase tracking-wide text-xs">
                    Command Failure: {error}
                </div>
            ) : (
                <div className="space-y-8 14in:space-y-6">
                    {/* Section 1: Immediate Deployments */}
                    <div className="space-y-3">
                        <div className="flex items-center gap-2 px-2">
                            <div className="h-2 w-2 rounded-full bg-blue-500 animate-pulse" />
                            <h2 className="text-[11px] font-black text-slate-900 uppercase tracking-[0.2em]">Immediate Deployments (Today)</h2>
                        </div>
                        <PendingRequestsTable requests={urgentRequests} onRefresh={refresh} />
                        {urgentRequests.length === 0 && (
                            <div className="p-12 text-center bg-slate-50/50 rounded-[2.5rem] border border-dashed border-slate-200">
                                <p className="text-slate-400 font-bold text-[10px] uppercase tracking-widest">No active deployments for today</p>
                            </div>
                        )}
                    </div>

                    {/* Section 2: Future Reservations */}
                    {futureReservations.length > 0 && (
                        <div className="space-y-3">
                            <div className="flex items-center gap-2 px-2">
                                <div className="h-2 w-2 rounded-full bg-amber-500" />
                                <h2 className="text-[11px] font-black text-slate-900 uppercase tracking-[0.2em]">Planned Reservations (Future)</h2>
                            </div>
                            <PendingRequestsTable requests={futureReservations} onRefresh={refresh} />
                        </div>
                    )}
                </div>
            )}

            {/* Quick Advisory */}
            <div className="bg-blue-900/5 backdrop-blur-md border border-blue-100/50 rounded-2xl p-4 flex items-center gap-4">
                <div className="h-10 w-10 bg-blue-600 rounded-xl flex items-center justify-center shrink-0 shadow-lg shadow-blue-200">
                    <ClipboardList className="h-5 w-5 text-white" />
                </div>
                <div>
                    <h4 className="text-[10px] font-black text-slate-900 uppercase tracking-widest">Tactical Protocol</h4>
                    <p className="text-[10px] text-slate-600 leading-relaxed max-w-2xl mt-0.5">
                        Authorization locks the inventory for the responder. Direct Handoff immediately activates the borrow log for field use.
                    </p>
                </div>
            </div>
        </div>
    )
}
