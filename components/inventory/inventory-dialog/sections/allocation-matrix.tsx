'use client'

import { Plus, Trash2, Warehouse, Calculator } from 'lucide-react'
import { Button } from '@/components/ui/button'
import { Input } from '@/components/ui/input'
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from '@/components/ui/select'
import { cn } from '@/lib/utils'

interface Allocation {
    location: string
    quantity: number
}

interface AllocationMatrixProps {
    allocations: Allocation[]
    setAllocations: (allocations: Allocation[]) => void
    savedLocations: string[]
    totalStock: number
}

export function AllocationMatrix({ 
    allocations, 
    setAllocations, 
    savedLocations, 
    totalStock 
}: AllocationMatrixProps) {
    const currentSum = allocations.reduce((sum, a) => sum + a.quantity, 0)
    const isOverAllocated = currentSum > totalStock
    const isUnderAllocated = currentSum < totalStock && totalStock > 0

    const addAllocation = () => {
        const remaining = Math.max(0, totalStock - currentSum)
        setAllocations([...allocations, { location: '', quantity: remaining }])
    }

    const updateAllocation = (index: number, field: keyof Allocation, value: string | number) => {
        const newAllocations = [...allocations]
        newAllocations[index] = { ...newAllocations[index], [field]: value }
        setAllocations(newAllocations)
    }

    const removeAllocation = (index: number) => {
        setAllocations(allocations.filter((_, i) => i !== index))
    }

    return (
        <div className="space-y-4 animate-in fade-in duration-500">
            <div className="flex items-center justify-between pb-2 border-b border-zinc-100">
                <div className="flex items-center gap-2">
                    <Warehouse className="h-3.5 w-3.5 text-blue-600" />
                    <span className="text-[11px] font-black text-slate-900 uppercase tracking-widest">Multi-Site Allocation</span>
                </div>
                <div className={cn(
                    "flex items-center gap-1.5 px-2 py-0.5 rounded-full text-[10px] font-bold",
                    isOverAllocated ? "bg-rose-50 text-rose-600" : 
                    isUnderAllocated ? "bg-amber-50 text-amber-600" : "bg-emerald-50 text-emerald-600"
                )}>
                    <Calculator className="h-3 w-3" />
                    {currentSum} / {totalStock} ALLOCATED
                </div>
            </div>

            <div className="space-y-2">
                {allocations.map((alloc, index) => (
                    <div key={index} className="flex items-center gap-2 group animate-in slide-in-from-left-2 duration-200" style={{ animationDelay: `${index * 50}ms` }}>
                        <div className="flex-1">
                            <Select 
                                value={alloc.location} 
                                onValueChange={(val) => updateAllocation(index, 'location', val)}
                            >
                                <SelectTrigger className="h-9 text-[12px] font-bold bg-white border-zinc-200 rounded-lg">
                                    <SelectValue placeholder="Select Room" />
                                </SelectTrigger>
                                <SelectContent>
                                    {savedLocations.filter(loc => !allocations.some((a, i) => i !== index && a.location === loc)).map(loc => (
                                        <SelectItem key={loc} value={loc} className="text-[12px] font-medium">{loc}</SelectItem>
                                    ))}
                                </SelectContent>
                            </Select>
                        </div>
                        <div className="w-24">
                            <Input 
                                type="number"
                                value={alloc.quantity}
                                onChange={(e) => updateAllocation(index, 'quantity', parseInt(e.target.value) || 0)}
                                className="h-9 text-[13px] font-mono font-black text-right border-zinc-200 rounded-lg"
                            />
                        </div>
                        <Button 
                            variant="ghost" 
                            size="icon" 
                            onClick={() => removeAllocation(index)}
                            className="h-9 w-9 text-slate-300 hover:text-rose-600 hover:bg-rose-50 rounded-lg transition-colors"
                        >
                            <Trash2 className="h-4 w-4" />
                        </Button>
                    </div>
                ))}

                <Button 
                    variant="outline" 
                    onClick={addAllocation}
                    disabled={currentSum >= totalStock && totalStock > 0}
                    className="w-full h-9 border-dashed border-zinc-300 text-slate-500 hover:text-blue-600 hover:border-blue-300 hover:bg-blue-50/50 rounded-lg text-[11px] font-bold uppercase tracking-widest gap-2 transition-all"
                >
                    <Plus className="h-3.5 w-3.5" />
                    Add Another Location
                </Button>
            </div>

            {isOverAllocated && (
                <p className="text-[10px] text-rose-500 font-bold italic text-center animate-pulse">
                    ⚠️ Total allocation exceeds fleet stock ({currentSum - totalStock} units over)
                </p>
            )}
        </div>
    )
}
