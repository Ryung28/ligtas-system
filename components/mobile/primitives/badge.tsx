'use client'

import React from 'react'
import { cn } from '@/lib/utils'

type Tone = 'neutral' | 'brand' | 'success' | 'warning' | 'danger' | 'info' | 'command'
type Size = 'xs' | 'sm'

interface MBadgeProps {
    children: React.ReactNode
    tone?: Tone
    size?: Size
    icon?: React.ComponentType<{ className?: string }>
    className?: string
}

const toneMap: Record<Tone, string> = {
    neutral: 'bg-gray-100 text-gray-700 border-gray-200',
    brand: 'bg-red-50 text-red-700 border-red-200',
    success: 'bg-emerald-50 text-emerald-700 border-emerald-200',
    warning: 'bg-amber-50 text-amber-700 border-amber-200',
    danger: 'bg-rose-50 text-rose-700 border-rose-200',
    info: 'bg-blue-50 text-blue-700 border-blue-200',
    command: 'bg-blue-900 text-white border-blue-900',
}

const sizeMap: Record<Size, string> = {
    xs: 'text-[9px] px-2 py-0.5 gap-1',
    sm: 'text-[10px] px-2.5 py-1 gap-1.5',
}

/**
 * Status pill used for inventory state, approval status, role labels, etc.
 * Tone is semantic — prefer `tone="danger"` over raw red classes.
 */
export function MBadge({
    children,
    tone = 'neutral',
    size = 'sm',
    icon: Icon,
    className,
}: MBadgeProps) {
    return (
        <span
            className={cn(
                'inline-flex items-center rounded-full border font-bold uppercase tracking-wider whitespace-nowrap',
                toneMap[tone],
                sizeMap[size],
                className,
            )}
        >
            {Icon && <Icon className={cn(size === 'xs' ? 'w-2.5 h-2.5' : 'w-3 h-3')} />}
            {children}
        </span>
    )
}
