'use client'

import { useState } from 'react'
import { ShieldCheck, Box, X } from 'lucide-react'
import { Button } from '@/components/ui/button'
import { Card } from '@/components/ui/card'
import { Dialog, DialogContent, DialogHeader, DialogTitle } from '@/components/ui/dialog'
import useSWR from 'swr'
import { createBrowserClient } from '@supabase/ssr'
import Image from 'next/image'
import { InventoryDialogV2 } from '@/components/inventory/inventory-dialog-v2'

const supabase = createBrowserClient(
    process.env.NEXT_PUBLIC_SUPABASE_URL!,
    process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY!
)

/**
 * 🛡️ COMPACT TRIAGE STRIP (ResQTrack Platinum v4.1)
 * High-density, simple-language component for inventory strategy.
 * Focuses on speed and visual verification without over-engineering.
 */
export function StrategyTriageBar() {
    const [isHidden, setIsHidden] = useState(false)
    const [isPreviewOpen, setIsPreviewOpen] = useState(false)
    const [isImagePreviewOpen, setIsImagePreviewOpen] = useState(false)
    const [openMode, setOpenMode] = useState<'review' | 'restock'>('review')

    const { data: triageItems = [], mutate } = useSWR('strategic_triage_v3', async () => {
        const { data } = await supabase
            .from('inventory')
            .select('*')
            .eq('stock_available', 1)
            .eq('stock_total', 1)
            .eq('restock_alert_enabled', false)
            .is('deleted_at', null)
            .limit(5) // Get a few to handle rapid triage
        return data || []
    }, { refreshInterval: 30000 })

    if (triageItems.length === 0 || isHidden) return null
    const item = triageItems[0]
    const moreCount = Math.max(0, triageItems.length - 1)
    const isRestockEnabled = item.restock_alert_enabled !== false
    const imageSrc = item.image_url
        ? item.image_url.startsWith('http')
            ? item.image_url
            : `${process.env.NEXT_PUBLIC_SUPABASE_URL}/storage/v1/object/public/item-images/${item.image_url}`
        : null

    return (
        <>
        <div className="mb-6 animate-in slide-in-from-top-2 duration-500">
            <Card className="bg-white border-2 border-blue-600/10 shadow-lg rounded-2xl overflow-hidden">
                <div className="p-3 md:p-4 space-y-3">
                    <div className="flex items-start justify-between gap-3">
                        {/* Identity block */}
                        <div className="flex items-center gap-3 min-w-0">
                        <div className="h-12 w-12 bg-slate-50 rounded-xl border border-slate-100 overflow-hidden relative shadow-sm cursor-pointer hover:ring-2 hover:ring-blue-600/20 transition-all" onClick={() => setIsImagePreviewOpen(true)}>
                            {imageSrc ? (
                                <Image 
                                    src={imageSrc}
                                    alt="" fill className="object-cover"
                                />
                            ) : (
                                <Box className="h-full w-full p-3 text-slate-300" />
                            )}
                        </div>
                            <div className="space-y-0.5 cursor-pointer group min-w-0" onClick={() => {
                                setOpenMode('review')
                                setIsPreviewOpen(true)
                            }}>
                            <div className="text-[10px] font-black text-blue-600 uppercase tracking-widest group-hover:text-blue-700 transition-colors">System Check</div>
                                <div className="text-sm font-black text-slate-900 uppercase italic leading-none group-hover:underline decoration-blue-200 underline-offset-4 truncate">
                                    {item.item_name}
                                </div>
                                <p className="text-[11px] font-semibold text-slate-500">
                                    Single-unit item detected. Review policy in Inventory.
                                </p>
                            </div>
                        </div>
                        <button onClick={() => setIsHidden(true)} className="text-slate-300 hover:text-slate-500 transition-colors p-1 shrink-0">
                            <X className="h-4 w-4" />
                        </button>
                    </div>

                    {/* Badges + actions row */}
                    <div className="flex flex-wrap items-center gap-2">
                        <span className="inline-flex items-center rounded-lg bg-slate-900 text-white text-[10px] font-black uppercase tracking-widest h-9 px-4">
                            <ShieldCheck className="h-3 w-3 mr-2" />
                            Only 1 unit
                        </span>
                        {!isRestockEnabled ? (
                            <Button
                                onClick={() => {
                                    setOpenMode('restock')
                                    setIsPreviewOpen(true)
                                }}
                                variant="outline"
                                className="border-emerald-200 hover:border-emerald-600 hover:bg-emerald-50 text-emerald-700 text-[10px] font-black uppercase tracking-widest h-9 px-4 rounded-lg transition-all active:scale-95"
                            >
                                Make Restockable
                            </Button>
                        ) : (
                            <span className="inline-flex items-center rounded-lg border border-emerald-200 text-emerald-700 bg-emerald-50 text-[10px] font-black uppercase tracking-widest h-9 px-4">
                                Restockable
                            </span>
                        )}
                        <Button
                            onClick={() => {
                                setOpenMode('review')
                                setIsPreviewOpen(true)
                            }}
                            variant="outline"
                            className="border-blue-200 hover:border-blue-600 hover:bg-blue-50 text-blue-700 text-[10px] font-black uppercase tracking-widest h-9 px-4 rounded-lg transition-all active:scale-95"
                        >
                            Review in Inventory
                        </Button>
                        {moreCount > 0 && (
                            <span className="inline-flex items-center rounded-lg border border-slate-200 text-slate-600 bg-slate-50 text-[10px] font-bold uppercase tracking-widest h-9 px-3">
                                +{moreCount} more
                            </span>
                        )}
                    </div>
                </div>
            </Card>
        </div>

        <InventoryDialogV2
            key={item.id}
            isOpen={isPreviewOpen}
            existingItem={item as any}
            focusRestockPolicy={openMode === 'restock'}
            showRestockWarningOnOpen={openMode === 'restock'}
            onOpenChange={(open) => {
                setIsPreviewOpen(open)
                if (!open) setOpenMode('review')
            }}
            onSuccess={() => {
                setIsPreviewOpen(false);
                setOpenMode('review')
                mutate();
            }}
        />
        <Dialog open={isImagePreviewOpen} onOpenChange={setIsImagePreviewOpen}>
            <DialogContent className="max-w-xl p-2 bg-white border-slate-200">
                <DialogHeader className="sr-only">
                    <DialogTitle>Image preview for {item.item_name}</DialogTitle>
                </DialogHeader>
                <div className="relative w-full aspect-square rounded-lg overflow-hidden bg-slate-50">
                    {imageSrc ? (
                        <Image src={imageSrc} alt={item.item_name || 'Item image'} fill className="object-contain" />
                    ) : (
                        <div className="h-full w-full flex items-center justify-center text-slate-400 text-sm font-semibold">
                            No image available
                        </div>
                    )}
                </div>
            </DialogContent>
        </Dialog>
        </>
    )
}
