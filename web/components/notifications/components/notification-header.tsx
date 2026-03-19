'use client'

import React from 'react'
import { motion, AnimatePresence } from 'framer-motion'
import { RefreshCw, CheckCheck, X } from 'lucide-react'
import { SheetClose } from '@/components/ui/sheet'
import { Icons } from '../constants/notification.config'
import { cn } from '@/lib/utils'

interface NotificationHeaderProps {
  unreadCount: number
  isRefreshing: boolean
  onRefresh: () => void
  onMarkAllRead: () => void
}

export function NotificationHeader({ unreadCount, isRefreshing, onRefresh, onMarkAllRead }: NotificationHeaderProps) {
  return (
    <div className="px-5 pt-5 pb-4">
      <div className="flex items-center justify-between mb-4">
        <div className="flex items-center gap-2">
          <div className="w-7 h-7 rounded-lg bg-gray-900 flex items-center justify-center text-white">
            {Icons.logo}
          </div>
          <div>
            <p className="text-[10px] font-semibold tracking-wider text-gray-400 uppercase leading-none">LIGTAS System</p>
            <h1 className="text-[22px] font-bold text-gray-900 leading-tight">Notifications</h1>
          </div>
        </div>

        <div className="flex items-center gap-2">
          <AnimatePresence>
            {unreadCount > 0 && (
              <motion.div 
                layoutId="notification-badge"
                className="px-2 py-1 rounded-full bg-red-500 flex items-center justify-center shadow-lg"
              >
                <span className="text-[10px] font-bold text-white tracking-tighter">{unreadCount}</span>
              </motion.div>
            )}
          </AnimatePresence>

          <motion.button onClick={onRefresh} className="flex items-center gap-1.5 px-3 py-1.5 rounded-xl text-gray-600 hover:text-gray-900 hover:bg-gray-100 transition-colors" whileTap={{ scale: 0.95 }}>
            <motion.div animate={{ rotate: isRefreshing ? 360 : 0 }} transition={{ duration: 1, ease: "linear", repeat: isRefreshing ? Infinity : 0 }}>
              <RefreshCw className="w-4 h-4" strokeWidth={2} />
            </motion.div>
            <span className="text-xs font-medium">Refresh</span>
          </motion.button>

          <motion.button onClick={onMarkAllRead} disabled={unreadCount === 0} className={cn("flex items-center gap-1.5 px-3 py-1.5 rounded-xl transition-colors", unreadCount > 0 ? "text-gray-600 hover:text-gray-900 hover:bg-gray-100" : "text-gray-300 cursor-not-allowed")} whileTap={{ scale: unreadCount > 0 ? 0.95 : 1 }}>
            <CheckCheck className="w-4 h-4" strokeWidth={2} />
            <span className="text-xs font-medium">Mark All</span>
          </motion.button>

          <SheetClose asChild>
            <motion.button className="w-8 h-8 rounded-xl flex items-center justify-center text-gray-400 hover:text-gray-900 hover:bg-gray-100 transition-colors" whileTap={{ scale: 0.95 }}>
              <X className="w-5 h-5" strokeWidth={2} />
            </motion.button>
          </SheetClose>
        </div>
      </div>
    </div>
  )
}
