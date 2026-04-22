'use client'

import React from 'react'
import { formatDistanceToNow } from 'date-fns'
import { useRouter } from 'next/navigation'
import { Bell, Shield, Clock, AlertTriangle, XCircle, UserPlus, MessageSquare, Trash2 } from 'lucide-react'
import { cn } from '@/lib/utils'
import { type NotificationItem } from '@/lib/validations/notifications'

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

interface MobileNotificationItemProps {
  item: NotificationItem
  onMarkAsRead: (id: string) => void
  onDelete?: (id: string) => void
  onClose: () => void
}

/**
 * 📱 MOBILE NOTIFICATION ITEM
 * Specialized for mobile routes (/m) and high-density touch targets.
 */
export function MobileNotificationItem({ item, onMarkAsRead, onDelete, onClose }: MobileNotificationItemProps) {
  const router = useRouter()

  if (!item) return null;

  const IconComponent = (icons as any)[item.type] || Bell

  const handleClick = () => {
    if (!item.isRead && item.id && !item.id.includes('err-packet')) {
        onMarkAsRead(item.id);
    }
    
    onClose(); // Close sheet before navigating

    const meta = item.metadata || {};
    const title = item.title || "";
    const message = item.message || item.description || "";

    // 1. INVENTORY CONTEXT -> /m/inventory
    const isInventoryContext = [
      'stock_low', 'stock_out', 'low_stock', 'inventory_alert'
    ].includes(item.type) || (item.id && item.id.startsWith('inv-'));

    if (isInventoryContext) {
      const itemId = meta.item_id || meta.id || item.referenceId || '';
      router.push(`/m/inventory/${itemId}`);
      return;
    }

    // 2. IDENTITY/APPROVAL CONTEXT -> /m/approvals or /m/borrowers
    // For now, most identity context on mobile maps to Approvals or Logs.
    const identityTypes = [
      'borrow_request', 'item_overdue', 'item_returned', 
      'user_pending', 'user_request', 'borrow_approved', 'borrow_rejected'
    ];
    
    const isIdentityContext = identityTypes.includes(item.type) || 
                             (item.id && (item.id.startsWith('log-') || item.id.startsWith('bor-')));

    if (isIdentityContext) {
      // If it's a request, go to approvals. 
      if (item.type.includes('request') || item.type.includes('pending')) {
        router.push('/m/approvals');
      } else {
        router.push('/m/logs');
      }
      return;
    }

    // Fallback: Default to dash
    router.push('/m');
  }

  return (
    <div 
      onClick={handleClick}
      className={cn(
        "py-4 flex items-center gap-4 cursor-pointer active:bg-gray-50 transition-colors border-b border-gray-100 last:border-0",
        !item.isRead ? "opacity-100" : "opacity-60"
      )}
    >
      <div className="relative shrink-0">
        <div className={cn(
          "h-10 w-10 rounded-xl flex items-center justify-center shadow-sm",
          !item.isRead ? colors[item.type as keyof typeof colors] : "bg-gray-100",
          !item.isRead ? "text-white" : "text-gray-400"
        )}>
          <IconComponent className="w-5 h-5" />
        </div>
        {!item.isRead && (
          <span className="absolute -top-0.5 -right-0.5 flex h-2.5 w-2.5">
            <span className="animate-ping absolute inline-flex h-full w-full rounded-full bg-red-400 opacity-75"></span>
            <span className="relative inline-flex rounded-full h-2.5 w-2.5 bg-red-500 border-2 border-white"></span>
          </span>
        )}
      </div>
      
      <div className="flex-1 min-w-0">
        <div className="flex items-center justify-between gap-2 mb-0.5">
          <span className={cn(
            "text-[9px] font-black uppercase tracking-widest",
            !item.isRead ? "text-red-600" : "text-gray-400"
          )}>
            {item.type.replace(/_/g, ' ')}
          </span>
          <span className="text-[10px] font-medium text-gray-400">
            {item.time ? formatDistanceToNow(new Date(item.time), { addSuffix: true }) : 'now'}
          </span>
        </div>
        <h4 className={cn(
          "text-sm font-bold truncate leading-tight",
          !item.isRead ? "text-gray-900" : "text-gray-500"
        )}>
          {item.title}
        </h4>
        <p className="text-xs text-gray-500 truncate mt-0.5">
          {item.message}
        </p>
      </div>

      {onDelete && (
        <button
          onClick={(e) => {
            e.stopPropagation();
            onDelete(item.id);
          }}
          className="p-2 text-gray-300 hover:text-red-500 active:scale-95"
          aria-label="Delete"
        >
          <Trash2 className="w-4 h-4" />
        </button>
      )}
    </div>
  )
}
