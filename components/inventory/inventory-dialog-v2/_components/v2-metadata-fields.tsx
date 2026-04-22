"use client"

import { Fingerprint, Barcode } from 'lucide-react'
import { Input } from '@/components/ui/input'
import { Label } from '@/components/ui/label'

interface MetadataFieldsProps {
    serialNumber: string
    onSerialChange: (val: string) => void
    modelNumber: string
    onModelChange: (val: string) => void
}

/**
 * ResQTrack V2 METADATA SECTION
 * Tracks hard identity markers: Serials and Model Tags.
 */
export function V2MetadataFields({
    serialNumber, onSerialChange, modelNumber, onModelChange
}: MetadataFieldsProps) {
    return (
        <div className="grid grid-cols-2 gap-4 px-1 pb-2">
            <div className="space-y-1.5">
                <Label className="text-[10px] font-black text-slate-600 uppercase tracking-widest pl-1">Serial / Tag #</Label>
                <div className="relative group">
                    <Fingerprint className="absolute left-3 top-1/2 -translate-y-1/2 h-3.5 w-3.5 text-slate-400 group-focus-within:text-blue-500 transition-colors" />
                    <Input 
                        placeholder="SN-0000"
                        value={serialNumber}
                        onChange={(e) => onSerialChange(e.target.value)}
                        className="h-10 pl-9 rounded-2xl border-slate-200 text-[13px] font-bold text-slate-700 bg-white"
                    />
                </div>
            </div>
            
            <div className="space-y-1.5">
                <Label className="text-[10px] font-black text-slate-600 uppercase tracking-widest pl-1">Model Name</Label>
                <div className="relative group">
                    <Barcode className="absolute left-3 top-1/2 -translate-y-1/2 h-3.5 w-3.5 text-slate-400 group-focus-within:text-blue-500 transition-colors" />
                    <Input 
                        placeholder="X-Series"
                        value={modelNumber}
                        onChange={(e) => onModelChange(e.target.value)}
                        className="h-10 pl-9 rounded-2xl border-slate-200 text-[13px] font-bold text-slate-700 bg-white"
                    />
                </div>
            </div>
        </div>
    )
}
