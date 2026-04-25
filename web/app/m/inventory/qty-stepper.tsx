'use client'

import React from 'react'
import { Minus, Plus } from 'lucide-react'
import { cn } from '@/lib/utils'
import { mFocus } from '@/lib/mobile/tokens'

type QtyTone = 'success' | 'warning' | 'info' | 'danger'

interface QtyStepperProps {
    id: string
    label: string
    value: number
    onChange: (v: number) => void
    tone: QtyTone
    error?: string
}

export function QtyStepper({
    id,
    label,
    value,
    onChange,
    tone,
    error,
}: QtyStepperProps) {
    const toneMap: Record<QtyTone, string> = {
        success: 'bg-emerald-50 border-emerald-100',
        warning: 'bg-amber-50 border-amber-100',
        info: 'bg-blue-50 border-blue-100',
        danger: 'bg-rose-50 border-rose-100',
    }
    const dotMap: Record<QtyTone, string> = {
        success: 'bg-emerald-500',
        warning: 'bg-amber-500',
        info: 'bg-blue-500',
        danger: 'bg-rose-500',
    }

    return (
        <div>
            <div className={cn('rounded-2xl border p-3 flex items-center gap-3', toneMap[tone])}>
                <span className={cn('w-2 h-2 rounded-full shrink-0', dotMap[tone])} aria-hidden />
                <label htmlFor={id} className="flex-1 text-sm font-semibold text-gray-900 min-w-0 truncate">
                    {label}
                </label>
                <div className="flex items-center gap-1">
                    <button
                        type="button"
                        onClick={() => onChange(Math.max(0, value - 1))}
                        className={cn(
                            'w-9 h-9 rounded-xl bg-white border border-gray-200 flex items-center justify-center',
                            'text-gray-700 hover:bg-gray-50 disabled:opacity-40',
                            'motion-safe:transition-colors',
                            mFocus,
                        )}
                        disabled={value <= 0}
                        aria-label={`Decrease ${label}`}
                    >
                        <Minus className="w-4 h-4" />
                    </button>
                    <input
                        id={id}
                        type="number"
                        inputMode="numeric"
                        min={0}
                        value={value}
                        onChange={(e) => onChange(Math.max(0, Number(e.target.value) || 0))}
                        className={cn(
                            'w-14 h-9 rounded-xl bg-white border border-gray-200 text-center text-sm font-bold tabular-nums',
                            'focus:outline-none focus:ring-2 focus:ring-red-500/20 focus:border-red-500',
                        )}
                        aria-label={`${label} quantity`}
                    />
                    <button
                        type="button"
                        onClick={() => onChange(value + 1)}
                        className={cn(
                            'w-9 h-9 rounded-xl bg-white border border-gray-200 flex items-center justify-center',
                            'text-gray-700 hover:bg-gray-50 motion-safe:transition-colors',
                            mFocus,
                        )}
                        aria-label={`Increase ${label}`}
                    >
                        <Plus className="w-4 h-4" />
                    </button>
                </div>
            </div>
            {error && (
                <p className="text-xs text-rose-600 mt-1 ml-1" role="alert">
                    {error}
                </p>
            )}
        </div>
    )
}
