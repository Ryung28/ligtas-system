'use client'

import React, { useState, useEffect } from 'react'
import { motion, AnimatePresence } from 'framer-motion'
import { Bell, RefreshCw } from 'lucide-react'
import { Sheet, SheetContent, SheetTrigger } from '@/components/ui/sheet'
import { cn } from '@/lib/utils'
import { useNotifications } from '@/hooks/use-notifications'
import { useRealtimeAudio } from '@/hooks/use-realtime-audio'

// 🛡️ SILOED FEATURE IMPORTS
import { Category, NotificationItem } from '../notifications/types/notification.types'
import { Icons, FILTER_MAP } from '../notifications/constants/notification.config'
import { NotificationSkeleton } from '../notifications/components/notification-skeleton'
import { NotificationCard } from '../notifications/components/notification-card'
import { NotificationHeader } from '../notifications/components/notification-header'
import { NotificationFilters } from '../notifications/components/notification-filters'

/**
 * 🔔 THE BOSS: Notification Bell V2 Orchestrator
 * Optimized for strict 150-line siloed architecture standards.
 */
export function NotificationBellV2() {
  const { notifications, unreadCount, markAsRead, markAllRead, deleteNotification, isLoading, refresh, loadMore } = useNotifications()
  const { playNotification } = useRealtimeAudio()
  const [activeFilter, setActiveFilter] = useState<Category>("ALL")
  const [isScanning, setIsScanning] = useState(false)
  const [isRefreshing, setIsRefreshing] = useState(false)
  const [isOpen, setIsOpen] = useState(false)

  const filtered = notifications.filter((n: NotificationItem) =>
    FILTER_MAP[activeFilter].includes(n.type)
  )

  useEffect(() => {
    const handleKeyDown = (e: KeyboardEvent) => {
      if ((e.metaKey || e.ctrlKey) && e.shiftKey && e.key === 'N') {
        e.preventDefault()
        setIsOpen(prev => !prev)
      }
    }
    window.addEventListener('keydown', handleKeyDown)
    return () => window.removeEventListener('keydown', handleKeyDown)
  }, [])

  // Removed: notification sound on close was annoying

  const handleRefresh = () => {
    setIsRefreshing(true)
    refresh()
    setTimeout(() => setIsRefreshing(false), 1200)
  }

  const handleScan = () => {
    setIsScanning(true)
    loadMore()
    setTimeout(() => setIsScanning(false), 2400)
  }

  const FILTERS: Category[] = ["ALL", "LOGS", "AUTH", "ALERTS"]

  return (
    <Sheet open={isOpen} onOpenChange={setIsOpen}>
      <SheetTrigger asChild>
        <motion.button
          whileHover={{ scale: 1.05 }}
          whileTap={{ scale: 0.95 }}
          transition={{ type: "spring", stiffness: 400, damping: 25 }}
          className={cn(
            'relative h-11 w-11 rounded-[1.25rem] transform-gpu transition-all duration-300 overflow-hidden flex items-center justify-center outline-none',
            unreadCount > 0 ? 'bg-zinc-950 shadow-[0_8px_24px_rgba(0,0,0,0.15)]' : 'hover:bg-gray-100'
          )}
        >
          <Bell className={cn('w-5 h-5 transition-colors', unreadCount > 0 ? 'text-white' : 'text-gray-500')} strokeWidth={2.5} />
          
          <AnimatePresence>
            {unreadCount > 0 && (
              <motion.div 
                layoutId="notification-badge"
                className="absolute top-2 right-2.5 flex h-4 min-w-[16px] items-center justify-center rounded-full bg-red-500 px-1 border border-zinc-950 shadow-lg z-20"
              >
                <span className="text-[8px] font-black text-white">{unreadCount > 99 ? '99+' : unreadCount}</span>
              </motion.div>
            )}
          </AnimatePresence>

          {unreadCount > 0 && (
            <motion.div 
              initial={{ scale: 0.8, opacity: 0 }}
              animate={{ scale: 1.8, opacity: 0 }}
              transition={{ repeat: Infinity, duration: 2, ease: "easeOut" }}
              className="absolute inset-0 rounded-full border border-red-500/20"
            />
          )}
        </motion.button>
      </SheetTrigger>

      <SheetContent 
        side="right" 
        hideClose 
        className="w-full sm:max-w-[440px] p-0 flex flex-col overflow-hidden border-none shadow-none bg-transparent font-dm-sans"
      >
        <motion.div
          initial={{ opacity: 0, x: 20 }} 
          animate={{ opacity: 1, x: 0 }}
          transition={{ duration: 0.25, ease: [0.16, 1, 0.3, 1] }}
          className="relative w-full h-full rounded-l-[28px] overflow-hidden flex flex-col"
          style={{ 
            background: "rgba(240,242,248,0.95)", 
            backdropFilter: "blur(32px)", 
            border: "1px solid rgba(255,255,255,0.7)",
            boxShadow: "0 32px 80px rgba(0,0,0,0.14), inset 0 1px 0 rgba(255,255,255,0.8)",
            willChange: "transform, opacity"
          }}
        >
          <NotificationHeader 
            unreadCount={unreadCount} isRefreshing={isRefreshing} 
            onRefresh={handleRefresh} onMarkAllRead={markAllRead} 
          />
          
          <NotificationFilters 
            activeFilter={activeFilter} setActiveFilter={setActiveFilter} filters={FILTERS} 
          />

          <div className="flex-1 overflow-y-auto px-4 pb-4 scrollbar-hide">
            <div className="flex items-center justify-between mb-3 px-1">
              <p className="text-[10px] font-bold tracking-wider text-gray-400 uppercase">Recent Activity</p>
              <p className="text-[10px] font-bold text-gray-400">{filtered.length} {filtered.length === 1 ? "item" : "items"}</p>
            </div>

            <div className="flex flex-col gap-2">
              <AnimatePresence mode="popLayout">
                {isLoading ? (
                  [0, 1, 2].map(i => <NotificationSkeleton key={`skeleton-${i}`} index={i} />)
                ) : filtered.length === 0 ? (
                  <motion.div initial={{ opacity: 0 }} animate={{ opacity: 1 }} className="flex flex-col items-center justify-center py-12 text-gray-400">
                    <div className="w-12 h-12 rounded-2xl bg-gray-100 flex items-center justify-center mb-3"><Bell className="w-6 h-6 text-gray-300" /></div>
                    <p className="text-sm font-medium">No notifications</p>
                  </motion.div>
                ) : (
                  filtered.map((notif: NotificationItem, i: number) => (
                    <NotificationCard 
                      key={notif.id} 
                      notif={notif} 
                      index={i}
                      onMarkRead={markAsRead} 
                      onDelete={deleteNotification} 
                    />
                  ))
                )}
              </AnimatePresence>
            </div>
          </div>

          <div className="px-4 pb-4">
            <motion.button onClick={handleScan} disabled={isScanning || isLoading} className="relative w-full py-2.5 rounded-xl overflow-hidden flex items-center justify-center gap-2.5 text-[11px] font-bold tracking-wide uppercase text-white shadow-lg transition-all active:scale-[0.98]" style={{ background: "linear-gradient(135deg, #111827 0%, #1f2937 100%)" }} whileHover={{ scale: 1.01, boxShadow: "0 8px 32px rgba(0,0,0,0.3)" }}>
              <AnimatePresence>
                {isScanning && <motion.div initial={{ x: "-100%" }} animate={{ x: "200%" }} transition={{ duration: 1.2, ease: "easeInOut", repeat: 1 }} className="absolute inset-0 pointer-events-none" style={{ background: "linear-gradient(90deg, transparent, rgba(255,255,255,0.12), transparent)", width: "60%" }} />}
              </AnimatePresence>
              <motion.div animate={{ rotate: isScanning ? 360 : 0 }} transition={{ duration: 0.8, repeat: isScanning ? Infinity : 0, ease: "linear" }} className="w-4 h-4">{Icons.scan}</motion.div>
              <span>{isScanning ? "Loading…" : "Load More"}</span>
            </motion.button>
          </div>
        </motion.div>
      </SheetContent>
    </Sheet>
  )
}
