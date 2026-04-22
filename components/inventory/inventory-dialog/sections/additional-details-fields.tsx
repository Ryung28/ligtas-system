import { Hash, Wrench } from 'lucide-react'
import { Input } from '@/components/ui/input'
import { Label } from '@/components/ui/label'
import { InventoryItem } from '@/lib/supabase'

interface AdditionalDetailsFieldsProps {
    existingItem?: InventoryItem
}

export function AdditionalDetailsFields({ 
    existingItem,
}: AdditionalDetailsFieldsProps) {
    return (
        <div className="space-y-4 pt-1">
            <div className="grid grid-cols-2 gap-3">
                <div className="space-y-1.5">
                    <Label htmlFor="serial_number" className="text-[10px] font-bold text-slate-500 uppercase tracking-wider">
                        Serial / Tag #
                    </Label>
                    <div className="relative">
                        <Hash className="absolute left-2.5 top-1/2 -translate-y-1/2 h-3.5 w-3.5 text-slate-300" strokeWidth={2.5} />
                        <Input
                            id="serial_number"
                            name="serial_number"
                            defaultValue={existingItem?.serial_number}
                            placeholder="e.g. LIG-2024-001"
                            className="h-9 pl-8 rounded-lg border border-slate-200 bg-white text-sm font-medium text-slate-900 focus:ring-4 focus:ring-blue-500/10 focus:border-blue-500"
                        />
                    </div>
                </div>
                <div className="space-y-1.5">
                    <Label htmlFor="equipment_type" className="text-[10px] font-bold text-slate-500 uppercase tracking-wider">
                        Model or Type
                    </Label>
                    <div className="relative">
                        <Wrench className="absolute left-2.5 top-1/2 -translate-y-1/2 h-4 w-4 text-slate-300" strokeWidth={2.5} />
                        <Input
                            id="equipment_type"
                            name="equipment_type"
                            defaultValue={existingItem?.equipment_type}
                            placeholder="e.g. Digital, Gas, etc"
                            className="h-9 pl-8 rounded-lg border border-slate-200 bg-white text-sm font-medium text-slate-900 focus:ring-4 focus:ring-blue-500/10 focus:border-blue-500"
                        />
                    </div>
                </div>
            </div>
        </div>
    )
}
