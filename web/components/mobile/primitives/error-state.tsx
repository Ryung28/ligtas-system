'use client'

import React from 'react'
import { AlertTriangle, RefreshCw } from 'lucide-react'
import { cn } from '@/lib/utils'
import { mFocus } from '@/lib/mobile/tokens'

interface ErrorStateProps {
    title?: string
    description?: string
    onRetry?: () => void
    isRetrying?: boolean
    icon?: React.ComponentType<{ className?: string }>
    className?: string
}

/**
 * Uniform error surface for network / server failures on mobile.
 * Always provides a retry affordance when a handler is supplied.
 */
export function ErrorState({
    title = "Couldn't load data",
    description = 'Check your connection and try again.',
    onRetry,
    isRetrying,
    icon: Icon = AlertTriangle,
    className,
}: ErrorStateProps) {
    return (
        <div
            className={cn(
                'flex flex-col items-center justify-center py-16 px-6 text-center',
                className,
            )}
            role="alert"
        >
            <div className="w-16 h-16 bg-rose-50 text-rose-600 rounded-3xl flex items-center justify-center mb-4 border border-rose-100">
                <Icon className="w-8 h-8" aria-hidden />
            </div>
            <h3 className="text-base font-bold text-gray-900">{title}</h3>
            <p className="mt-1 text-sm text-gray-500 max-w-xs">{description}</p>
            {onRetry && (
                <button
                    onClick={onRetry}
                    disabled={isRetrying}
                    className={cn(
                        'mt-5 h-11 px-5 rounded-xl bg-gray-900 text-white text-sm font-semibold',
                        'inline-flex items-center gap-2 disabled:opacity-60',
                        'motion-safe:transition-transform motion-safe:active:scale-95',
                        mFocus,
                    )}
                >
                    <RefreshCw className={cn('w-4 h-4', isRetrying && 'animate-spin')} />
                    {isRetrying ? 'Retrying…' : 'Try again'}
                </button>
            )}
        </div>
    )
}
