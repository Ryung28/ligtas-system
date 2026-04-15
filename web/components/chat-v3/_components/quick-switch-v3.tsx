'use client'

import React from 'react'
import { cn } from '@/lib/utils'

interface QuickSwitchRoom {
    id: string
    name: string
}

interface QuickSwitchV3Props {
    rooms: QuickSwitchRoom[]
    activeRoomId: string
    onSwitch: (id: string) => void
}

/**
 * LIGTAS Awareness Bar (V3)
 * Minimalist avatar row for one-tap switching between active sessions.
 */
export function QuickSwitchV3({ rooms, activeRoomId, onSwitch }: QuickSwitchV3Props) {
    if (rooms.length <= 1) return null

    const getInitials = (name: string) => {
        return name.split(' ').map(n => n[0]).join('').toUpperCase().substring(0, 2)
    }

    return (
        <div className="flex items-center gap-2 px-4 py-2 bg-slate-50 border-b border-slate-100 overflow-x-auto no-scrollbar">
            <span className="text-[9px] font-black text-slate-400 uppercase tracking-widest mr-1">Active:</span>
            {rooms.map((room) => (
                <button
                    key={room.id}
                    onClick={() => onSwitch(room.id)}
                    className={cn(
                        "h-7 w-7 rounded-xl flex items-center justify-center text-[10px] font-bold transition-all shrink-0",
                        activeRoomId === room.id 
                            ? "bg-blue-600 text-white shadow-md scale-110" 
                            : "bg-white text-slate-500 border border-slate-200 hover:border-blue-300"
                    )}
                    title={room.name}
                >
                    {getInitials(room.name)}
                </button>
            ))}
        </div>
    )
}
