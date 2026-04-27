'use client'

import React from 'react'
import { PopoverContent } from '@/components/ui/popover'
import { Button } from '@/components/ui/button'
import { BellRing, CheckCheck, RefreshCcw, AlertTriangle } from 'lucide-react'
import { useNotifications } from '@/hooks/use-notifications'
import { NotificationItemComponent } from './notification-item'
import { cn } from '@/lib/utils'
import { Skeleton } from '@/components/ui/skeleton'

/**
 * 🛡️ THE STEEL CAGE: Popover Viewport Controller
 * Enforces absolute viewport clamping and tactical overflow management.
 */
export const NotificationPopover: React.FC = () => {
  const { notifications, unreadCount, markAsRead, markAllRead, deleteNotification, isLoading, refresh, limit, loadMore, error } = useNotifications()

  return (
    <PopoverContent 
      align="end" 
      className="w-[420px] p-0 overflow-hidden rounded-tl-none rounded-tr-3xl rounded-b-3xl shadow-[0_32px_64px_-16px_rgba(0,0,0,0.12)] border-slate-200/40 bg-white/80 backdrop-blur-2xl animate-in fade-in zoom-in-95 duration-500"
    >
      <div className="flex flex-col h-full max-h-[80vh]">
        {/* 🛡️ TACTICAL COMMAND HEADER */}
        <div className="p-5 border-b border-slate-100 flex items-center justify-between bg-white/40 backdrop-blur-md relative overflow-hidden">
          <div className="absolute top-0 left-0 w-full h-[1px] bg-gradient-to-r from-transparent via-blue-500/20 to-transparent" />
          <div className="flex items-center gap-3">
            <div className="relative">
                <BellRing className="w-4 h-4 text-blue-600" />
                {unreadCount > 0 && (
                    <span className="absolute -top-1 -right-1 w-2 h-2 bg-red-500 rounded-full border-2 border-white animate-pulse" />
                )}
            </div>
            <div className="flex flex-col">
                <span className="font-black text-slate-900 text-[11px] tracking-widest uppercase leading-none">Notifications</span>
                <span className="text-[9px] font-bold text-slate-400 mt-1 uppercase tracking-tighter">Status: {unreadCount > 0 ? `${unreadCount} Unread` : 'All caught up'}</span>
            </div>
          </div>
          <div className="flex items-center gap-1.5">
            <Button 
                variant="ghost" 
                size="icon" 
                className="h-8 w-8 rounded-lg text-slate-400 hover:text-blue-600 hover:bg-blue-50/50 transition-all"
                onClick={() => refresh()}
                disabled={isLoading}
            >
              <RefreshCcw className={cn("w-3.5 h-3.5", isLoading && "animate-spin")} />
            </Button>
            <Button 
              variant="ghost" 
              className="h-8 rounded-lg text-[9px] font-black text-slate-500 hover:text-emerald-600 hover:bg-emerald-50/50 tracking-widest px-3"
              onClick={() => markAllRead()}
            >
              <CheckCheck className="w-3.5 h-3.5 mr-1.5" />
              CLEAR ALL
            </Button>
          </div>
        </div>

        {/* 🛡️ THE CHANNEL: Scrollable list */}
        <div className="flex-1 overflow-y-auto p-4 space-y-3 bg-slate-100/80 scrollbar-thin scrollbar-thumb-slate-300 hover:scrollbar-thumb-slate-400 transition-colors">
          {/* 🚨 TACTICAL ERROR BOUNDARY: Surface silent failures */}
          <div aria-live="polite">
            {error && (
              <div className="p-3 mb-3 bg-red-500/10 border border-red-500/20 rounded-tl-none rounded-tr-xl rounded-b-xl backdrop-blur-md flex gap-3 items-start">
                  <AlertTriangle className="w-4 h-4 text-red-600 shrink-0 mt-0.5" />
                  <div className="space-y-1">
                      <p className="text-[10px] font-black text-red-600 uppercase tracking-widest">Sync Failed</p>
                      <p className="text-xs text-red-800/80 leading-snug font-medium italic">
                          {error.message || 'Unable to load notifications right now.'}
                      </p>
                  </div>
              </div>
            )}
          </div>

          {isLoading && notifications.length === 0 ? (
            <div className="space-y-2">
              {[...Array(4)].map((_, i) => (
                <Skeleton key={i} className="h-24 w-full rounded-2xl bg-slate-100" />
              ))}
            </div>
          ) : notifications.length > 0 ? (
            notifications.map((n: any) => (
              <NotificationItemComponent 
                key={n.id} 
                item={n} 
                onMarkAsRead={markAsRead} 
                onDelete={deleteNotification}
                onRefresh={refresh}
              />
            ))
          ) : (
            // 🛡️ TACTICAL EMPTY STATE: Premium operator feedback
            <div aria-live="polite" className="p-10 text-center text-slate-400 backdrop-blur-xl bg-white/30 rounded-tl-none rounded-tr-3xl rounded-b-3xl border border-white/60 shadow-[0_8px_32px_rgba(0,0,0,0.02)] transition-all duration-700 animate-in fade-in zoom-in-95 fill-mode-both">
              <div className="w-14 h-14 mx-auto mb-4 rounded-full bg-slate-100 flex items-center justify-center relative">
                  <BellRing className="w-6 h-6 text-slate-300" />
                  <div className="absolute inset-0 rounded-full border border-slate-200 animate-ping opacity-20" />
              </div>
              <p className="text-[10px] font-black uppercase tracking-[0.3em] text-slate-500">No New Notifications</p>
              <p className="text-[9px] font-bold italic text-slate-400/60 mt-2 max-w-[160px] mx-auto leading-relaxed">You are all caught up.</p>
            </div>
          )}
        </div>

        {/* 🛡️pagination Tigger */}
        <div className="p-4 border-t border-slate-100 bg-white/60 backdrop-blur-md">
          <Button 
            variant="outline" 
            className="w-full h-10 text-[9px] font-black uppercase tracking-[0.2em] border-slate-200 bg-white text-slate-600 hover:bg-slate-900 hover:text-white hover:border-slate-900 transition-all duration-500 rounded-xl shadow-sm"
            onClick={loadMore}
            disabled={isLoading || notifications.length < limit}
          >
            {isLoading && notifications.length > 0 ? (
                <div className="flex items-center gap-2">
                    <RefreshCcw className="w-3 h-3 animate-spin" />
                    Syncing...
                </div>
            ) : 'Show Older'}
          </Button>
        </div>
      </div>
    </PopoverContent>
  )
}
