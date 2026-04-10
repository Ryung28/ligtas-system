'use client'

import React from 'react'
import Image from 'next/image'
import { useRouter, usePathname } from 'next/navigation'
import { ChevronLeft, RefreshCw, MoreVertical } from 'lucide-react'
import { cn } from '@/lib/utils'

interface MobileHeaderProps {
    title?: string
    onRefresh?: () => void
    isLoading?: boolean
}

/**
 * 📱 LIGTAS Mobile Header
 * 🏛️ ARCHITECTURE: Simple top bar with dynamic back navigation and contextual actions.
 */
export function MobileHeader({ title, onRefresh, isLoading }: MobileHeaderProps) {
    const router = useRouter()
    const pathname = usePathname()
    
    // Hide back button on the root mobile page
    const showBack = pathname !== '/m'

    return (
        <header className="sticky top-0 left-0 right-0 h-14 bg-white/90 backdrop-blur-md border-b border-gray-100 flex items-center px-4 z-50 -mx-4 -mt-4 mb-4">
            <div className="flex-1 flex items-center gap-3">
                {showBack && (
                    <button 
                        onClick={() => router.back()}
                        className="p-2 -ml-2 hover:bg-gray-50 rounded-full transition-colors active:scale-95"
                        aria-label="Go back"
                    >
                        <ChevronLeft className="w-6 h-6 text-gray-700" />
                    </button>
                )}
                
                {title ? (
                     <h1 className="font-syne font-bold text-lg text-gray-900 tracking-tight uppercase italic font-black">
                        {title}
                    </h1>
                ) : !showBack && (
                    <div className="flex items-center gap-2">
                        <div className="w-8 h-8 rounded-lg overflow-hidden flex-shrink-0">
                            <Image 
                                src="/oro-cervo.png" 
                                alt="LIGTAS Logo" 
                                width={32} 
                                height={32}
                                className="object-cover"
                            />
                        </div>
                        <h1 className="font-syne font-bold text-lg text-gray-900 tracking-tight">
                            LIGTAS
                        </h1>
                    </div>
                )}
            </div>

            <div className="flex-none flex items-center gap-1">
                {onRefresh && (
                    <button 
                        onClick={onRefresh}
                        disabled={isLoading}
                        className="p-2 text-gray-500 active:text-red-500 transition-colors disabled:opacity-50"
                        aria-label="Refresh content"
                    >
                        <RefreshCw className={cn("w-5 h-5", isLoading && "animate-spin")} />
                    </button>
                )}
                 <button className="p-2 text-gray-400">
                    <MoreVertical className="w-5 h-5" />
                </button>
            </div>
        </header>
    )
}
