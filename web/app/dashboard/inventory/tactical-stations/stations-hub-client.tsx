'use client'

import { useState } from 'react'
import { ArrowLeft, Target } from 'lucide-react'
import { Button } from '@/components/ui/button'
import Link from 'next/link'
import { useSearchParams } from 'next/navigation'
import { StationRegistry } from '@/src/features/tactical-stations/components/station-registry'
import { ManifestWorkbench } from '@/src/features/tactical-stations/components/manifest-workbench'
import type { Station, InventoryPickerItem } from '@/src/features/tactical-stations/types'

interface StationsHubClientProps {
    stations: Station[]
    inventoryItems: InventoryPickerItem[]
}

export function StationsHubClient({ stations, inventoryItems }: StationsHubClientProps) {
    const searchParams = useSearchParams()
    const urlStationId = searchParams.get('id')

    const [stationList, setStationList] = useState<Station[]>(stations)
    const [isDirty, setIsDirty] = useState(false)
    const [activeStationId, setActiveStationId] = useState<number | null>(() => {
        if (urlStationId) {
            const id = parseInt(urlStationId)
            if (!isNaN(id) && stations.find(s => s.id === id)) return id
        }
        return stations[0]?.id ?? null
    })
    const [isCreating, setIsCreating] = useState(false)
    const [blueprintItems, setBlueprintItems] = useState<number[]>([])

    // Called by StationRegistry when a station is selected OR created
    function handleSelectStation(station: Station) {
        if (isDirty || (isCreating && blueprintItems.length > 0)) {
            const confirmed = window.confirm('You have unsaved changes. Discard them?')
            if (!confirmed) return
        }

        setIsCreating(false)
        setBlueprintItems([])

        if (!stationList.find(s => s.id === station.id)) {
            setStationList(prev => [station, ...prev])
        }
        setActiveStationId(station.id)
    }

    return (
        <div className="fixed inset-0 z-[100] flex flex-col bg-[#fdfdfd] overflow-hidden select-none">
            {/* TOP NAV */}
            <header className="h-12 px-4 bg-slate-900 text-white flex items-center justify-between shrink-0">
                <div className="flex items-center gap-4">
                    <Link href="/dashboard/inventory">
                        <Button
                            variant="ghost"
                            size="sm"
                            className="h-8 text-slate-400 hover:text-white px-2 font-bold text-[11px] uppercase tracking-wider"
                        >
                            <ArrowLeft className="h-3.5 w-3.5 mr-1.5" />
                            EXIT
                        </Button>
                    </Link>
                    <div className="h-4 w-px bg-slate-700" />
                    <div className="flex items-center gap-2">
                        <Target className="h-4 w-4 text-blue-500" />
                        <h1 className="text-[12px] font-black tracking-widest uppercase italic">
                            Storage Station Hub
                        </h1>
                    </div>
                </div>
                <div className="flex items-center gap-2 px-3 py-1 bg-slate-800 rounded-md">
                    <div className="h-2 w-2 rounded-full bg-emerald-500 animate-pulse" />
                    <span className="text-[10px] font-bold text-slate-300 uppercase tracking-widest">
                        {stationList.length} Stations Deployed
                    </span>
                </div>
            </header>

            <div className="flex-1 flex overflow-hidden">
                {/* LEFT: REGISTRY */}
                <aside className="w-[220px] bg-slate-50 border-r border-slate-200 flex flex-col shrink-0">
                    <StationRegistry
                        stations={stationList}
                        activeStationId={isCreating ? null : activeStationId}
                        onSelect={handleSelectStation}
                        isCreating={isCreating}
                        onToggleCreate={() => {
                            if (isDirty) {
                                if (!window.confirm('Discard unsaved manifest changes?')) return
                            }
                            setIsCreating(!isCreating)
                            if (!isCreating) setActiveStationId(null)
                        }}
                        blueprintItems={blueprintItems}
                    />
                </aside>

                {/* CENTER + RIGHT: WORKBENCH */}
                <main className="flex-1 flex overflow-hidden">
                    <ManifestWorkbench
                        key={isCreating ? 'blueprint' : activeStationId ?? 'none'}
                        stations={stationList}
                        inventoryItems={inventoryItems}
                        activeStationId={isCreating ? null : activeStationId}
                        isBlueprint={isCreating}
                        blueprintItems={isCreating ? blueprintItems : []}
                        onBlueprintChange={setBlueprintItems}
                        onStationChange={setActiveStationId}
                        onDirtyChange={setIsDirty}
                    />
                </main>
            </div>
        </div>
    )
}
