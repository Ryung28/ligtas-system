'use client'

import { useState, useEffect } from "react"
import { useRouter } from "next/navigation"
import { Package, AlertCircle, LayoutGrid } from 'lucide-react'
import { Button } from '@/components/ui/button'
import { TacticalAssetImage } from '@/src/shared/ui/tactical-asset-image'
import { DirectBorrowSheet } from "@/src/features/inventory/components/direct-borrow-sheet"
import { cn } from "@/lib/utils"

interface ScannerResultsProps {
    result: {
        item?: any;
        station?: any;
        rawText?: string;
        error?: string;
    } | null;
    isResolving?: boolean;
    onReturn?: () => void;
}

export function ScannerResults({ result, isResolving, onReturn }: ScannerResultsProps) {
    const router = useRouter()
    
    const [selectedBorrowItem, setSelectedBorrowItem] = useState<any>(null)
    const [isBorrowSheetOpen, setIsBorrowSheetOpen] = useState(false)

    // 🧹 STATE SYNC: Clear internal selection if the parent scanner resets
    useEffect(() => {
        if (!result) {
            setSelectedBorrowItem(null)
            setIsBorrowSheetOpen(false)
        }
    }, [result])

    const handleOpenBorrow = (item: any) => {
        // Map polymorphic item properties to standard format for the sheet
        setSelectedBorrowItem({
            id: item.id || item.item_id,
            name: item.item_name,
            image_url: item.image_url,
            stock_available: item.stock_available,
            item_type: item.item_type || 'equipment'
        })
        setIsBorrowSheetOpen(true)
    }

    if (isResolving) {
        return (
            <div className="py-20 flex flex-col items-center justify-center space-y-6">
                <div className="h-10 w-10 border-4 border-slate-100 border-t-slate-900 rounded-full animate-spin" />
                <p className="text-[13px] text-slate-400 font-bold uppercase tracking-widest">Searching...</p>
            </div>
        )
    }

    if (!result) return null;

    if (result.error) {
        return (
            <div className="p-8 bg-red-50 border-y border-red-100 flex flex-col items-center text-center space-y-4">
                <div className="p-3 bg-white rounded-2xl shadow-sm">
                    <AlertCircle className="h-10 w-10 text-red-500" />
                </div>
                <p className="text-[15px] font-bold text-red-900">{result.error}</p>
            </div>
        )
    }

    // 🕊️ EMPTY / UNKNOWN STATE
    if (!result.item && !result.station) {
        return (
            <div className="p-8 text-center space-y-4">
                <div className="w-16 h-16 bg-slate-100 rounded-full flex items-center justify-center mx-auto">
                    <span className="text-2xl italic font-black text-slate-300">?</span>
                </div>
                <div>
                    <h3 className="font-black text-slate-950 uppercase italic tracking-tight">Unknown Identifier</h3>
                    <p className="text-[13px] text-slate-500 font-bold mt-1">This code does not map to a tactical resource.</p>
                </div>
                <div className="bg-slate-50 p-3 rounded-xl border border-slate-100 font-mono text-[11px] text-slate-400 break-all">
                    {result.rawText}
                </div>
            </div>
        )
    }

    // 📦 ITEM VIEW
    if (result.item) {
        const item = result.item;

        return (
            <div className="animate-in fade-in slide-in-from-bottom-4 duration-500">
                <div className="relative h-64 bg-slate-100 overflow-hidden border-b">
                    <TacticalAssetImage 
                        url={item.image_url} 
                        alt={item.item_name} 
                        size="full" 
                        className="object-cover"
                    />
                </div>
                
                <div className="p-6 space-y-6">
                    <div className="space-y-1">
                        <h3 className="text-[24px] font-black text-slate-950 leading-tight uppercase italic">{item.item_name}</h3>
                        <p className="text-[14px] text-slate-500 font-bold uppercase tracking-wide">{item.category}</p>
                    </div>

                    <div className="bg-slate-50 border border-slate-100 p-4 rounded-2xl flex items-center justify-between">
                        <span className="text-[13px] font-black text-slate-400 uppercase tracking-widest">Available to Borrow</span>
                        <span className="text-[20px] font-black text-slate-950">{item.stock_available}</span>
                    </div>

                    <Button 
                        className="w-full bg-slate-900 hover:bg-slate-800 text-white rounded-2xl h-14 font-black uppercase tracking-widest text-[13px] shadow-xl transition-all active:scale-[0.97] disabled:opacity-30"
                        onClick={() => handleOpenBorrow(item)}
                        disabled={item.stock_available <= 0}
                    >
                        {item.stock_available > 0 ? "Borrow This Equipment" : "Resource Depleted"}
                    </Button>
                </div>

                {selectedBorrowItem && (
                    <DirectBorrowSheet 
                        isOpen={isBorrowSheetOpen}
                        onOpenChange={setIsBorrowSheetOpen}
                        item={selectedBorrowItem}
                        onSuccess={() => onReturn?.()}
                    />
                )}
            </div>
        )
    }

    // 🏗️ STATION VIEW
    if (result.station) {
        const stn = result.station;

        return (
            <div className="animate-in fade-in slide-in-from-bottom-4 duration-500">
                <div className="relative h-48 bg-slate-100 overflow-hidden border-b">
                    <TacticalAssetImage 
                        url={stn.image_url} 
                        alt={stn.name} 
                        size="full" 
                        className="object-cover"
                    />
                </div>

                <div className="p-6 space-y-6">
                    <div className="border-b pb-4 border-slate-100">
                        <p className="text-[11px] font-black text-blue-600 uppercase tracking-[0.2em] mb-1">Equipment Hub</p>
                        <h3 className="text-[28px] font-black italic uppercase tracking-tight leading-none text-slate-950">{stn.name}</h3>
                    </div>

                    <div className="space-y-4">
                        <h4 className="text-[13px] font-black text-slate-400 uppercase tracking-widest px-1">Available Equipment</h4>
                        <div className="grid gap-3 max-h-[45vh] overflow-y-auto pr-1">
                            {stn.manifest.map((item: any, i: number) => {
                                const isOutOfStock = item.stock_available <= 0;
                                
                                return (
                                    <div 
                                        key={i} 
                                        className={cn(
                                            "w-full flex items-center justify-between bg-white border border-slate-100 p-3 rounded-2xl shadow-sm transition-all text-left group",
                                            isOutOfStock 
                                                ? "opacity-40 grayscale cursor-not-allowed" 
                                                : "active:scale-[0.98] hover:border-slate-200 cursor-pointer"
                                        )}
                                        onClick={() => !isOutOfStock && handleOpenBorrow(item)}
                                    >
                                        <div className="flex items-center gap-4 flex-1 min-w-0">
                                            <TacticalAssetImage 
                                                url={item.image_url} 
                                                alt={item.item_name} 
                                                size="sm" 
                                                className="rounded-xl border-slate-200"
                                            />
                                            <div className="flex-1 min-w-0">
                                                <p className="text-[15px] font-bold text-slate-900 uppercase break-words leading-tight group-hover:text-blue-600 transition-colors">
                                                    {item.item_name}
                                                </p>
                                                <p className={cn(
                                                    "text-[12px] font-bold mt-0.5",
                                                    isOutOfStock ? "text-red-500" : "text-slate-500"
                                                )}>
                                                    {isOutOfStock ? "Out of Stock" : `${item.stock_available} Available`}
                                                </p>
                                            </div>
                                        </div>
                                        {!isOutOfStock && (
                                            <div className="w-8 h-8 rounded-full bg-slate-50 flex items-center justify-center text-slate-400 group-hover:bg-blue-600 group-hover:text-white transition-all">
                                                <span className="font-black text-[18px] leading-none">+</span>
                                            </div>
                                        )}
                                    </div>
                                );
                            })}
                    </div>
                </div>
            </div>

                {selectedBorrowItem && (
                    <DirectBorrowSheet 
                        isOpen={isBorrowSheetOpen}
                        onOpenChange={setIsBorrowSheetOpen}
                        item={selectedBorrowItem}
                        onSuccess={() => onReturn?.()}
                    />
                )}
            </div>
        )
    }

    return null;
}
