"use client"

import { ShoppingBag, Calendar, Bell } from 'lucide-react'
import { Input } from '@/components/ui/input'
import { Label } from '@/components/ui/label'

interface ConsumableFieldsProps {
    brand: string
    onBrandChange: (val: string) => void
    expiryDate: string
    onExpiryChange: (val: string) => void
    expiryAlertDays: number | string
    onExpiryAlertDaysChange: (val: number | string) => void
}

/**
 * LIGTAS V2 CONSUMABLE SECTION
 * Specialized tracking for non-equipment assets (Medical, Food, etc.)
 */
export function V2ConsumableFields({
    brand, onBrandChange, expiryDate, onExpiryChange, expiryAlertDays, onExpiryAlertDaysChange,
}: ConsumableFieldsProps) {
    return (
        <div className="space-y-4 animate-in fade-in slide-in-from-bottom-2">
            <div className="grid grid-cols-2 gap-4 px-1">
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

            {/* Expiry alert threshold — only relevant when a date is set */}
            {expiryDate && (
                <div className="px-1">
                    <div className="space-y-1.5">
                        <Label className="text-[10px] font-black text-amber-600 uppercase tracking-widest pl-1">
                            Notify when expiry is within (days)
                        </Label>
                        <div className="relative group">
                            <Bell className="absolute left-3 top-1/2 -translate-y-1/2 h-3.5 w-3.5 text-slate-400 group-focus-within:text-amber-500 transition-colors" />
                            <Input
                                type="number"
                                inputMode="numeric"
                                min={1}
                                max={365}
                                placeholder="15"
                                value={expiryAlertDays}
                                onChange={(e) => onExpiryAlertDaysChange(e.target.value === '' ? '' : Math.max(1, Number(e.target.value)))}
                                className="h-10 pl-9 rounded-2xl border-amber-200 text-[13px] font-bold text-slate-700 bg-amber-50/20"
                            />
                        </div>
                        <p className="text-[10px] font-semibold text-slate-400 pl-1">
                            Default is 15 days. Alert fires on the dashboard and mobile app.
                        </p>
                    </div>
                </div>
            )}

            {/* Expiry colour legend */}
            <div className="flex items-center gap-4 px-2 pt-1">
                <div className="flex items-center gap-1.5">
                    <div className="h-1.5 w-1.5 rounded-full bg-rose-500" />
                    <span className="text-[9px] font-bold text-slate-400">Expired / ≤7d</span>
                </div>
                <div className="flex items-center gap-1.5">
                    <div className="h-1.5 w-1.5 rounded-full bg-amber-500" />
                    <span className="text-[9px] font-bold text-slate-400">Within alert window</span>
                </div>
                <div className="flex items-center gap-1.5">
                    <div className="h-1.5 w-1.5 rounded-full bg-emerald-500" />
                    <span className="text-[9px] font-bold text-slate-400">Good</span>
                </div>
            </div>
        </div>
    )
}
