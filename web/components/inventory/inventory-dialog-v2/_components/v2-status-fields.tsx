"use client"

import { ShieldCheck, Target, Percent, AlertTriangle } from 'lucide-react'
import { Input } from '@/components/ui/input'
import { Label } from '@/components/ui/label'

interface StatusFieldsProps {
    qtyGood: number | string
    setQtyGood: (val: number | string) => void
    qtyDamaged: number | string
    setQtyDamaged: (val: number | string) => void
    qtyMaintenance: number | string
    setQtyMaintenance: (val: number | string) => void
    qtyLost: number | string
    setQtyLost: (val: number | string) => void
    targetStock: number | string
    setTargetStock: (val: number | string) => void
    lowStockThreshold: number | string
    setLowStockThreshold: (val: number | string) => void
    restockAlertEnabled: boolean
    setRestockAlertEnabled: (val: boolean) => void
    policyErrors?: {
        ready?: string
        target?: string
        threshold?: string
    }
}

/**
 * LIGTAS V2 STATUS SECTION (VERIFIED PARITY)
 * Handles all 4 health buckets plus planning strategy.
 */
export function V2StatusFields({
    qtyGood, setQtyGood,
    qtyDamaged, setQtyDamaged,
    qtyMaintenance, setQtyMaintenance,
    qtyLost, setQtyLost,
    targetStock, setTargetStock,
    lowStockThreshold, setLowStockThreshold,
    restockAlertEnabled, setRestockAlertEnabled,
    policyErrors
}: StatusFieldsProps) {
    
    const targetNum = Number(targetStock) || 0
    const thresholdNum = Number(lowStockThreshold) || 0
    const calculatedLimit = Math.ceil(targetNum * (thresholdNum / 100))

    return (
        <div className="bg-slate-50/50 rounded-3xl p-4 border border-slate-100 space-y-4">
            <div className="flex items-center gap-2 mb-1">
                <ShieldCheck className="h-4 w-4 text-emerald-500" />
                <p className="text-[11px] font-extrabold text-slate-700 uppercase tracking-tighter text-blue-600">Equipment Status</p>
            </div>

            {/* Health Grid: 2x2 for better readability on laptops */}
            <div className="grid grid-cols-2 gap-3">
                <div className="bg-white p-3 rounded-2xl border border-slate-100/50 shadow-sm">
                    <Label className="text-[10px] font-bold text-slate-600 uppercase mb-1 block">Good / Ready</Label>
                    <Input 
                        type="number" value={qtyGood} onChange={(e) => setQtyGood(e.target.value)}
                        className={`h-9 rounded-lg font-black text-emerald-600 text-lg bg-emerald-50/10 p-0 focus-visible:ring-0 ${
                            policyErrors?.ready ? 'border-red-400 ring-2 ring-red-200' : 'border-none'
                        }`} 
                    />
                    {policyErrors?.ready ? (
                        <p className="text-[10px] font-bold text-red-600 mt-1">{policyErrors.ready}</p>
                    ) : null}
                </div>
                <div className="bg-white p-3 rounded-2xl border border-slate-100/50 shadow-sm">
                    <Label className="text-[10px] font-bold text-slate-600 uppercase mb-1 block">Damaged</Label>
                    <Input 
                        type="number" value={qtyDamaged} onChange={(e) => setQtyDamaged(e.target.value)}
                        className="h-9 rounded-lg border-none font-black text-rose-500 text-lg bg-rose-50/10 p-0 focus-visible:ring-0" 
                    />
                </div>
                <div className="bg-white p-3 rounded-2xl border border-slate-100/50 shadow-sm">
                    <Label className="text-[10px] font-bold text-slate-600 uppercase mb-1 block">Maintenance</Label>
                    <Input 
                        type="number" value={qtyMaintenance} onChange={(e) => setQtyMaintenance(e.target.value)}
                        className="h-9 rounded-lg border-none font-black text-amber-500 text-lg bg-amber-50/10 p-0 focus-visible:ring-0" 
                    />
                </div>
                <div className="bg-white p-3 rounded-2xl border border-slate-100/50 shadow-sm">
                    <Label className="text-[10px] font-bold text-slate-600 uppercase mb-1 block">Lost</Label>
                    <Input 
                        type="number" value={qtyLost} onChange={(e) => setQtyLost(e.target.value)}
                        className="h-9 rounded-lg border-none font-black text-slate-500 text-lg bg-slate-50/10 p-0 focus-visible:ring-0" 
                    />
                </div>
            </div>

            {/* Strategic Warning Section */}
            <div className="pt-3 border-t border-slate-100">
                <div className="flex items-center gap-2 mb-3 bg-amber-50/50 p-2 rounded-xl border border-amber-100/50">
                    <AlertTriangle className="h-3.5 w-3.5 text-amber-500" />
                    <p className="text-[10px] font-bold text-amber-700 leading-tight">
                        Notice: Changing these only sets when you get alerts. It will not change your current stock count.
                    </p>
                </div>

                <div className="grid grid-cols-2 gap-4">
                    <div className="space-y-1.5">
                        <div className="flex items-center gap-1.5 opacity-70">
                            <Target className="h-3.5 w-3.5 text-slate-600" />
                            <Label className="text-[10px] font-bold text-slate-600 uppercase tracking-tight">Max Stock Goal</Label>
                        </div>
                        <Input 
                            data-restock-input="target"
                            type="number" value={targetStock} onChange={(e) => setTargetStock(e.target.value)}
                            className={`h-10 rounded-2xl font-bold text-slate-900 shadow-inner ${
                                policyErrors?.target ? 'border-red-400 ring-2 ring-red-200' : 'border-slate-200'
                            }`} 
                        />
                        {policyErrors?.target ? (
                            <p className="text-[10px] font-bold text-red-600 mt-1">{policyErrors.target}</p>
                        ) : null}
                    </div>
                    <div className="space-y-1.5">
                        <div className="flex items-center gap-1.5 opacity-70">
                            <Percent className="h-3.5 w-3.5 text-slate-600" />
                            <Label className="text-[10px] font-bold text-slate-600 uppercase tracking-tight">Warn at (%)</Label>
                        </div>
                        <Input 
                            data-restock-input="threshold"
                            type="number" value={lowStockThreshold} onChange={(e) => setLowStockThreshold(e.target.value)}
                            className={`h-10 rounded-2xl font-bold text-slate-900 shadow-inner ${
                                policyErrors?.threshold ? 'border-red-400 ring-2 ring-red-200' : 'border-slate-200'
                            }`} 
                        />
                        {policyErrors?.threshold ? (
                            <p className="text-[10px] font-bold text-red-600 mt-1">{policyErrors.threshold}</p>
                        ) : null}
                    </div>
                </div>
                <label className="flex items-center gap-2 mt-3 text-[11px] font-bold text-slate-700">
                    <input
                        type="checkbox"
                        checked={restockAlertEnabled}
                        onChange={(e) => setRestockAlertEnabled(e.target.checked)}
                        className="h-4 w-4 rounded border-slate-300"
                    />
                    Enable low-stock alerts for this item
                </label>
                <p className="text-[10px] text-slate-500 mt-1">
                    Turn this off to exclude this item from low-stock alerts.
                </p>
            </div>

            {/* Smart Footer - Reverted to Clean Blue */}
            <div className="bg-blue-600/5 p-3 rounded-2xl border border-blue-50 flex items-center gap-3">
                <AlertTriangle className="h-4 w-4 text-blue-500" />
                <p className="text-[11px] font-bold text-blue-800 leading-tight">
                    Low Stock Alert at or below: <span className="text-blue-600 underline underline-offset-2">{calculatedLimit} units</span>
                </p>
            </div>
        </div>
    )
}
