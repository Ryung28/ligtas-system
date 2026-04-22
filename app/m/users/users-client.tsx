'use client'

import { useMemo, useState } from 'react'
import {
    Search,
    X,
    Shield,
    UserX,
    UsersRound,
    Smartphone,
    Plus,
} from 'lucide-react'
import { MobileHeader } from '@/components/mobile/mobile-header'
import { EmptyState, ErrorState } from '@/components/mobile/primitives'
import { useUserManagement, buildPendingBorrowersQueue, type UserProfile } from '@/hooks/use-user-management'
import { useUser } from '@/providers/auth-provider'
import { useDebounce } from '@/hooks/use-debounce'
import { roleCan, mFocus } from '@/lib/mobile/tokens'
import { cn } from '@/lib/utils'
import { UserCard } from './user-card'
import { UserDetailSheet } from './user-detail-sheet'
import { InviteStaffSheet } from './invite-staff-sheet'
import { UsersSkeleton } from './users-skeleton'

type Tab = 'pending' | 'staff' | 'responders'

export function UsersClient() {
    const { user: currentUser } = useUser()
    const canManage = roleCan.manageUsers(currentUser?.role)

    const {
        users,
        pendingRequests,
        authorizedEmails,
        stats,
        isLoading,
        isValidating,
        refresh,
        approveUser,
        rejectUser,
        suspendUser,
        reactivateUser,
        updateUserRole,
        authorizeUser,
    } = useUserManagement()

    const [tab, setTab] = useState<Tab>('pending')
    const [searchQuery, setSearchQuery] = useState('')
    const [selected, setSelected] = useState<UserProfile | null>(null)
    const [inviteOpen, setInviteOpen] = useState(false)
    const debounced = useDebounce(searchQuery, 250)
    const q = debounced.trim().toLowerCase()

    const pendingBase = useMemo(
        () => buildPendingBorrowersQueue(users, pendingRequests),
        [users, pendingRequests],
    )
    const pending = useMemo(
        () =>
            pendingBase.filter(
                (u) =>
                    !q ||
                    (u.full_name || '').toLowerCase().includes(q) ||
                    (u.email || '').toLowerCase().includes(q),
            ),
        [pendingBase, q],
    )

    // Access guard — must come BEFORE list filtering
    if (!isLoading && currentUser && !canManage) {
        return (
            <div className="space-y-5">
                <MobileHeader title="Users" />
                <EmptyState
                    icon={Shield}
                    title="Admin access only"
                    description="User management is restricted to administrators. Contact your admin if you need access."
                />
            </div>
        )
    }

    if (isLoading && users.length === 0) {
        return <UsersSkeleton />
    }

    const matches = (u: Partial<UserProfile>) =>
        !q ||
        (u.full_name || '').toLowerCase().includes(q) ||
        (u.email || '').toLowerCase().includes(q)

    const activeStaff = users.filter(
        (u) => u.status === 'active' && (u.role === 'admin' || u.role === 'editor'),
    )
    const pendingInvites: UserProfile[] = authorizedEmails
        .filter(
            (auth: any) =>
                !activeStaff.some(
                    (s) => s.email?.toLowerCase() === auth.email?.toLowerCase(),
                ),
        )
        .map((auth: any) => ({
            id: `pending-${auth.email}`,
            email: auth.email,
            role: auth.role,
            status: 'pending',
            isPending: true,
            created_at: new Date().toISOString(),
        } as UserProfile))
    const staff = [...activeStaff, ...pendingInvites].filter(matches)

    const responders = users
        .filter(
            (u) =>
                u.status === 'active' &&
                (u.role === 'viewer' || u.role === 'responder'),
        )
        .filter(matches)

    const tabs: {
        id: Tab
        label: string
        count: number
        icon: React.ComponentType<{ className?: string }>
    }[] = [
        { id: 'pending', label: 'Pending', count: pending.length, icon: UserX },
        { id: 'staff', label: 'Staff', count: staff.length, icon: UsersRound },
        { id: 'responders', label: 'Responders', count: responders.length, icon: Smartphone },
    ]

    const list =
        tab === 'pending' ? pending : tab === 'staff' ? staff : responders

    return (
        <div className="space-y-5 pb-20">
            <MobileHeader title="Users" onRefresh={refresh} isLoading={isValidating} />

            {/* Stats */}
            <section className="grid grid-cols-3 gap-2" aria-label="User summary">
                <StatPill label="Pending" value={stats.pendingCount} tone="warning" />
                <StatPill label="Staff" value={stats.adminsCount + stats.editorsCount} tone="info" />
                <StatPill label="Responders" value={stats.viewersCount} tone="success" />
            </section>

            {/* Tabs */}
            <div
                className="flex items-center gap-1 p-1 rounded-2xl bg-gray-100 sticky top-[56px] z-40"
                role="tablist"
                aria-label="User categories"
            >
                {tabs.map((t) => (
                    <button
                        key={t.id}
                        role="tab"
                        aria-selected={tab === t.id}
                        onClick={() => setTab(t.id)}
                        className={cn(
                            'flex-1 h-10 rounded-xl text-xs font-bold uppercase tracking-wider',
                            'inline-flex items-center justify-center gap-1.5',
                            'motion-safe:transition-all',
                            tab === t.id
                                ? 'bg-white text-gray-900 shadow-sm'
                                : 'text-gray-500 hover:text-gray-700',
                            mFocus,
                        )}
                    >
                        <t.icon className="w-3.5 h-3.5" aria-hidden />
                        {t.label}
                        {t.count > 0 && (
                            <span
                                className={cn(
                                    'ml-0.5 text-[10px] font-black tabular-nums rounded-full px-1.5 py-0.5',
                                    tab === t.id
                                        ? 'bg-red-600 text-white'
                                        : 'bg-gray-200 text-gray-700',
                                )}
                            >
                                {t.count}
                            </span>
                        )}
                    </button>
                ))}
            </div>

            {/* Search */}
            <div className="relative">
                <label htmlFor="user-search" className="sr-only">
                    Search users
                </label>
                <div className="absolute inset-y-0 left-4 flex items-center pointer-events-none">
                    <Search className="w-5 h-5 text-gray-400" aria-hidden />
                </div>
                <input
                    id="user-search"
                    type="search"
                    value={searchQuery}
                    onChange={(e) => setSearchQuery(e.target.value)}
                    placeholder="Search by name or email…"
                    autoComplete="off"
                    className={cn(
                        'w-full h-12 bg-white border border-gray-200 rounded-2xl pl-12 pr-10 text-sm',
                        'focus:outline-none focus:ring-2 focus:ring-red-500/20 focus:border-red-500',
                        'motion-safe:transition-all shadow-sm',
                    )}
                />
                {searchQuery && (
                    <button
                        type="button"
                        onClick={() => setSearchQuery('')}
                        className={cn(
                            'absolute inset-y-0 right-2 my-auto w-8 h-8 flex items-center justify-center rounded-full',
                            'text-gray-400 hover:text-gray-700 hover:bg-gray-100',
                            mFocus,
                        )}
                        aria-label="Clear search"
                    >
                        <X className="w-4 h-4" />
                    </button>
                )}
            </div>

            {/* List */}
            {list.length === 0 ? (
                <EmptyState
                    icon={tab === 'pending' ? UserX : tab === 'staff' ? UsersRound : Smartphone}
                    title={
                        q
                            ? 'No matches'
                            : tab === 'pending'
                                ? 'No pending requests'
                                : tab === 'staff'
                                    ? 'No staff yet'
                                    : 'No active responders'
                    }
                    description={
                        q
                            ? `No user matches "${q}".`
                            : tab === 'pending'
                                ? 'New signups will appear here for approval.'
                                : tab === 'staff'
                                    ? 'Invite administrators and editors to manage the system.'
                                    : 'Approved mobile-app users will appear here.'
                    }
                    action={
                        q
                            ? { label: 'Clear search', onClick: () => setSearchQuery('') }
                            : tab === 'staff'
                                ? { label: 'Invite staff', onClick: () => setInviteOpen(true) }
                                : undefined
                    }
                />
            ) : (
                <ul className="space-y-3" aria-label={`${tab} users`}>
                    {list.map((u) => (
                        <li key={u.id}>
                            <UserCard user={u} onSelect={setSelected} />
                        </li>
                    ))}
                </ul>
            )}

            {/* Invite FAB — staff tab only */}
            {tab === 'staff' && (
                <button
                    type="button"
                    onClick={() => setInviteOpen(true)}
                    className={cn(
                        'fixed right-4 z-40',
                        'bottom-[calc(72px+env(safe-area-inset-bottom)+16px)]',
                        'h-14 w-14 rounded-full bg-red-600 text-white shadow-xl shadow-red-300',
                        'flex items-center justify-center',
                        'motion-safe:transition-transform motion-safe:active:scale-90',
                        mFocus,
                    )}
                    aria-label="Invite staff"
                >
                    <Plus className="w-6 h-6" aria-hidden />
                </button>
            )}

            <UserDetailSheet
                user={selected}
                currentUserId={currentUser?.id}
                onOpenChange={(o) => !o && setSelected(null)}
                onApprove={approveUser}
                onReject={rejectUser}
                onSuspend={suspendUser}
                onReactivate={reactivateUser}
                onUpdateRole={updateUserRole}
            />

            <InviteStaffSheet
                open={inviteOpen}
                onOpenChange={setInviteOpen}
                onInvite={authorizeUser}
            />
        </div>
    )
}

function StatPill({
    label,
    value,
    tone,
}: {
    label: string
    value: number
    tone: 'info' | 'warning' | 'success'
}) {
    const toneMap: Record<typeof tone, string> = {
        info: 'bg-blue-50 text-blue-900 border-blue-100',
        warning: 'bg-amber-50 text-amber-900 border-amber-100',
        success: 'bg-emerald-50 text-emerald-900 border-emerald-100',
    }
    return (
        <div className={cn('rounded-2xl border p-3 shadow-sm', toneMap[tone])}>
            <p className="text-[10px] font-bold uppercase tracking-widest opacity-70">
                {label}
            </p>
            <p className="text-xl font-black tabular-nums leading-tight mt-0.5">
                {value}
            </p>
        </div>
    )
}
