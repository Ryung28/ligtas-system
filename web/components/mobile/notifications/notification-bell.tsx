'use client'

import React, { useState } from 'react'
import { Bell } from 'lucide-react'
import { cn } from '@/lib/utils'
import { useNotifications } from '@/hooks/use-notifications'
import { mFocus } from '@/lib/mobile/tokens'
import { MobileNotificationSheet } from './mobile-notification-sheet'

/**
 * 📱 NOTIFICATION BELL TRIGGER
 * Header-bound trigger with unread count badge.
 */
export function NotificationBell() {
    const [open, setOpen] = useState(false)
    const { unreadCount } = useNotifications()

    return (
        <>
            <button
                onClick={() => setOpen(true)}
                className={cn(
                    'p-2 text-gray-500 hover:text-gray-900 active:scale-95 transition-all relative',
                    'min-w-[44px] min-h-[44px] flex items-center justify-center rounded-full',
                    mFocus
                )}
                aria-label="Open notifications"
            >
                <Bell className="w-5 h-5" />
                
                {unreadCount > 0 && (
                    <span className="absolute top-2 right-2 flex h-4 w-4">
                        <span className="animate-ping absolute inline-flex h-full w-full rounded-full bg-red-400 opacity-75"></span>
                        <span className="relative inline-flex rounded-full h-4 w-4 bg-red-600 border-2 border-white flex items-center justify-center">
                            <span className="text-[8px] font-black text-white leading-none">
                                {unreadCount > 9 ? '9+' : unreadCount}
                            </span>
                        </span>
                    </span>
                )}
            </button>

            <MobileNotificationSheet open={open} onOpenChange={setOpen} />
        </>
    )
}
