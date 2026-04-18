'use client'

import React, { useState } from 'react'
import Image from 'next/image'
import { useRouter, usePathname } from 'next/navigation'
import { ChevronLeft, RefreshCw, MoreVertical, LogOut, User, Shield } from 'lucide-react'
import { cn } from '@/lib/utils'
import { signOut } from '@/lib/auth'
import { useUser } from '@/providers/auth-provider'
import {
    Popover,
    PopoverContent,
    PopoverTrigger,
} from "@/components/ui/popover"
import { Button } from '@/components/ui/button'
import { Avatar, AvatarFallback } from '@/components/ui/avatar'

interface MobileHeaderProps {
    title?: string
    onRefresh?: () => void
    isLoading?: boolean
}

/**
 * 📱 LIGTAS Mobile Header
 * 🏛️ ARCHITECTURE: Simple top bar with dynamic back navigation and Identity Hub.
 */
export function MobileHeader({ title, onRefresh, isLoading }: MobileHeaderProps) {
    const router = useRouter()
    const pathname = usePathname()
    const { user } = useUser()
    const [isLoggingOut, setIsLoggingOut] = useState(false)
    
    // Hide back button on the root mobile page
    const showBack = pathname !== '/m'

    const handleLogout = async () => {
        try {
            setIsLoggingOut(true)
            await signOut()
            // Force a full page reload to the login page to clear all memory states
            window.location.href = '/login'
        } catch (error) {
            console.error('Logout failed:', error)
            setIsLoggingOut(false)
        }
    }

    const initials = user?.full_name?.substring(0, 2).toUpperCase() || 'AD'

    return (
        <header className="sticky top-0 left-0 right-0 h-14 bg-white/90 backdrop-blur-md border-b border-gray-100 flex items-center px-4 z-50 -mx-4 -mt-4 mb-4 shadow-sm/50">
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
                        <div className="w-8 h-8 rounded-lg overflow-hidden flex-shrink-0 border border-slate-100 shadow-sm">
                            <Image 
                                src="/oro-cervo.png" 
                                alt="LIGTAS Logo" 
                                width={32} 
                                height={32}
                                className="object-cover"
                            />
                        </div>
                        <h1 className="font-syne font-bold text-lg text-gray-900 tracking-tight uppercase font-black italic">
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

                <Popover>
                    <PopoverTrigger asChild>
                        <button className="p-2 text-gray-400 hover:text-gray-900 transition-colors active:scale-90">
                            <MoreVertical className="w-5 h-5" />
                        </button>
                    </PopoverTrigger>
                    <PopoverContent className="w-64 mr-4 rounded-2xl p-2 shadow-2xl border-slate-100">
                        <div className="flex flex-col gap-1">
                            {/* User Profile Info */}
                            <div className="flex items-center gap-3 p-3 mb-1 border-b border-slate-50">
                                <Avatar className="h-10 w-10 border border-slate-100 shadow-sm">
                                    <AvatarFallback className="text-[10px] font-black bg-slate-900 text-white">
                                        {initials}
                                    </AvatarFallback>
                                </Avatar>
                                <div className="min-w-0">
                                    <p className="text-xs font-black text-slate-900 truncate uppercase tracking-tight">
                                        {user?.full_name || 'Responder'}
                                    </p>
                                    <p className="text-[9px] font-bold text-slate-400 uppercase tracking-widest flex items-center gap-1">
                                        <Shield className="w-2.5 h-2.5" />
                                        {user?.role || 'Personnel'}
                                    </p>
                                </div>
                            </div>

                            <Button
                                onClick={handleLogout}
                                disabled={isLoggingOut}
                                variant="ghost"
                                className="w-full justify-start gap-3 h-12 text-rose-600 hover:text-rose-700 hover:bg-rose-50 rounded-xl font-bold text-xs uppercase tracking-wider"
                            >
                                <LogOut className={cn("w-4 h-4", isLoggingOut && "animate-spin")} />
                                {isLoggingOut ? 'Logging out...' : 'Safe Logout'}
                            </Button>
                        </div>
                    </PopoverContent>
                </Popover>
            </div>
        </header>
    )
}
