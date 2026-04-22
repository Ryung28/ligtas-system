'use client'

import { useState, useTransition } from 'react'
import { Plus, Loader2 } from 'lucide-react'
import { Button } from '@/components/ui/button'
import { Input } from '@/components/ui/input'
import { ScrollArea } from '@/components/ui/scroll-area'
import { toast } from 'sonner'
import { cn } from '@/lib/utils'
import type { Station } from '@/src/features/tactical-stations/types'
import { createStation } from '@/src/features/tactical-stations/actions/station.actions'
import { STORAGE_LOCATION_LABELS } from '@/lib/supabase'
import {
    Select,
    SelectContent,
    SelectItem,
    SelectTrigger,
    SelectValue,
} from "@/components/ui/select"

interface StationRegistryProps {
    stations: Station[]
    activeStationId: number | null
    onSelect: (station: Station) => void
    isCreating: boolean
    onToggleCreate: () => void
    blueprintItems: number[]
}

export function StationRegistry({ stations, activeStationId, onSelect, isCreating, onToggleCreate, blueprintItems }: StationRegistryProps) {
    const [name, setName] = useState('')
    const [location, setLocation] = useState('')
    const [isPending, startTransition] = useTransition()

    function handleCreate() {
        if (!name.trim() || !location) {
            toast.error('Please provide a name and select a location.')
            return
        }
        startTransition(async () => {
            const result = await createStation({
                station_name: name.trim(),
                location_name: location,
                description: null,
                item_ids: blueprintItems,
            })
            if (result.error) {
                // If the error message indicates station was created (even if manifest failed)
                // we still want to proceed but show the error
                if (result.data) {
                    toast.warning(result.error)
                } else {
                    toast.error(result.error)
                    return
                }
            } else {
                toast.success(`Station ${result.data?.station_code} deployed.`)
            }

            setName('')
            setLocation('')
            if (result.data) onSelect(result.data)
        })
    }

    return (
        <>
            {/* New station button */}
            <div className="p-3 border-b border-slate-200">
                <Button
                    variant={isCreating ? "default" : "outline"}
                    onClick={onToggleCreate}
                    className={cn(
                        "w-full h-8 border-slate-300 font-black text-[10px] uppercase tracking-widest gap-2 transition-all",
                        isCreating 
                            ? "bg-blue-600 text-white border-blue-700 hover:bg-blue-700 shadow-md shadow-blue-100" 
                            : "bg-white text-slate-600 hover:bg-white hover:border-blue-400"
                    )}
                >
                    {isCreating ? (
                        <>
                            <Loader2 className={cn("h-3.5 w-3.5", isPending ? "animate-spin" : "hidden")} />
                            CANCEL SETUP
                        </>
                    ) : (
                        <>
                            <Plus className="h-3.5 w-3.5" />
                            Setup New Station
                        </>
                    )}
                </Button>
            </div>

            {/* Inline creation form */}
            {isCreating && (
                <div className="p-3 border-b border-slate-200 bg-blue-50/50 space-y-2">
                    <div className="space-y-1">
                        <label className="text-[9px] font-black text-blue-600 uppercase tracking-widest ml-1">Identity Name</label>
                        <Input
                            placeholder="e.g. Medic Alpha"
                            value={name}
                            onChange={e => setName(e.target.value)}
                            className="h-8 text-[11px] bg-white border-slate-200 rounded-md focus-visible:ring-blue-600"
                        />
                    </div>
                    <div className="space-y-1">
                        <label className="text-[9px] font-black text-blue-600 uppercase tracking-widest ml-1">Physical Area</label>
                        <Input
                            placeholder="e.g. Shelf A, Office"
                            value={location}
                            onChange={e => setLocation(e.target.value)}
                            className="h-8 text-[11px] bg-white border-slate-200 rounded-md focus-visible:ring-blue-600"
                        />
                    </div>
                    <Button
                        onClick={handleCreate}
                        disabled={isPending || !name.trim() || !location}
                        className="w-full h-8 bg-slate-900 hover:bg-black text-white text-[10px] font-black uppercase tracking-widest gap-2 shadow-lg shadow-slate-200 mt-2"
                    >
                        {isPending ? <Loader2 className="h-3.5 w-3.5 animate-spin" /> : 'Confirm Blueprint'}
                    </Button>
                </div>
            )}

            {/* Station list */}
            <ScrollArea className="flex-1">
                <div className="py-2">
                    {stations.length === 0 ? (
                        <p className="text-center text-[10px] text-slate-400 uppercase font-bold tracking-widest py-8">
                            No stations yet
                        </p>
                    ) : (
                        stations.map(station => (
                            <button
                                key={station.id}
                                onClick={() => onSelect(station)}
                                className={cn(
                                    'w-full px-4 py-2.5 flex items-center justify-between border-y border-transparent transition-all text-left',
                                    activeStationId === station.id
                                        ? 'bg-white border-slate-200 shadow-sm'
                                        : 'hover:bg-slate-100/50'
                                )}
                            >
                                <div className="min-w-0 flex-1">
                                    <p className={cn(
                                        'text-[12px] font-heading font-black truncate leading-tight',
                                        activeStationId === station.id ? 'text-blue-600' : 'text-slate-800'
                                    )}>
                                        {station.station_name}
                                    </p>
                                    <p className="text-[9px] font-bold text-slate-400 uppercase tracking-widest leading-none mt-0.5">
                                        {station.location_name} • {station.station_code ?? 'PRV'}
                                    </p>
                                </div>
                                {activeStationId === station.id && (
                                    <div className="h-1.5 w-1.5 rounded-full bg-blue-500 shrink-0 ml-2" />
                                )}
                            </button>
                        ))
                    )}
                </div>
            </ScrollArea>
        </>
    )
}
