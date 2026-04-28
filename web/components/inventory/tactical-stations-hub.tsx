'use client'

import { useState, useMemo } from 'react'
import { 
    LayoutGrid, 
    QrCode, 
    Printer, 
    ChevronRight, 
    ChevronDown,
    Package, 
    Box, 
    ArrowRight,
    Search,
    ShieldAlert,
    Info,
    FileText,
    Cross,
    Wrench,
    Shield,
    Grid3X3
} from 'lucide-react'
import { TacticalAssetImage } from '@/src/shared/ui/tactical-asset-image'
import { Button } from '@/components/ui/button'
import { Card, CardContent, CardHeader, CardTitle, CardDescription } from '@/components/ui/card'
import { Input } from '@/components/ui/input'
import { Badge } from '@/components/ui/badge'
import { QRCodeSVG } from 'qrcode.react'
import {
    Popover,
    PopoverContent,
    PopoverTrigger,
} from "@/components/ui/popover"
import { InventoryItem } from '@/lib/supabase'
import { cn } from '@/lib/utils'
import { isLowStock } from '@/lib/inventory-utils'
import useSWR from 'swr'
import { supabase } from '@/lib/supabase'

interface Station {
    id: number
    location_name: string
    station_name: string | null
    station_code: string | null
}

interface ManifestEntry {
    station_id: number
    item_id: number
}

interface TacticalStationsHubProps {
    items: InventoryItem[]
}

export function TacticalStationsHub({ items }: TacticalStationsHubProps) {
    const [searchQuery, setSearchQuery] = useState('')
    const [selectedStationId, setSelectedStationId] = useState<string | null>(null)
    const [printMode, setPrintMode] = useState<'POSTER' | 'LABELS' | 'CATALOG'>('POSTER')

    const { data: dbStations = [], isLoading: stationsLoading } = useSWR('storage_stations', async () => {
        const { data } = await supabase
            .from('storage_locations')
            .select('id, location_name, station_name, station_code')
            .not('station_code', 'is', null)
            .order('created_at', { ascending: true })
        return data as Station[]
    }, { revalidateOnMount: true, dedupingInterval: 2000 })

    const { data: globalManifest = [] } = useSWR('global_manifest', async () => {
        const { data } = await supabase
            .from('station_manifest')
            .select('station_id, item_id')
        return data as ManifestEntry[]
    }, { revalidateOnMount: true })

    // 📂 Group Inventory by Strict Manifest
    const stations = useMemo(() => {
        if (!dbStations.length) return []
        
        return dbStations.map(dbStn => {
            // Find which items are explicitly provisioned for THIS station
            const provisionedItemIds = globalManifest
                .filter(m => m.station_id === dbStn.id)
                .map(m => m.item_id)

            const activeProvisionedItems = items.filter(item => 
                provisionedItemIds.includes(item.id)
            )

            return {
                id: dbStn.station_code || `STN-${dbStn.id}`,
                db_id: dbStn.id,
                name: dbStn.station_name || dbStn.location_name,
                items: activeProvisionedItems,
                lowStockCount: activeProvisionedItems.filter(isLowStock).length
            }
        }).sort((a, b) => b.lowStockCount - a.lowStockCount || a.name.localeCompare(b.name))
    }, [items, dbStations, globalManifest])

    const filteredStations = stations.filter(s => 
        s.name.toLowerCase().includes(searchQuery.toLowerCase())
    )

    // Auto-select first station if none selected
    useMemo(() => {
        if (!selectedStationId && filteredStations.length > 0) {
            setSelectedStationId(filteredStations[0].id)
        }
    }, [filteredStations, selectedStationId])

    const getCategoryIcon = (category: string) => {
        const cat = (category || '').toLowerCase()
        if (cat.includes('medical')) return Cross
        if (cat.includes('tool')) return Wrench
        if (cat.includes('res')) return Shield
        if (cat.includes('ppe')) return Shield
        return Box
    }

    const activeStation = stations.find(s => s.id === selectedStationId)

    const triggerPrint = (mode: 'POSTER' | 'LABELS' | 'CATALOG') => {
        setPrintMode(mode)
        // Short timeout to ensure state update propagates to DOM before print dialog opens
        setTimeout(() => window.print(), 150)
    }

    return (
        <div className="flex bg-white h-[calc(100vh-64px)] overflow-hidden">
            {/* ── LEFT: STATION MASTER LIST ─────────────────────────────────── */}
            <aside className="w-80 border-r border-slate-100 flex flex-col bg-slate-50/30 shrink-0">
                <div className="p-3 border-b border-slate-100 bg-white">
                    <div className="relative">
                        <Search className="absolute left-3 top-1/2 -translate-y-1/2 h-3 w-3 text-slate-400" />
                        <Input 
                            placeholder="Find station..." 
                            className="pl-8 h-9 14in:h-10 bg-slate-50/50 border-none text-[11px] 14in:text-xs font-bold uppercase tracking-wider focus-visible:ring-0"
                            value={searchQuery}
                            onChange={(e) => setSearchQuery(e.target.value)}
                        />
                    </div>
                </div>
                <div className="flex-1 overflow-y-auto p-2 space-y-1">
                    {filteredStations.map((station) => (
                        <button
                            key={station.id}
                            onClick={() => setSelectedStationId(station.id)}
                            className={cn(
                                "w-full text-left p-2.5 rounded-lg transition-all border flex items-center gap-2.5",
                                selectedStationId === station.id
                                    ? "bg-blue-600 border-blue-700 text-white shadow-lg shadow-blue-100"
                                    : "bg-white border-transparent hover:bg-white hover:border-slate-200 text-slate-600"
                            )}
                        >
                                <div className="h-1.5 w-1.5 rounded-full shrink-0 bg-transparent" />
                            <div className="min-w-0 flex-1">
                                <p className={cn("text-xs 14in:text-sm font-heading font-black uppercase italic truncate tracking-tight leading-none", selectedStationId === station.id ? "text-white" : "text-slate-900")}>
                                    {station.name}
                                </p>
                                <p className={cn("text-[10px] 14in:text-xs font-mono font-black uppercase tracking-widest mt-1.5", selectedStationId === station.id ? "text-blue-200" : "text-slate-400")}>
                                    {station.items.length} ITM • {station.id.slice(0, 8)}
                                </p>
                            </div>
                            <ChevronRight className={cn("h-3 w-3 shrink-0 transition-transform", selectedStationId === station.id ? "rotate-90 text-white" : "text-slate-300")} />
                        </button>
                    ))}
                </div>
            </aside>

            {/* ── RIGHT: STATION DETAIL WORKSPACE ────────────────────────────── */}
            <main className="flex-1 flex flex-col bg-slate-50/20 overflow-hidden relative">
                {activeStation ? (
                    <>
                        {/* Header Actions */}
                        <div className="p-4 bg-white border-b border-slate-100 flex items-center justify-between shrink-0">
                            <div>
                                <h1 className="text-xl 14in:text-2xl 3xl:text-3xl font-heading font-[950] tracking-tighter text-slate-900 uppercase italic leading-none">
                                    {activeStation.name}
                                </h1>
                            </div>
                            <div className="flex items-center gap-2">
                                <Popover>
                                    <PopoverTrigger asChild>
                                        <Button 
                                            size="sm" 
                                            className="h-11 rounded-xl px-8 bg-blue-600 hover:bg-blue-700 text-white font-black text-xs 14in:text-sm uppercase tracking-[0.15em] gap-3 shadow-xl shadow-blue-200 group"
                                        >
                                            <Printer className="h-4.5 w-4.5" />
                                            Print Labels
                                            <ChevronDown className="h-4 w-4 ml-1 opacity-50 group-data-[state=open]:rotate-180 transition-transform" />
                                        </Button>
                                    </PopoverTrigger>
                                    <PopoverContent align="end" className="w-64 p-2 rounded-2xl border-slate-200 shadow-2xl">
                                        <div className="space-y-1">
                                            <button 
                                                onClick={() => triggerPrint('POSTER')}
                                                className="w-full flex items-center gap-3 p-3 rounded-xl hover:bg-blue-50 text-left transition-colors group"
                                            >
                                                <div className="h-9 w-9 rounded-lg bg-blue-50 flex items-center justify-center shrink-0 group-hover:bg-white border border-transparent group-hover:border-blue-100 transition-colors">
                                                    <QrCode className="h-5 w-5 text-blue-600" />
                                                </div>
                                                <div>
                                                    <p className="text-[11px] font-black uppercase tracking-wider text-slate-900">Large Sticker</p>
                                                    <p className="text-[10px] font-bold text-slate-400 uppercase tracking-tight">For doors or entrances</p>
                                                </div>
                                            </button>
                                            
                                            <button 
                                                onClick={() => triggerPrint('LABELS')}
                                                className="w-full flex items-center gap-3 p-3 rounded-xl hover:bg-blue-50 text-left transition-colors group"
                                            >
                                                <div className="h-9 w-9 rounded-lg bg-blue-50 flex items-center justify-center shrink-0 group-hover:bg-white border border-transparent group-hover:border-blue-100 transition-colors">
                                                    <Grid3X3 className="h-5 w-5 text-blue-600" />
                                                </div>
                                                <div>
                                                    <p className="text-[11px] font-black uppercase tracking-wider text-slate-900">Small Labels</p>
                                                    <p className="text-[10px] font-bold text-slate-400 uppercase tracking-tight">6 stickers for bins</p>
                                                </div>
                                            </button>

                                            <div className="h-px bg-slate-100 my-1" />

                                            <button 
                                                onClick={() => triggerPrint('CATALOG')}
                                                className="w-full flex items-center gap-3 p-3 rounded-xl hover:bg-emerald-50 text-left transition-colors group"
                                            >
                                                <div className="h-9 w-9 rounded-lg bg-emerald-50 flex items-center justify-center shrink-0 group-hover:bg-white border border-transparent group-hover:border-emerald-100 transition-colors">
                                                    <FileText className="h-5 w-5 text-emerald-600" />
                                                </div>
                                                <div>
                                                    <p className="text-[11px] font-black uppercase tracking-wider text-slate-900">Item Catalog</p>
                                                    <p className="text-[10px] font-bold text-slate-400 uppercase tracking-tight">Complete list for scanning</p>
                                                </div>
                                            </button>
                                        </div>
                                    </PopoverContent>
                                </Popover>
                            </div>
                        </div>

                        {/* Detail Content */}
                        <div className="flex-1 overflow-y-auto p-6 flex gap-6">
                            {/* Left: QR & Meta */}
                            <div className="w-60 shrink-0 space-y-4">
                                <Button 
                                    variant="outline" 
                                    className="w-full h-10 border-slate-200 text-slate-600 font-bold text-[10px] uppercase tracking-widest rounded-xl hover:bg-white hover:border-blue-400 gap-2 shadow-sm"
                                    onClick={() => triggerPrint('POSTER')}
                                >
                                    <Printer className="h-3.5 w-3.5 text-blue-600" />
                                    Print ID Label
                                </Button>
                                <div className="bg-white p-6 rounded-3xl border border-slate-100 shadow-xl flex flex-col items-center">
                                    <Badge className="bg-slate-900 text-white text-[10px] 14in:text-xs mb-4 px-3">DOOR LABEL</Badge>
                                    <div className="p-3 bg-slate-50 rounded-2xl border border-slate-100">
                                        <QRCodeSVG 
                                            value={JSON.stringify({ sid: activeStation.id, loc: activeStation.name })}
                                            size={160}
                                            level="M"
                                        />
                                    </div>
                                    <p className="mt-4 text-[10px] 14in:text-xs font-mono font-black text-slate-400 uppercase tracking-[0.2em]">
                                        ID: {activeStation.id}
                                    </p>
                                </div>

                                <div className="bg-slate-900 p-6 rounded-2xl text-white border border-slate-800 shadow-xl overflow-hidden relative">
                                    <div className="absolute right-0 top-0 h-full w-24 bg-blue-600/10 skew-x-[30deg] translate-x-12" />
                                    <ShieldAlert className="h-6 w-6 text-blue-500 mb-3" />
                                    <p className="text-xs 14in:text-sm font-black uppercase tracking-widest mb-2">How it works</p>
                                    <p className="text-slate-400 text-[11px] 14in:text-xs leading-relaxed font-medium">
                                        Scanning this sticker instantly shows live stock updates on mobile. It allows responders to find critical items without opening every drawer.
                                    </p>
                                </div>
                            </div>

                            {/* Right: Full Item Table */}
                            <div className="flex-1 bg-white rounded-3xl border border-slate-100 shadow-xl overflow-hidden flex flex-col">
                                <div className="p-0 overflow-auto flex-1">
                                    <table className="w-full text-left">
                                        <thead className="sticky top-0 bg-white border-b border-slate-50 z-10">
                                            <tr>
                                                <th className="px-6 py-4 text-[11px] 14in:text-xs font-black text-slate-400 uppercase tracking-widest">Item Name</th>
                                                <th className="px-6 py-4 text-[11px] 14in:text-xs font-black text-slate-400 uppercase tracking-widest text-right">Qty</th>
                                                <th className="px-6 py-4 text-[11px] 14in:text-xs font-black text-slate-400 uppercase tracking-widest text-right">Status</th>
                                            </tr>
                                        </thead>
                                        <tbody className="divide-y divide-slate-50">
                                            {activeStation.items.map((item, idx) => (
                                                <tr key={idx} className="group hover:bg-slate-50/50 transition-colors">
                                                    <td className="px-6 py-5">
                                                        <div className="flex items-center gap-3.5">
                                                            <TacticalAssetImage 
                                                                url={item.image_url} 
                                                                alt={item.item_name}
                                                                size="sm"
                                                                className="rounded-lg shadow-sm border border-slate-100"
                                                            />
                                                            <div className="flex flex-col min-w-0">
                                                                <span className="text-sm 14in:text-base font-bold text-slate-700 capitalize leading-tight">{item.item_name}</span>
                                                                <div className="flex items-center gap-1.5 mt-1">
                                                                    {(() => {
                                                                        const CategoryIcon = getCategoryIcon(item.category)
                                                                        return <CategoryIcon className="h-3 w-3 text-slate-300" />
                                                                    })()}
                                                                    <span className="text-[11px] font-bold text-slate-400 uppercase tracking-tight">{item.category || 'Uncategorized'}</span>
                                                                </div>
                                                            </div>
                                                        </div>
                                                    </td>
                                                    <td className="px-6 py-4 text-right">
                                                        <div className="flex flex-col items-end">
                                                            <span className="text-sm 14in:text-base font-black text-slate-900 tabular-nums leading-none">
                                                                {item.stock_available}
                                                                <span className="text-slate-400 font-medium mx-1">/</span>
                                                                {item.target_stock > 0 ? item.target_stock : item.stock_total || 0}
                                                            </span>
                                                            <span className="text-[9px] font-black text-slate-400 uppercase tracking-tighter mt-1">
                                                                STOCK LEVEL
                                                            </span>
                                                        </div>
                                                    </td>
                                                    <td className="px-6 py-4 text-right">
                                                        <div className="flex justify-end">
                                                            {isLowStock(item) ? (
                                                                <div className="h-1.5 w-1.5 rounded-full bg-orange-500 shadow-lg shadow-orange-200" />
                                                            ) : (
                                                                <div className="h-1.5 w-1.5 rounded-full bg-emerald-500 shadow-lg shadow-emerald-100" />
                                                            )}
                                                        </div>
                                                    </td>
                                                </tr>
                                            ))}
                                        </tbody>
                                    </table>
                                </div>
                            </div>
                        </div>
                    </>
                ) : (
                    <div className="flex-1 flex flex-col items-center justify-center text-slate-300">
                        <LayoutGrid className="h-12 w-12 mb-4 opacity-20" />
                        <p className="text-[12px] font-black uppercase tracking-[0.2em]">Select Station to Inspect</p>
                    </div>
                )}
            </main>

            {/* 🖨️ DYNAMIC PRINT SYSTEM */}
            {activeStation && (
                <div id="tactical-print-root" className="hidden print:flex fixed inset-0 bg-white p-0 flex-col overflow-visible z-[99999]">
                    <style dangerouslySetInnerHTML={{ __html: `
                        @media print {
                            @page { 
                                size: ${printMode === 'CATALOG' ? 'A4 landscape' : 'A4 portrait'}; 
                                margin: 10mm; 
                            }
                            body * { visibility: hidden !important; }
                            #tactical-print-root, #tactical-print-root * { visibility: visible !important; }
                            #tactical-print-root { 
                                position: fixed; 
                                left: 0; 
                                top: 0; 
                                width: 100vw; 
                                height: 100vh; 
                                background: white;
                                display: flex !important;
                                padding: 0 !important;
                                margin: 0 !important;
                            }
                            
                            /* High Density Catalog Grid */
                            .catalog-grid {
                                display: grid;
                                grid-template-columns: repeat(5, 1fr);
                                gap: 4mm;
                                width: 100%;
                            }
                            .catalog-card {
                                border: 1.5px solid #e2e8f0;
                                border-radius: 8px;
                                padding: 3mm;
                                display: flex;
                                flex-direction: column;
                                align-items: center;
                                text-align: center;
                                break-inside: avoid;
                            }
                            
                            /* 6x Label Grid */
                            .label-grid {
                                display: grid;
                                grid-template-columns: repeat(2, 1fr);
                                grid-template-rows: repeat(3, 1fr);
                                gap: 10mm;
                                width: 100%;
                                height: 100%;
                            }
                            .station-sticker {
                                border: 3px solid #0f172a;
                                border-radius: 30px;
                                padding: 8mm;
                                display: flex;
                                flex-direction: column;
                                align-items: center;
                                justify-content: center;
                                gap: 4mm;
                            }
                        }
                    `}} />
                    
                    {/* MODE 1: STATION POSTER (1x Large) */}
                    {printMode === 'POSTER' && (
                        <div className="flex-1 flex flex-col items-center justify-center p-12">
                            <p className="text-4xl font-heading font-black uppercase italic mb-8 tracking-tighter text-slate-900">
                                {activeStation.name.replace(/Station/gi, '').replace(/^The\s+/i, '').trim()}
                            </p>
                            <div className="border-[12px] border-slate-900 p-8 rounded-[40px] bg-white shadow-sm">
                                <QRCodeSVG 
                                    value={JSON.stringify({ 
                                        protocol: 'resqtrack',
                                        version: '1.0',
                                        type: 'station',
                                        id: activeStation.db_id,
                                        code: activeStation.id
                                    })}
                                    size={450}
                                    level="H"
                                />
                            </div>
                            <div className="mt-12 flex flex-col items-center gap-2">
                                <div className="h-px w-64 bg-slate-200 mb-6" />
                                <p className="text-2xl font-heading font-bold text-slate-400 uppercase tracking-widest">
                                    Scan to check items
                                </p>
                            </div>
                        </div>
                    )}

                    {/* MODE 2: LABEL SHEET (6x Medium) */}
                    {printMode === 'LABELS' && (
                        <div className="label-grid p-4">
                            {[...Array(6)].map((_, i) => (
                                <div key={i} className="station-sticker">
                                    <QRCodeSVG 
                                        value={JSON.stringify({ 
                                            protocol: 'resqtrack',
                                            type: 'station',
                                            id: activeStation.db_id,
                                            code: activeStation.id
                                        })}
                                        size={180}
                                        level="H"
                                    />
                                    <div className="text-center">
                                        <p className="text-[10px] font-black text-blue-600 uppercase tracking-[0.2em] mb-1">Scan QR</p>
                                        <p className="text-xl font-black text-slate-900 uppercase italic tracking-tighter leading-none">
                                            {activeStation.name.replace(/Station/gi, '').replace(/^The\s+/i, '').trim()}
                                        </p>
                                    </div>
                                </div>
                            ))}
                        </div>
                    )}

                    {/* MODE 3: EQUIPMENT CATALOG (Grid of Items) */}
                    {printMode === 'CATALOG' && (
                        <div className="w-full p-6">
                            <div className="flex items-center justify-between border-b-[3px] border-slate-900 pb-6 mb-8">
                                <div>
                                    <p className="text-[10px] font-black text-blue-600 uppercase tracking-[0.4em] mb-1">EQUIPMENT MANIFEST</p>
                                    <h1 className="text-4xl font-heading font-[950] text-slate-900 uppercase italic tracking-tighter">{activeStation.name}</h1>
                                </div>
                                <div className="text-right">
                                    <p className="text-[10px] font-black text-slate-400 uppercase tracking-widest">STATION CODE</p>
                                    <p className="text-2xl font-mono font-black text-slate-900">{activeStation.id}</p>
                                </div>
                            </div>

                            {/* Group items by category */}
                            {Array.from(new Set(activeStation.items.map(i => i.category || 'General'))).sort().map(category => (
                                <div key={category} className="mb-10 break-inside-avoid">
                                    <div className="flex items-center gap-4 mb-4">
                                        <h2 className="text-xs font-black uppercase tracking-[0.2em] text-slate-900 shrink-0">{category}</h2>
                                        <div className="h-px flex-1 bg-slate-100" />
                                    </div>
                                    <div className="catalog-grid">
                                        {activeStation.items.filter(i => (i.category || 'General') === category).map(item => (
                                            <div key={item.id} className="catalog-card">
                                                <div className="bg-white p-1 rounded-lg border border-slate-100 mb-3">
                                                    <QRCodeSVG 
                                                        value={`resqtrack://item/${item.id}?v=2.0&a=view&name=${encodeURIComponent(item.item_name || 'Unknown Item')}`}
                                                        size={110}
                                                        level="H"
                                                    />
                                                </div>
                                                <p className="text-[10px] font-black text-slate-800 uppercase tracking-tight leading-[1.1] mb-2 h-7 line-clamp-2">
                                                    {item.item_name}
                                                </p>
                                                <div className="w-full border-t border-slate-100 pt-1.5">
                                                    <p className="text-[8px] font-mono font-bold text-slate-400 truncate uppercase">
                                                        {item.serial_number || `REF-${item.id.toString().padStart(4, '0')}`}
                                                    </p>
                                                </div>
                                            </div>
                                        ))}
                                    </div>
                                </div>
                            ))}
                        </div>
                    )}
                </div>
            )}
        </div>
    )
}
