'use client'

import { useState, useTransition, useEffect, useMemo } from 'react'
import { QrCode, Printer, Trash2, Package, Save, Loader2 } from 'lucide-react'
import { Button } from '@/components/ui/button'
import { Badge } from '@/components/ui/badge'
import { ScrollArea } from '@/components/ui/scroll-area'
import { toast } from 'sonner'
import { cn } from '@/lib/utils'
import type { Station, InventoryPickerItem } from '@/src/features/tactical-stations/types'
import {
    getStationManifest,
    syncStationManifest,
    updateStationName,
    deleteStation,
} from '@/src/features/tactical-stations/actions/station.actions'
import { PrintLabelSheet } from './print-label-sheet'
import { InventoryPicker } from './inventory-picker'
import { StationIdentityCard } from './station-identity-card'
import { ManifestItemRow } from './manifest-item-row'

interface ManifestWorkbenchProps {
    stations: Station[]
    inventoryItems: InventoryPickerItem[]
    activeStationId: number | null
    onStationChange: (id: number) => void
    onDirtyChange: (isDirty: boolean) => void
    isBlueprint?: boolean
    blueprintItems?: number[]
    onBlueprintChange?: (items: number[]) => void
}

export function ManifestWorkbench({ 
    stations, inventoryItems, activeStationId, onStationChange, onDirtyChange,
    isBlueprint = false, blueprintItems = [], onBlueprintChange
}: ManifestWorkbenchProps) {
    const [manifestItemIds, setManifestItemIds] = useState<number[]>([])
    const [originalItemIds, setOriginalItemIds] = useState<number[]>([])
    const [searchQuery, setSearchQuery] = useState('')
    const [categoryFilter, setCategoryFilter] = useState('ALL')
    const [isPending, startTransition] = useTransition()
    const [isLoaded, setIsLoaded] = useState(false)

    const activeStation = stations.find(s => s.id === activeStationId) ?? null

    useEffect(() => {
        if (activeStationId && !isLoaded) {
            startTransition(async () => {
                const result = await getStationManifest(activeStationId)
                if (!result.error) {
                    const ids = (result.data ?? []).map(i => i.item_id)
                    setManifestItemIds(ids); setOriginalItemIds(ids); setIsLoaded(true)
                }
            })
        }
    }, [activeStationId, isLoaded])

    const isDirty = useMemo(() => {
        if (manifestItemIds.length !== originalItemIds.length) return true
        return [...manifestItemIds].sort().some((id, i) => id !== [...originalItemIds].sort()[i])
    }, [manifestItemIds, originalItemIds])

    useEffect(() => { onDirtyChange(isDirty) }, [isDirty, onDirtyChange])

    function toggleItem(itemId: number) {
        if (isBlueprint && onBlueprintChange) {
            onBlueprintChange(blueprintItems.includes(itemId) ? blueprintItems.filter(id => id !== itemId) : [...blueprintItems, itemId])
            return
        }
        setManifestItemIds(prev => prev.includes(itemId) ? prev.filter(id => id !== itemId) : [...prev, itemId])
    }

    const inventoryMap = useMemo(() => {
        const map = new Map<number, InventoryPickerItem>()
        inventoryItems.forEach(item => map.set(item.id, item))
        return map
    }, [inventoryItems])

    const mappedItems = useMemo(() => 
        (isBlueprint ? blueprintItems : manifestItemIds).map(id => inventoryMap.get(id)).filter(Boolean) as InventoryPickerItem[]
    , [isBlueprint, blueprintItems, manifestItemIds, inventoryMap])

    const handleCommit = () => activeStationId && startTransition(async () => {
        const res = await syncStationManifest(activeStationId, manifestItemIds)
        if (res.error) return toast.error(res.error)
        setOriginalItemIds([...manifestItemIds]); toast.success('Station manifest saved.')
    })

    const handleDownloadQR = () => {
        if (!activeStation) return;
        const svg = document.getElementById(`station-qr-${activeStation.id}`) as any;
        if (!svg) return;
        const canvas = document.createElement('canvas'); const ctx = canvas.getContext('2d');
        const img = new Image(); img.onload = () => {
            canvas.width = 400; canvas.height = 200;
            if (ctx) {
                ctx.fillStyle = 'white'; ctx.fillRect(0, 0, 400, 200); ctx.drawImage(img, 20, 20, 160, 160);
                ctx.fillStyle = '#1e293b'; ctx.font = 'bold 24px Inter'; ctx.fillText(activeStation.station_name || activeStation.location_name, 200, 70);
                ctx.fillStyle = '#64748b'; ctx.font = 'bold 12px Inter'; ctx.fillText('STATION IDENTIFIER', 200, 100);
                ctx.fillStyle = '#0f172a'; ctx.font = '900 28px "JetBrains Mono"'; ctx.fillText(activeStation.station_code || '', 200, 140);
                const link = document.createElement('a'); link.download = `LABEL-${activeStation.station_code}.png`; link.href = canvas.toDataURL(); link.click();
            }
        };
        img.src = 'data:image/svg+xml;base64,' + btoa(new XMLSerializer().serializeToString(svg))
    }

    return (
        <div className="flex-1 flex overflow-hidden">
            <div className="flex-1 border-r border-slate-100 flex flex-col bg-white overflow-hidden">
                <div className="h-14 px-5 border-b border-slate-100 flex items-center justify-between shrink-0">
                    <div className="flex items-center gap-3">
                        <div className="h-8 w-8 bg-slate-900 rounded-lg flex items-center justify-center"><QrCode className="h-4 w-4 text-blue-400" /></div>
                        {isBlueprint ? (
                            <div><h2 className="text-[13px] font-[900] text-blue-600 uppercase italic">NEW STATION BLUEPRINT</h2><p className="text-[10px] font-bold text-slate-400 uppercase leading-none mt-1">STAGING {mappedItems.length} ITEMS</p></div>
                        ) : activeStation ? (
                            <div>
                                <input type="text" defaultValue={activeStation.station_name || activeStation.location_name} onBlur={e => {
                                    const n = e.target.value.trim(); if (n && n !== activeStation.station_name) startTransition(async () => { await updateStationName({ station_id: activeStation.id, station_name: n }); toast.success('Station renamed') })
                                }} className="block w-full bg-transparent border-none p-0 text-[13px] font-[900] text-slate-900 uppercase italic focus:ring-0" />
                                <p className="text-[10px] font-bold text-slate-400 uppercase leading-none mt-1">STATION ID: {activeStation.station_code} • {mappedItems.length} ITEMS</p>
                            </div>
                        ) : <p className="text-[12px] text-slate-400 font-medium">Select a station to edit →</p>}
                    </div>
                    {!isBlueprint && <div className="flex items-center gap-1">
                        <Button variant="ghost" size="sm" disabled={stations.length === 0} onClick={() => window.print()} className="h-8 text-slate-400 hover:text-blue-600 text-[10px] font-black uppercase tracking-widest gap-1.5"><Printer className="h-3.5 w-3.5" />PRINT ALL</Button>
                        <Button variant="ghost" size="sm" disabled={!activeStation || isPending} onClick={() => activeStationId && startTransition(async () => { await deleteStation(activeStationId); onStationChange(stations.find(s => s.id !== activeStationId)?.id ?? 0); toast.success('Station deleted.') })} className="h-8 text-slate-300 hover:text-red-500 px-2"><Trash2 className="h-3.5 w-3.5" /></Button>
                    </div>}
                </div>
                <div className="h-9 px-4 bg-slate-50/50 border-b border-slate-100 flex items-center justify-between shrink-0">
                    <span className="text-[10px] font-black text-slate-400 uppercase tracking-widest">Station Supply List</span>
                    <Badge className="bg-slate-900 text-white text-[9px] px-2 h-4">{mappedItems.length}</Badge>
                </div>
                <ScrollArea className="flex-1">
                    {isPending ? <div className="flex justify-center py-20"><Loader2 className="h-5 w-5 animate-spin text-slate-300" /></div> : mappedItems.length === 0 ? <div className="flex flex-col items-center justify-center py-20 text-slate-300"><Package className="h-8 w-8 mb-2 opacity-20" /><p className="text-[11px] font-bold uppercase tracking-widest">Station is empty</p></div> : 
                        <div className="divide-y divide-slate-50">{mappedItems.map(item => <ManifestItemRow key={item.id} item={item} onRemove={toggleItem} />)}</div>
                    }
                </ScrollArea>
            </div>
            <div className="w-[380px] flex flex-col bg-slate-50/30 shrink-0 overflow-hidden">
                <InventoryPicker items={inventoryItems.filter(item => (categoryFilter === 'ALL' || item.category === categoryFilter) && item.item_name.toLowerCase().includes(searchQuery.toLowerCase()))} activeStationId={activeStationId} manifestItemIds={manifestItemIds} searchQuery={searchQuery} onSearchChange={setSearchQuery} categoryFilter={categoryFilter} onCategoryFilterChange={setCategoryFilter} categories={['ALL', ...Array.from(new Set(inventoryItems.map(i => i.category)))]} onToggleItem={toggleItem} />
                <div className="p-4 border-t border-slate-200 bg-white space-y-3 shrink-0">
                    {!isBlueprint && activeStation && <StationIdentityCard station={activeStation} onDownload={handleDownloadQR} />}
                    {isBlueprint ? <div className="p-3 bg-blue-50 border border-blue-100 rounded-xl"><p className="text-[10px] font-bold text-blue-600 uppercase">💡 Setup items first, then click "Confirm Blueprint" in the Registry sidebar to deploy.</p></div> : 
                        <Button onClick={handleCommit} disabled={!activeStation || isPending || !isDirty} className={cn("w-full h-10 font-black text-[11px] uppercase tracking-widest rounded-xl gap-2 transition-all", isDirty ? "bg-blue-600 hover:bg-blue-700 text-white shadow-lg shadow-blue-200" : "bg-slate-900 hover:bg-black text-white")}>{isPending ? <Loader2 className="h-4 w-4 animate-spin" /> : <Save className="h-4 w-4" />}{isPending ? 'Saving...' : isDirty ? 'Save Supply List' : 'Supply List Saved'}</Button>
                    }
                </div>
            </div>
            <PrintLabelSheet stations={stations} />
        </div>
    )
}
