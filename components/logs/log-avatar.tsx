'use client'

import React from 'react'

interface LogAvatarProps {
    name: string
    lastSeen?: string | null
    size?: number
}

export function InitialsAvatar({ name, lastSeen, size = 9 }: LogAvatarProps) {
    const initials = name
        .split(' ')
        .filter(Boolean)
        .map(n => n[0])
        .slice(0, 2)
        .join('')
        .toUpperCase()

    const colors = [
        'bg-red-100 text-red-700',
        'bg-blue-100 text-blue-700',
        'bg-emerald-100 text-emerald-700',
        'bg-amber-100 text-amber-700',
        'bg-violet-100 text-violet-700',
        'bg-pink-100 text-pink-700'
    ]
    // Simple hash for consistent color
    const charCode = name.charCodeAt(0) || 0
    const colorClass = colors[charCode % colors.length]

    const isOnline = lastSeen && (new Date().getTime() - new Date(lastSeen).getTime() < 1000 * 60 * 5)

    const sizeClasses: Record<number, string> = {
        6: 'h-6 w-6 text-[9px]',
        7: 'h-7 w-7 text-[10px]',
        8: 'h-8 w-8 text-[11px]',
        9: 'h-9 w-9 text-[12px]',
    }

    return (
        <div className="relative shrink-0">
            <div className={`${sizeClasses[size] || sizeClasses[9]} rounded-full flex items-center justify-center font-bold ring-2 ring-white ${colorClass}`}>
                {initials}
            </div>
            {isOnline && (
                <span className="absolute -bottom-0.5 -right-0.5 h-3 w-3 bg-emerald-500 border-2 border-white rounded-full shadow-sm animate-in fade-in zoom-in duration-300" />
            )}
        </div>
    )
}
