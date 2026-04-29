'use client'

import { useState, useEffect, useCallback, useMemo } from 'react'
import { usePendingRequests } from '@/hooks/use-pending-requests'
import { RefreshCw, Search, ClipboardList } from 'lucide-react'
import { Button } from '@/components/ui/button'
import { Input } from '@/components/ui/input'
import { BorrowLog } from '@/lib/types/inventory'
import { RequestLedgerList } from '@/components/approvals/_components/request-ledger-list'
import { RequestDossier } from '@/components/approvals/_components/request-dossier'

interface ApprovalsClientProps {
    initialRequests: BorrowLog[]
    staffName: string
    staffRole: string | null
}

export function ApprovalsClient({ initialRequests, staffName: initialStaffName, staffRole: initialStaffRole }: ApprovalsClientProps) {
    const { requests: liveRequests, isLoading, error, refresh } = usePendingRequests()
    const [searchTerm, setSearchTerm] = useState('')
    const [selectedRequest, setSelectedRequest] = useState<BorrowLog | null>(null)
    const [staffName] = useState(initialStaffName)
    const [staffRole] = useState(initialStaffRole)

    const requests = (isLoading && liveRequests.length === 0) ? initialRequests : liveRequests

    // Unified searchable stream
    const filteredRequests = useMemo(() => {
        if (!searchTerm) return requests
        const term = searchTerm.toLowerCase()
        return requests.filter(r => 
            r.borrower_name.toLowerCase().includes(term) || 
            r.item_name.toLowerCase().includes(term) ||
            r.borrower_department?.toLowerCase().includes(term)
        )
    }, [requests, searchTerm])

    // Auto-select first item when list changes
    useEffect(() => {
        if (filteredRequests.length > 0) {
            const stillExists = filteredRequests.find(r => r.id === selectedRequest?.id)
            if (!stillExists) {
                setSelectedRequest(filteredRequests[0])
            }
        } else {
            setSelectedRequest(null)
        }
    }, [filteredRequests, selectedRequest?.id])

    const handleActionComplete = useCallback(() => {
        setSelectedRequest(null)
        refresh()
    }, [refresh])

    return (
        <div className="flex flex-col h-[calc(100vh-105px)] animate-in fade-in duration-200">

            {/* ── Page Header ── */}
            <header className="flex items-center justify-between mb-5">
                <div>
                    <h1 className="text-xl font-bold text-slate-900 tracking-tight">Active Requests</h1>
                    <p className="text-[11px] text-slate-500 mt-0.5">Approve or manage equipment dispatches and reservations.</p>
                </div>
                <div className="flex items-center gap-3">
                    <div className="relative group w-64">
                        <Search className="absolute left-3 top-1/2 -translate-y-1/2 h-3.5 w-3.5 text-slate-400 group-focus-within:text-blue-500 transition-colors" />
                        <Input 
                            placeholder="Search name, item, or dept..."
                            value={searchTerm}
                            onChange={(e) => setSearchTerm(e.target.value)}
                            className="h-10 pl-9 pr-4 rounded-xl border-slate-200 bg-white/50 focus:bg-white text-[12px] transition-all"
                        />
                    </div>
                    <Button
                        variant="outline"
                        size="sm"
                        onClick={() => refresh()}
                        disabled={isLoading}
                        className="h-10 w-10 p-0 rounded-xl border-slate-200 bg-white hover:bg-slate-50 text-slate-500 shadow-sm"
                    >
                        <RefreshCw className={`h-3.5 w-3.5 ${isLoading ? 'animate-spin' : ''}`} />
                    </Button>
                </div>
            </header>

            {/* ── Error ── */}
            {error && (
                <div className="mb-4 p-3 rounded-xl bg-red-50 border border-red-100 text-red-600 text-[11px] font-bold">
                    System Alert: {error}
                </div>
            )}

            {/* ── Pro Console Layout ── */}
            <div className="flex-1 overflow-hidden grid grid-cols-12 gap-6">

                {/* LEFT: Request List (5 cols) */}
                <div className="col-span-5 bg-white rounded-[1.5rem] border border-slate-100 shadow-sm overflow-hidden flex flex-col">
                    {/* List Header */}
                    <div className="px-5 py-3 border-b border-slate-50 bg-slate-50/30 flex items-center justify-between">
                        <span className="text-[10px] font-bold text-slate-500 uppercase tracking-widest">
                            Request List
                        </span>
                        <span className="text-[10px] font-bold text-slate-400 bg-white px-2 py-0.5 rounded-full border border-slate-100">
                            {filteredRequests.length} Total
                        </span>
                    </div>
                    {/* Scrollable list */}
                    <div className="flex-1 overflow-y-auto">
                        <RequestLedgerList
                            requests={filteredRequests}
                            selectedId={selectedRequest?.id ?? null}
                            onSelect={setSelectedRequest}
                        />
                    </div>
                </div>

                {/* RIGHT: Details (7 cols) */}
                <div className="col-span-7 bg-white rounded-[1.5rem] border border-slate-100 shadow-sm overflow-hidden flex flex-col">
                    {selectedRequest ? (
                        <RequestDossier
                            key={selectedRequest.id}
                            request={selectedRequest}
                            staffName={staffName}
                            userRole={staffRole}
                            isReservationView={selectedRequest.status === 'reserved'}
                            onActionComplete={handleActionComplete}
                        />
                    ) : (
                        <div className="flex flex-col items-center justify-center h-full text-center p-12">
                            <div className="h-14 w-14 rounded-2xl bg-slate-50 border border-slate-100 flex items-center justify-center mb-5 shadow-sm">
                                <ClipboardList className="h-7 w-7 text-slate-200" strokeWidth={1} />
                            </div>
                            <p className="text-[13px] font-bold text-slate-700">No selection</p>
                            <p className="text-[11px] text-slate-400 max-w-[200px] mt-1">
                                Choose a request from the list to view its full details.
                            </p>
                        </div>
                    )}
                </div>
            </div>

        </div>
    )
}
