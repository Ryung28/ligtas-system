'use client'

import React from 'react'
import { ChevronRight, Mail, Clock, Shield } from 'lucide-react'
import { cn } from '@/lib/utils'
import { mFocus } from '@/lib/mobile/tokens'
import { MBadge } from '@/components/mobile/primitives'
import type { UserProfile } from '@/hooks/use-user-management'
import { formatDistanceToNow } from 'date-fns'

type RoleTone = 'brand' | 'info' | 'warning' | 'neutral'
const roleTone: Record<string, RoleTone> = {
    admin: 'brand',
    editor: 'info',
    responder: 'warning',
    viewer: 'neutral',
}

type StatusTone = 'success' | 'warning' | 'danger' | 'neutral'
const statusTone: Record<string, StatusTone> = {
    active: 'success',
    pending: 'warning',
    suspended: 'danger',
}

export function UserCard({
    user,
    onSelect,
}: {
    user: UserProfile
    onSelect: (u: UserProfile) => void
}) {
    const initials =
        (user.full_name || user.email || 'NA')
            .split(/\s+/)
            .map((w) => w[0])
            .slice(0, 2)
            .join('')
            .toUpperCase() || 'NA'

    const isInvite = !!user.isPending

    return (
        <button
            type="button"
            onClick={() => onSelect(user)}
            className={cn(
                'w-full text-left bg-white border border-gray-100 rounded-2xl p-4 shadow-sm',
                'flex items-start gap-3 motion-safe:transition-transform motion-safe:active:scale-[0.99]',
                'hover:border-gray-200',
                mFocus,
            )}
            aria-label={`Manage ${user.full_name || user.email}`}
        >
            <div
                className={cn(
                    'w-11 h-11 rounded-xl flex items-center justify-center shrink-0 font-bold text-sm',
                    isInvite
                        ? 'bg-amber-100 text-amber-700 border border-amber-200'
                        : user.role === 'admin'
                            ? 'bg-red-600 text-white'
                            : 'bg-gray-900 text-white',
                )}
                aria-hidden
            >
                {initials}
            </div>

            <div className="flex-1 min-w-0">
                <p className="text-sm font-bold text-gray-900 truncate">
                    {user.full_name || (isInvite ? 'Invited staff' : 'Unnamed user')}
                </p>
                <p className="text-xs text-gray-500 truncate flex items-center gap-1 mt-0.5">
                    <Mail className="w-3 h-3 shrink-0" aria-hidden />
                    {user.email}
                </p>
                <div className="mt-2 flex items-center gap-1.5 flex-wrap">
                    <MBadge tone={roleTone[user.role] || 'neutral'} size="xs" icon={Shield}>
                        {user.role}
                    </MBadge>
                    <MBadge tone={statusTone[user.status] || 'neutral'} size="xs">
                        {user.status}
                    </MBadge>
                    {isInvite && (
                        <MBadge tone="info" size="xs" icon={Clock}>
                            Invite sent
                        </MBadge>
                    )}
                </div>
                {user.created_at && !isInvite && (
                    <p className="text-[10px] text-gray-400 mt-1.5">
                        Joined {formatDistanceToNow(new Date(user.created_at), { addSuffix: true })}
                    </p>
                )}
            </div>

            <ChevronRight className="w-4 h-4 text-gray-300 shrink-0 mt-1" aria-hidden />
        </button>
    )
}
