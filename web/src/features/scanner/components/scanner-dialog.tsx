'use client'

import { useState } from 'react'
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

    const handleOpenChange = (open: boolean) => {
        setIsOpen(open)
        if (open) {
            setIsCameraActive(true)
            resetScanner()
        } else {
            setIsCameraActive(false)
        }
    }

    return (
        <Dialog open={isOpen} onOpenChange={handleOpenChange}>
            <DialogTrigger asChild>
                {trigger || (
                    <Button 
                        className="fixed bottom-24 right-6 h-16 w-16 rounded-full bg-slate-900 hover:bg-slate-800 text-white shadow-2xl shadow-slate-200 z-50 flex items-center justify-center border-4 border-white active:scale-95 transition-all"
                        onClick={() => handleOpenChange(true)}
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
                            <span className="font-bold text-slate-900 tracking-tight">Tactical Scanner</span>
                        </div>
                    </DialogTitle>
                </DialogHeader>

                <div className="flex-1 overflow-y-auto bg-slate-50/50">
                    <div className="p-4 space-y-4">
                        <ScannerViewport 
                            isActive={isCameraActive} 
                            onScan={handleScan} 
                        />
                        
                        <ScannerResults 
                            result={scanResult} 
                            isResolving={isResolving} 
                        />

                        {!isCameraActive && !isResolving && (
                            <Button 
                                variant="outline"
                                className="w-full h-12 rounded-xl border-slate-200 font-bold text-[10px] uppercase tracking-widest text-slate-500 hover:bg-white hover:border-slate-900 hover:text-slate-900 transition-all"
                                onClick={() => {
                                    resetScanner()
                                    setIsCameraActive(true)
                                }}
                            >
                                Reset & Reactivate Camera
                            </Button>
                        )}
                    </div>
                </div>

                <div className="p-4 bg-white border-t text-center">
                    <p className="text-[9px] font-black text-slate-300 uppercase tracking-[0.3em]">
                        ResQTrack Unified Protocol v2.4
                    </p>
                </div>
            </DialogContent>
        </Dialog>
    )
}
