import React from 'react'
import { formatDistanceToNow } from 'date-fns'
import Link from 'next/link'
import { Icons, TYPE_CONFIG } from '../constants/notification.config'
import { NotificationCardProps } from '../types/notification.types'
import { cn } from '@/lib/utils'
import { User, Activity, Clock, ChevronRight, Hash, Trash2 } from 'lucide-react'

import { resolveSystemRoute } from '@/lib/utils/route-resolver'

export function NotificationCard({ notif, onMarkRead, onDelete, onClose }: NotificationCardProps) {

  const cfg = TYPE_CONFIG[notif.type] || {
    icon: Icons.box,
    label: "Update",
    accent: "#64748b",
    bg: "rgba(241, 245, 249, 0.8)",
    border: "rgba(148, 163, 184, 0.1)",
  }

  const meta = notif.metadata || {}
  const parsedQtyFromMessage = (() => {
    if (typeof notif.message !== 'string') return null
    const match = notif.message.match(/\(Qty:\s*(\d+)\)/i)
    return match ? Number(match[1]) : null
  })()
  const quantity =
    typeof meta.quantity === 'number'
      ? meta.quantity
      : Number.isFinite(Number(meta.quantity))
      ? Number(meta.quantity)
      : parsedQtyFromMessage

  const target = resolveSystemRoute({
    type: notif.type,
    metadata: notif.metadata,
    reference_id: notif.reference_id,
    id: notif.id,
    title: notif.title
  })

  return (
    <Link 
      href={target || '#'}
      onClick={() => { if (!notif.isRead) onMarkRead(notif.id); if (onClose) onClose(); }}
      className={cn(
        "group relative flex flex-col p-[13px] transition-all duration-300 cursor-pointer overflow-visible mb-2",
        "rounded-[20px] border border-slate-200",
        !notif.isRead 
          ? "bg-white shadow-[0_12px_40px_-12px_rgba(0,0,0,0.1)] ring-1 ring-blue-500/10" 
          : "bg-slate-100/60 shadow-sm border-slate-100 grayscale-[0.3] opacity-80",
        "hover:shadow-[0_20px_50px_-15px_rgba(0,0,0,0.15)] hover:-translate-y-0.5 mx-1 mt-5"
      )}
    >
      {/* 🛡️ TACTICAL SPATIAL ICON */}
      <div 
        className={cn(
            "absolute -top-3.5 left-5 w-8 h-8 rounded-[10px] flex items-center justify-center shadow-lg ring-[4px] ring-white transition-transform group-hover:scale-110 z-10",
            notif.isRead && "opacity-50 grayscale"
        )}
        style={{ background: cfg.bg, color: cfg.accent }}
      >
        {React.cloneElement(cfg.icon as React.ReactElement<{ size: number; strokeWidth: number }>, { size: 14, strokeWidth: 3 })}
      </div>

      {/* HEADER COMMAND ROW */}
      <div className="flex items-center justify-between gap-4 mb-2.5 pt-0.5 pl-10">
        <div className="flex items-center gap-2 flex-1 min-w-0">
          <span className="text-[9px] font-black uppercase tracking-[0.1em] px-2 py-0.5 rounded-md bg-white border border-slate-100 text-slate-500">
            {cfg.label}
          </span>
          <span className="text-slate-300">·</span>
          <div className="flex items-center gap-1.5 text-slate-400">
            <Clock className="w-3.5 h-3.5 opacity-40 text-slate-500" />
            <span className="text-[9px] font-black tabular-nums tracking-tighter">
                {notif.time ? formatDistanceToNow(new Date(notif.time), { addSuffix: true }).toUpperCase() : 'NOW'}
            </span>
          </div>
        </div>

        <div className="flex items-center gap-2">
            {!notif.isRead && (
                <div className="w-2 h-2 rounded-full bg-blue-500 shadow-[0_0_8px_rgba(59,130,246,0.8)] animate-pulse shrink-0" />
            )}
            <div className={cn(
                "shrink-0 px-2 py-1 text-[9px] font-black uppercase tracking-[0.1em] bg-white border border-slate-200 rounded-lg group-hover:bg-slate-900 group-hover:text-white transition-all shadow-sm",
                !notif.isRead ? "text-slate-900" : "text-slate-400"
            )}>
                OPEN
            </div>
        </div>
      </div>

      <div className="space-y-1.5 pl-1">
        <div className="flex items-center gap-3">
          <div className="shrink-0 opacity-20"><Activity className="w-4.5 h-4.5 text-slate-900" /></div>
          <h4 className={cn(
            "text-[13px] font-black tracking-tight uppercase leading-none truncate",
            !notif.isRead ? "text-slate-900" : "text-slate-500"
          )}>
            {notif.title}
          </h4>
        </div>
        <div className="flex items-center gap-3">
           <div className="shrink-0 opacity-20">
            {notif.type.includes('user') ? <User className="w-4.5 h-4.5 text-slate-900" /> : <ChevronRight className="w-4.5 h-4.5 text-slate-900" />}
           </div>
           <p className={cn(
            "text-[11px] font-bold leading-tight truncate",
            !notif.isRead ? "text-slate-600" : "text-slate-400"
           )}>
             {meta.borrower_name || notif.title}
           </p>
        </div>
      </div>

      {/* FOOTER DATA SHELF */}
      <div className="mt-3 flex items-center justify-between gap-2 border-t border-slate-100/50 pt-2.5 pb-0.5">
        <div className="flex items-center gap-5">
             {(() => {
                const itemName = meta.item_name || meta.search_query || (notif.title.includes(':') ? notif.title.split(':').pop()?.trim() : null);
                if (!itemName) return null;
                return (
                    <div className="inline-flex items-center gap-2 font-black uppercase text-[10px] tracking-tight">
                        <span className="opacity-20 text-[8px] text-slate-500">UNIT:</span>
                        <span className={cn("truncate max-w-[200px]", !notif.isRead ? "text-slate-800" : "text-slate-400")}>{itemName}</span>
                    </div>
                );
            })()}
            {meta.id && (
                <div className="flex items-center gap-1.5 text-[10px] font-black font-mono uppercase tracking-tighter text-slate-300">
                    <Hash className="w-3.5 h-3.5 opacity-20 text-blue-600" />
                    {meta.id.toString().slice(-6)}
                </div>
            )}
            {notif.type === 'item_returned' && (
                quantity && quantity > 0 ? (
                  <div className={cn(
                    "inline-flex items-center gap-1.5 rounded-md border px-1.5 py-0.5 text-[9px] font-black uppercase tracking-[0.1em]",
                    !notif.isRead ? "border-emerald-200 bg-emerald-50 text-emerald-700" : "border-slate-200 bg-white text-slate-400"
                  )}>
                    <span className="opacity-70">Qty</span>
                    <span>x{quantity}</span>
                  </div>
                ) : (
                  <div className={cn(
                    "inline-flex items-center gap-1.5 rounded-md border px-1.5 py-0.5 text-[9px] font-black uppercase tracking-[0.1em]",
                    !notif.isRead ? "border-amber-200 bg-amber-50 text-amber-700" : "border-slate-200 bg-white text-slate-400"
                  )}>
                    <span>Qty unavailable</span>
                  </div>
                )
            )}
        </div>
        {onDelete && (
          <button onClick={(e) => { e.preventDefault(); e.stopPropagation(); onDelete(notif.id); }} className="opacity-0 group-hover:opacity-100 text-slate-300 hover:text-red-600 transition-all p-1.5 hover:bg-red-50 rounded-lg active:scale-90">
            <Trash2 className="w-4 h-4" />
          </button>
        )}
      </div>
    </Link>
  )
}

export default NotificationCard;
