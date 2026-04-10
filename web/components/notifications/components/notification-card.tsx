import React from 'react'
import { formatDistanceToNow } from 'date-fns'
import { useRouter } from 'next/navigation'
import { Icons, TYPE_CONFIG } from '../constants/notification.config'
import { NotificationCardProps } from '../types/notification.types'
import { Button } from '@/components/ui/button'
import { cn } from '@/lib/utils'

export function NotificationCard({ notif, onMarkRead, onDelete }: NotificationCardProps) {
  const router = useRouter()
  
  const cfg = TYPE_CONFIG[notif.type] || {
    icon: Icons.box,
    label: "Update",
    accent: "#64748b",
    bg: "rgba(241, 245, 249, 0.8)",
    border: "rgba(148, 163, 184, 0.1)",
  }

  const isCritical = ['stock_out', 'item_overdue', 'borrow_rejected'].includes(notif.type);
  const meta = notif.metadata || {}

    const getTargetRoute = () => {
      const message = notif.message || notif.description || ""
      const title = notif.title || ""
      
      // 1. ASSET DOMAIN (The "What"): Redirect to Inventory Hub
      // 🛡️ Priority One: Explicit Stock/Inventory types
      const isInventoryContext = [
        'stock_low', 'stock_out', 'low_stock', 'inventory_alert'
      ].includes(notif.type) || (notif.id && notif.id.startsWith('inv-'))
      
      if (isInventoryContext) {
        const itemName = meta.search_query || meta.item_name || title
        const itemId = meta.item_id || meta.id || notif.reference_id || ''
        return `/dashboard/inventory?search=${encodeURIComponent(itemName)}&id=${itemId}&highlight=true`
      }

      // 2. IDENTITY/LOGISTICS DOMAIN (The "Who"): Redirect to Logs
      // 🛡️ TACTICAL NAME EXTRACTION (Fallback for Legacy/Unpatched Notifs)
      const extractName = () => {
        // Check Metadata first (Highest priority)
        if (meta.search_query) return meta.search_query
        if (meta.borrower_name) return meta.borrower_name
        if (meta.requester_name) return meta.requester_name
        
        // Regex Scan from message ("from Lll", "by Lll")
        const fromMatch = message.match(/from\s+([A-Za-z0-9\s]+?)(?=\s*\()|from\s+([A-Za-z0-9\s]+?)$|by\s+([A-Za-z0-9\s]+?)(?=\s*\.|$)/i)
        if (fromMatch) return (fromMatch[1] || fromMatch[2] || fromMatch[3]).trim()
        
        // Fallback to title keywords if title contains user info
        if (title.includes("BORROWER") || title.includes("USER")) return title.split(":").pop()?.trim() || ""
        
        return ""
      }

      const identityTypes = [
        'borrow_request', 'item_overdue', 'item_returned', 
        'user_pending', 'user_request', 'borrow_approved', 'borrow_rejected'
      ]
      
      const targetName = extractName()
      const isIdentityContext = identityTypes.includes(notif.type) || 
                               (notif.id && (notif.id.startsWith('log-') || notif.id.startsWith('bor-'))) ||
                               targetName.length > 0

      if (isIdentityContext) {
        return `/dashboard/logs?search=${encodeURIComponent(targetName)}&id=${meta.borrower_user_id || meta.id || notif.reference_id || ''}&highlight=true`
      }
      
      return null
    }

  const getActionLabel = (type: string) => {
    switch(type) {
      case 'stock_low':
      case 'stock_out':
      case 'low_stock': return 'RESTOCK';
      case 'item_overdue': return 'RECALL';
      case 'user_pending':
      case 'user_request': return 'REVIEW';
      case 'borrow_approved':
      case 'item_returned': return 'ARCHIVE';
      default: return 'DETAILS';
    }
  }

  const actionLabel = getActionLabel(notif.type);

  const onRoute = () => {
    if (!notif.isRead) onMarkRead(notif.id)
    const target = getTargetRoute()
    if (target) router.push(target)
  }

  return (
    <div 
      className={cn(
        "group relative flex items-start gap-3 p-3 transition-all cursor-pointer border-b border-slate-100/50 hover:bg-slate-50",
        !notif.isRead && "bg-blue-50/20"
      )}
      onClick={onRoute}
    >
      {/* Intent Strip (The Admin Edge) */}
      <div 
        className="absolute left-0 top-[10%] bottom-[10%] w-[2.5px] rounded-r-full"
        style={{ backgroundColor: cfg.accent }}
      />

      <div className="relative flex-shrink-0">
        <div 
          className="w-9 h-9 rounded-xl flex items-center justify-center transition-transform group-hover:scale-105 border border-slate-200/50 shadow-sm"
          style={{ background: cfg.bg, color: cfg.accent }}
        >
          {React.cloneElement(cfg.icon as React.ReactElement<{ size: number; strokeWidth: number }>, { size: 16, strokeWidth: 2 })}
        </div>
      </div>

      <div className="flex-1 min-w-0">
        <div className="flex items-center gap-2 mb-0.5">
          <span className="text-[10px] font-bold uppercase tracking-wider font-mono opacity-90" style={{ color: cfg.accent }}>
            {cfg.label}
          </span>
          {isCritical && (
            <span className="px-1.5 py-0.5 rounded-[4px] bg-[#991b1b15] text-[#991b1b] text-[8px] font-black tracking-tighter uppercase border border-[#991b1b20]">
              CRITICAL
            </span>
          )}
          <span className="text-[10px] text-slate-400">•</span>
          <span className="text-[10px] text-slate-400 font-medium tabular-nums">
            {formatDistanceToNow(new Date(notif.time))}
          </span>
          {!notif.isRead && (
             <div className="ml-auto w-1.5 h-1.5 rounded-full" style={{ backgroundColor: cfg.accent }} />
          )}
        </div>

        <div className="mb-1">
          <h4 className={cn(
            "text-sm font-black truncate tracking-tight text-slate-900 group-hover:text-black transition-colors uppercase"
          )}>
            {notif.title}
          </h4>
        </div>
        
        <div className="mb-2">
          <p className="text-[11px] text-slate-700 truncate font-bold font-sans">
            {meta.borrower_name || notif.title}
          </p>
          {meta.borrower_organization && (
            <span className="text-[7px] inline-block bg-slate-100 text-slate-500 px-1 py-0.5 rounded-[2px] font-black uppercase tracking-widest leading-none border border-slate-200 mt-1">
              {meta.borrower_organization}
            </span>
          )}
        </div>

        {(() => {
          const itemName = meta.item_name || meta.search_query || (notif.title.includes(':') ? notif.title.split(':').pop()?.trim() : null);
          const quantity = meta.quantity || (notif.message?.match(/\(Qty:\s*(\d+)\)/i)?.[1]);
          
          if (!itemName) return null;

          return (
            <div className="mb-2">
              <span className="inline-flex items-center gap-1.5 text-zinc-900 font-bold bg-zinc-50 px-1.5 py-1 rounded-[4px] border border-zinc-200 uppercase text-[9px] tracking-tight shadow-sm">
                  <span className="opacity-60 text-[8px]">ITEM:</span>
                  {itemName}
                  {quantity && (
                    <span className="text-zinc-400 bg-white px-1 rounded-[2px] border border-zinc-100 font-mono italic">x{quantity}</span>
                  )}
              </span>
            </div>
          );
        })()}
        
        {/* 🛡️ DESCRIPTION: Removed as redundant with Title + Item Chips */}

        {meta.id && (
          <p className="text-[8px] text-slate-300 font-mono mt-1.5 font-bold tracking-tighter uppercase">
            TXN: #{meta.id.toString().slice(-6)}
          </p>
        )}
      </div>

      <div className="flex items-center self-center pl-2 gap-2">
        <Button 
          variant="ghost" 
          size="sm" 
          className="opacity-0 group-hover:opacity-100 transition-all h-7 px-2.5 text-[9px] font-black uppercase tracking-[0.15em] border border-slate-200/80 bg-white hover:bg-slate-50"
          style={{ color: cfg.accent }}
        >
          {actionLabel}
        </Button>
        
        {onDelete && (
          <button
            onClick={(e) => {
              e.stopPropagation();
              onDelete(notif.id);
            }}
            className="opacity-0 group-hover:opacity-100 text-slate-400 hover:text-red-500 transition-all p-1 hover:bg-red-50 rounded-md active:scale-90"
            aria-label="Delete log"
          >
            {React.cloneElement(Icons.trash as React.ReactElement<{ size: number; strokeWidth: number }>, { size: 12, strokeWidth: 2.5 })}
          </button>
        )}
      </div>
    </div>
  )
}
