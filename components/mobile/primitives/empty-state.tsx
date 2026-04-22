'use client'

import React from 'react'
import { cn } from '@/lib/utils'
import { mFocus } from '@/lib/mobile/tokens'

interface EmptyStateProps {
    icon: React.ComponentType<{ className?: string }>
    title: string
    description?: string
    action?: {
        label: string
        onClick: () => void
    }
    className?: string
}

/**
 * Uniform empty-state for every list in `/m`.
 * Usage: `<EmptyState icon={Package} title="No items" description="..." />`
 */
export function EmptyState({ icon: Icon, title, description, action, className }: EmptyStateProps) {
    return (
        <div
            className={cn(
                'flex flex-col items-center justify-center py-16 px-6 text-center',
                className,
            )}
            role="status"
        >
            <div className="w-16 h-16 bg-gray-100 rounded-3xl flex items-center justify-center mb-4">
                <Icon className="w-8 h-8 text-gray-400" aria-hidden />
            </div>
            <h3 className="text-base font-bold text-gray-900">{title}</h3>
            {description && (
                <p className="mt-1 text-sm text-gray-500 max-w-xs">{description}</p>
            )}
            {action && (
                <button
                    onClick={action.onClick}
                    className={cn(
                        'mt-5 h-11 px-5 rounded-xl bg-red-600 text-white text-sm font-semibold',
                        'motion-safe:transition-transform motion-safe:active:scale-95',
                        mFocus,
                    )}
                >
                    {action.label}
                </button>
            )}
        </div>
    )
}
