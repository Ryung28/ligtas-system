'use client'

import { useState, useEffect } from 'react'
import { QrCode, X } from 'lucide-react'
import { 
    Dialog, 
    DialogContent, 
    DialogHeader, 
    DialogTitle, 
    DialogTrigger 
} from '@/components/ui/dialog'
import { Button } from '@/components/ui/button'
import { ScannerViewport } from './scanner-viewport'
import { ScannerResults } from './scanner-results'
import { useScannerData } from '../hooks/use-scanner-data'
import { parseQrPayload } from '../utils'
import { cn } from '@/lib/utils'

interface ScannerDialogProps {
    trigger?: React.ReactNode;
}

/**
 * 🛰️ SMART SCANNER (FEATURE VERSION)
 * Unified entry point for Item and Station Hub scanning.
 */
export function ScannerDialog({ trigger }: ScannerDialogProps) {
    const [isOpen, setIsOpen] = useState(false)
    const [isCameraActive, setIsCameraActive] = useState(false)
    const { isResolving, scanResult, resolvePayload, resetScanner } = useScannerData()

    const handleScan = (text: string) => {
        const payload = parseQrPayload(text)
        resolvePayload(payload)
        setIsCameraActive(false)
    }

    // 🔄 LIFECYCLE SYNC: Purge stale state and restart camera whenever modal opens/closes
    useEffect(() => {
        if (!isOpen) {
            setIsCameraActive(false)
            resetScanner()
            return
        }

        // When opening:
        resetScanner()
        // Use a stable flag to prevent race conditions during the DOM transition
        const timer = setTimeout(() => {
            setIsCameraActive(true)
        }, 200)

        return () => {
            clearTimeout(timer)
        }
    }, [isOpen, resetScanner])

    const showCamera = isCameraActive && !scanResult;

    return (
        <Dialog open={isOpen} onOpenChange={setIsOpen}>
            <DialogTrigger asChild>
                {trigger || (
                    <Button 
                        className="fixed bottom-24 right-6 h-16 w-16 rounded-full bg-slate-900 hover:bg-slate-800 text-white shadow-2xl shadow-slate-200 z-50 flex items-center justify-center border-4 border-white active:scale-95 transition-all"
                    >
                        <QrCode className="h-7 w-7" />
                    </Button>
                )}
            </DialogTrigger>
            
            <DialogContent className="sm:max-w-md border-0 shadow-2xl rounded-t-[2.5rem] sm:rounded-3xl p-0 overflow-hidden bg-white flex flex-col h-[85vh] sm:h-auto">
                <DialogHeader className="p-4 bg-white border-b flex-shrink-0">
                    <DialogTitle className="flex items-center justify-between">
                        <div className="flex items-center gap-2">
                            <div className="p-2 bg-slate-100 rounded-lg">
                                <QrCode className="h-5 w-5 text-slate-700" />
                            </div>
                            <span className="font-bold text-slate-900 tracking-tight text-[18px]">QR Scanner</span>
                        </div>
                    </DialogTitle>
                </DialogHeader>

                <div className="flex-1 overflow-y-auto bg-white">
                    <div className={cn("p-4 space-y-4", !showCamera && "p-0")}>
                        {showCamera && (
                            <ScannerViewport 
                                isActive={isCameraActive} 
                                onScan={handleScan} 
                            />
                        )}
                        
                        <div className={cn(!showCamera && "animate-in fade-in zoom-in-95 duration-500")}>
                            <ScannerResults 
                                result={scanResult} 
                                isResolving={isResolving} 
                            />
                        </div>
                    </div>
                </div>

                <div className="p-4 bg-white border-t text-center opacity-40">
                    <p className="text-[10px] font-black text-slate-400 uppercase tracking-[0.3em]">
                        System v2.4
                    </p>
                </div>
            </DialogContent>
        </Dialog>
    )
}
