import { ShoppingBag, Calendar } from 'lucide-react'
import { Input } from '@/components/ui/input'
import { Label } from '@/components/ui/label'
import { InventoryItem } from '@/lib/supabase'

interface ConsumableFieldsProps {
    existingItem?: InventoryItem
}

export function ConsumableFields({ existingItem }: ConsumableFieldsProps) {
    return (
        <div className="space-y-3 pt-1">
            <div className="grid grid-cols-2 gap-3">
                {/* Brand Name */}
                <div className="space-y-1.5">
                    <Label htmlFor="brand" className="text-[10px] font-bold text-slate-500 uppercase tracking-wider">Brand</Label>
                    <div className="relative">
                        <ShoppingBag className="absolute left-2.5 top-1/2 -translate-y-1/2 h-3.5 w-3.5 text-slate-300 z-10" strokeWidth={2.5} />
                        <Input
                            id="brand"
                            name="brand"
                            defaultValue={(existingItem as any)?.brand || ''}
                            placeholder="e.g. 3M, Philips"
                            className="h-9 pl-8 rounded-lg border border-slate-200 bg-white text-sm font-medium text-slate-900 focus:ring-4 focus:ring-blue-500/10 focus:border-blue-500"
                        />
                    </div>
                </div>

                {/* Expiry Date */}
                <div className="space-y-1.5">
                    <Label htmlFor="expiry_date" className="text-[10px] font-bold text-slate-500 uppercase tracking-wider">Expiry Date</Label>
                    <div className="relative">
                        <Calendar className="absolute left-2.5 top-1/2 -translate-y-1/2 h-3.5 w-3.5 text-slate-300 z-10" strokeWidth={2.5} />
                        <Input
                            id="expiry_date"
                            name="expiry_date"
                            type="date"
                            defaultValue={(existingItem as any)?.expiry_date
                                ? new Date((existingItem as any).expiry_date).toISOString().split('T')[0]
                                : ''}
                            className="h-9 pl-8 rounded-lg border border-slate-200 bg-white text-sm font-medium text-slate-900 focus:ring-4 focus:ring-blue-500/10 focus:border-blue-500"
                        />
                    </div>
                </div>
            </div>

            {/* Expiry Legend */}
            <div className="flex items-center gap-3 px-2">
                <div className="flex items-center gap-1.5"><div className="h-1.5 w-1.5 rounded-full bg-rose-500" /><span className="text-[9px] font-bold text-slate-400">Expired (≤7d)</span></div>
                <div className="flex items-center gap-1.5"><div className="h-1.5 w-1.5 rounded-full bg-amber-500" /><span className="text-[9px] font-bold text-slate-400">Warning (30d)</span></div>
                <div className="flex items-center gap-1.5"><div className="h-1.5 w-1.5 rounded-full bg-emerald-500" /><span className="text-[9px] font-bold text-slate-400">Good (&gt;30d)</span></div>
            </div>
        </div>
    )
}
