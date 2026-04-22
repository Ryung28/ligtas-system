'use client'

import { useState, useTransition, useEffect, useMemo } from 'react'
import {
    Plus,
    Search,
    QrCode,
    Printer,
    Trash2,
    CheckCircle2,
    Circle,
    Package,
    Save,
    X,
    Loader2,
    Download,
} from 'lucide-react'
import { Button } from '@/components/ui/button'
import { Input } from '@/components/ui/input'
import { Badge } from '@/components/ui/badge'
import { ScrollArea } from '@/components/ui/scroll-area'
import { QRCodeSVG } from 'qrcode.react'
import { toast } from 'sonner'
import { cn } from '@/lib/utils'
import { isLowStock } from '@/src/features/inventory/utils'
import type { Station, InventoryPickerItem } from '@/src/features/tactical-stations/types'
import {
    getStationManifest,
    syncStationManifest,
    updateStationName,
    deleteStation,
} from '@/src/features/tactical-stations/actions/station.actions'

// ─── Props ────────────────────────────────────────────────────────────────────

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

// ─── Main Component ───────────────────────────────────────────────────────────

export function ManifestWorkbench({ 
    stations, 
    inventoryItems, 
    activeStationId, 
    onStationChange, 
    onDirtyChange,
    isBlueprint = false,
    blueprintItems = [],
    onBlueprintChange
}: ManifestWorkbenchProps) {
    const [manifestItemIds, setManifestItemIds] = useState<number[]>([])
    const [originalItemIds, setOriginalItemIds] = useState<number[]>([]) // track baseline
    const [searchQuery, setSearchQuery] = useState('')
    const [categoryFilter, setCategoryFilter] = useState('ALL')
    const [isPending, startTransition] = useTransition()
    const [isLoaded, setIsLoaded] = useState(false) // fixed fetch logic

    const activeStation = stations.find(s => s.id === activeStationId) ?? null

    // Load manifest on mount/station change
    useEffect(() => {
        if (activeStationId && !isLoaded) {
            startTransition(async () => {
                const result = await getStationManifest(activeStationId)
                if (!result.error) {
                    const ids = (result.data ?? []).map(i => i.item_id)
                    setManifestItemIds(ids)
                    setOriginalItemIds(ids)
                    setIsLoaded(true)
                }
            })
        }
    }, [activeStationId, isLoaded])

    // Detect if current manifest differs from what is in DB
    const isDirty = useMemo(() => {
        if (manifestItemIds.length !== originalItemIds.length) return true
        const sortedManifest = [...manifestItemIds].sort()
        const sortedOriginal = [...originalItemIds].sort()
        return !sortedManifest.every((id, idx) => id === sortedOriginal[idx])
    }, [manifestItemIds, originalItemIds])

    // Sync dirty state to parent
    useEffect(() => {
        onDirtyChange(isDirty)
    }, [isDirty, onDirtyChange])

    // Prevent accidental reload/close
    useEffect(() => {
        if (!isDirty) return
        const handleBeforeUnload = (e: BeforeUnloadEvent) => {
            e.preventDefault()
            e.returnValue = ''
        }
        window.addEventListener('beforeunload', handleBeforeUnload)
        return () => window.removeEventListener('beforeunload', handleBeforeUnload)
    }, [isDirty])

    // ── Toggle item in/out of manifest ────────────────────────────────────────
    function toggleItem(itemId: number) {
        if (isBlueprint && onBlueprintChange) {
            const next = blueprintItems.includes(itemId)
                ? blueprintItems.filter(id => id !== itemId)
                : [...blueprintItems, itemId]
            onBlueprintChange(next)
            return
        }

        setManifestItemIds(prev =>
            prev.includes(itemId) ? prev.filter(id => id !== itemId) : [...prev, itemId]
        )
    }

    // ── Commit manifest to DB ─────────────────────────────────────────────────
    function handleCommit() {
        if (!activeStationId) return
        startTransition(async () => {
            const result = await syncStationManifest(activeStationId, manifestItemIds)
            if (result.error) {
                toast.error(result.error)
                return
            }
            setOriginalItemIds([...manifestItemIds]) // sync baseline
            toast.success('Station manifest saved.')
        })
    }

    // ── Delete station ────────────────────────────────────────────────────────
    function handleDelete() {
        if (!activeStationId) return
        startTransition(async () => {
            const result = await deleteStation(activeStationId)
            if (result.error) {
                toast.error(result.error)
                return
            }
            const next = stations.find(s => s.id !== activeStationId)
            onStationChange(next?.id ?? 0)
            setManifestItemIds([])
            toast.success('Station deleted.')
        })
    }

    // ── Download Station Card ────────────────────────────────────────────────
    function handleDownloadQR() {
        if (!activeStation) return
        const svg = document.getElementById(`station-qr-${activeStation.id}`) as SVGGraphicsElement
        if (!svg) return

        const svgData = new XMLSerializer().serializeToString(svg)
        const canvas = document.createElement('canvas')
        const ctx = canvas.getContext('2d')
        const img = new Image()
        
        img.onload = () => {
            canvas.width = 400
            canvas.height = 200
            if (ctx) {
                // Background
                ctx.fillStyle = 'white'
                ctx.fillRect(0, 0, canvas.width, canvas.height)
                
                // QR
                ctx.drawImage(img, 20, 20, 160, 160)
                
                // Text
                ctx.fillStyle = '#1e293b'
                ctx.font = 'bold 24px Inter, sans-serif'
                ctx.textAlign = 'left'
                ctx.fillText(activeStation.station_name || activeStation.location_name, 200, 70)
                
                ctx.fillStyle = '#64748b'
                ctx.font = 'bold 12px Inter, sans-serif'
                ctx.fillText('STATION IDENTIFIER', 200, 100)
                
                ctx.fillStyle = '#0f172a'
                ctx.font = '900 28px "JetBrains Mono", monospace'
                ctx.fillText(activeStation.station_code || '', 200, 140)
                
                const url = canvas.toDataURL('image/png')
                const link = document.createElement('a')
                link.download = `LABEL-${activeStation.station_code}.png`
                link.href = url
                link.click()
            }
        }
        img.src = 'data:image/svg+xml;base64,' + btoa(svgData)
    }

    // ── Filtered inventory list for picker ────────────────────────────────────
    const categories = useMemo(() => 
        ['ALL', ...Array.from(new Set(inventoryItems.map(i => i.category)))],
        [inventoryItems]
    )

    const filteredItems = useMemo(() => {
        return inventoryItems.filter(item => {
            const matchSearch = item.item_name.toLowerCase().includes(searchQuery.toLowerCase())
            const matchCat = categoryFilter === 'ALL' || item.category === categoryFilter
            return matchSearch && matchCat
        })
    }, [inventoryItems, searchQuery, categoryFilter])

    // ── Optimized Item Lookup ($O(1)) ───────────────────────────────────────
    const inventoryMap = useMemo(() => {
        const map = new Map<number, InventoryPickerItem>()
        inventoryItems.forEach(item => map.set(item.id, item))
        return map
    }, [inventoryItems])

    const mappedItems = useMemo(() => {
        const ids = isBlueprint ? blueprintItems : manifestItemIds
        return ids
            .map(id => inventoryMap.get(id))
            .filter(Boolean) as InventoryPickerItem[]
    }, [isBlueprint, blueprintItems, manifestItemIds, inventoryMap])

    return (
        <div className="flex-1 flex overflow-hidden">
            {/* ── CENTER: MANIFEST ──────────────────────────────────────────── */}
            <div className="flex-1 border-r border-slate-100 flex flex-col bg-white overflow-hidden">
                {/* Station header */}
                <div className="h-14 px-5 border-b border-slate-100 flex items-center justify-between shrink-0">
                    <div className="flex items-center gap-3">
                        <div className="h-8 w-8 bg-slate-900 rounded-lg flex items-center justify-center shrink-0">
                            <QrCode className="h-4 w-4 text-blue-400" />
                        </div>
                        {isBlueprint ? (
                            <div className="flex-1">
                                <h2 className="text-[13px] font-[900] text-blue-600 uppercase italic tracking-tight leading-none">
                                    NEW STATION BLUEPRINT
                                </h2>
                                <p className="text-[10px] font-bold text-slate-400 uppercase tracking-[0.15em] leading-none mt-1">
                                    STAGING {mappedItems.length} ITEMS FOR DEPLOYMENT
                                </p>
                            </div>
                        ) : activeStation ? (
                            <div className="flex-1">
                                <input
                                    type="text"
                                    defaultValue={activeStation.station_name || activeStation.location_name}
                                    onBlur={(e) => {
                                        const newName = e.target.value.trim()
                                        if (newName && newName !== activeStation.station_name) {
                                            startTransition(async () => {
                                                await updateStationName({ 
                                                    station_id: activeStation.id, 
                                                    station_name: newName 
                                                })
                                                toast.success('Station renamed')
                                            })
                                        }
                                    }}
                                    className="block w-full bg-transparent border-none p-0 text-[13px] font-[900] text-slate-900 uppercase italic tracking-tight leading-none focus:ring-0 focus:outline-none"
                                />
                                <p className="text-[10px] font-bold text-slate-400 uppercase tracking-[0.15em] leading-none mt-1">
                                    STATION ID: {activeStation.station_code ?? 'PENDING'} • {mappedItems.length} ITEMS
                                </p>
                            </div>
                        ) : (
                            <p className="text-[12px] text-slate-400 font-medium">Select a station to edit →</p>
                        )}
                    </div>
                    {!isBlueprint && (
                        <div className="flex items-center gap-1">
                            <Button
                                variant="ghost"
                                size="sm"
                                disabled={!activeStation}
                                className="h-8 text-slate-400 hover:text-blue-600 text-[10px] font-black uppercase tracking-widest gap-1.5"
                            >
                                <Printer className="h-3.5 w-3.5" />
                                PRINT
                            </Button>
                            <Button
                                variant="ghost"
                                size="sm"
                                disabled={!activeStation || isPending}
                                onClick={handleDelete}
                                className="h-8 text-slate-300 hover:text-red-500 px-2"
                            >
                                <Trash2 className="h-3.5 w-3.5" />
                            </Button>
                        </div>
                    )}
                </div>

                {/* Manifest section label */}
                <div className="h-9 px-4 bg-slate-50/50 border-b border-slate-100 flex items-center justify-between shrink-0">
                    <span className="text-[10px] font-black text-slate-400 uppercase tracking-widest">
                        Station Supply List
                    </span>
                    <Badge className="bg-slate-900 text-white text-[9px] px-2 h-4">
                        {mappedItems.length}
                    </Badge>
                </div>

                {/* Manifest rows */}
                <ScrollArea className="flex-1">
                    {isPending ? (
                        <div className="flex items-center justify-center py-20">
                            <Loader2 className="h-5 w-5 text-slate-300 animate-spin" />
                        </div>
                    ) : mappedItems.length === 0 ? (
                        <div className="flex flex-col items-center justify-center py-20 text-slate-300">
                            <Package className="h-8 w-8 mb-2 opacity-20" />
                            <p className="text-[11px] font-bold uppercase tracking-widest">
                                {activeStation ? 'Station is empty' : 'No station selected'}
                            </p>
                        </div>
                    ) : (
                        <div className="divide-y divide-slate-50">
                            {mappedItems.map(item => (
                                <div
                                    key={item.id}
                                    className="h-10 flex items-center px-4 hover:bg-slate-50 transition-all group"
                                >
                                    <Package className="h-3.5 w-3.5 text-blue-500 mr-3 shrink-0" />
                                    <div className="flex-1 flex flex-col min-w-0 pr-3">
                                        <div className="flex items-center gap-2">
                                            <span className="text-[12px] font-black text-slate-900 truncate">
                                                {item.base_name || item.item_name}
                                            </span>
                                            {item.variant_label && (
                                                <Badge variant="outline" className="h-4 px-1.5 text-[8px] font-black bg-slate-50 text-slate-400 border-slate-200">
                                                    {item.variant_label}
                                                </Badge>
                                            )}
                                        </div>
                                    </div>
                                    <div className="flex items-center gap-2 tabular-nums">
                                        <span className={cn(
                                            "text-[10px] font-black px-1.5 py-0.5 rounded",
                                            isLowStock(item) ? "bg-rose-50 text-rose-600" : "text-slate-900"
                                        )}>
                                            {item.stock_available}
                                            <span className="text-slate-300 font-medium mx-0.5">/</span>
                                            {item.target_stock > 0 ? item.target_stock : item.stock_total}
                                        </span>
                                        <span className="text-[10px] font-black text-slate-400 uppercase w-14 text-right shrink-0">
                                            {item.category}
                                        </span>
                                    </div>
                                    <button
                                        onClick={() => toggleItem(item.id)}
                                        className="ml-3 p-1 text-slate-200 hover:text-red-500 opacity-0 group-hover:opacity-100 transition-all"
                                    >
                                        <X className="h-3.5 w-3.5" />
                                    </button>
                                </div>
                            ))}
                        </div>
                    )}
                </ScrollArea>
            </div>

            {/* ── RIGHT: PICKER ─────────────────────────────────────────────── */}
            <div className="w-[380px] flex flex-col bg-slate-50/30 shrink-0 overflow-hidden">
                {/* Search + filter */}
                <div className="p-4 border-b border-slate-100 shrink-0">
                    <div className="relative">
                        <Search className="absolute left-2.5 top-1/2 -translate-y-1/2 h-3.5 w-3.5 text-slate-400" />
                        <Input
                            placeholder="SEARCH INVENTORY..."
                            className="h-9 pl-8 bg-white border-slate-200 text-[11px] font-bold uppercase tracking-wider rounded-md focus-visible:ring-blue-600"
                            value={searchQuery}
                            onChange={e => setSearchQuery(e.target.value)}
                        />
                    </div>
                    <div className="flex gap-1.5 mt-3 flex-wrap">
                        {categories.slice(0, 6).map(cat => (
                            <button
                                key={cat}
                                onClick={() => setCategoryFilter(cat)}
                                className={cn(
                                    'px-3 py-1 rounded-md text-[9px] font-black border transition-all',
                                    categoryFilter === cat
                                        ? 'bg-slate-900 border-slate-900 text-white'
                                        : 'bg-white border-slate-200 text-slate-400 hover:border-blue-400'
                                )}
                            >
                                {cat}
                            </button>
                        ))}
                    </div>
                </div>

                {/* Picker rows */}
                <ScrollArea className="flex-1">
                    <div className="p-2 space-y-1">
                        {filteredItems.map(item => {
                            const isMapped = manifestItemIds.includes(item.id)
                            return (
                                <button
                                    key={item.id}
                                    onClick={() => toggleItem(item.id)}
                                    disabled={!activeStation}
                                    className={cn(
                                        'w-full h-11 flex items-center px-4 rounded-lg transition-all border',
                                        isMapped
                                            ? 'bg-blue-600 border-blue-700 text-white shadow-sm'
                                            : 'bg-white border-slate-100 hover:border-slate-300',
                                        !activeStation && 'opacity-40 cursor-not-allowed'
                                    )}
                                >
                                    <div className="mr-3 shrink-0">
                                        {isMapped
                                            ? <CheckCircle2 className="h-4 w-4 text-white" />
                                            : <Circle className="h-4 w-4 text-slate-200" />
                                        }
                                    </div>
                                    <div className="flex-1 text-left min-w-0 pr-3">
                                        <div className="flex items-center gap-2">
                                            <p className={cn('text-[12px] font-black truncate leading-none', isMapped ? 'text-white' : 'text-slate-900')}>
                                                {item.base_name || item.item_name}
                                            </p>
                                            {item.variant_label && (
                                                <span className={cn(
                                                    "text-[8px] font-black px-1 rounded-sm uppercase tracking-tighter",
                                                    isMapped ? "bg-white/20 text-white" : "bg-slate-100 text-slate-400"
                                                )}>
                                                    {item.variant_label}
                                                </span>
                                            )}
                                        </div>
                                        <p className={cn('text-[9px] font-black uppercase tracking-widest mt-1.5', isMapped ? 'text-blue-200' : 'text-slate-400')}>
                                            {item.category} • <span className={isLowStock(item) && !isMapped ? "text-rose-500 underline decoration-rose-500/30 underline-offset-2" : ""}>
                                                {item.stock_available}/{item.target_stock > 0 ? item.target_stock : item.stock_total}
                                            </span> {item.unit}
                                        </p>
                                    </div>
                                    {isMapped && (
                                        <span className="text-[9px] font-black uppercase italic text-blue-200 shrink-0">
                                            LISTED
                                        </span>
                                    )}
                                </button>
                            )
                        })}
                    </div>
                </ScrollArea>

                <div className="p-4 border-t border-slate-200 bg-white space-y-3 shrink-0">
                    {!isBlueprint && activeStation && (
                        <div className="flex items-center gap-3 bg-slate-50 p-3 rounded-xl border border-slate-100 h-[100px]">
                            <div className="bg-white p-1 rounded-lg border border-slate-200 shadow-sm shrink-0 h-full aspect-square flex items-center justify-center">
                                <QRCodeSVG
                                    id={`station-qr-${activeStation.id}`}
                                    value={`ligtas://station/${activeStation.station_code || activeStation.id}?name=${encodeURIComponent(activeStation.station_name || activeStation.location_name)}`}
                                    size={80}
                                    includeMargin={false}
                                />
                            </div>
                            <div className="flex-1 min-w-0 flex flex-col justify-between h-full py-0.5">
                                <div>
                                    <p className="text-[10px] font-black text-blue-600 uppercase tracking-widest leading-none">
                                        IDENTITY STICKER
                                    </p>
                                    <p className="text-[14px] font-black text-slate-900 truncate uppercase italic mt-1 leading-none">
                                        {activeStation.station_code}
                                    </p>
                                    <p className="text-[9px] font-bold text-slate-400 mt-1 uppercase leading-none opacity-60">
                                        {activeStation.location_name.replace(/_/g, ' ')}
                                    </p>
                                </div>
                                <Button 
                                    size="sm" 
                                    variant="outline"
                                    onClick={handleDownloadQR}
                                    className="h-7 border-slate-200 text-slate-600 font-bold text-[9px] uppercase tracking-widest gap-2 bg-white hover:bg-slate-50 transition-all active:scale-95"
                                >
                                    <Download className="h-3 w-3" />
                                    Download Label
                                </Button>
                            </div>
                        </div>
                    )}

                    {isBlueprint ? (
                         <div className="p-3 bg-blue-50 border border-blue-100 rounded-xl">
                            <p className="text-[10px] font-bold text-blue-600 uppercase leading-normal tracking-wide">
                                💡 Setup items first, then click "Confirm Blueprint" in the Registry sidebar to deploy.
                            </p>
                         </div>
                    ) : (
                        <Button
                            onClick={handleCommit}
                            disabled={!activeStation || isPending || !isDirty}
                            className={cn(
                                "w-full h-10 font-black text-[11px] uppercase tracking-widest rounded-xl gap-2 transition-all",
                                isDirty 
                                    ? "bg-blue-600 hover:bg-blue-700 text-white shadow-lg shadow-blue-200" 
                                    : "bg-slate-900 hover:bg-black text-white"
                            )}
                        >
                            {isPending
                                ? <Loader2 className="h-4 w-4 animate-spin" />
                                : isDirty ? <Save className="h-4 w-4 animate-bounce" /> : <Save className="h-4 w-4" />
                            }
                            {isPending ? 'Saving...' : isDirty ? 'Save Supply List' : 'Supply List Saved'}
                        </Button>
                    )}
                </div>
            </div>
        </div>
    )
}
