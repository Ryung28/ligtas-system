'use client'

import React from 'react'
import Image from 'next/image'
import { useRouter, usePathname } from 'next/navigation'
import { ChevronLeft, RefreshCw } from 'lucide-react'
import { cn } from '@/lib/utils'
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
 * Sticky top bar: back nav / brand · title · refresh · notification bell.
 */
export function MobileHeader({ title, breadcrumb, onRefresh, isLoading }: MobileHeaderProps) {
    const router = useRouter()
    const pathname = usePathname()

    const showBack = pathname !== '/m'

    return (
        <>
            <header
                className={cn(
                    'sticky top-0 left-0 right-0 h-14 bg-white/90 backdrop-blur-md border-b border-gray-100',
                    'flex items-center px-4 z-50 mb-4 shadow-sm/50',
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
                                    src="/oro-cervo.png"
                                    alt=""
                                    width={32}
                                    height={32}
                                    className="object-contain bg-white"
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

                </div>
            </header>
        </>
    )
}
