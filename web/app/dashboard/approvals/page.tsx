'use client'

import { usePendingRequests } from '@/hooks/use-pending-requests'
import { PendingRequestsTable } from '@/components/approvals/pending-requests-table'
import { RefreshCw, ClipboardList, ShieldCheck } from 'lucide-react'
import { Button } from '@/components/ui/button'

export default function ApprovalsPage() {
    const { requests, isLoading, error, refresh } = usePendingRequests()

    return (
        <div className="space-y-6 animate-in fade-in duration-500">
            {/* Header Section */}
            <header className="flex flex-col gap-4 sm:flex-row sm:items-center sm:justify-between bg-white/80 backdrop-blur-md p-4 14in:p-6 rounded-3xl border border-slate-100 shadow-sm relative overflow-hidden">
                <div className="absolute top-0 right-0 p-4 opacity-5">
                    <ShieldCheck className="h-24 w-24 text-blue-900" />
                </div>

                <div className="relative z-10">
                    <div className="flex items-center gap-2 mb-1">
                        <div className="h-2 w-2 rounded-full bg-blue-500 animate-pulse" />
                        <span className="text-[10px] font-black text-blue-600 uppercase tracking-[0.2em]">Live Approval Command</span>
                    </div>
                    <h1 className="text-2xl 14in:text-3xl font-black tracking-tight text-slate-900 font-heading uppercase italic">
                        Pending Requests
                    </h1>
                    <p className="text-slate-500 text-xs 14in:text-sm mt-1 max-w-md">
                        Review and authorize equipment issuance requests submitted from the field mobile app.
                    </p>
                </div>

                <div className="flex items-center gap-2 relative z-10">
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

            {/* Main Content */}
            {error ? (
                <div className="p-8 text-center bg-red-50 text-red-600 rounded-3xl border border-red-100 font-bold uppercase tracking-wide text-xs">
                    Command Failure: {error}
                </div>
            ) : (
                <PendingRequestsTable requests={requests} onRefresh={refresh} />
            )}

            {/* Quick Advisory */}
            <div className="bg-blue-900/5 backdrop-blur-md border border-blue-100/50 rounded-2xl p-4 flex items-center gap-4">
                <div className="h-10 w-10 bg-blue-600 rounded-xl flex items-center justify-center shrink-0 shadow-lg shadow-blue-200">
                    <ClipboardList className="h-5 w-5 text-white" />
                </div>
                <div>
                    <h4 className="text-xs font-bold text-slate-900 uppercase tracking-tight">Logistics Protocol</h4>
                    <p className="text-[10px] text-slate-600 leading-relaxed max-w-2xl mt-0.5">
                        Approval automatically converts the request into an active borrow log and confirms the stock reservation.
                        If the request is rejected, the reserved items are immediately returned to the available inventory pool.
                    </p>
                </div>
            </div>
        </div>
    )
}
