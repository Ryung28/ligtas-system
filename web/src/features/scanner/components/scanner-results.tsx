'use client'

import { Package, MapPin, AlertCircle, LayoutGrid, CheckCircle2 } from 'lucide-react'
import { Button } from '@/components/ui/button'
import { ScanResult } from '../types'
import { Badge } from '@/components/ui/badge'
import { useRouter } from 'next/navigation'

interface ScannerResultsProps {
    result: ScanResult | null;
    isResolving: boolean;
    onReturn?: (borrowerName: string) => void;
}

export function ScannerResults({ result, isResolving, onReturn }: ScannerResultsProps) {
    const router = useRouter()
    if (isResolving) {
        return (
            <div className="py-12 flex flex-col items-center justify-center space-y-4">
                <div className="h-8 w-8 border-4 border-slate-200 border-t-slate-900 rounded-full animate-spin" />
                <p className="text-[10px] text-slate-400 font-black uppercase tracking-widest">Resolving Payload</p>
            </div>
        )
    }

    if (!result) return null;

    if (result.error) {
        return (
            <div className="p-6 bg-red-50 border border-red-100 rounded-2xl flex flex-col items-center text-center space-y-3">
                <AlertCircle className="h-8 w-8 text-red-500" />
                <p className="text-xs font-bold text-red-900">{result.error}</p>
            </div>
        )
    }

    // 📦 ITEM VIEW
    if (result.item) {
        const item = result.item;
        return (
            <div className="space-y-4 animate-in fade-in slide-in-from-bottom-2 duration-300">
                <div className="bg-white border rounded-2xl p-4 shadow-sm relative overflow-hidden">
                    <div className="flex items-center justify-between">
                        <div className="flex items-center gap-3">
                            <div className="bg-slate-100 p-2 rounded-xl">
                                <Package className="h-5 w-5 text-slate-600" />
                            </div>
                            <div>
                                <h3 className="font-bold text-slate-900">{item.item_name}</h3>
                                <p className="text-[10px] text-slate-500 uppercase tracking-wider">{item.category}</p>
                            </div>
                        </div>
                        <div className="text-right">
                            <p className="text-[10px] text-slate-400 font-medium uppercase">In Stock</p>
                            <p className="text-xl font-bold text-slate-900">{item.stock_available}</p>
                        </div>
                    </div>
                </div>
            </div>
        )
    }

    // 🏗️ STATION VIEW (New Feature)
    if (result.station) {
        const stn = result.station;
        const totalItems = stn.manifest.length;
        const healthyItems = stn.manifest.filter(i => i.stock_available >= (i.target_stock || 1)).length;
        const readiness = totalItems > 0 ? Math.round((healthyItems / totalItems) * 100) : 0;

        return (
            <div className="space-y-4 animate-in fade-in slide-in-from-bottom-2 duration-300">
                <div className="bg-slate-900 text-white border rounded-2xl p-5 shadow-xl relative overflow-hidden">
                    <div className="absolute right-0 top-0 h-full w-24 bg-blue-600/10 skew-x-[30deg] translate-x-12" />
                    <div className="flex items-start justify-between relative z-10">
                        <div className="space-y-1">
                            <div className="flex items-center gap-2">
                                <MapPin className="h-4 w-4 text-blue-400" />
                                <span className="text-[10px] font-black uppercase tracking-widest text-slate-400">Tactical Hub</span>
                            </div>
                            <h3 className="text-lg font-black italic uppercase tracking-tight">{stn.name}</h3>
                        </div>
                        <div className="text-right">
                            <p className="text-[10px] font-black text-blue-400 uppercase tracking-widest mb-1">{readiness}% READY</p>
                            <div className="h-1.5 w-24 bg-slate-800 rounded-full overflow-hidden">
                                <div className="h-full bg-blue-500" style={{ width: `${readiness}%` }} />
                            </div>
                        </div>
                    </div>
                </div>

                <div className="space-y-2">
                    <h4 className="text-[10px] font-black text-slate-400 uppercase tracking-widest px-1">Critical Manifest</h4>
                    <div className="grid gap-2 max-h-48 overflow-y-auto pr-1">
                        {stn.manifest.map((item, i) => (
                            <div key={i} className="flex items-center justify-between bg-white border p-3 rounded-xl shadow-sm">
                                <div className="flex items-center gap-3">
                                    <div className={`h-2 w-2 rounded-full ${item.stock_available < (item.target_stock || 1) ? 'bg-orange-500' : 'bg-emerald-500'}`} />
                                    <div>
                                        <p className="text-xs font-bold text-slate-900 uppercase truncate max-w-[140px]">{item.item_name}</p>
                                        <p className="text-[9px] text-slate-400 font-bold tracking-tight">
                                            {item.stock_available} / {item.target_stock || item.stock_total} {item.unit}
                                        </p>
                                    </div>
                                </div>
                                <CheckCircle2 className={`h-4 w-4 ${item.stock_available >= (item.target_stock || 1) ? 'text-emerald-500' : 'text-slate-200'}`} />
                            </div>
                        ))}
                    </div>
                </div>

                <Button 
                    className="w-full bg-slate-900 hover:bg-slate-800 text-white rounded-xl h-11 font-black uppercase tracking-widest text-[10px] gap-2 shadow-lg"
                    onClick={() => {
                        router.push(`/dashboard/inventory/tactical-stations?id=${stn.id}`)
                    }}
                >
                    <LayoutGrid className="h-4 w-4" />
                    Open Deployment Hub
                </Button>
            </div>
        )
    }

    return null;
}
