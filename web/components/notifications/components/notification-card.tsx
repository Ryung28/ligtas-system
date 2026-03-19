import React, { useState } from 'react'
import { motion, AnimatePresence } from 'framer-motion'
import { formatDistanceToNow } from 'date-fns'
import { useRouter } from 'next/navigation'
import { Icons, TYPE_CONFIG } from '../constants/notification.config'
import { NotificationCardProps } from '../types/notification.types'
import {
  Dialog,
  DialogContent,
  DialogHeader,
  DialogTitle,
  DialogTrigger,
  DialogDescription,
} from '@/components/ui/dialog'
import { RestockForm } from '@/components/layout/_components/RestockForm'

export function NotificationCard({ notif, index, onMarkRead, onDelete }: NotificationCardProps) {
  const router = useRouter()
  const [isOpen, setIsOpen] = useState(false)
  
  const cfg = TYPE_CONFIG[notif.type] || {
    icon: Icons.users,
    label: "Auth",
    accent: "#10b981",
    bg: "rgba(16,185,129,0.08)",
    border: "rgba(16,185,129,0.2)",
  }

  const isLowStock = notif.type.includes('stock')

  const getActionData = () => {
    if (notif.type === 'borrow_request') return { label: 'Manage Log', route: '/dashboard/logs' }
    if (notif.type === 'user_pending') return { label: 'Review Access', route: '/dashboard/borrowers' }
    if (isLowStock) return { label: 'Fast Restock', action: 'dialog' }
    return null
  }

  const actionData = getActionData()

  const handleActionClick = (e: React.MouseEvent) => {
    e.stopPropagation()
    if (actionData?.route) router.push(actionData.route)
  }

  const cardContent = (
    <div className="p-4 pl-5">
      <div className="flex items-start gap-3">
        {/* Icon badge */}
        <motion.div
          className="flex-shrink-0 w-10 h-10 rounded-xl flex items-center justify-center mt-0.5"
          style={{ background: cfg.bg, border: `1px solid ${cfg.border}`, color: cfg.accent }}
          whileHover={{ rotate: [0, -8, 8, 0], transition: { duration: 0.4 } }}
        >
          {cfg.icon}
        </motion.div>

        <div className="flex-1 min-w-0">
          {/* Header row */}
          <div className="flex items-center justify-between gap-2 mb-1">
            <div className="flex items-center gap-2">
              <span
                className="text-[10px] font-bold tracking-widest uppercase"
                style={{ color: cfg.accent }}
              >
                {cfg.label}
              </span>
              {!notif.isRead && (
                <motion.span
                  animate={{ scale: [1, 1.3, 1] }}
                  transition={{ repeat: Infinity, duration: 2, ease: "easeInOut" }}
                  className="w-1.5 h-1.5 rounded-full"
                  style={{ background: cfg.accent }}
                />
              )}
            </div>
            <span className="text-[11px] text-gray-400 font-medium flex-shrink-0">
              {notif.time ? formatDistanceToNow(new Date(notif.time), { addSuffix: true }).replace('about ', '') : 'now'}
            </span>
          </div>

          <h3 className="font-black text-[15px] text-gray-900 leading-tight tracking-tight mb-1">
            {notif.title}
          </h3>

          <p className="text-[13px] text-gray-500 leading-relaxed mb-3 line-clamp-2">{notif.message || notif.description}</p>

          <div className="flex items-center justify-between">
            {actionData && (
              isLowStock ? (
                <DialogTrigger asChild>
                  <motion.button
                    className="flex items-center gap-1.5 text-[11px] font-bold tracking-wide uppercase px-4 py-2 rounded-full bg-zinc-50 text-zinc-700 shadow-[0_2px_8px_rgba(0,0,0,0.08)] border border-zinc-200/60 transition-all duration-200 hover:bg-zinc-950 hover:text-white hover:shadow-[0_4px_12px_rgba(0,0,0,0.15)] hover:border-zinc-950 hover:-translate-y-0.5"
                    whileTap={{ scale: 0.97 }}
                  >
                    {actionData.label}
                    <motion.span initial={{ x: 0, y: 0 }} whileHover={{ x: 2, y: -2 }} transition={{ duration: 0.15 }}>
                      {Icons.arrowUpRight}
                    </motion.span>
                  </motion.button>
                </DialogTrigger>
              ) : (
                <motion.button
                  onClick={handleActionClick}
                  className="flex items-center gap-1.5 text-[11px] font-bold tracking-wide uppercase px-4 py-2 rounded-full bg-zinc-50 text-zinc-700 shadow-[0_2px_8px_rgba(0,0,0,0.08)] border border-zinc-200/60 transition-all duration-200 hover:bg-zinc-950 hover:text-white hover:shadow-[0_4px_12px_rgba(0,0,0,0.15)] hover:border-zinc-950 hover:-translate-y-0.5"
                  whileTap={{ scale: 0.97 }}
                >
                  {actionData.label}
                  <motion.span initial={{ x: 0, y: 0 }} whileHover={{ x: 2, y: -2 }} transition={{ duration: 0.15 }}>
                    {Icons.arrowUpRight}
                  </motion.span>
                </motion.button>
              )
            )}

            <div className="flex items-center gap-2">
              {onDelete && (
                <motion.button
                  onClick={(e) => { e.stopPropagation(); onDelete(notif.id) }}
                  className="text-gray-400 hover:text-red-500 transition-colors bg-white/50 rounded-full p-1 shadow-sm hover:shadow border border-zinc-200/50"
                  whileTap={{ scale: 0.95 }}
                  aria-label="Delete"
                >
                  {Icons.trash}
                </motion.button>
              )}
              {!notif.isRead && (
                <motion.button
                  onClick={(e) => { e.stopPropagation(); onMarkRead(notif.id) }}
                  className="text-[11px] text-gray-400 hover:text-gray-700 font-medium transition-colors px-2 py-1"
                  whileTap={{ scale: 0.95 }}
                >
                  Mark read
                </motion.button>
              )}
            </div>
          </div>
        </div>
      </div>
    </div>
  )

  return (
    <Dialog open={isOpen} onOpenChange={setIsOpen}>
      <motion.div
        layout
        initial={{ opacity: 0, y: 16, scale: 0.97 }}
        animate={{ opacity: 1, y: 0, scale: 1 }}
        exit={{ opacity: 0, scale: 0.95, y: -8, transition: { duration: 0.15, ease: "easeOut", delay: 0 } }}
        transition={{ duration: 0.35, ease: [0.22, 1, 0.36, 1], layout: { type: "spring", stiffness: 400, damping: 35 } }}
        className="group relative rounded-xl overflow-hidden cursor-pointer transform-gpu will-change-[transform,opacity,height]"
        style={{
          background: "rgba(255,255,255,0.72)",
          border: "1px solid rgba(0,0,0,0.07)",
          backdropFilter: "blur(12px)",
          boxShadow: "0 2px 12px rgba(0,0,0,0.04), 0 1px 3px rgba(0,0,0,0.03)",
        }}
        whileHover={{
          y: -2,
          boxShadow: "0 8px 32px rgba(0,0,0,0.1), 0 2px 8px rgba(0,0,0,0.06)",
          transition: { duration: 0.2 },
        }}
      >
        {/* Unread indicator bar */}
        <AnimatePresence>
          {!notif.isRead && (
            <motion.div
              initial={{ scaleY: 0 }}
              animate={{ scaleY: 1 }}
              exit={{ scaleY: 0 }}
              className="absolute left-0 top-0 bottom-0 w-[3px] rounded-l-xl origin-top"
              style={{ background: cfg.accent }}
            />
          )}
        </AnimatePresence>

        {cardContent}
      </motion.div>

      {isLowStock && (
        <DialogContent className="sm:max-w-[400px] rounded-[24px] border-none shadow-2xl bg-white/95 backdrop-blur-xl p-6 overflow-hidden">
          <DialogHeader className="mb-4">
            <div className="w-12 h-12 rounded-2xl bg-amber-50 flex items-center justify-center text-amber-500 mb-3 border border-amber-100">
              {Icons.package}
            </div>
            <DialogTitle className="text-xl font-black text-slate-900 tracking-tight"> Fast Restock </DialogTitle>
            <DialogDescription className="text-sm text-slate-500 font-medium leading-relaxed">
              Replenish inventory directly from the command center. This action will commit to the Vault immediately.
            </DialogDescription>
          </DialogHeader>
          <RestockForm 
            n={notif as any} 
            onSuccess={() => {
              setIsOpen(false)
              onMarkRead(notif.id)
            }} 
          />
        </DialogContent>
      )}
    </Dialog>
  )
}
