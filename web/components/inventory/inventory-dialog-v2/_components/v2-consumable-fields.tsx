"use client"

import { ShoppingBag, Calendar } from 'lucide-react'
import { Input } from '@/components/ui/input'
import { Label } from '@/components/ui/label'

interface ConsumableFieldsProps {
    brand: string
    onBrandChange: (val: string) => void
    expiryDate: string
    onExpiryChange: (val: string) => void
}

/**
 * LIGTAS V2 CONSUMABLE SECTION
 * Specialized tracking for non-equipment assets (Medical, Food, etc.)
 */
export function V2ConsumableFields({
    brand, onBrandChange, expiryDate, onExpiryChange
}: ConsumableFieldsProps) {
    return (
        <div className="grid grid-cols-2 gap-4 px-1 animate-in fade-in slide-in-from-bottom-2">
            <div className="space-y-1.5">
                <Label className="text-[10px] font-black text-rose-600 uppercase tracking-widest pl-1">Brand</Label>
                <div className="relative group">
                    <ShoppingBag className="absolute left-3 top-1/2 -translate-y-1/2 h-3.5 w-3.5 text-slate-400 group-focus-within:text-rose-500 transition-colors" />
                    <Input 
                        placeholder="e.g. 3M, Philips"
                        value={brand}
                        onChange={(e) => onBrandChange(e.target.value)}
                        className="h-10 pl-9 rounded-2xl border-slate-200 text-[13px] font-bold text-slate-700 bg-rose-50/5"
                    />
                </div>
            </div>
            
            <div className="space-y-1.5">
                <Label className="text-[10px] font-black text-rose-600 uppercase tracking-widest pl-1">Expires on</Label>
                <div className="relative group">
                    <Calendar className="absolute left-3 top-1/2 -translate-y-1/2 h-3.5 w-3.5 text-slate-400 group-focus-within:text-rose-500 transition-colors" />
                    <Input 
                        type="date"
                        value={expiryDate}
                        onChange={(e) => onExpiryChange(e.target.value)}
                        className="h-10 pl-9 rounded-2xl border-slate-200 text-[13px] font-bold text-slate-700 bg-rose-50/5"
                    />
                </div>
            </div>
        </div>
    )
}
