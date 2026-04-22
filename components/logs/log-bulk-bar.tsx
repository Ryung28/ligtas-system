'use client'

import { Button } from '@/components/ui/button'
import { RefreshCw, CheckCircle2 } from 'lucide-react'

interface LogBulkActionBarProps {
    selectedCount: number
    isLoading: boolean
    onDeselect: () => void
    onConfirm: () => void
}

export function LogBulkActionBar({
    selectedCount,
    isLoading,
    onDeselect,
    onConfirm
}: LogBulkActionBarProps) {
    if (selectedCount === 0) return null

    return (
        <div className="fixed bottom-8 left-1/2 -translate-x-1/2 z-50 animate-in fade-in slide-in-from-bottom-6 duration-500">
            <div className="bg-slate-900/95 backdrop-blur-xl text-white px-6 py-4 rounded-[2rem] shadow-2xl flex items-center gap-8 ring-1 ring-white/10">
                <div className="flex items-center gap-3">
                    <div className="bg-blue-600 text-white rounded-full h-7 w-7 flex items-center justify-center text-[10px] font-bold shadow-[0_0_15px_rgba(37,99,235,0.4)]">
                        {selectedCount}
                    </div>
                    <span className="text-[10px] font-bold uppercase tracking-[0.2em] text-slate-300">Tactical Selection</span>
                </div>

                <div className="h-6 w-[1px] bg-slate-700/50" />

                <div className="flex gap-3">
                    <Button
                        variant="ghost"
                        size="sm"
                        className="text-slate-400 hover:text-white hover:bg-slate-800 text-[10px] font-bold uppercase tracking-[0.15em] h-10 px-4 rounded-xl transition-all"
                        onClick={onDeselect}
                    >
                        Reset
                    </Button>
                    <Button
                        size="sm"
                        className="bg-emerald-600 hover:bg-emerald-500 text-white font-bold h-10 px-6 rounded-xl gap-2 shadow-[0_4px_15px_-3px_rgba(16,185,129,0.3)] text-[10px] uppercase tracking-[0.15em] transition-all active:scale-95"
                        onClick={onConfirm}
                        disabled={isLoading}
                    >
                        {isLoading ? (
                            <RefreshCw className="h-3.5 w-3.5 animate-spin" />
                        ) : (
                            <CheckCircle2 className="h-3.5 w-3.5" />
                        )}
                        Confirm Return
                    </Button>
                </div>
            </div>
        </div>
    )
}
