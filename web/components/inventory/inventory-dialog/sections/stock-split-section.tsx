'use client'

import { useState } from 'react'
import { Button } from '@/components/ui/button'
import { Input } from '@/components/ui/input'
import { Label } from '@/components/ui/label'
import { 
    Select, 
    SelectContent, 
    SelectItem, 
    SelectTrigger, 
    SelectValue 
} from '@/components/ui/select'
import { InventoryItem } from '@/lib/supabase'
import { splitInventoryItem } from '@/src/features/catalog'
import { toast } from 'sonner'
import { Split, ArrowRight, Loader2 } from 'lucide-react'

interface StockSplitSectionProps {
    item: InventoryItem
    onSuccess?: () => void
    onClose?: () => void
}

export function StockSplitSection({ item, onSuccess, onClose }: StockSplitSectionProps) {
    const [splitQty, setSplitQty] = useState<number>(1)
    const [targetStatus, setTargetStatus] = useState<string>('Damaged')
    const [isPending, setIsPending] = useState(false)

    const handleSplit = async () => {
        if (splitQty <= 0) return
        if (splitQty >= item.stock_total) {
            toast.error("You cannot split the total quantity. Use the 'Status' dropdown instead.")
            return
        }

        setIsPending(true)
        try {
            const result = await splitInventoryItem(item.id, splitQty, targetStatus)
            if (result.success) {
                toast.success(result.message)
                onSuccess?.()
                onClose?.()
            } else {
                toast.error(result.error)
            }
        } catch (error) {
            toast.error('An unexpected error occurred.')
        } finally {
            setIsPending(false)
        }
    }

    return (
        <div className="mt-8 pt-6 border-t border-gray-100 animate-in fade-in slide-in-from-bottom-4 duration-500">
            <div className="flex items-center gap-2 mb-4">
                <div className="p-2 bg-amber-50 rounded-lg">
                    <Split className="h-4 w-4 text-amber-600" />
                </div>
                <div>
                    <h3 className="text-sm font-semibold text-gray-900">Tactical Stock Split</h3>
                    <p className="text-[11px] text-gray-500 font-medium">Move a portion of this batch to a new status</p>
                </div>
            </div>

            <div className="bg-gray-50/50 border border-gray-100 rounded-xl p-4 flex flex-col md:flex-row items-end gap-4">
                <div className="flex-1 space-y-1.5">
                    <Label className="font-bold text-gray-400 uppercase tracking-wider ml-1 text-[10px]">Quantity to Move</Label>
                    <Input
                        type="number"
                        min={1}
                        max={item.stock_total - 1}
                        value={splitQty}
                        onChange={(e) => setSplitQty(Number(e.target.value))}
                        className="h-9 bg-white border-gray-200 text-sm focus:ring-amber-500 focus:border-amber-500"
                    />
                </div>

                <div className="flex-1 space-y-1.5">
                    <Label className="font-bold text-gray-400 uppercase tracking-wider ml-1 text-[10px]">To Target Status</Label>
                    <Select value={targetStatus} onValueChange={setTargetStatus}>
                        <SelectTrigger className="h-9 bg-white border-gray-200 text-sm focus:ring-amber-500">
                            <SelectValue />
                        </SelectTrigger>
                        <SelectContent>
                            <SelectItem value="Operational" className="text-sm">Operational</SelectItem>
                            <SelectItem value="Maintenance" className="text-sm">Maintenance</SelectItem>
                            <SelectItem value="Damaged" className="text-sm">Damaged</SelectItem>
                            <SelectItem value="Out of Service" className="text-sm">Out of Service</SelectItem>
                        </SelectContent>
                    </Select>
                </div>

                <Button 
                    variant="default"
                    onClick={handleSplit}
                    disabled={isPending || splitQty <= 0 || splitQty >= item.stock_total}
                    className="h-9 bg-amber-600 hover:bg-amber-700 text-white border-none shadow-sm shadow-amber-600/20 active:scale-95 transition-all text-[12px] font-semibold px-4 rounded-lg"
                >
                    {isPending ? (
                        <Loader2 className="h-3.5 w-3.5 animate-spin" />
                    ) : (
                        <div className="flex items-center gap-2">
                            <span>Split Items</span>
                            <ArrowRight className="h-3.5 w-3.5" />
                        </div>
                    )}
                </Button>
            </div>
            
            <p className="mt-3 text-[10px] text-gray-400 italic text-center">
                This will decrement original stock by {splitQty} and create a new variant row with status &quot;{targetStatus}&quot;.
            </p>
        </div>
    )
}
