'use client'

import React, { useEffect, useState } from 'react'
import { useRouter, useSearchParams } from 'next/navigation'
import { BottomSheet } from '@/components/mobile/primitives/bottom-sheet'
import { TransactionDetailBody } from '@/src/features/transactions/components/transaction-detail-body'
import { useBorrowLogs } from '@/hooks/use-borrow-logs'
import { BorrowLog } from '@/lib/types/inventory'
import { Loader2 } from 'lucide-react'
import { getBorrowLogByIdAction } from '@/app/actions/logs-actions'

/**
 * 📱 MOBILE TRANSACTION DETAIL SHEET
 * 🏛️ ARCHITECTURE: "URL-Driven Triage"
 * 
 * This is the "Full Card" view for mobile. 
 * It reads from the URL ?id=XXX to determine which log to show.
 */
export function TransactionDetailSheet() {
    const router = useRouter()
    const searchParams = useSearchParams()
    const triageId = searchParams.get('id')
    const { logs, refresh } = useBorrowLogs()
    
    const [selectedLog, setSelectedLog] = useState<BorrowLog | null>(null)
    const [isLoading, setIsLoading] = useState(false)

    // 🛡️ SYNC ENGINE: Listen for URL ID and resolve the record
    useEffect(() => {
        if (!triageId) {
            setSelectedLog(null)
            return
        }

        const logInCache = logs.find(l => String(l.id) === triageId)
        if (logInCache) {
            setSelectedLog(logInCache)
        } else {
            // Fetch if not in current dashboard/logs cache
            setIsLoading(true)
            getBorrowLogByIdAction(triageId).then(res => {
                if (res.success && res.data) {
                    setSelectedLog(res.data)
                }
                setIsLoading(false)
            })
        }
    }, [triageId, logs])

    const handleClose = () => {
        // Clean up URL without triggering full page reload
        const params = new URLSearchParams(searchParams.toString())
        params.delete('id')
        params.delete('triage')
        router.replace(`?${params.toString()}`, { scroll: false })
    }

    return (
        <BottomSheet
            open={!!triageId}
            onOpenChange={(open) => !open && handleClose()}
            title="Transaction Detail"
            description={selectedLog ? `#${selectedLog.id} • ${selectedLog.status}` : 'Ledger lookup...'}
            size="full"
        >
            {isLoading ? (
                <div className="flex flex-col items-center justify-center py-24 text-gray-400 gap-4">
                    <Loader2 className="w-8 h-8 animate-spin text-blue-500" />
                    <p className="text-xs font-bold uppercase tracking-widest animate-pulse">Consulting Ledger...</p>
                </div>
            ) : selectedLog ? (
                <TransactionDetailBody 
                    log={selectedLog} 
                    isMobile 
                    onActionSuccess={() => {
                        refresh()
                        // Small delay before close to show success state if needed
                        setTimeout(handleClose, 800)
                    }} 
                />
            ) : (
                <div className="py-20 text-center">
                    <p className="text-sm text-gray-500 italic">Record not found in this sector.</p>
                </div>
            )}
        </BottomSheet>
    )
}
