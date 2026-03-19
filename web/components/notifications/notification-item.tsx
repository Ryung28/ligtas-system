import React, { useState } from 'react'
import { formatDistanceToNow } from 'date-fns'
import { useRouter } from 'next/navigation'
import { Bell, Shield, Package, Clock, UserCheck, AlertTriangle, XCircle, UserPlus, MessageSquare, Trash2 } from 'lucide-react'
import { cn } from '@/lib/utils'
import { type NotificationItem } from '@/lib/validations/notifications'
import { Dialog, DialogContent, DialogHeader, DialogTitle, DialogDescription } from '@/components/ui/dialog'
import { RestockForm } from '@/components/layout/_components/RestockForm'

const icons = {
  borrow: Shield,
  return: Clock,
  stock_low: AlertTriangle,
  stock_out: XCircle,
  user_pending: UserPlus,
  borrow_request: Shield,
  overdue_alert: Bell,
  chat_message: MessageSquare,
  system_alert: Bell,
}

const colors = {
  borrow: 'bg-blue-500',
  return: 'bg-emerald-500',
  stock_low: 'bg-amber-500',
  stock_out: 'bg-rose-600',
  user_pending: 'bg-indigo-500',
  borrow_request: 'bg-blue-600',
  overdue_alert: 'bg-orange-500',
  chat_message: 'bg-violet-500',
  system_alert: 'bg-slate-600',
}

const borderColors = {
  borrow: 'border-l-blue-500',
  return: 'border-l-emerald-500',
  stock_low: 'border-l-amber-500',
  stock_out: 'border-l-rose-600',
  user_pending: 'border-l-indigo-500',
  borrow_request: 'border-l-blue-600',
  overdue_alert: 'border-l-orange-500',
  chat_message: 'border-l-violet-500',
  system_alert: 'border-l-slate-500',
}

interface NotificationItemProps {
  item: NotificationItem
  onMarkAsRead: (id: string) => void
  onRefresh: () => void
  onDelete?: (id: string) => void
}

/**
 * 🛡️ TACTICAL PREMIUM NOTIFICATION ITEM
 * Implements the asymmetric rounding and neumorphic shadow standards.
 */
export const NotificationItemComponent: React.FC<NotificationItemProps> = ({ item, onMarkAsRead, onRefresh, onDelete }) => {
  const router = useRouter()
  const [isRestockOpen, setIsRestockOpen] = useState(false)

  // 🛡️ COMPONENT CRASH GUARD: Defensive property access
  if (!item) return null;

  try {
    const IconComponent = (icons as any)[item.type] || Bell
    const isBroadcast = !item.userId // 🛡️ camelCase: Consistent with repo mapper

    const onExecuteAction = (e: React.MouseEvent | React.KeyboardEvent) => {
      e.stopPropagation(); // 🛡️ Prevent parent div from double-firing
      if (!item.isRead && item.id && !item.id.includes('err-packet')) {
          onMarkAsRead(item.id);
      }
      
      if (!item.action) return;

      if (item.action.type === 'link') {
        router.push(item.action.target);
      } else if (item.action.type === 'dialog' && item.action.target === 'restock_modal') {
        // 🛡️ INLINE ORCHESTRATION: Mount dialog locally instead of global route change
        setIsRestockOpen(true);
      }
    }

    return (
      <>
        <div 
          role="button"
          tabIndex={0}
          aria-label={item.isRead ? 'Notification' : 'Unread notification, click to mark as read'}
          onClick={() => {
            if (!item.isRead && item.id && !item.id.includes('err-packet')) {
                onMarkAsRead(item.id);
            }
          }}
          onKeyDown={(e) => {
            if (e.key === 'Enter' && !item.isRead && item.id && !item.id.includes('err-packet')) {
                onMarkAsRead(item.id);
            }
          }}
          className={cn(
            "p-4 mb-3 cursor-pointer transition-all duration-500 relative overflow-hidden group outline-none",
            "animate-in fade-in slide-in-from-right-4",
            // 📐 ASYMMETRICAL GEOMETRY: Sharp top-left (Command Zero)
            "rounded-tl-none rounded-tr-2xl rounded-br-2xl rounded-bl-2xl",
            // 💎 PREMIUM DEPTH: White for unread, "Arctic Glass" for read
            !item.isRead 
                ? "bg-white border-transparent shadow-[0_30px_60px_-12px_rgba(0,0,0,0.08),0_18px_36px_-18px_rgba(0,0,0,0.1)] scale-[1.01] z-10" 
                : "bg-slate-50/40 border-slate-100 hover:bg-white hover:shadow-md opacity-80 hover:opacity-100",
            "border-l-4",
            borderColors[item.type as keyof typeof borderColors] || 'border-l-slate-300'
          )}
        >
          {/* 🌫️ REFLECTIVE GLOW (Unread only) */}
          {!item.isRead && (
            <div className="absolute -inset-4 bg-gradient-to-tr from-blue-500/5 via-transparent to-transparent blur-2xl group-hover:from-blue-500/10 transition-all duration-700 pointer-events-none" />
          )}

          <div className="flex gap-4 relative z-10">
            <div className="relative">
                <div className={cn(
                    "p-2.5 rounded-xl h-fit transition-all duration-500",
                    !item.isRead ? "bg-slate-900 text-white shadow-xl scale-110" : "bg-slate-200/50 text-slate-500"
                )}>
                    <IconComponent className="w-4 h-4" />
                </div>
                {!item.isRead && (
                    <span className="absolute -top-1 -right-1 flex h-3 w-3">
                        <span className="animate-ping absolute inline-flex h-full w-full rounded-full bg-blue-400 opacity-75"></span>
                        <span className="relative inline-flex rounded-full h-3 w-3 bg-blue-500 border-2 border-white"></span>
                    </span>
                 )}
            </div>
            
            <div className="flex-1 space-y-1.5">
              <div className="flex justify-between items-start gap-2">
                <div className="flex flex-col">
                    <span className={cn(
                        "text-[9px] font-black tracking-[0.25em] uppercase mb-1",
                        isBroadcast ? "text-amber-600" : "text-blue-600"
                    )}>
                        {isBroadcast ? "Global Broadcast" : "Direct Command"}
                    </span>
                    <h4 className={cn(
                        "text-sm font-bold tracking-tight leading-tight transition-colors",
                        !item.isRead ? "text-slate-950" : "text-slate-600"
                    )}>
                        {item.title || 'Notification Intel'}
                    </h4>
                </div>
                <div className="flex flex-col items-end shrink-0 gap-1.5 mt-0.5">
                    <span className="text-[10px] tabular-nums font-bold text-slate-400 font-mono tracking-tighter leading-none">
                        {item.time ? formatDistanceToNow(new Date(item.time), { addSuffix: false }).toUpperCase() : 'NOW'}
                    </span>
                    <div className="flex items-center gap-2 mt-1">
                        {onDelete && (
                            <button
                                onClick={(e) => {
                                    e.stopPropagation();
                                    onDelete(item.id);
                                }}
                                className="text-slate-300 hover:text-red-500 transition-colors bg-white/50 rounded-full p-1 shadow-sm hover:shadow border border-slate-100 active:scale-95"
                                aria-label="Delete intel"
                            >
                                <Trash2 className="w-3.5 h-3.5" />
                            </button>
                        )}
                        {!item.isRead && (
                            <span className="text-[8px] font-black text-blue-500 leading-none animate-pulse">NEW</span>
                        )}
                    </div>
                </div>
              </div>
              
              <p className={cn(
                "text-xs leading-relaxed line-clamp-2 transition-colors",
                !item.isRead ? "text-slate-600 font-medium" : "text-slate-500/70 italic"
              )}>
                {item.message || 'Transmission received.'}
              </p>
              
              {item.action && !item.isRead && (
                <div className="pt-3">
                  <button 
                    onClick={onExecuteAction}
                    className="group/btn relative px-4 py-2 bg-slate-900 text-white overflow-hidden transition-all duration-300 rounded-lg outline-none active:scale-95 shadow-lg shadow-slate-200"
                  >
                    <div className="absolute inset-x-0 bottom-0 h-0.5 bg-blue-500 transform scale-x-0 group-hover/btn:scale-x-100 transition-transform duration-500 origin-left" />
                    <div className="flex items-center gap-2">
                        <span className="text-[10px] font-black tracking-widest uppercase">
                            {item.action?.label || 'Execute Intel'}
                        </span>
                        <span className="text-xs transition-transform group-hover/btn:translate-x-1 duration-300">→</span>
                    </div>
                  </button>
                </div>
              )}
            </div>
          </div>
        </div>

        {/* 🛡️ TACTICAL RESTOCK DIALOG: Local Orchestration */}
        <Dialog open={isRestockOpen} onOpenChange={setIsRestockOpen}>
          <DialogContent className="sm:max-w-[500px] p-0 overflow-hidden rounded-tl-none rounded-tr-2xl rounded-b-2xl border-slate-200/60 shadow-[0_20px_50px_rgba(0,0,0,0.15)] bg-white/95 backdrop-blur-xl z-[100]">
            <DialogHeader className="p-6 pb-0">
              <DialogTitle className="text-xl font-bold tracking-tight text-slate-900 uppercase">Resource Intelligence: Restock</DialogTitle>
              <DialogDescription className="text-sm text-slate-500 italic">
                Updating logistics ledger for {item.title}.
              </DialogDescription>
            </DialogHeader>
            <div className="p-6">
              <RestockForm 
                n={item} 
                onSuccess={async () => {
                  setIsRestockOpen(false);
                  
                  // 🛡️ TACTICAL SYNC: The hook's Realtime listener will handle the card removal
                  if (item.id) {
                    await onMarkAsRead(item.id);
                  }
                }} 
              />
            </div>
          </DialogContent>
        </Dialog>
      </>
    )
  } catch (error) {
    console.error('[NotificationItem] Render Crash:', error);
    return null;
  }
}
