'use client'

import React, { useState } from 'react'
import {
    AlertDialog,
    AlertDialogAction,
    AlertDialogCancel,
    AlertDialogContent,
    AlertDialogDescription,
    AlertDialogFooter,
    AlertDialogHeader,
    AlertDialogTitle,
} from '@/components/ui/alert-dialog'
import { cn } from '@/lib/utils'

interface ConfirmDialogProps {
    open: boolean
    onOpenChange: (open: boolean) => void
    title: string
    description?: string
    confirmLabel?: string
    cancelLabel?: string
    /** Force user to type the confirmation word for highly destructive actions. */
    requireTypeToConfirm?: string
    tone?: 'neutral' | 'danger'
    loading?: boolean
    onConfirm: () => void | Promise<void>
}

/**
 * Replacement for `window.confirm()` — accessible, themeable, supports
 * type-to-confirm for destructive actions like delete-user.
 */
export function ConfirmDialog({
    open,
    onOpenChange,
    title,
    description,
    confirmLabel = 'Confirm',
    cancelLabel = 'Cancel',
    requireTypeToConfirm,
    tone = 'neutral',
    loading = false,
    onConfirm,
}: ConfirmDialogProps) {
    const [typed, setTyped] = useState('')
    const matchesGuard = !requireTypeToConfirm || typed.trim() === requireTypeToConfirm

    const handleConfirm = async () => {
        await onConfirm()
        setTyped('')
    }

    return (
        <AlertDialog
            open={open}
            onOpenChange={(next) => {
                if (!next) setTyped('')
                onOpenChange(next)
            }}
        >
            <AlertDialogContent className="rounded-3xl max-w-sm mx-auto">
                <AlertDialogHeader>
                    <AlertDialogTitle className="text-lg font-bold">{title}</AlertDialogTitle>
                    {description && (
                        <AlertDialogDescription className="text-sm text-gray-600">
                            {description}
                        </AlertDialogDescription>
                    )}
                </AlertDialogHeader>

                {requireTypeToConfirm && (
                    <div className="space-y-1.5">
                        <label className="text-[10px] font-bold uppercase tracking-widest text-gray-500">
                            Type <span className="text-gray-900">{requireTypeToConfirm}</span> to confirm
                        </label>
                        <input
                            autoFocus
                            value={typed}
                            onChange={(e) => setTyped(e.target.value)}
                            className="w-full h-11 rounded-xl border border-gray-200 px-3 text-sm focus:outline-none focus:ring-2 focus:ring-red-500/20 focus:border-red-500"
                        />
                    </div>
                )}

                <AlertDialogFooter className="gap-2">
                    <AlertDialogCancel className="rounded-xl">{cancelLabel}</AlertDialogCancel>
                    <AlertDialogAction
                        disabled={!matchesGuard || loading}
                        onClick={(e) => {
                            e.preventDefault()
                            if (matchesGuard && !loading) void handleConfirm()
                        }}
                        className={cn(
                            'rounded-xl',
                            tone === 'danger'
                                ? 'bg-rose-600 hover:bg-rose-700 text-white'
                                : 'bg-gray-900 hover:bg-gray-800 text-white',
                        )}
                    >
                        {loading ? 'Working…' : confirmLabel}
                    </AlertDialogAction>
                </AlertDialogFooter>
            </AlertDialogContent>
        </AlertDialog>
    )
}
