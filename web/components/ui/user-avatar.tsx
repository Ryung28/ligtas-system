'use client'

import React from 'react'
import { cn } from '@/lib/utils'

interface UserAvatarProps {
    fullName: string | null | undefined
    className?: string
}

/**
 * Deterministic color generator based on string hash.
 * Ensures the same name always gets the same high-end color.
 */
const getAvatarStyle = (name: string) => {
    if (!name) return { bg: 'bg-slate-200', text: 'text-slate-500', border: 'border-slate-300' }

    const colors = [
        { bg: 'bg-blue-100', text: 'text-blue-700', border: 'border-blue-200' },
        { bg: 'bg-indigo-100', text: 'text-indigo-700', border: 'border-indigo-200' },
        { bg: 'bg-violet-100', text: 'text-violet-700', border: 'border-violet-200' },
        { bg: 'bg-emerald-100', text: 'text-emerald-700', border: 'border-emerald-200' },
        { bg: 'bg-amber-100', text: 'text-amber-700', border: 'border-amber-200' },
        { bg: 'bg-rose-100', text: 'text-rose-700', border: 'border-rose-200' },
        { bg: 'bg-cyan-100', text: 'text-cyan-700', border: 'border-cyan-200' },
    ]

    // Simple hash to select color
    let hash = 0
    for (let i = 0; i < name.length; i++) {
        hash = name.charCodeAt(i) + ((hash << 5) - hash)
    }

    const index = Math.abs(hash) % colors.length
    return colors[index]
}

/**
 * Extracts first and last name initials.
 * 'MARKKENJI BATERNA' -> 'MB'
 */
const getInitials = (name: string | null | undefined) => {
    if (!name || name.trim() === '' || name === 'Unknown') return '??'

    const parts = name.trim().split(/\s+/)
    if (parts.length === 1) return parts[0].substring(0, 2).toUpperCase()

    const firstInitial = parts[0][0]
    const lastInitial = parts[parts.length - 1][0]

    return (firstInitial + lastInitial).toUpperCase()
}

export function UserAvatar({ fullName, className }: UserAvatarProps) {
    const initials = getInitials(fullName)
    const style = getAvatarStyle(fullName || '')

    return (
        <div
            className={cn(`
                flex-shrink-0
                w-10 h-10 
                rounded-xl 
                flex items-center justify-center 
                border 
                ${style.bg} 
                ${style.text} 
                ${style.border || 'border-slate-200'}
                shadow-sm
                transition-all
                duration-300
                group-hover:scale-105
                group-hover:shadow-md
            `, className)}
        >
            <span className="text-sm font-black tracking-tighter font-sans uppercase">
                {initials}
            </span>
        </div>
    )
}
