'use client'

import React, { useMemo } from 'react'
import { Package, XCircle, CheckCircle2 } from 'lucide-react'
import { Button } from '@/components/ui/button'
import { ReturnCommandSheet } from '@/src/features/transactions/v2/return-command-sheet'
import { BorrowSession } from '@/lib/types/inventory'

interface LogBatchDockProps {
    selectedLogIds: Set<number>
    setSelectedLogIds: (ids: Set<number>) => void
    sessions: BorrowSession[]
}

export function LogBatchDock({ selectedLogIds, setSelectedLogIds, sessions }: LogBatchDockProps) {
    const selectedItemsData = useMemo(() => {
        return sessions
            .flatMap(s => s.items)
            .filter(i => selectedLogIds.has(i.id))
            .map(i => ({
                logId: i.id,
                itemName: i.item_name,
                quantity: i.quantity,
                inventoryId: i.inventory_id,
                imageUrl: (i as any).inventory?.image_url,
                borrowedFrom: (i as any).borrowed_from_warehouse || (i as any).inventory?.storage_location
            }))
    }, [sessions, selectedLogIds])

    const batchBorrowerName = useMemo(() => {
        if (selectedLogIds.size === 0) return ""
        const firstId = Array.from(selectedLogIds)[0]
        const session = sessions.find(s => s.items.some(i => i.id === firstId))
        return session?.borrower_name || "Borrower"
    }, [sessions, selectedLogIds])

    if (selectedLogIds.size === 0) return null

    return (
        <div className="fixed bottom-10 left-0 right-0 flex justify-center z-[999] pointer-events-none px-4 animate-in fade-in slide-in-from-bottom-8 duration-500">
            <div className="bg-zinc-950/95 backdrop-blur-xl text-white px-6 py-4 rounded-[2rem] shadow-[0_20px_50px_rgba(0,0,0,0.4)] flex items-center gap-8 pointer-events-auto border border-white/10 ring-1 ring-white/5 max-w-2xl w-full sm:w-auto">
                <div className="flex items-center gap-4 pr-8 border-r border-white/10">
                    <div className="h-10 w-10 rounded-2xl bg-white/10 flex items-center justify-center border border-white/10">
                        <Package className="h-5 w-5 text-white" />
                    </div>
                    <div className="flex flex-col">
                        <span className="text-[11px] font-bold text-white uppercase tracking-[0.2em] leading-none mb-1.5">Selected</span>
                        <span className="text-[16px] font-black tracking-tight leading-none">
                            {selectedLogIds.size} <span className="text-zinc-400 font-bold ml-1">{selectedLogIds.size === 1 ? 'Item' : 'Items'}</span>
                        </span>
                    </div>
                </div>

                <div className="flex items-center gap-3">
                    <Button
                        variant="ghost"
                        size="sm"
                        onClick={() => setSelectedLogIds(new Set())}
                        className="text-zinc-400 hover:text-white hover:bg-white/10 h-10 px-4 font-bold text-[13px] uppercase tracking-wider transition-all"
                    >
                        <XCircle className="h-4 w-4 mr-2" />
                        Cancel
                    </Button>

                    <ReturnCommandSheet
                        items={selectedItemsData}
                        borrowerName={batchBorrowerName}
                        onActionSuccess={() => setSelectedLogIds(new Set())}
                    >
                        <Button
                            size="sm"
                            className="bg-white text-zinc-950 hover:bg-zinc-100 h-11 px-8 rounded-2xl font-black text-[13px] uppercase tracking-widest shadow-xl transition-all active:scale-95"
                        >
                            <div className="flex items-center gap-2.5">
                                <CheckCircle2 className="h-5 w-5 text-emerald-600" />
                                <span>Return Items</span>
                            </div>
                        </Button>
                    </ReturnCommandSheet>
                </div>
            </div>
        </div>
    )
}
