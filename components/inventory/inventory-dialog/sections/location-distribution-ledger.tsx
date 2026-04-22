import { MapPin, Plus, Trash2, AlertTriangle, Building2 } from 'lucide-react'
import { Input } from '@/components/ui/input'
import { Label } from '@/components/ui/label'
import { Button } from '@/components/ui/button'
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from '@/components/ui/select'
import { Badge } from '@/components/ui/badge'

interface Allocation {
    locationId: string
    locationName: string
    quantity: number
}

interface LocationDistributionLedgerProps {
    allocations: Allocation[]
    onAllocationChange: (index: number, quantity: number) => void
    onAddAllocation: (locationId: string, locationName: string) => void
    onRemoveAllocation: (index: number) => void
    savedLocations: any[]
    totalStock: number
}

export function LocationDistributionLedger({
    allocations,
    onAllocationChange,
    onAddAllocation,
    onRemoveAllocation,
    savedLocations,
    totalStock
}: LocationDistributionLedgerProps) {
    const allocatedSum = allocations.reduce((sum, a) => sum + (Number(a.quantity) || 0), 0)
    const isMismatch = allocatedSum !== totalStock && allocations.length > 0
    const remainingToAllocate = totalStock - allocatedSum

    return (
        <div className="space-y-4">
            {/* Header */}
            <div className="flex items-center justify-between pb-2 border-b border-gray-200">
                <div className="flex items-center gap-2">
                    <MapPin className="h-4 w-4 text-orange-600" />
                    <h3 className="text-sm font-bold text-gray-900 uppercase tracking-wide">Site Distribution</h3>
                </div>
                {allocations.length > 1 && (
                    <Badge variant={isMismatch ? "destructive" : "outline"} className="text-[10px] font-bold">
                        {isMismatch ? `Mismatch: ${allocatedSum}/${totalStock}` : "Fully Allocated"}
                    </Badge>
                )}
            </div>

            {/* Allocation List */}
            <div className="space-y-2">
                {allocations.length === 0 ? (
                    <div className="p-8 text-center border-2 border-dashed border-gray-100 rounded-2xl bg-gray-50/30">
                        <Building2 className="h-8 w-8 text-gray-200 mx-auto mb-2" />
                        <p className="text-[10px] font-bold text-gray-400 uppercase">No sites distributed yet</p>
                    </div>
                ) : (
                    allocations.map((alloc, index) => {
                        // RE-RESOLVE NAME FROM REGISTRY (Production Check)
                        const registryMatch = savedLocations.find(l => l.id?.toString() === alloc.locationId)
                        const displayName = registryMatch?.location_name || alloc.locationName || "Custom Location"

                        return (
                            <div 
                                key={`${alloc.locationId}-${index}`} 
                                className="flex items-center gap-3 bg-white p-2.5 rounded-xl border border-gray-200 shadow-sm transition-all hover:border-orange-200 group"
                            >
                                <div className="h-9 w-9 rounded-lg bg-orange-50 flex items-center justify-center shrink-0 group-hover:bg-orange-100 transition-colors">
                                    <Building2 className="h-5 w-5 text-orange-600" />
                                </div>
                                
                                <div className="flex-1 min-w-0">
                                    <p className="text-[11px] font-black text-gray-900 uppercase tracking-tight truncate">
                                        {displayName}
                                    </p>
                                    <p className="text-[9px] font-bold text-gray-400 uppercase">
                                        Asset Node #{index + 1}
                                    </p>
                                </div>

                                <div className="w-24 relative">
                                    <Input
                                        type="number"
                                        min={0}
                                        value={alloc.quantity}
                                        onChange={(e) => onAllocationChange(index, Number(e.target.value))}
                                        className="h-10 pl-3 pr-8 rounded-lg border-2 border-gray-100 bg-gray-50 text-[13px] font-black text-gray-900 focus:bg-white focus:border-orange-500 focus:ring-4 focus:ring-orange-500/10 transition-all text-right"
                                    />
                                    <span className="absolute right-3 top-1/2 -translate-y-1/2 text-[10px] font-black text-gray-400 pointer-events-none uppercase">
                                        Qty
                                    </span>
                                </div>
                                {allocations.length > 1 && (
                                    <Button
                                        variant="ghost"
                                        size="icon"
                                        type="button"
                                        onClick={() => onRemoveAllocation(index)}
                                        className="h-8 w-8 text-gray-400 hover:text-red-600 hover:bg-red-50 rounded-lg flex-shrink-0"
                                    >
                                        <Trash2 className="h-4 w-4" />
                                    </Button>
                                )}
                            </div>
                        )
                    })
                )}
            </div>

            {/* Warnings */}
            {isMismatch && (
                <div className="flex items-center gap-2 p-2 bg-amber-50 border border-amber-200 rounded-lg animate-in fade-in slide-in-from-top-1">
                    <AlertTriangle className="h-3.5 w-3.5 text-amber-600" />
                    <p className="text-[10px] font-bold text-amber-700 uppercase leading-none">
                        Allocation imbalance: {remainingToAllocate > 0 ? `Please distribute ${remainingToAllocate} more units.` : `Total exceeds stock by ${Math.abs(remainingToAllocate)} units.`}
                    </p>
                </div>
            )}

            {/* Add Action */}
            <div className="pt-2">
                <Select
                    onValueChange={(val) => {
                        const loc = savedLocations.find(l => l.id?.toString() === val)
                        if (loc) onAddAllocation(val, loc.location_name)
                    }}
                >
                    <SelectTrigger className="h-10 border-dashed border-2 border-gray-200 hover:border-orange-400 hover:bg-orange-50/30 text-gray-500 text-xs font-bold rounded-xl transition-all">
                        <div className="flex items-center gap-2">
                            <Plus className="h-3.5 w-3.5" />
                            <span>Add Site Placement</span>
                        </div>
                    </SelectTrigger>
                    <SelectContent className="rounded-xl border-gray-200 shadow-xl">
                        {savedLocations
                            .filter(loc => !allocations.some(a => a.locationId === loc.id?.toString()))
                            .map(loc => (
                                <SelectItem key={loc.id} value={loc.id.toString()} className="text-xs">
                                    {loc.location_name}
                                </SelectItem>
                            ))
                        }
                        {savedLocations.length === 0 && (
                            <div className="p-2 text-center text-gray-400 text-[10px]">No other sites available</div>
                        )}
                    </SelectContent>
                </Select>
                <p className="text-[10px] text-gray-400 mt-2 ml-1 italic">
                    Note: Splitting gear across sites creates tracking satellites for each room.
                </p>
            </div>
        </div>
    )
}
