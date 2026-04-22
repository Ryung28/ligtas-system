'use client'

import React from 'react'
import { Layers, Box, User, BellRing } from 'lucide-react'
import { cn } from '@/lib/utils'
import { Category } from '../types/notification.types'

interface NotificationFiltersProps {
  activeFilter: Category
  setActiveFilter: (filter: Category) => void
  filters: Category[]
}

export function NotificationFilters({ activeFilter, setActiveFilter, filters }: NotificationFiltersProps) {
  return (
    <div className="px-5 pb-4">
      <div className="flex p-1 rounded-full bg-slate-100/60 backdrop-blur-md shadow-[inset_0_2px_4px_rgba(0,0,0,0.06)] border border-white/20">
        {filters.map((f) => (
          <button
            key={f}
            onClick={() => setActiveFilter(f)}
            className={cn(
              "flex-1 flex items-center justify-center gap-1.5 rounded-full px-4 py-1.5 text-[13px] font-medium transition-all duration-300 outline-none",
              activeFilter === f 
                ? "bg-zinc-950 text-white shadow-md" 
                : "text-slate-500 hover:text-slate-800 hover:bg-white/60"
            )}
          >
            {f === "ALL" && <Layers className="w-3.5 h-3.5" strokeWidth={2.5} />}
            {f === "LOGS" && <Box className="w-3.5 h-3.5" strokeWidth={2.5} />}
            {f === "AUTH" && <User className="w-3.5 h-3.5" strokeWidth={2.5} />}
            {f === "ALERTS" && <BellRing className="w-3.5 h-3.5" strokeWidth={2.5} />}
            <span>{f.charAt(0).toUpperCase() + f.slice(1).toLowerCase()}</span>
          </button>
        ))}
      </div>
    </div>
  )
}
