'use client'

import React, { useState } from 'react'
import Image from 'next/image'
import { useRouter, usePathname } from 'next/navigation'
import { ChevronLeft, RefreshCw, Menu } from 'lucide-react'
import { cn } from '@/lib/utils'
import { MoreSheet } from '@/components/mobile/more-sheet'
import { mFocus } from '@/lib/mobile/tokens'
import { NotificationBell } from './notifications/notification-bell'

interface MobileHeaderProps {
    title?: string
    /** Optional breadcrumb trail shown above the title (e.g. "Inventory / Generator-02"). */
    breadcrumb?: string
    onRefresh?: () => void
    isLoading?: boolean
}

/**
 * 📱 ResQTrack Mobile Header
 * Sticky top bar: back nav / brand · title · refresh · more-menu.
 * The "More" button opens MoreSheet (secondary nav + identity + logout).
 */
export function MobileHeader({ title, breadcrumb, onRefresh, isLoading }: MobileHeaderProps) {
    const router = useRouter()
    const pathname = usePathname()
    const [moreOpen, setMoreOpen] = useState(false)

    const showBack = pathname !== '/m'

    return (
        <>
            <header
                className={cn(
                    'sticky top-0 left-0 right-0 h-14 bg-white/90 backdrop-blur-md border-b border-gray-100',
                    'flex items-center px-4 z-50 -mx-4 -mt-4 mb-4 shadow-sm/50',
                )}
            >
                <div className="flex-1 flex items-center gap-2 min-w-0">
                    {showBack && (
                        <button
                            onClick={() => router.back()}
                            className={cn(
                                'p-2 -ml-2 hover:bg-gray-50 rounded-full motion-safe:transition-transform motion-safe:active:scale-95',
                                'min-w-[44px] min-h-[44px] flex items-center justify-center',
                                mFocus,
                            )}
                            aria-label="Go back"
                        >
                            <ChevronLeft className="w-6 h-6 text-gray-700" />
                        </button>
                    )}

                    {title ? (
                        <div className="min-w-0 flex flex-col">
                            {breadcrumb && (
                                <span className="text-[10px] font-bold uppercase tracking-widest text-gray-400 truncate">
                                    {breadcrumb}
                                </span>
                            )}
                            <h1 className="font-syne font-black italic uppercase tracking-tight text-lg text-gray-900 truncate pr-1.5">
                                {title}
                            </h1>
                        </div>
                    ) : !showBack ? (
                        <div className="flex items-center gap-2">
                            <div className="w-8 h-8 rounded-lg overflow-hidden flex-shrink-0 border border-slate-100 shadow-sm">
                                <Image
                                    src="/resqtrack-logo.jpg"
                                    alt=""
                                    width={32}
                                    height={32}
                                    className="object-cover"
                                    aria-hidden
                                />
                            </div>
                            <h1 className="font-syne font-black italic uppercase tracking-tight text-lg text-gray-900">
                                ResQTrack
                            </h1>
                        </div>
                    ) : null}
                </div>

                <div className="flex-none flex items-center gap-0.5">
                    {onRefresh && (
                        <button
                            onClick={onRefresh}
                            disabled={isLoading}
                            className={cn(
                                'p-2 text-gray-500 active:text-red-600 motion-safe:transition-colors disabled:opacity-50',
                                'min-w-[44px] min-h-[44px] flex items-center justify-center rounded-full',
                                mFocus,
                            )}
                            aria-label="Refresh content"
                        >
                            <RefreshCw className={cn('w-5 h-5', isLoading && 'animate-spin')} />
                        </button>
                    )}

                    <NotificationBell />

                    <button
                        onClick={() => setMoreOpen(true)}
                        className={cn(
                            'p-2 text-gray-500 hover:text-gray-900 motion-safe:transition-colors motion-safe:active:scale-95 relative',
                            'min-w-[44px] min-h-[44px] flex items-center justify-center rounded-full',
                            mFocus,
                        )}
                        aria-label="Open menu"
                        aria-haspopup="dialog"
                        aria-expanded={moreOpen}
                    >
                        {/* 🧭 NAVIGATION NUDGE: Only pulses on the main dashboard to signal hidden features */}
                        {pathname === '/m' && (
                            <span className="absolute inset-2 rounded-full border-2 border-red-500/20 animate-ping opacity-75" />
                        )}
                        <Menu className="w-6 h-6" />
                    </button>
                </div>
            </header>

            <MoreSheet open={moreOpen} onOpenChange={setMoreOpen} />
        </>
    )
}
