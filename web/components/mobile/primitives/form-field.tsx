'use client'

import React from 'react'
import { AlertCircle } from 'lucide-react'
import { cn } from '@/lib/utils'

interface FormFieldProps {
    label: string
    htmlFor?: string
    required?: boolean
    optional?: boolean
    hint?: string
    error?: string
    children: React.ReactNode
    className?: string
}

/**
 * Uniform label + helper + error layout for mobile forms.
 * Keeps required/optional state and error messaging visible without crowding.
 */
export function FormField({
    label,
    htmlFor,
    required,
    optional,
    hint,
    error,
    children,
    className,
}: FormFieldProps) {
    const describedBy = error
        ? `${htmlFor}-error`
        : hint
            ? `${htmlFor}-hint`
            : undefined

    return (
        <div className={cn('space-y-1.5', className)}>
            <div className="flex items-center justify-between">
                <label
                    htmlFor={htmlFor}
                    className="text-[10px] font-bold uppercase tracking-widest text-gray-600"
                >
                    {label}
                    {required && <span className="text-rose-600 ml-0.5">*</span>}
                </label>
                {optional && !required && (
                    <span className="text-[9px] font-semibold uppercase tracking-wider text-gray-400">
                        Optional
                    </span>
                )}
            </div>

            {/* Children can read `aria-describedby` / `aria-invalid` if cloned manually.
                We deliberately don't clone here to keep the primitive unopinionated. */}
            <div data-described-by={describedBy} data-invalid={!!error || undefined}>
                {children}
            </div>

            {error ? (
                <p
                    id={`${htmlFor}-error`}
                    className="text-xs text-rose-600 flex items-center gap-1"
                    role="alert"
                >
                    <AlertCircle className="w-3 h-3" aria-hidden />
                    {error}
                </p>
            ) : hint ? (
                <p id={`${htmlFor}-hint`} className="text-xs text-gray-500">
                    {hint}
                </p>
            ) : null}
        </div>
    )
}

/**
 * Base mobile input — 44px min height, large touch target, consistent focus ring.
 * Pair with FormField for label + error.
 */
export const MInput = React.forwardRef<
    HTMLInputElement,
    React.InputHTMLAttributes<HTMLInputElement> & { invalid?: boolean }
>(({ className, invalid, ...props }, ref) => (
    <input
        ref={ref}
        aria-invalid={invalid || undefined}
        className={cn(
            'w-full h-12 rounded-xl border bg-white px-4 text-sm text-gray-900 placeholder:text-gray-400',
            'focus:outline-none focus:ring-2 transition-colors',
            invalid
                ? 'border-rose-400 focus:ring-rose-500/20 focus:border-rose-500'
                : 'border-gray-200 focus:ring-red-500/20 focus:border-red-500',
            'disabled:bg-gray-50 disabled:text-gray-400',
            className,
        )}
        {...props}
    />
))
MInput.displayName = 'MInput'

export const MTextarea = React.forwardRef<
    HTMLTextAreaElement,
    React.TextareaHTMLAttributes<HTMLTextAreaElement> & { invalid?: boolean }
>(({ className, invalid, ...props }, ref) => (
    <textarea
        ref={ref}
        aria-invalid={invalid || undefined}
        className={cn(
            'w-full min-h-[88px] rounded-xl border bg-white px-4 py-3 text-sm text-gray-900 placeholder:text-gray-400 resize-y',
            'focus:outline-none focus:ring-2 transition-colors',
            invalid
                ? 'border-rose-400 focus:ring-rose-500/20 focus:border-rose-500'
                : 'border-gray-200 focus:ring-red-500/20 focus:border-red-500',
            'disabled:bg-gray-50 disabled:text-gray-400',
            className,
        )}
        {...props}
    />
))
MTextarea.displayName = 'MTextarea'
