import { Hash, Wrench } from 'lucide-react'
import { Input } from '@/components/ui/input'
import { Label } from '@/components/ui/label'
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from '@/components/ui/select'
import { InventoryItem } from '@/lib/supabase'

interface AdditionalDetailsFieldsProps {
    existingItem?: InventoryItem
}

export function AdditionalDetailsFields({ existingItem }: AdditionalDetailsFieldsProps) {
    return (
        <div className="space-y-4">
            {/* Equipment ID & Model/Type */}
            <div className="grid grid-cols-2 gap-4">
                <div className="grid gap-2">
                    <Label htmlFor="serial_number" className="text-xs font-bold text-gray-700 uppercase tracking-wide">
                        Equipment ID
                    </Label>
                    <div className="relative">
                        <Hash className="absolute left-3 top-1/2 -translate-y-1/2 h-4 w-4 text-gray-400" />
                        <Input
                            id="serial_number"
                            name="serial_number"
                            defaultValue={existingItem?.serial_number}
                            placeholder="e.g. LIG-2024-001"
                            className="h-11 pl-10 rounded-lg border-2 border-gray-200 bg-white text-sm transition-all duration-200 focus:ring-2 focus:ring-blue-500/20 focus:border-blue-500 focus:shadow-[0_4px_20px_rgba(59,130,246,0.15)] hover:border-gray-300"
                        />
                    </div>
                </div>
                <div className="grid gap-2">
                    <Label htmlFor="equipment_type" className="text-xs font-bold text-gray-700 uppercase tracking-wide">
                        Model/Type
                    </Label>
                    <div className="relative">
                        <Wrench className="absolute left-3 top-1/2 -translate-y-1/2 h-4 w-4 text-gray-400" />
                        <Input
                            id="equipment_type"
                            name="equipment_type"
                            defaultValue={existingItem?.equipment_type}
                            placeholder="e.g. Digital, Gas, etc"
                            className="h-11 pl-10 rounded-lg border-2 border-gray-200 bg-white text-sm transition-all duration-200 focus:ring-2 focus:ring-blue-500/20 focus:border-blue-500 focus:shadow-[0_4px_20px_rgba(59,130,246,0.15)] hover:border-gray-300"
                        />
                    </div>
                </div>
            </div>

            {/* Status */}
            <div className="grid gap-2">
                <Label className="text-xs font-bold text-gray-700 uppercase tracking-wide">Status</Label>
                <Select name="status" defaultValue={existingItem?.status || 'Good'}>
                    <SelectTrigger className="h-11 rounded-lg border-2 border-gray-200 bg-white text-sm transition-all duration-200 focus:ring-2 focus:ring-blue-500/20 focus:border-blue-500 hover:border-gray-300">
                        <SelectValue placeholder="Select status" />
                    </SelectTrigger>
                    <SelectContent className="rounded-xl border-gray-200 shadow-xl">
                        <SelectItem value="Good" className="text-sm text-emerald-600">Operational</SelectItem>
                        <SelectItem value="Maintenance" className="text-sm text-amber-600">Under Maintenance</SelectItem>
                        <SelectItem value="Damaged" className="text-sm text-red-600">Damaged</SelectItem>
                        <SelectItem value="Lost" className="text-sm text-gray-600">Lost/Missing</SelectItem>
                    </SelectContent>
                </Select>
            </div>
        </div>
    )
}
