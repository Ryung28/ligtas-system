import { Hash, AlertCircle } from 'lucide-react'
import { Input } from '@/components/ui/input'
import { Label } from '@/components/ui/label'
import { InventoryItem } from '@/lib/supabase'

interface StockManagementFieldsProps {
    existingItem?: InventoryItem
}

export function StockManagementFields({ existingItem }: StockManagementFieldsProps) {
    return (
        <div className="space-y-4">
            {/* Fixed Total Stock & Current Stock */}
            <div className="grid grid-cols-2 gap-4">
                <div className="grid gap-2">
                    <Label htmlFor="stock_total" className="text-xs font-bold text-gray-700 uppercase tracking-wide">
                        Fixed Total Stock
                    </Label>
                    <div className="relative">
                        <Hash className="absolute left-3 top-1/2 -translate-y-1/2 h-4 w-4 text-gray-400" />
                        <Input
                            id="stock_total"
                            name="stock_total"
                            type="number"
                            min="1"
                            defaultValue={existingItem?.stock_total || ''}
                            placeholder="Total units owned"
                            className="h-11 pl-10 rounded-lg border-2 border-gray-200 bg-white text-sm transition-all duration-200 focus:ring-2 focus:ring-blue-500/20 focus:border-blue-500 focus:shadow-[0_4px_20px_rgba(59,130,246,0.15)] hover:border-gray-300"
                            required
                        />
                    </div>
                </div>
                <div className="grid gap-2">
                    <Label htmlFor="stock_available" className="text-xs font-bold text-gray-700 uppercase tracking-wide">
                        Current Stock
                    </Label>
                    <div className="relative">
                        <Hash className="absolute left-3 top-1/2 -translate-y-1/2 h-4 w-4 text-gray-400" />
                        <Input
                            id="stock_available"
                            name="stock_available"
                            type="number"
                            min="0"
                            defaultValue={existingItem?.stock_available || ''}
                            placeholder="Available units"
                            className="h-11 pl-10 rounded-lg border-2 border-gray-200 bg-white text-sm transition-all duration-200 focus:ring-2 focus:ring-blue-500/20 focus:border-blue-500 focus:shadow-[0_4px_20px_rgba(59,130,246,0.15)] hover:border-gray-300"
                            required
                        />
                    </div>
                </div>
            </div>

            {/* Low Stock Alert */}
            <div className="grid gap-2">
                <Label htmlFor="low_stock_threshold" className="text-xs font-bold text-gray-700 uppercase tracking-wide">
                    Low Stock Alert (%)
                </Label>
                <div className="relative">
                    <AlertCircle className="absolute left-3 top-1/2 -translate-y-1/2 h-4 w-4 text-gray-400" />
                    <Input
                        id="low_stock_threshold"
                        name="low_stock_threshold"
                        type="number"
                        min="0"
                        max="100"
                        defaultValue={(existingItem as any)?.low_stock_threshold || 20}
                        placeholder="20"
                        className="h-11 pl-10 rounded-lg border-2 border-gray-200 bg-white text-sm transition-all duration-200 focus:ring-2 focus:ring-blue-500/20 focus:border-blue-500 focus:shadow-[0_4px_20px_rgba(59,130,246,0.15)] hover:border-gray-300"
                    />
                </div>
                <p className="text-[11px] text-gray-500 mt-1">
                    Alert when stock falls below this percentage (default: 20%)
                </p>
            </div>
        </div>
    )
}
