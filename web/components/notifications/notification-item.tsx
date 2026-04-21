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

  if (!item) return null;

  try {
    const IconComponent = (icons as any)[item.type] || Bell

    return (
      <div 
        role="button"
        tabIndex={0}
        onClick={() => {
          if (!item.isRead && item.id && !item.id.includes('err-packet')) {
              onMarkAsRead(item.id);
          }
          
          const meta = item.metadata || {};
          const title = item.title || "";
          const message = item.message || item.description || "";

          // 1. ASSET DOMAIN (The "What"): Redirect to Inventory Hub
          const isInventoryContext = [
            'stock_low', 'stock_out', 'low_stock', 'inventory_alert'
          ].includes(item.type) || (item.id && item.id.startsWith('inv-'));

          if (isInventoryContext) {
            const itemId = meta.item_id || meta.id || item.referenceId || '';
            const itemName = meta.item_name || meta.search_query || title;
            const target = `/dashboard/inventory?id=${itemId}&search=${encodeURIComponent(itemName)}&highlight=true`;
            router.push(target);
            return;
          }

          // 2. IDENTITY/LOGISTICS DOMAIN (The "Who"): Redirect to Logs
          const extractName = () => {
            if (meta.search_query) return meta.search_query;
            if (meta.borrower_name) return meta.borrower_name;
            if (meta.requester_name) return meta.requester_name;
            const fromMatch = message.match(/from\s+([A-Za-z0-9\s]+?)(?=\s*\()|from\s+([A-Za-z0-9\s]+?)$|by\s+([A-Za-z0-9\s]+?)(?=\s*\.|$)/i);
            if (fromMatch) return (fromMatch[1] || fromMatch[2] || fromMatch[3]).trim();
            if (title.includes("BORROWER") || title.includes("USER")) return title.split(":").pop()?.trim() || "";
            return "";
          };

          const identityTypes = [
            'borrow_request', 'item_overdue', 'item_returned', 
            'user_pending', 'user_request', 'borrow_approved', 'borrow_rejected'
          ];
          
          const targetName = extractName();
          const isIdentityContext = identityTypes.includes(item.type) || 
                                   (item.id && (item.id.startsWith('log-') || item.id.startsWith('bor-'))) ||
                                   targetName.length > 0;

          if (isIdentityContext) {
            // 🛡️ AGGRESSIVE ID HUNTER: Search all possible identity sinks
            const transactionId = item.referenceId || 
                                 meta.log_id || 
                                 meta.borrow_id || 
                                 meta.reference_id || 
                                 meta.id || 
                                 meta.borrower_user_id || 
                                 '';

            const target = `/dashboard/logs?id=${transactionId}&search=${encodeURIComponent(targetName)}&highlight=true`;
            router.push(target);
            return;
          }

          // Fallback to existing action target if available
          if (item.action?.target) {
            const target = item.action.target === 'restock_modal' ? '/dashboard/inventory' : item.action.target;
            router.push(target);
          }
        }}
        className={cn(
          "relative p-4 flex items-start gap-4 cursor-pointer transition-all duration-300 group outline-none",
          "bg-white rounded-xl border border-slate-200 shadow-sm hover:shadow-md hover:-translate-y-0.5",
          "border-l-[6px]",
          borderColors[item.type as keyof typeof borderColors] || "border-l-slate-300",
          item.isRead ? "opacity-75" : "opacity-100"
        )}
      >
        <div className="relative shrink-0 mt-1">
          <div className={cn(
            "h-10 w-10 rounded-xl flex items-center justify-center transition-all duration-300 shadow-sm ring-1 ring-white/50",
            !item.isRead ? colors[item.type as keyof typeof colors] : "bg-slate-100",
            !item.isRead ? "text-white" : "text-slate-400"
          )}>
            <IconComponent className="w-5 h-5" />
          </div>
        </div>
        
        <div className="flex-1 min-w-0">
          <div className="flex items-center justify-between gap-2 mb-1">
            <div className="flex items-center gap-1.5 min-w-0">
              <span className={cn(
                "text-[9px] font-black tracking-[0.15em] uppercase truncate",
                !item.isRead ? "text-emerald-600" : "text-slate-400"
              )}>
                {item.type.includes('stock') ? 'INVENTORY' : item.type.includes('user') ? 'ACCESS' : 'LOGISTICS'}
              </span>
              <span className="text-slate-300">·</span>
              <span className="text-[9px] font-bold text-slate-400 tabular-nums uppercase">
                {item.time ? formatDistanceToNow(new Date(item.time), { addSuffix: true }).toUpperCase() : 'JUST NOW'}
              </span>
            </div>
            {!item.isRead && (
              <span className="flex h-2 w-2 rounded-full bg-emerald-500 animate-pulse ring-4 ring-emerald-500/10"></span>
            )}
          </div>

          <h4 className={cn(
            "text-[13px] font-black uppercase tracking-tight truncate transition-colors leading-tight mb-0.5",
            !item.isRead ? "text-slate-900" : "text-slate-500"
          )}>
            {item.title}
          </h4>

          <p className="text-[12px] text-slate-500 font-medium leading-relaxed opacity-90 mb-3">
            {item.message}
          </p>

          {/* 🛡️ DATA TAGS: Premium Context Labels */}
          {(item.metadata?.item_name || item.metadata?.borrower_name || item.metadata?.id) && (
            <div className="flex flex-wrap gap-1.5">
              <span className="inline-flex items-center px-1.5 py-0.5 rounded-md bg-slate-100 border border-slate-200 text-[9px] font-black text-slate-600 uppercase tracking-wider">
                ITEM: <span className="ml-1 text-slate-900">{item.metadata?.item_name || item.metadata?.id || 'ALPHA-DATA'}</span>
              </span>
            </div>
          )}
        </div>

        {onDelete && (
          <button
            onClick={(e) => {
              e.stopPropagation();
              onDelete(item.id);
            }}
            className="opacity-0 group-hover:opacity-100 text-slate-300 hover:text-red-500 transition-all p-2 hover:bg-red-50 rounded-xl active:scale-95 mt-0.5"
            aria-label="Delete log"
          >
            <Trash2 className="w-4 h-4" />
          </button>
        )}
      </div>
    )
  } catch (error) {
    console.error('[NotificationItem] Render Crash:', error);
    return null;
  }
}
