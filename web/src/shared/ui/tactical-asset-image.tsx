'use client'

import { useState } from 'react'
import { Package, Maximize2, ShieldCheck } from 'lucide-react'
import { getInventoryImageUrl } from '@/lib/supabase'
import { cn } from '@/lib/utils'
import { Dialog, DialogContent, DialogTrigger, DialogTitle, DialogDescription } from '@/components/ui/dialog'
import Image from 'next/image'

interface TacticalAssetImageProps {
    url?: string | null
    alt: string
    className?: string
    size?: 'sm' | 'md' | 'lg' | 'xl'
    priority?: boolean
}

/**
 * TACTICAL ASSET IMAGE (SSOT)
 * 
 * Centralized component for inventory photography.
 * Handles:
 * - Supabase Bucket resolution
 * - Smooth loading & blur states
 * - Error fallbacks (Package icon)
 * - Click-to-Zoom Lightbox
 */
export function TacticalAssetImage({ url, alt, className, size = 'md', priority = false }: TacticalAssetImageProps) {
    const [isLoading, setIsLoading] = useState(true)
    const [isError, setIsError] = useState(false)

    const fullUrl = url ? getInventoryImageUrl(url) : null

    const sizeClasses = {
        sm: 'w-10 h-10',
        md: 'w-14 h-14',
        lg: 'w-16 h-16',
        xl: 'w-24 h-24'
    }

    const content = (
        <div className={cn(
            "relative bg-white border border-slate-100 overflow-hidden flex items-center justify-center transition-all shrink-0",
            sizeClasses[size],
            className
        )}>
            {fullUrl && !isError ? (
                <>
                    {isLoading && (
                        <div className="absolute inset-0 bg-slate-50 animate-pulse flex items-center justify-center z-10">
                            <Package className="w-1/2 h-1/2 text-slate-200" strokeWidth={1} />
                        </div>
                    )}
                    <Image
                        src={fullUrl}
                        alt={alt}
                        fill
                        unoptimized
                        priority={priority}
                        className={cn(
                            "object-contain p-1.5 transition-all duration-500",
                            isLoading ? "scale-90 blur-md opacity-0" : "scale-100 blur-0 opacity-100"
                        )}
                        onLoadingComplete={() => setIsLoading(false)}
                        onError={() => setIsError(true)}
                    />
                    {/* Hover Overlay */}
                    <div className="absolute inset-0 bg-black/40 opacity-0 group-hover:opacity-100 transition-opacity flex items-center justify-center z-20">
                        <Maximize2 className="w-4 h-4 text-white" />
                    </div>
                </>
            ) : (
                <div className="flex items-center justify-center bg-slate-50 w-full h-full">
                    <Package className="w-1/2 h-1/2 text-slate-200" strokeWidth={1} />
                </div>
            )}
        </div>
    )

    // No lightbox if there's no image
    if (!fullUrl || isError) return content

    return (
        <Dialog>
            <DialogTrigger asChild>
                <button type="button" className="group focus:outline-none shrink-0">
                    {content}
                </button>
            </DialogTrigger>
            <DialogContent className="max-w-4xl w-full border-none bg-black p-0 overflow-hidden shadow-2xl pointer-events-auto rounded-2xl">
                {/* Floating Meta Badge (Top Left) */}
                <div className="absolute top-6 left-6 z-50">
                    <div className="bg-black/60 backdrop-blur-md border border-white/10 px-3 py-1.5 rounded-lg">
                        <DialogTitle className="text-[12px] font-black text-white uppercase tracking-tight">
                            {alt}
                        </DialogTitle>
                        <DialogDescription className="sr-only">
                            Detailed visual inspection for {alt}
                        </DialogDescription>
                    </div>
                </div>

                {/* Cinema Canvas - Bounded to Aspect Video like Legacy */}
                <div className="relative w-full aspect-video flex items-center justify-center p-8">
                    {fullUrl && (
                        <Image 
                            src={fullUrl} 
                            alt={alt} 
                            fill
                            unoptimized
                            className="object-contain rounded-lg animate-in zoom-in-95 duration-300 p-8"
                        />
                    )}
                </div>
            </DialogContent>
        </Dialog>
    )
}
