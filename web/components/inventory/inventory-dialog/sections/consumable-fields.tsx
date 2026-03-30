import { ShoppingBag, Calendar } from 'lucide-react'
import { Input } from '@/components/ui/input'
import { Label } from '@/components/ui/label'
import { InventoryItem } from '@/lib/supabase'

interface ConsumableFieldsProps {
    existingItem?: InventoryItem
}

export function ConsumableFields({ existingItem }: ConsumableFieldsProps) {
    return (
        <div className="space-y-4">
            {/* Brand */}
            <div className="grid gap-2">
                <Label htmlFor="brand" className="text-xs font-bold text-gray-700 uppercase tracking-wide">
                    Brand
                </Label>
                <div className="relative">
                    <ShoppingBag className="absolute left-3 top-1/2 -translate-y-1/2 h-4 w-4 text-gray-400" />
                    <Input
                        id="brand"
                        name="brand"
                        defaultValue={(existingItem as any)?.brand || ''}
                        placeholder="e.g. Del Monte, Nestle"
                        className="h-11 pl-10 rounded-lg border-2 border-gray-200 bg-white text-sm transition-all duration-200 focus:ring-2 focus:ring-blue-500/20 focus:border-blue-500 focus:shadow-[0_4px_20px_rgba(59,130,246,0.15)] hover:border-gray-300"
                    />
                </div>
            </div>

            {/* Expiry Date */}
            <div className="grid gap-2">
                <Label htmlFor="expiry_date" className="text-xs font-bold text-gray-700 uppercase tracking-wide flex items-center gap-1">
                    Expiry Date
                </Label>
                <div className="relative">
                    <Calendar className="absolute left-3 top-1/2 -translate-y-1/2 h-4 w-4 text-gray-400" />
                    <Input
                        id="expiry_date"
                        name="expiry_date"
                        type="date"
                        defaultValue={(existingItem as any)?.expiry_date ? new Date((existingItem as any).expiry_date).toISOString().split('T')[0] : ''}
                        className="h-11 pl-10 rounded-lg border-2 border-gray-200 bg-white text-sm transition-all duration-200 focus:ring-2 focus:ring-blue-500/20 focus:border-blue-500 focus:shadow-[0_4px_20px_rgba(59,130,246,0.15)] hover:border-gray-300"
                    />
                </div>
                <p className="text-[11px] text-gray-500 mt-1">
                    Alerts: Red (≤7 days), Amber (8-30 days), Green (&gt;30 days)
                </p>
            </div>
        </div>
    )
}
