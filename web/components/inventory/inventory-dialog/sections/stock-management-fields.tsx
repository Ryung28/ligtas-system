import { Hash, Hammer, Ban, ShieldCheck, Activity, Target, BellRing, AlertCircle } from 'lucide-react'
import { Input } from '@/components/ui/input'
import { Label } from '@/components/ui/label'

interface StockManagementFieldsProps {
    qtyGood: number | string
    setQtyGood: (value: number | string) => void
    qtyDamaged: number | string
    setQtyDamaged: (value: number | string) => void
    qtyMaintenance: number | string
    setQtyMaintenance: (value: number | string) => void
    qtyLost: number | string
    setQtyLost: (value: number | string) => void
    stockTotalValue: number
    targetStock: number | string
    onTargetStockChange: (value: number | string) => void
    lowStockThreshold: number | string
    onThresholdChange: (value: number | string) => void
}

export function StockManagementFields({
    qtyGood,
    setQtyGood,
    qtyDamaged,
    setQtyDamaged,
    qtyMaintenance,
    setQtyMaintenance,
    qtyLost,
    setQtyLost,
    stockTotalValue,
    targetStock,
    onTargetStockChange,
    lowStockThreshold,
    onThresholdChange,
}: StockManagementFieldsProps) {
    const thresholdNum = Number(lowStockThreshold) || 0
    const targetNum = Number(targetStock) || 0
    const calculatedThreshold = Math.ceil(targetNum * (thresholdNum / 100))

    return (
        <div className="space-y-4">
            {/* Header: Overview */}
            <div className="flex items-center justify-between mb-1">
                <div className="flex items-center gap-2">
                    <Activity className="h-3.5 w-3.5 text-blue-500" strokeWidth={2.5} />
                    <p className="text-[10px] font-black text-slate-800 uppercase tracking-widest">Inventory Health</p>
                </div>
                <div className="flex items-center gap-2">
                    <span className="text-[9px] font-black text-slate-400 uppercase tracking-widest">Total Stock</span>
                    <span className="text-[11px] font-black text-blue-600 bg-blue-50 px-3 py-0.5 rounded-full border border-blue-100">
                        {stockTotalValue} UNITS
                    </span>
                </div>
            </div>

            <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
                {/* COLUMN 1: CONDITION */}
                <div className="space-y-3">
                    <p className="text-[9px] font-black text-slate-400 uppercase tracking-[0.2em] mb-3">Check Condition</p>
                    
                    <div className="grid grid-cols-2 gap-2.5">
                        <div className="space-y-1.5">
                            <Label className="text-[10px] font-bold text-emerald-600 uppercase tracking-wider flex items-center gap-1">
                                Ready to Use
                            </Label>
                            <div className="relative">
                                <ShieldCheck className="absolute left-2.5 top-1/2 -translate-y-1/2 h-4 w-4 text-emerald-500/30 font-black" />
                                <Input
                                    type="number" min={0} value={qtyGood}
                                    onChange={(e) => setQtyGood(e.target.value)}
                                    className="h-10 pl-9 rounded-xl border border-slate-200 bg-white text-sm font-black text-slate-950 focus:border-emerald-500 focus:ring-4 focus:ring-emerald-500/10"
                                />
                            </div>
                        </div>

                        <div className="space-y-1.5">
                            <Label className="text-[10px] font-bold text-rose-600 uppercase tracking-wider flex items-center gap-1">
                                Damaged
                            </Label>
                            <div className="relative">
                                <Ban className="absolute left-2.5 top-1/2 -translate-y-1/2 h-4 w-4 text-rose-500/30" />
                                <Input
                                    type="number" min={0} value={qtyDamaged}
                                    onChange={(e) => setQtyDamaged(e.target.value)}
                                    className="h-10 pl-9 rounded-xl border border-slate-200 bg-white text-sm font-black text-slate-950 focus:border-rose-500 focus:ring-4 focus:ring-rose-500/10"
                                />
                            </div>
                        </div>

                        <div className="space-y-1.5">
                            <Label className="text-[10px] font-bold text-amber-600 uppercase tracking-wider flex items-center gap-1">
                                In Repair
                            </Label>
                            <div className="relative">
                                <Hammer className="absolute left-2.5 top-1/2 -translate-y-1/2 h-4 w-4 text-amber-500/30" strokeWidth={2.5} />
                                <Input
                                    type="number" min={0} value={qtyMaintenance}
                                    onChange={(e) => setQtyMaintenance(e.target.value)}
                                    className="h-10 pl-9 rounded-xl border border-slate-200 bg-white text-sm font-black text-slate-950 focus:border-amber-500 focus:ring-4 focus:ring-amber-500/10"
                                />
                            </div>
                        </div>

                        <div className="space-y-1.5">
                            <Label className="text-[10px] font-bold text-slate-500 uppercase tracking-wider flex items-center gap-1">
                                Lost
                            </Label>
                            <div className="relative">
                                <Hash className="absolute left-2.5 top-1/2 -translate-y-1/2 h-4 w-4 text-slate-300" strokeWidth={2.5} />
                                <Input
                                    type="number" min={0} value={qtyLost}
                                    onChange={(e) => setQtyLost(e.target.value)}
                                    className="h-10 pl-9 rounded-xl border border-slate-200 bg-white text-sm font-black text-slate-950 focus:border-slate-500 focus:ring-4 focus:ring-slate-500/10"
                                />
                            </div>
                        </div>
                    </div>
                </div>

                {/* COLUMN 2: PLANNING */}
                <div className="space-y-3">
                    <p className="text-[9px] font-black text-slate-400 uppercase tracking-[0.2em] mb-3">Planning</p>
                    
                    <div className="space-y-3.5 bg-slate-100/50 p-3 rounded-2xl border border-slate-200/50">
                        <div className="space-y-1.5 px-0.5">
                            <Label className="text-[10px] font-bold text-slate-600 uppercase tracking-widest">
                                How many should we have?
                            </Label>
                            <div className="relative">
                                <Target className="absolute left-2 top-1/2 -translate-y-1/2 h-4 w-4 text-slate-400" strokeWidth={2.5} />
                                <Input
                                    type="number"
                                    value={targetStock}
                                    onChange={(e) => onTargetStockChange(e.target.value)}
                                    placeholder="0"
                                    className="h-10 pl-8 rounded-xl border border-slate-200 bg-white text-sm font-black text-slate-950 focus:ring-4 focus:ring-blue-500/10"
                                />
                            </div>
                        </div>

                        <div className="space-y-1.5 px-0.5">
                            <Label className="text-[10px] font-bold text-slate-600 uppercase tracking-widest">
                                Alert Level (%)
                            </Label>
                            <div className="relative">
                                <BellRing className="absolute left-2 top-1/2 -translate-y-1/2 h-4 w-4 text-slate-400" strokeWidth={2.5} />
                                <Input
                                    type="number"
                                    value={lowStockThreshold}
                                    onChange={(e) => onThresholdChange(e.target.value)}
                                    placeholder="20"
                                    className="h-10 pl-8 rounded-xl border border-slate-200 bg-white text-sm font-black text-slate-950 focus:ring-4 focus:ring-blue-500/10"
                                />
                            </div>
                        </div>
                    </div>
                </div>
            </div>

            {/* ALERT RULE FOOTER */}
            <div className="mt-2 p-3 bg-blue-50 rounded-xl border border-blue-100 flex items-start gap-3">
                <AlertCircle className="h-4 w-4 text-blue-500 mt-0.5" strokeWidth={2.5} />
                <p className="text-[11px] font-medium text-blue-700 leading-normal">
                    <span className="font-black uppercase tracking-tighter mr-1 text-blue-900">Alert Rule:</span>
                    Tell me if my <span className="font-black italic text-blue-900">Ready to Use</span> stock hits 
                    <span className="mx-1 px-1.5 py-0.5 rounded bg-blue-600 text-white font-black">{calculatedThreshold}</span> 
                    units.
                </p>
            </div>
        </div>
    )
}
