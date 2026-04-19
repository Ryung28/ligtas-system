'use client'

import React, { useState } from 'react'
import {
    Check,
    X,
    UserCog,
    Mail,
    Shield,
    Clock,
    Loader2,
    RefreshCcw,
    Ban,
    Building2,
    UserMinus,
} from 'lucide-react'
import { BottomSheet, MBadge, ConfirmDialog } from '@/components/mobile/primitives'
import { cn } from '@/lib/utils'
import { mFocus } from '@/lib/mobile/tokens'
import { formatDistanceToNow } from 'date-fns'
import type { UserProfile } from '@/hooks/use-user-management'

type Role = 'admin' | 'editor' | 'viewer' | 'responder'

interface UserDetailSheetProps {
    user: UserProfile | null
    currentUserId?: string
    onOpenChange: (open: boolean) => void
    onApprove: (id: string, role: Role) => Promise<boolean>
    onReject: (id: string) => Promise<boolean>
    onSuspend: (id: string) => Promise<boolean>
    onReactivate: (id: string) => Promise<boolean>
    onUpdateRole: (id: string, role: Role) => Promise<boolean>
}

type RoleTone = 'brand' | 'info' | 'warning' | 'neutral'
const roleToneMap: Record<string, RoleTone> = {
    admin: 'brand',
    editor: 'info',
    responder: 'warning',
    viewer: 'neutral',
}

export function UserDetailSheet({
    user,
    currentUserId,
    onOpenChange,
    onApprove,
    onReject,
    onSuspend,
    onReactivate,
    onUpdateRole,
}: UserDetailSheetProps) {
    const [busy, setBusy] = useState(false)
    const [suspendConfirmOpen, setSuspendConfirmOpen] = useState(false)
    const [rejectConfirmOpen, setRejectConfirmOpen] = useState(false)
    const [pendingRole, setPendingRole] = useState<Role>('responder')
    const [roleChangeOpen, setRoleChangeOpen] = useState(false)
    const [newRole, setNewRole] = useState<Role | null>(null)

    const open = !!user

    const initials =
        (user?.full_name || user?.email || 'NA')
            .split(/\s+/)
            .map((w) => w[0])
            .slice(0, 2)
            .join('')
            .toUpperCase() || 'NA'

    const isSelf = !!currentUserId && user?.id === currentUserId
    const isPendingUser = user?.status === 'pending'
    const isSuspended = user?.status === 'suspended'
    const isInvite = !!user?.isPending

    const run = async (fn: () => Promise<boolean>, closeOnSuccess = true) => {
        setBusy(true)
        try {
            const ok = await fn()
            if (ok && closeOnSuccess) onOpenChange(false)
        } finally {
            setBusy(false)
        }
    }

    const handleApprove = () => {
        if (!user) return
        run(() => onApprove(user.id, pendingRole))
    }

    const handleReject = () => {
        if (!user) return
        run(async () => {
            const ok = await onReject(user.id)
            setRejectConfirmOpen(false)
            return ok
        })
    }

    const handleSuspend = () => {
        if (!user) return
        run(async () => {
            const ok = await onSuspend(user.id)
            setSuspendConfirmOpen(false)
            return ok
        })
    }

    const handleReactivate = () => {
        if (!user) return
        run(() => onReactivate(user.id))
    }

    const handleRoleChange = () => {
        if (!user || !newRole) return
        run(async () => {
            const ok = await onUpdateRole(user.id, newRole)
            setRoleChangeOpen(false)
            setNewRole(null)
            return ok
        }, false)
    }

    return (
        <>
            <BottomSheet
                open={open}
                onOpenChange={onOpenChange}
                title={user?.full_name || user?.email || 'User'}
                description={user?.email}
                size="full"
            >
                {user && (
                    <div className="space-y-6">
                        {/* Identity */}
                        <section className="flex items-center gap-3">
                            <div
                                className={cn(
                                    'w-14 h-14 rounded-2xl flex items-center justify-center shrink-0 font-black text-base',
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
                            <div className="min-w-0 flex-1">
                                <h3 className="text-base font-bold text-gray-900 truncate">
                                    {user.full_name || (isInvite ? 'Invited staff' : 'Unnamed user')}
                                </h3>
                                <p className="text-xs text-gray-500 truncate flex items-center gap-1 mt-0.5">
                                    <Mail className="w-3 h-3" aria-hidden />
                                    {user.email}
                                </p>
                                <div className="mt-2 flex items-center gap-1.5 flex-wrap">
                                    <MBadge tone={roleToneMap[user.role] || 'neutral'} size="xs" icon={Shield}>
                                        {user.role}
                                    </MBadge>
                                    <MBadge
                                        tone={
                                            user.status === 'active'
                                                ? 'success'
                                                : user.status === 'pending'
                                                    ? 'warning'
                                                    : 'danger'
                                        }
                                        size="xs"
                                    >
                                        {user.status}
                                    </MBadge>
                                </div>
                            </div>
                        </section>

                        {/* Facts */}
                        <section className="rounded-2xl bg-gray-50 border border-gray-100 divide-y divide-gray-100">
                            <Fact
                                icon={Building2}
                                label="Department"
                                value={user.department || '—'}
                            />
                            <Fact
                                icon={Clock}
                                label={user.approved_at ? 'Approved' : 'Created'}
                                value={
                                    user.approved_at
                                        ? formatDistanceToNow(new Date(user.approved_at), { addSuffix: true })
                                        : user.created_at
                                            ? formatDistanceToNow(new Date(user.created_at), { addSuffix: true })
                                            : '—'
                                }
                            />
                            {user.approved_by && (
                                <Fact icon={Shield} label="Approved by" value={user.approved_by} />
                            )}
                        </section>

                        {isSelf && (
                            <div
                                className="rounded-2xl bg-amber-50 border border-amber-200 p-3 text-xs text-amber-900"
                                role="note"
                            >
                                This is your own account. You can&apos;t change your own role or status from here —
                                use your Profile page for editable fields.
                            </div>
                        )}

                        {/* Actions */}
                        {!isSelf && (
                            <section className="space-y-3">
                                {/* Pending user → approve with role */}
                                {isPendingUser && !isInvite && (
                                    <div className="rounded-2xl bg-white border border-gray-100 p-4 space-y-3 shadow-sm">
                                        <div className="flex items-center gap-2">
                                            <UserCog className="w-4 h-4 text-red-600" aria-hidden />
                                            <h4 className="text-sm font-bold uppercase tracking-tight text-gray-900">
                                                Approve this request
                                            </h4>
                                        </div>
                                        <p className="text-xs text-gray-500">
                                            Choose the access level to grant this user.
                                        </p>

                                        <div className="grid grid-cols-2 gap-2" role="radiogroup" aria-label="Grant role">
                                            {(['responder', 'viewer', 'editor', 'admin'] as Role[]).map((r) => (
                                                <button
                                                    key={r}
                                                    type="button"
                                                    role="radio"
                                                    aria-checked={pendingRole === r}
                                                    onClick={() => setPendingRole(r)}
                                                    className={cn(
                                                        'h-11 rounded-xl text-sm font-bold capitalize border',
                                                        'motion-safe:transition-colors',
                                                        pendingRole === r
                                                            ? 'bg-gray-900 text-white border-gray-900'
                                                            : 'bg-white text-gray-700 border-gray-200 hover:border-gray-300',
                                                        mFocus,
                                                    )}
                                                >
                                                    {r}
                                                </button>
                                            ))}
                                        </div>

                                        <div className="flex items-center gap-2 pt-1">
                                            <button
                                                type="button"
                                                disabled={busy}
                                                onClick={() => setRejectConfirmOpen(true)}
                                                className={cn(
                                                    'flex-none h-11 px-4 rounded-xl border border-rose-200 bg-rose-50 text-rose-700',
                                                    'text-xs font-bold uppercase tracking-wider hover:bg-rose-100',
                                                    'inline-flex items-center gap-1.5 disabled:opacity-50',
                                                    mFocus,
                                                )}
                                            >
                                                <X className="w-4 h-4" aria-hidden />
                                                Reject
                                            </button>
                                            <button
                                                type="button"
                                                disabled={busy}
                                                onClick={handleApprove}
                                                className={cn(
                                                    'flex-1 h-11 rounded-xl bg-red-600 text-white text-sm font-semibold',
                                                    'inline-flex items-center justify-center gap-2 shadow-md shadow-red-200',
                                                    'disabled:opacity-60',
                                                    mFocus,
                                                )}
                                            >
                                                {busy ? (
                                                    <Loader2 className="w-4 h-4 animate-spin" aria-hidden />
                                                ) : (
                                                    <Check className="w-4 h-4" aria-hidden />
                                                )}
                                                Approve as {pendingRole}
                                            </button>
                                        </div>
                                    </div>
                                )}

                                {/* Active user → role change + suspend */}
                                {user.status === 'active' && !isInvite && (
                                    <>
                                        <div className="rounded-2xl bg-white border border-gray-100 p-4 space-y-3 shadow-sm">
                                            <div className="flex items-center gap-2">
                                                <Shield className="w-4 h-4 text-red-600" aria-hidden />
                                                <h4 className="text-sm font-bold uppercase tracking-tight text-gray-900">
                                                    Change role
                                                </h4>
                                            </div>
                                            <div className="grid grid-cols-2 gap-2">
                                                {(['admin', 'editor', 'responder', 'viewer'] as Role[]).map((r) => {
                                                    const active = user.role === r
                                                    return (
                                                        <button
                                                            key={r}
                                                            type="button"
                                                            disabled={busy || active}
                                                            onClick={() => {
                                                                setNewRole(r)
                                                                setRoleChangeOpen(true)
                                                            }}
                                                            className={cn(
                                                                'h-11 rounded-xl text-sm font-bold capitalize border',
                                                                'motion-safe:transition-colors',
                                                                active
                                                                    ? 'bg-gray-100 text-gray-400 border-gray-100 cursor-default'
                                                                    : 'bg-white text-gray-700 border-gray-200 hover:border-gray-300',
                                                                mFocus,
                                                            )}
                                                        >
                                                            {r}
                                                            {active && <span className="ml-1 text-[10px]">· current</span>}
                                                        </button>
                                                    )
                                                })}
                                            </div>
                                        </div>

                                        <button
                                            type="button"
                                            disabled={busy}
                                            onClick={() => setSuspendConfirmOpen(true)}
                                            className={cn(
                                                'w-full h-12 rounded-2xl border border-rose-200 bg-rose-50 text-rose-700',
                                                'inline-flex items-center justify-center gap-2 text-sm font-bold',
                                                'hover:bg-rose-100 disabled:opacity-50',
                                                mFocus,
                                            )}
                                        >
                                            <Ban className="w-4 h-4" aria-hidden />
                                            Suspend account
                                        </button>
                                    </>
                                )}

                                {/* Suspended → reactivate */}
                                {isSuspended && (
                                    <button
                                        type="button"
                                        disabled={busy}
                                        onClick={handleReactivate}
                                        className={cn(
                                            'w-full h-12 rounded-2xl bg-emerald-600 text-white',
                                            'inline-flex items-center justify-center gap-2 text-sm font-bold',
                                            'shadow-md shadow-emerald-200 disabled:opacity-50',
                                            mFocus,
                                        )}
                                    >
                                        {busy ? (
                                            <Loader2 className="w-4 h-4 animate-spin" aria-hidden />
                                        ) : (
                                            <RefreshCcw className="w-4 h-4" aria-hidden />
                                        )}
                                        Reactivate account
                                    </button>
                                )}

                                {/* Invite (whitelist) → revoke */}
                                {isInvite && (
                                    <button
                                        type="button"
                                        disabled={busy}
                                        onClick={() => setSuspendConfirmOpen(true)}
                                        className={cn(
                                            'w-full h-12 rounded-2xl border border-rose-200 bg-rose-50 text-rose-700',
                                            'inline-flex items-center justify-center gap-2 text-sm font-bold',
                                            'hover:bg-rose-100 disabled:opacity-50',
                                            mFocus,
                                        )}
                                    >
                                        <UserMinus className="w-4 h-4" aria-hidden />
                                        Revoke invite
                                    </button>
                                )}
                            </section>
                        )}
                    </div>
                )}
            </BottomSheet>

            <ConfirmDialog
                open={suspendConfirmOpen}
                onOpenChange={setSuspendConfirmOpen}
                title={isInvite ? 'Revoke this invite?' : 'Suspend this account?'}
                description={
                    isInvite
                        ? `${user?.email} will no longer be able to sign up with this address.`
                        : `${user?.full_name || user?.email} will lose access immediately. You can reactivate later.`
                }
                confirmLabel={isInvite ? 'Revoke invite' : 'Suspend account'}
                tone="danger"
                loading={busy}
                onConfirm={handleSuspend}
            />

            <ConfirmDialog
                open={rejectConfirmOpen}
                onOpenChange={setRejectConfirmOpen}
                title="Reject this request?"
                description={`${user?.full_name || user?.email} will be notified that their access was denied.`}
                confirmLabel="Reject request"
                tone="danger"
                loading={busy}
                onConfirm={handleReject}
            />

            <ConfirmDialog
                open={roleChangeOpen}
                onOpenChange={(o) => {
                    setRoleChangeOpen(o)
                    if (!o) setNewRole(null)
                }}
                title={`Change role to ${newRole}?`}
                description={
                    newRole === 'admin'
                        ? 'Admins can manage all users, inventory, and system settings. Use with care.'
                        : `This will change ${user?.full_name || user?.email}'s access level immediately.`
                }
                confirmLabel={`Make ${newRole}`}
                tone={newRole === 'admin' ? 'danger' : 'neutral'}
                loading={busy}
                onConfirm={handleRoleChange}
            />
        </>
    )
}

function Fact({
    icon: Icon,
    label,
    value,
}: {
    icon: React.ComponentType<{ className?: string }>
    label: string
    value: React.ReactNode
}) {
    return (
        <div className="flex items-center gap-3 px-4 py-3">
            <div className="w-8 h-8 rounded-lg bg-white border border-gray-100 flex items-center justify-center shrink-0">
                <Icon className="w-3.5 h-3.5 text-gray-500" aria-hidden />
            </div>
            <div className="min-w-0 flex-1">
                <p className="text-[10px] font-bold uppercase tracking-widest text-gray-500">{label}</p>
                <p className="text-sm text-gray-900 truncate">{value}</p>
            </div>
        </div>
    )
}
