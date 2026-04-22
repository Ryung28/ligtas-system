'use client'

import React from 'react'
import { BottomSheet } from '@/components/mobile/primitives/bottom-sheet'
import { Button } from '@/components/ui/button'
import { RefreshCcw, CheckCheck, BellRing } from 'lucide-react'
import { useNotifications } from '@/hooks/use-notifications'
import { MobileNotificationItem } from './notification-item'
import { EmptyState } from '@/components/mobile/primitives/empty-state'
import { cn } from '@/lib/utils'

interface MobileNotificationSheetProps {
  open: boolean
  onOpenChange: (open: boolean) => void
}

/**
 * 📱 MOBILE NOTIFICATION SHEET
 * Native-feel drawer for Intelligence Inbox.
 */
export function MobileNotificationSheet({ open, onOpenChange }: MobileNotificationSheetProps) {
  const { 
    notifications, 
    unreadCount, 
    markAsRead, 
    markAllRead, 
    deleteNotification, 
    isLoading, 
    refresh, 
    limit, 
    loadMore 
  } = useNotifications()

  return (
    <BottomSheet
      open={open}
      onOpenChange={onOpenChange}
      title="Notifications"
      description={unreadCount > 0 ? `${unreadCount} new` : 'All caught up'}
      footer={
        <div className="flex gap-3">
          <Button 
            variant="outline" 
            className="flex-1 text-xs font-bold"
            onClick={() => markAllRead()}
            disabled={unreadCount === 0 || isLoading}
          >
            <CheckCheck className="w-4 h-4 mr-2" />
            Clear All
          </Button>
          <Button 
            variant="ghost" 
            size="icon"
            className="rounded-xl border border-gray-100"
            onClick={() => refresh()}
            disabled={isLoading}
          >
            <RefreshCcw className={cn("w-4 h-4 text-gray-500", isLoading && "animate-spin")} />
          </Button>
        </div>
      }
    >
      <div className="flex flex-col gap-1 pb-4">
        {notifications.length > 0 ? (
          <>
            {notifications.map((n) => (
              <MobileNotificationItem 
                key={n.id}
                item={n}
                onMarkAsRead={markAsRead}
                onDelete={deleteNotification}
                onClose={() => onOpenChange(false)}
              />
            ))}
            
            {notifications.length >= limit && (
              <Button 
                variant="ghost" 
                className="w-full mt-4 text-xs font-bold text-gray-500"
                onClick={loadMore}
                disabled={isLoading}
              >
                {isLoading ? 'Updating...' : 'See more'}
              </Button>
            )}
          </>
        ) : (
          <div className="py-12">
            <EmptyState 
              title="All clear"
              description="No new notifications at the moment."
              icon={BellRing}
            />
          </div>
        )}
      </div>
    </BottomSheet>
  )
}
