'use client'

import { useEffect, useRef, useState, useCallback } from 'react'
import { Html5Qrcode } from 'html5-qrcode'
import { Camera, RefreshCw } from 'lucide-react'
import { toast } from 'sonner'
import { Button } from '@/components/ui/button'

interface ScannerViewportProps {
    onScan: (text: string) => void;
    isActive: boolean;
}

// 🔊 TACTICAL FEEDBACK SINGLETON: Prevents "Too many WebMediaPlayers" intervention
const SCAN_SOUND = typeof Audio !== 'undefined' 
    ? new Audio('https://assets.mixkit.co/active_storage/sfx/2571/2571-preview.mp3') 
    : null

export function ScannerViewport({ onScan, isActive }: ScannerViewportProps) {
    const scannerRef = useRef<Html5Qrcode | null>(null)
    const [cameras, setCameras] = useState<{ id: string, label: string }[]>([])
    const [selectedCameraId, setSelectedCameraId] = useState<string>('')
    const [isStarting, setIsStarting] = useState(false)
    
    // Unique ID per instance to prevent "ghosting" or duplicated feeds from stale mounts
    const regionId = useRef(`qr-reader-${Math.random().toString(36).slice(2, 9)}`).current

    const playScanSound = useCallback(() => {
        if (!SCAN_SOUND) return
        SCAN_SOUND.currentTime = 0
        SCAN_SOUND.play().catch(() => {})
    }, [])

    useEffect(() => {
        const discover = async () => {
            try {
                const devices = await Html5Qrcode.getCameras()
                setCameras(devices.map(d => ({ id: d.id, label: d.label })))
                
                if (devices.length > 0) {
                    // 🛰️ TACTICAL DEFAULT: Prioritize back/rear cameras
                    const backCam = devices.find(d => 
                        d.label.toLowerCase().includes('back') || 
                        d.label.toLowerCase().includes('rear') ||
                        d.label.toLowerCase().includes('environment')
                    )
                    setSelectedCameraId(backCam?.id || devices[0].id)
                }
            } catch (e) {
                console.error('[Scanner:Discover]', e)
            }
        }
        discover()
    }, [])

    const toggleCamera = useCallback(() => {
        if (cameras.length <= 1) return
        const currentIndex = cameras.findIndex(c => c.id === selectedCameraId)
        const nextIndex = (currentIndex + 1) % cameras.length
        setSelectedCameraId(cameras[nextIndex].id)
    }, [cameras, selectedCameraId])

    const stopScanner = async () => {
        if (scannerRef.current) {
            try {
                if (scannerRef.current.isScanning) {
                    await scannerRef.current.stop()
                }
                // Hard cleanup: ensure the DOM element is purged of library-injected nodes
                const container = document.getElementById(regionId)
                if (container) container.innerHTML = ''
            } catch (e) {
                console.warn('[Scanner:Stop]', e)
            }
            scannerRef.current = null
        }
    }

    const startScanner = async () => {
        if (!isActive || isStarting) return
        
        const container = document.getElementById(regionId)
        if (!container) return

        setIsStarting(true)
        
        try {
            await stopScanner()
            const scanner = new Html5Qrcode(regionId)
            scannerRef.current = scanner
            
            // SENIOR DEV: Use qrbox function for responsive, center-focused scanning
            // This ensures detection only happens within the tactical viewfinder
            const config = { 
                fps: 20, // Higher FPS for smoother tactical feel
                qrbox: (viewWidth: number, viewHeight: number) => {
                    // FIX: Enforce html5-qrcode minimum dimension of 50px
                    const size = Math.max(50, Math.min(viewWidth, viewHeight) * 0.65)
                    return { width: size, height: size }
                },
                aspectRatio: 1.0
            }

            const source = selectedCameraId || { facingMode: "environment" }

            await scanner.start(source, config, (text) => {
                onScan(text)
                
                // Tactical feedback
                playScanSound()
                
                // FIX: Small delay before stopping to prevent AbortError on the video stream
                // being interrupted during the 'play' request of internal library mechanics
                setTimeout(() => stopScanner(), 150)
            }, () => {
                // Verbose scanning logs disabled for performance
            })
        } catch (err: any) {
            console.error('[Scanner:Start]', err)
            const isLocked = err?.name === 'NotReadableError' || err?.message?.includes('NotReadableError')
            toast.error(isLocked ? "Camera locked by system." : "Scanner initialization failed.")
        } finally {
            setIsStarting(false)
        }
    }

    useEffect(() => {
        if (isActive) startScanner()
        else stopScanner()
        
        return () => { 
            stopScanner() 
        }
    }, [isActive, selectedCameraId])

    return (
        <div className="relative bg-slate-950 aspect-square overflow-hidden rounded-[2rem] border-4 border-white shadow-inner group">
            {/* 
                CSS FIX: Ensure the library-injected video is contained and centered.
                The 'html5-qrcode' library sometimes creates duplicate artifacts if 
                the container styling doesn't strictly force overflow containment.
            */}
            <div 
                id={regionId} 
                className="w-full h-full [&>video]:object-cover [&>video]:w-full [&>video]:h-full" 
            />
            
            {!isActive && (
                <div className="absolute inset-0 flex items-center justify-center bg-slate-900/90 backdrop-blur-md z-10">
                    <div className="text-center animate-in zoom-in-95 duration-500">
                        <div className="p-5 bg-white/5 rounded-full mb-4 inline-block border border-white/10">
                            <Camera className="h-10 w-10 text-white/40" />
                        </div>
                        <p className="text-[10px] text-white/30 uppercase font-black tracking-[0.3em]">
                            System Standby
                        </p>
                    </div>
                </div>
            )}

            {/* Tactical Viewfinder Overlay - Strictly aligned with qrbox scanning region */}
            {isActive && (
                <div className="absolute inset-0 pointer-events-none z-20 flex items-center justify-center">
                    <div className="relative w-2/3 h-2/3 max-w-[280px] max-h-[280px]">
                        {/* High-visibility corner brackets */}
                        <div className="absolute top-0 left-0 w-8 h-8 border-t-4 border-l-4 border-blue-500 rounded-tl-2xl shadow-[0_0_15px_rgba(59,130,246,0.5)]" />
                        <div className="absolute top-0 right-0 w-8 h-8 border-t-4 border-r-4 border-blue-500 rounded-tr-2xl shadow-[0_0_15px_rgba(59,130,246,0.5)]" />
                        <div className="absolute bottom-0 left-0 w-8 h-8 border-b-4 border-l-4 border-blue-500 rounded-bl-2xl shadow-[0_0_15px_rgba(59,130,246,0.5)]" />
                        <div className="absolute bottom-0 right-0 w-8 h-8 border-b-4 border-r-4 border-blue-500 rounded-br-2xl shadow-[0_0_15px_rgba(59,130,246,0.5)]" />
                        
                        {/* Scanning Line Animation */}
                        <div className="absolute top-0 left-0 w-full h-1 bg-gradient-to-r from-transparent via-blue-400 to-transparent shadow-[0_0_10px_rgba(59,130,246,0.8)] animate-scan opacity-50" />
                    </div>
                    
                    {/* Peripheral dimming for focus */}
                    <div className="absolute inset-0 bg-black/30 pointer-events-none ring-[1px] ring-white/10" />
                </div>
            )}

            {cameras.length > 1 && (
                <div className="absolute top-4 right-4 z-30">
                    <Button 
                        variant="ghost"
                        size="icon"
                        onClick={toggleCamera}
                        className="bg-slate-900/80 text-white rounded-xl border border-white/10 backdrop-blur-xl h-10 w-10 hover:bg-slate-800 active:scale-95 transition-all shadow-2xl"
                        title="Switch Camera"
                    >
                        <RefreshCw className="h-4 w-4" />
                    </Button>
                </div>
            )}
        </div>
    )
}
