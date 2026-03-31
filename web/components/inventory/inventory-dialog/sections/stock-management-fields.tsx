import { Hash, AlertCircle, Package } from 'lucide-react'
import { Input } from '@/components/ui/input'
import { Label } from '@/components/ui/label'
import { InventoryItem } from '@/lib/supabase'

interface StockManagementFieldsProps {
    existingItem?: InventoryItem
    // Bucket States
    qtyGood: number | string
    setQtyGood: (value: number | string) => void
    qtyDamaged: number | string
    setQtyDamaged: (value: number | string) => void
    qtyMaintenance: number | string
    setQtyMaintenance: (value: number | string) => void
    qtyLost: number | string
    setQtyLost: (value: number | string) => void
    // Computed Values
    stockTotalValue: number
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
    existingItem
}: StockManagementFieldsProps) {
    return (
        <div className="space-y-6">
            {/* Header: Global Fleet Health */}
            <div className="flex items-center gap-2 pb-2 border-b border-gray-200">
                <Package className="h-4 w-4 text-blue-600" />
                <h3 className="text-sm font-bold text-gray-900 uppercase tracking-wide">Stock Management</h3>
            </div>

            <div className="bg-zinc-50 rounded-lg p-3 border border-zinc-200/60 flex items-center justify-between">
                <div className="flex items-center gap-2">
                    <div className="h-2 w-2 rounded-full bg-blue-500 animate-pulse" />
                    <span className="text-[11px] font-black text-zinc-500 uppercase tracking-tighter">Total Fleet Inventory</span>
                </div>
                <span className="text-xl font-black text-zinc-900 tracking-tighter">
                    {stockTotalValue}
                </span>
            </div>

            {/* Status Distribution Grid (The Enterprise Way) */}
            <div className="grid grid-cols-2 gap-4">
                {/* 1. Good / Ready */}
                <div className="space-y-1.5">
                    <Label className="text-[10px] font-bold text-emerald-700 uppercase tracking-tight flex items-center gap-1.5 ml-1">
                        <div className="h-1.5 w-1.5 rounded-full bg-emerald-500" />
                        Ready / Good
                    </Label>
                    <div className="relative group">
                        <Hash className="absolute left-3 top-1/2 -translate-y-1/2 h-4 w-4 text-emerald-500/40 group-focus-within:text-emerald-500 transition-colors z-10" />
                        <Input
                            type="number"
                            min={0}
                            value={qtyGood}
                            onChange={(e) => setQtyGood(e.target.value)}
                            className="h-11 pl-9 rounded-lg border-2 border-zinc-100 bg-white text-[13px] font-black text-zinc-900 transition-all focus:border-emerald-500 focus:ring-4 focus:ring-emerald-500/10 hover:border-zinc-200"
                        />
                    </div>
                </div>

                {/* 2. Damaged */}
                <div className="space-y-1.5">
                    <Label className="text-[10px] font-bold text-rose-700 uppercase tracking-tight flex items-center gap-1.5 ml-1">
                        <div className="h-1.5 w-1.5 rounded-full bg-rose-500" />
                        Damaged
                    </Label>
                    <div className="relative group">
                        <Hash className="absolute left-3 top-1/2 -translate-y-1/2 h-4 w-4 text-rose-500/40 group-focus-within:text-rose-500 transition-colors z-10" />
                        <Input
                            type="number"
                            min={0}
                            value={qtyDamaged}
                            onChange={(e) => setQtyDamaged(e.target.value)}
                            className="h-11 pl-9 rounded-lg border-2 border-zinc-100 bg-white text-[13px] font-black text-zinc-900 transition-all focus:border-rose-500 focus:ring-4 focus:ring-rose-500/10 hover:border-zinc-200"
                        />
                    </div>
                </div>

                {/* 3. Maintenance */}
                <div className="space-y-1.5">
                    <Label className="text-[10px] font-bold text-amber-700 uppercase tracking-tight flex items-center gap-1.5 ml-1">
                        <div className="h-1.5 w-1.5 rounded-full bg-amber-500" />
                        Maintenance
                    </Label>
                    <div className="relative group">
                        <Hash className="absolute left-3 top-1/2 -translate-y-1/2 h-4 w-4 text-amber-500/40 group-focus-within:text-amber-500 transition-colors z-10" />
                        <Input
                            type="number"
                            min={0}
                            value={qtyMaintenance}
                            onChange={(e) => setQtyMaintenance(e.target.value)}
                            className="h-11 pl-9 rounded-lg border-2 border-zinc-100 bg-white text-[13px] font-black text-zinc-900 transition-all focus:border-amber-500 focus:ring-4 focus:ring-amber-500/10 hover:border-zinc-200"
                        />
                    </div>
                </div>

                {/* 4. Lost / Missing */}
                <div className="space-y-1.5">
                    <Label className="text-[10px] font-bold text-slate-700 uppercase tracking-tight flex items-center gap-1.5 ml-1">
                        <div className="h-1.5 w-1.5 rounded-full bg-slate-500" />
                        Lost / Missing
                    </Label>
                    <div className="relative group">
                        <Hash className="absolute left-3 top-1/2 -translate-y-1/2 h-4 w-4 text-slate-500/40 group-focus-within:text-slate-500 transition-colors z-10" />
                        <Input
                            type="number"
                            min={0}
                            value={qtyLost}
                            onChange={(e) => setQtyLost(e.target.value)}
                            className="h-11 pl-9 rounded-lg border-2 border-zinc-100 bg-white text-[13px] font-black text-zinc-900 transition-all focus:border-slate-500 focus:ring-4 focus:ring-slate-500/10 hover:border-zinc-200"
                        />
                    </div>
                </div>
            </div>

            {/* Low Stock Alert */}
            <div className="grid gap-1.5 border-t border-zinc-100 pt-4 mt-2">
                <Label htmlFor="low_stock_threshold" className="text-[10px] font-black text-zinc-500 uppercase tracking-tight ml-1">
                    Low Stock Alert (%)
                </Label>
                <div className="relative group">
                    <AlertCircle className="absolute left-3 top-1/2 -translate-y-1/2 h-4 w-4 text-zinc-400 group-focus-within:text-blue-500 transition-colors z-10" />
                    <Input
                        id="low_stock_threshold"
                        name="low_stock_threshold"
                        type="number"
                        min="0"
                        max="100"
                        defaultValue={(existingItem as any)?.low_stock_threshold || 20}
                        placeholder="20"
                        className="h-11 pl-9 rounded-lg border-2 border-zinc-100 bg-white text-[13px] font-black text-zinc-900 transition-all focus:border-blue-500 focus:ring-4 focus:ring-blue-500/10 hover:border-zinc-200"
                    />
                </div>
            </div>
        </div>
    )
}
