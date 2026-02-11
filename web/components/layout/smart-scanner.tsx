'use client'

import React, { useState, useEffect, useRef } from 'react'
import {
    Dialog,
    DialogContent,
    DialogHeader,
    DialogTitle,
    DialogTrigger,
    DialogFooter,
} from '@/components/ui/dialog'
import { Button } from '@/components/ui/button'
import { Input } from '@/components/ui/input'
import { QrCode, Search, RotateCcw, Package, User, CheckCircle2, AlertTriangle, ShieldCheck, Camera, X } from 'lucide-react'
import { useBorrowLogs } from '@/hooks/use-borrow-logs'
import { useInventory } from '@/hooks/use-inventory'
import { returnItem } from '@/app/actions/inventory'
import { toast } from 'sonner'
import { Badge } from '@/components/ui/badge'
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from '@/components/ui/select'
import { Html5Qrcode } from 'html5-qrcode'

export function SmartScanner() {
    const [open, setOpen] = useState(false)
    const [scanValue, setScanValue] = useState('')
    const { logs, refresh: refreshLogs } = useBorrowLogs()
    const { inventory, refresh: refreshInventory } = useInventory()

    // Camera State
    const [isCameraActive, setIsCameraActive] = useState(false)
    const scannerRef = useRef<Html5Qrcode | null>(null)
    const scannerRegionId = "qr-reader"

    // UI State
    const [foundItem, setFoundItem] = useState<any>(null)
    const [activeBorrowers, setActiveBorrowers] = useState<any[]>([])

    // Return Flow State
    const [returningLog, setReturningLog] = useState<any>(null)
    const [returnCondition, setReturnCondition] = useState('Good')
    const [returnNotes, setReturnNotes] = useState('')
    const [isProcessing, setIsProcessing] = useState(false)

    // Cleanup camera on close
    const stopScanner = async () => {
        if (scannerRef.current && scannerRef.current.isScanning) {
            try {
                await scannerRef.current.stop()
                scannerRef.current = null
                setIsCameraActive(false)
            } catch (err) {
                console.error("Failed to stop scanner", err)
            }
        }
    }

    const startScanner = async () => {
        try {
            const scanner = new Html5Qrcode(scannerRegionId)
            scannerRef.current = scanner
            setIsCameraActive(true)

            await scanner.start(
                { facingMode: "environment" },
                {
                    fps: 10,
                    qrbox: { width: 250, height: 250 },
                },
                (decodedText) => {
                    setScanValue(decodedText)
                    // Visual feedback
                    const audio = new Audio('https://assets.mixkit.co/active_storage/sfx/2571/2571-preview.mp3')
                    audio.play().catch(() => { })
                    stopScanner()
                },
                () => { } // Continuous scan error (ignored)
            )
        } catch (err) {
            console.error("Scanner start error", err)
            toast.error("Could not start camera. Check permissions.")
            setIsCameraActive(false)
        }
    }

    // CORE LOGIC: Stabilized Discovery
    useEffect(() => {
        const searchItem = () => {
            if (!scanValue) {
                setFoundItem(null)
                setActiveBorrowers([])
                return
            }

            let itemId: number | null = null
            try {
                if (scanValue.startsWith('{')) {
                    const data = JSON.parse(scanValue)
                    itemId = data.itemId
                } else {
                    itemId = parseInt(scanValue)
                }
            } catch (e) { }

            const item = inventory.find(i =>
                i.id === itemId ||
                i.item_name.toLowerCase() === scanValue.toLowerCase() ||
                (scanValue.length > 3 && i.item_name.toLowerCase().includes(scanValue.toLowerCase()))
            )

            if (item) {
                // Only update if it's a different item to prevent loops
                if (!foundItem || foundItem.id !== item.id) {
                    setFoundItem(item)
                    setActiveBorrowers((item as any).active_borrows || [])
                }
            } else {
                if (foundItem) {
                    setFoundItem(null)
                    setActiveBorrowers([])
                }
            }
        }

        searchItem()
    }, [scanValue, inventory, foundItem]) // Added foundItem to guard against unnecessary updates

    const startReturn = (borrowerName: string) => {
        const log = logs.find(l =>
            l.inventory_id === foundItem.id &&
            l.borrower_name === borrowerName &&
            l.status === 'borrowed'
        )
        if (log) {
            setReturningLog(log)
            setReturnCondition('Good')
            setReturnNotes('')
        } else {
            toast.error('Could not find active borrow record.')
        }
    }

    const confirmReturn = async () => {
        if (!returningLog) return

        try {
            setIsProcessing(true)
            const res = await returnItem(returningLog.id, returnCondition, returnNotes)
            if (res.success) {
                toast.success(`Successfully returned ${foundItem.item_name}`)
                setReturningLog(null)
                setScanValue('')
                setOpen(false)
                refreshLogs()
                refreshInventory()
            } else {
                toast.error(res.error)
            }
        } catch (error) {
            toast.error('Failed to process return')
        } finally {
            setIsProcessing(false)
        }
    }

    return (
        <Dialog open={open} onOpenChange={(val) => {
            if (!val) {
                stopScanner()
                setReturningLog(null)
                setScanValue('')
            }
            setOpen(val)
        }}>
            <DialogTrigger asChild>
                <Button variant="outline" className="gap-2 bg-blue-600 text-white border-blue-600 hover:bg-blue-700 hover:text-white shadow-md rounded-xl h-10 ring-offset-2 ring-blue-500/20 active:scale-95 transition-all">
                    <QrCode className="h-4 w-4" />
                    <span className="hidden sm:inline text-xs font-bold uppercase tracking-wider">Smart Scan</span>
                </Button>
            </DialogTrigger>

            <DialogContent className="sm:max-w-md border-0 shadow-2xl rounded-3xl p-0 overflow-hidden bg-white max-h-[90vh] flex flex-col">
                {!returningLog ? (
                    <>
                        <DialogHeader className="p-6 bg-gray-50 border-b border-gray-100 flex-shrink-0">
                            <DialogTitle className="flex items-center justify-between">
                                <div className="flex items-center gap-2">
                                    <div className="p-2 bg-blue-100 rounded-lg">
                                        <QrCode className="h-5 w-5 text-blue-600" />
                                    </div>
                                    <span className="font-black uppercase tracking-tighter text-blue-900">Smart Scanner</span>
                                </div>
                                {!isCameraActive && (
                                    <Button variant="ghost" size="sm" onClick={startScanner} className="h-8 px-3 rounded-lg bg-blue-50 text-blue-700 font-bold text-[10px] uppercase tracking-widest gap-2">
                                        <Camera className="h-3 w-3" /> Start Camera
                                    </Button>
                                )}
                            </DialogTitle>
                        </DialogHeader>

                        <div className="flex-1 overflow-y-auto p-0">
                            {/* CAMERA AREA */}
                            <div className="relative aspect-square sm:aspect-video bg-gray-900 overflow-hidden group">
                                <div id={scannerRegionId} className="w-full h-full object-cover" />

                                {!isCameraActive && (
                                    <div className="absolute inset-0 flex flex-col items-center justify-center bg-gray-900/40 backdrop-blur-sm transition-all">
                                        <div className="w-16 h-16 rounded-full bg-white/10 flex items-center justify-center mb-4 border border-white/20">
                                            <Camera className="h-8 w-8 text-white/50" />
                                        </div>
                                        <Button
                                            onClick={startScanner}
                                            className="bg-white text-gray-900 hover:bg-gray-100 font-black uppercase tracking-widest text-[10px] h-10 px-8 rounded-full shadow-xl"
                                        >
                                            Activate Camera
                                        </Button>
                                    </div>
                                )}

                                {isCameraActive && (
                                    <div className="absolute inset-0 pointer-events-none">
                                        {/* Viewfinder corners */}
                                        <div className="absolute top-1/2 left-1/2 -translate-x-1/2 -translate-y-1/2 w-48 h-48 border-2 border-white/20 rounded-3xl overflow-hidden">
                                            <div className="absolute top-0 left-0 w-8 h-8 border-t-4 border-l-4 border-blue-500" />
                                            <div className="absolute top-0 right-0 w-8 h-8 border-t-4 border-r-4 border-blue-500" />
                                            <div className="absolute bottom-0 left-0 w-8 h-8 border-b-4 border-l-4 border-blue-500" />
                                            <div className="absolute bottom-0 right-0 w-8 h-8 border-b-4 border-r-4 border-blue-500" />
                                            <div className="absolute top-0 left-0 w-full h-1 bg-gradient-to-b from-blue-500 to-transparent animate-scan" style={{ top: '0%' }} id="scan-line" />
                                        </div>
                                    </div>
                                )}
                            </div>

                            <div className="p-6 space-y-6">
                                <div className="relative">
                                    <Search className="absolute left-3 top-1/2 -translate-y-1/2 h-4 w-4 text-gray-400" />
                                    <Input
                                        placeholder="Or type Item Name / ID..."
                                        className="pl-10 h-14 bg-white rounded-2xl border-gray-100 shadow-inner ring-offset-blue-600 focus-visible:ring-blue-600 font-bold"
                                        value={scanValue}
                                        onChange={(e) => setScanValue(e.target.value)}
                                    />
                                    {scanValue && (
                                        <button
                                            onClick={() => setScanValue('')}
                                            className="absolute right-3 top-1/2 -translate-y-1/2 p-1 hover:bg-gray-100 rounded-full text-gray-400"
                                        >
                                            <X className="h-4 w-4" />
                                        </button>
                                    )}
                                </div>

                                {foundItem ? (
                                    <div className="space-y-4 animate-in fade-in slide-in-from-bottom-2 duration-300">
                                        <div className="bg-gradient-to-br from-blue-600 to-blue-800 rounded-3xl p-5 text-white shadow-xl shadow-blue-100 relative overflow-hidden">
                                            <div className="absolute -right-4 -bottom-4 opacity-10 rotate-12">
                                                <Package className="h-32 w-32" />
                                            </div>
                                            <div className="flex items-center justify-between relative z-10">
                                                <div className="flex items-center gap-4">
                                                    <div className="bg-white/20 p-3 rounded-2xl backdrop-blur-md">
                                                        <Package className="h-6 w-6" />
                                                    </div>
                                                    <div>
                                                        <h3 className="font-black text-lg leading-tight uppercase tracking-tight">{foundItem.item_name}</h3>
                                                        <p className="text-[10px] opacity-70 font-black uppercase tracking-widest">{foundItem.category}</p>
                                                    </div>
                                                </div>
                                                <div className="text-right">
                                                    <p className="text-[10px] opacity-70 font-black uppercase tracking-widest">Available</p>
                                                    <p className="text-3xl font-black leading-none">{foundItem.stock_available}</p>
                                                </div>
                                            </div>
                                        </div>

                                        <div className="space-y-3">
                                            <h4 className="text-[10px] font-black text-gray-400 uppercase tracking-[0.2em] px-1">Field Holdings</h4>
                                            {activeBorrowers.length === 0 ? (
                                                <div className="bg-green-50 rounded-2xl p-8 border border-green-100 text-center">
                                                    <div className="inline-flex p-3 bg-green-100 rounded-full mb-3">
                                                        <ShieldCheck className="h-6 w-6 text-green-600" />
                                                    </div>
                                                    <p className="text-sm font-black text-green-800 uppercase tracking-tight">Full Storage</p>
                                                    <p className="text-[10px] text-green-600/70 font-bold uppercase tracking-widest mt-1">Item is 100% accounted for.</p>
                                                </div>
                                            ) : (
                                                <div className="grid gap-3">
                                                    {activeBorrowers.map((b, i) => (
                                                        <div key={i} className="flex items-center justify-between bg-white border border-gray-100 p-4 rounded-3xl shadow-sm hover:shadow-md transition-all group border-l-4 border-l-orange-400">
                                                            <div className="flex items-center gap-3">
                                                                <div className="h-10 w-10 rounded-2xl bg-orange-100 flex items-center justify-center text-xs font-black text-orange-700 border border-orange-200 uppercase">
                                                                    {b.name.charAt(0)}
                                                                </div>
                                                                <div>
                                                                    <p className="text-sm font-black text-gray-900 group-hover:text-blue-700 transition-colors uppercase tracking-tight">{b.name}</p>
                                                                    <p className="text-[10px] text-gray-400 font-bold uppercase tracking-widest">Quantity: {b.quantity}</p>
                                                                </div>
                                                            </div>
                                                            <Button
                                                                size="sm"
                                                                className="bg-gray-900 hover:bg-blue-600 text-white rounded-2xl h-9 px-5 text-[10px] font-black uppercase tracking-widest transition-all gap-2 shadow-lg shadow-gray-100 active:scale-95"
                                                                onClick={() => startReturn(b.name)}
                                                            >
                                                                <RotateCcw className="h-3 w-3" />
                                                                Return
                                                            </Button>
                                                        </div>
                                                    ))}
                                                </div>
                                            )}
                                        </div>
                                    </div>
                                ) : scanValue && (
                                    <div className="text-center py-10 opacity-30">
                                        <Search className="h-12 w-12 text-gray-400 mx-auto mb-3 animate-pulse" />
                                        <p className="text-[10px] text-gray-500 font-black uppercase tracking-[.3em]">Querying Records...</p>
                                    </div>
                                )}
                            </div>
                        </div>
                    </>
                ) : (
                    <div className="animate-in zoom-in-95 duration-200 flex flex-col h-full bg-white">
                        <DialogHeader className="p-6 bg-orange-50 border-b border-orange-100 flex-shrink-0">
                            <DialogTitle className="flex items-center gap-2 text-orange-800">
                                <div className="p-2 bg-orange-200 rounded-lg">
                                    <RotateCcw className="h-5 w-5" />
                                </div>
                                <span className="font-black uppercase tracking-tighter">Field Audit Result</span>
                            </DialogTitle>
                        </DialogHeader>

                        <div className="flex-1 overflow-y-auto p-6 space-y-8">
                            <div className="space-y-4">
                                <label className="text-[10px] font-black text-gray-400 uppercase tracking-[0.2em]">Validated Item</label>
                                <div className="flex items-center gap-4 p-5 bg-orange-50/30 rounded-3xl border border-orange-100 text-orange-900">
                                    <div className="bg-orange-800 p-2 rounded-xl text-white">
                                        <Package className="h-6 w-6" />
                                    </div>
                                    <div>
                                        <p className="font-black text-lg uppercase tracking-tight leading-none">{foundItem.item_name}</p>
                                        <p className="text-[10px] font-bold opacity-60 uppercase tracking-widest mt-1">Returning {returningLog.quantity} Unit(s)</p>
                                    </div>
                                </div>
                            </div>

                            <div className="space-y-6">
                                <div className="space-y-3">
                                    <label className="text-[10px] font-black text-gray-400 uppercase tracking-[0.2em]">Condition Assessment</label>
                                    <Select value={returnCondition} onValueChange={setReturnCondition}>
                                        <SelectTrigger className="h-16 rounded-3xl border-gray-100 shadow-sm font-black text-sm uppercase tracking-widest ring-offset-orange-600 focus:ring-orange-600">
                                            <SelectValue />
                                        </SelectTrigger>
                                        <SelectContent className="rounded-2xl border-0 shadow-2xl">
                                            <SelectItem value="Good" className="focus:bg-green-50 rounded-xl py-3">
                                                <div className="flex items-center gap-3 text-green-600">
                                                    <CheckCircle2 className="h-5 w-5" />
                                                    <span className="font-black uppercase tracking-widest text-[11px]">Deployable (Good)</span>
                                                </div>
                                            </SelectItem>
                                            <SelectItem value="Maintenance" className="focus:bg-orange-50 rounded-xl py-3">
                                                <div className="flex items-center gap-3 text-orange-600">
                                                    <RotateCcw className="h-5 w-5" />
                                                    <span className="font-black uppercase tracking-widest text-[11px]">Assessment Needed</span>
                                                </div>
                                            </SelectItem>
                                            <SelectItem value="Damaged" className="focus:bg-red-50 rounded-xl py-3">
                                                <div className="flex items-center gap-3 text-red-600">
                                                    <AlertTriangle className="h-5 w-5" />
                                                    <span className="font-black uppercase tracking-widest text-[11px]">Damaged / Broken</span>
                                                </div>
                                            </SelectItem>
                                            <SelectItem value="Lost" className="focus:bg-gray-100 rounded-xl py-3">
                                                <div className="flex items-center gap-3 text-gray-600">
                                                    <Package className="h-5 w-5" />
                                                    <span className="font-black uppercase tracking-widest text-[11px]">Unaccounted (Lost)</span>
                                                </div>
                                            </SelectItem>
                                        </SelectContent>
                                    </Select>
                                </div>

                                <div className="space-y-3">
                                    <label className="text-[10px] font-black text-gray-400 uppercase tracking-[0.2em]">Audit Notes</label>
                                    <Input
                                        placeholder="Add mission-critical details..."
                                        className="h-16 rounded-3xl border-gray-100 font-bold px-6 shadow-inner bg-gray-50/50"
                                        value={returnNotes}
                                        onChange={(e) => setReturnNotes(e.target.value)}
                                    />
                                </div>
                            </div>
                        </div>

                        <DialogFooter className="p-6 bg-gray-50 border-t border-gray-100 flex flex-col sm:flex-row gap-3 flex-shrink-0">
                            <Button
                                variant="ghost"
                                className="flex-1 rounded-2xl font-black text-gray-400 uppercase tracking-[0.2em] text-[10px] h-14"
                                onClick={() => setReturningLog(null)}
                            >
                                Back to scan
                            </Button>
                            <Button
                                className="flex-[1.5] bg-orange-600 hover:bg-orange-700 text-white rounded-3xl h-14 font-black uppercase tracking-[0.2em] text-[11px] shadow-xl shadow-orange-100 transition-all active:scale-95"
                                onClick={confirmReturn}
                                disabled={isProcessing}
                            >
                                {isProcessing ? 'Finalizing...' : 'Complete Entry'}
                            </Button>
                        </DialogFooter>
                    </div>
                )}
            </DialogContent>

            <style jsx global>{`
                @keyframes scan {
                    0% { top: 0%; opacity: 0; }
                    10% { opacity: 1; }
                    90% { opacity: 1; }
                    100% { top: 100%; opacity: 0; }
                }
                .animate-scan {
                    animation: scan 2s linear infinite;
                }
                #qr-reader__scan_region video {
                    object-fit: cover !important;
                }
                #qr-reader {
                    border: none !important;
                }
            `}</style>
        </Dialog>
    )
}

