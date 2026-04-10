'use client'

import { useState } from 'react'
import useSWR from 'swr'
import { motion, AnimatePresence } from 'framer-motion'
import { ShieldAlert, CheckCircle2, AlertOctagon, RotateCcw, User, Package, Clock } from 'lucide-react'
import { Button } from '@/components/ui/button'
import { Card } from '@/components/ui/card'
import { toast } from 'sonner'
import { getBorrowerPending } from '@/hooks/use-borrower-registry'
import { resolveLogisticsAction } from '@/app/actions/logistics-actions'

interface PendingTriageHeaderProps {
  searchQuery: string
}

/**
 * 🛰️ UNIFIED LOGISTICS TRIAGE HEADER
 * 
 * Injects pending logistics actions (e.g., authorization requests) at the top of the 
 * Borrow/Return Logs page when an identity-based search is active.
 * 
 * Patterns: "Contextual Teleportation", "Zero-Latency Feedback"
 */
export function PendingTriageHeader({ searchQuery }: PendingTriageHeaderProps) {
  const [isProcessing, setIsProcessing] = useState<string | null>(null)
  
  // Use a targeted SWR key for this specific search
  const { data: pending = [], mutate, isLoading } = useSWR(
    searchQuery && searchQuery.length > 2 ? `pending-triage-${searchQuery}` : null,
    () => getBorrowerPending(searchQuery),
    { refreshInterval: 5000 }
  )

  const handleAction = async (id: string, decision: 'completed' | 'flagged') => {
    setIsProcessing(id)
    try {
      const result = await resolveLogisticsAction(id, decision)
      if (result.success) {
        toast.success(`Request ${decision === 'completed' ? 'authorized' : 'flagged'}`)
        // Immediate local mutation for high-performance feel
        mutate(pending.filter(p => p.id !== id), false)
      } else {
        toast.error(result.error || 'Failed to update request')
      }
    } finally {
      setIsProcessing(null)
    }
  }

  // Display nothing if no search query or no pending items found
  if (!searchQuery || searchQuery.length < 2 || (!isLoading && pending.length === 0)) {
    return null
  }

  return (
    <AnimatePresence>
      <motion.div
        initial={{ height: 0, opacity: 0 }}
        animate={{ height: 'auto', opacity: 1 }}
        exit={{ height: 0, opacity: 0 }}
        className="overflow-hidden mb-6"
      >
        <div className="grid gap-4">
          {pending.map((item) => (
            <Card 
              key={item.id}
              className="relative overflow-hidden border-none shadow-[0_8px_30px_rgb(0,0,0,0.04)] bg-gradient-to-r from-slate-900 to-slate-800 p-4 14in:p-6"
            >
              {/* Intent Background Pattern */}
              <div className="absolute inset-0 opacity-[0.03] pointer-events-none">
                <svg width="100%" height="100%"><defs><pattern id="triage-pattern" width="40" height="40" patternUnits="userSpaceOnUse"><path d="M0 40L40 0" fill="none" stroke="white" strokeWidth="1"/></pattern></defs><rect width="100%" height="100%" fill="url(#triage-pattern)"/></svg>
              </div>

              <div className="flex flex-col md:flex-row md:items-center justify-between gap-6 relative z-10">
                <div className="flex items-start gap-4">
                  <div className="h-12 w-12 rounded-[1.2rem] bg-amber-500/10 flex items-center justify-center border border-amber-500/20 shadow-[0_0_20px_rgba(245,158,11,0.1)] shrink-0">
                    <ShieldAlert className="h-6 w-6 text-amber-500 animate-pulse" />
                  </div>
                  
                  <div>
                    <div className="flex items-center gap-2 mb-1">
                      <span className="px-2 py-0.5 rounded-full bg-amber-500/10 text-amber-500 text-[9px] font-black tracking-widest uppercase border border-amber-500/20">
                        ACTION REQUIRED
                      </span>
                      <span className="text-slate-500 text-[10px] uppercase font-bold tracking-wider tabular-nums flex items-center gap-1">
                        <Clock className="w-3 h-3" />
                        Awaiting Triage
                      </span>
                    </div>
                    <h3 className="text-xl font-black text-white tracking-tight uppercase italic leading-none mb-2">
                       {item.item_name} Authorization
                    </h3>
                    <div className="flex items-center gap-3 text-slate-400 text-xs font-semibold">
                       <span className="flex items-center gap-1.5 px-2 py-1 bg-white/5 rounded-lg border border-white/10">
                         <User className="w-3 h-3" /> {item.requester_name}
                       </span>
                       <span className="flex items-center gap-1.5 px-2 py-1 bg-white/5 rounded-lg border border-white/10">
                         <Package className="w-3 h-3" /> {item.category}
                       </span>
                    </div>
                  </div>
                </div>

                <div className="flex items-center gap-3">
                   <Button
                    onClick={() => handleAction(item.id, 'completed')}
                    disabled={isProcessing === item.id}
                    className="bg-emerald-500 hover:bg-emerald-400 text-white font-black text-[11px] uppercase tracking-widest px-6 h-11 rounded-xl shadow-[0_0_30px_rgba(16,185,129,0.2)] border-none transition-all active:scale-95"
                  >
                    {isProcessing === item.id ? (
                      <RotateCcw className="h-4 w-4 animate-spin mr-2" />
                    ) : (
                      <CheckCircle2 className="h-4 w-4 mr-2" />
                    )}
                    Authorize
                  </Button>

                  <Button
                    variant="outline"
                    onClick={() => handleAction(item.id, 'flagged')}
                    disabled={isProcessing === item.id}
                    className="bg-white/5 border-white/10 text-white hover:bg-red-500 hover:border-red-500 font-black text-[11px] uppercase tracking-widest px-6 h-11 rounded-xl transition-all active:scale-95"
                  >
                    <AlertOctagon className="h-4 w-4 mr-2" />
                    Flag
                  </Button>
                </div>
              </div>
            </Card>
          ))}
        </div>
      </motion.div>
    </AnimatePresence>
  )
}
