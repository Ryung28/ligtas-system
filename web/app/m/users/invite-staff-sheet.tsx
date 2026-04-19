'use client'

import React, { useState } from 'react'
import { AtSign, Send, Loader2 } from 'lucide-react'
import { BottomSheet, FormField, MInput } from '@/components/mobile/primitives'
import { cn } from '@/lib/utils'
import { mFocus } from '@/lib/mobile/tokens'

type InviteRole = 'admin' | 'editor'

interface InviteStaffSheetProps {
    open: boolean
    onOpenChange: (open: boolean) => void
    onInvite: (email: string, role: InviteRole) => Promise<boolean>
}

export function InviteStaffSheet({ open, onOpenChange, onInvite }: InviteStaffSheetProps) {
    const [email, setEmail] = useState('')
    const [role, setRole] = useState<InviteRole>('editor')
    const [saving, setSaving] = useState(false)
    const [error, setError] = useState<string>()

    const reset = () => {
        setEmail('')
        setRole('editor')
        setError(undefined)
    }

    const validate = () => {
        const trimmed = email.trim()
        if (!trimmed) {
            setError('Email is required.')
            return false
        }
        if (!/^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(trimmed)) {
            setError('Enter a valid email address.')
            return false
        }
        setError(undefined)
        return true
    }

    const handleSubmit = async () => {
        if (!validate()) return
        setSaving(true)
        try {
            const ok = await onInvite(email.trim().toLowerCase(), role)
            if (ok) {
                reset()
                onOpenChange(false)
            }
        } finally {
            setSaving(false)
        }
    }

    return (
        <BottomSheet
            open={open}
            onOpenChange={(next) => {
                if (!next) reset()
                onOpenChange(next)
            }}
            title="Invite staff"
            description="Whitelist an email to grant access as admin or editor."
            footer={
                <div className="flex items-center gap-2">
                    <button
                        type="button"
                        onClick={() => onOpenChange(false)}
                        disabled={saving}
                        className={cn(
                            'flex-none h-11 px-4 rounded-xl text-xs font-bold uppercase tracking-wider',
                            'text-gray-700 hover:bg-gray-50 disabled:opacity-50',
                            mFocus,
                        )}
                    >
                        Cancel
                    </button>
                    <button
                        type="button"
                        onClick={handleSubmit}
                        disabled={saving}
                        className={cn(
                            'flex-1 h-11 rounded-xl text-sm font-semibold inline-flex items-center justify-center gap-2',
                            'bg-red-600 text-white hover:bg-red-700 shadow-md shadow-red-200 disabled:opacity-60',
                            mFocus,
                        )}
                    >
                        {saving ? (
                            <>
                                <Loader2 className="w-4 h-4 animate-spin" aria-hidden />
                                Sending…
                            </>
                        ) : (
                            <>
                                <Send className="w-4 h-4" aria-hidden />
                                Send invite
                            </>
                        )}
                    </button>
                </div>
            }
        >
            <div className="space-y-5">
                <FormField label="Work email" htmlFor="invite-email" required error={error}>
                    <div className="relative">
                        <AtSign
                            className="absolute left-4 top-1/2 -translate-y-1/2 w-4 h-4 text-gray-400 pointer-events-none"
                            aria-hidden
                        />
                        <MInput
                            id="invite-email"
                            type="email"
                            inputMode="email"
                            autoCapitalize="none"
                            autoCorrect="off"
                            value={email}
                            onChange={(e) => {
                                setEmail(e.target.value)
                                if (error) setError(undefined)
                            }}
                            placeholder="name@ligtas.gov.ph"
                            className="pl-10"
                            invalid={!!error}
                        />
                    </div>
                </FormField>

                <FormField
                    label="Role"
                    htmlFor="invite-role"
                    hint="Admins can manage all users and system settings. Editors manage inventory and approvals."
                >
                    <div className="grid grid-cols-2 gap-2" role="radiogroup" aria-label="Role">
                        {(['editor', 'admin'] as const).map((opt) => (
                            <button
                                key={opt}
                                type="button"
                                role="radio"
                                aria-checked={role === opt}
                                onClick={() => setRole(opt)}
                                className={cn(
                                    'h-11 rounded-xl text-sm font-bold capitalize border',
                                    'motion-safe:transition-colors',
                                    role === opt
                                        ? 'bg-gray-900 text-white border-gray-900'
                                        : 'bg-white text-gray-700 border-gray-200 hover:border-gray-300',
                                    mFocus,
                                )}
                            >
                                {opt}
                            </button>
                        ))}
                    </div>
                </FormField>
            </div>
        </BottomSheet>
    )
}
