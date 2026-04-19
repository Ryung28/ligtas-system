'use client'

import React, { useState, useTransition } from 'react'
import Link from 'next/link'
import { usePathname } from 'next/navigation'
import {
    Sheet,
    SheetContent,
    SheetHeader,
    SheetTitle,
    SheetDescription,
} from '@/components/ui/sheet'
import { Avatar, AvatarFallback } from '@/components/ui/avatar'
import { useUser } from '@/providers/auth-provider'
import { logoutAction } from '@/app/actions/auth-actions'
import {
    Users as UsersIcon,
    BarChart3,
    MessageSquare,
    UserCircle,
    LogOut,
    Shield,
    ChevronRight,
    UsersRound,
    ShieldCheck,
} from 'lucide-react'
import { cn } from '@/lib/utils'
import { roleCan, mFocus } from '@/lib/mobile/tokens'

interface MoreSheetProps {
    open: boolean
    onOpenChange: (open: boolean) => void
}

interface NavItem {
    label: string
    description: string
    href: string
    icon: React.ComponentType<{ className?: string }>
    gate: (role?: string) => boolean
}

const NAV_ITEMS: NavItem[] = [
    {
        label: 'Borrowers',
        description: 'Registered requesters',
        href: '/m/borrowers',
        icon: UsersRound,
        gate: roleCan.viewBorrowers,
    },
    {
        label: 'Reports',
        description: 'Analytics & exports',
        href: '/m/reports',
        icon: BarChart3,
        gate: roleCan.viewReports,
    },
    {
        label: 'Chat',
        description: 'Team communication',
        href: '/m/chat',
        icon: MessageSquare,
        gate: roleCan.useChat,
    },
    {
        label: 'Users',
        description: 'Manage accounts & roles',
        href: '/m/users',
        icon: UsersIcon,
        gate: roleCan.manageUsers,
    },
    {
        label: 'Profile',
        description: 'Your account settings',
        href: '/m/profile',
        icon: UserCircle,
        gate: () => true,
    },
]

/**
 * 🧭 LIGTAS Mobile "More" Sheet
 * Secondary navigation drawer — houses routes that don't fit in the 4-slot
 * bottom nav. Role-gated. Replaces the old popover menu in MobileHeader.
 */
export function MoreSheet({ open, onOpenChange }: MoreSheetProps) {
    const { user } = useUser()
    const pathname = usePathname()
    const [isLoggingOut, startLogout] = useTransition()

    const initials = user?.full_name?.substring(0, 2).toUpperCase() || 'AD'
    const visibleItems = NAV_ITEMS.filter((item) => item.gate(user?.role))

    const handleLogout = () => {
        startLogout(async () => {
            try {
                if (
                    typeof navigator !== 'undefined' &&
                    'serviceWorker' in navigator &&
                    navigator.serviceWorker.controller
                ) {
                    navigator.serviceWorker.controller.postMessage({ type: 'LOGOUT' })
                }
                await logoutAction()
            } catch (err) {
                console.error('[MoreSheet] logout failed', err)
            }
        })
    }

    return (
        <Sheet open={open} onOpenChange={onOpenChange}>
            <SheetContent
                side="right"
                className="w-[86%] max-w-sm p-0 flex flex-col bg-white pb-[env(safe-area-inset-bottom)]"
            >
                {/* Identity header */}
                <SheetHeader className="px-5 pt-6 pb-5 text-left border-b border-gray-100 bg-gradient-to-br from-gray-50 to-white">
                    <SheetTitle className="sr-only">Navigation menu</SheetTitle>
                    <SheetDescription className="sr-only">
                        Quick access to borrowers, reports, chat, and settings.
                    </SheetDescription>
                    <div className="flex items-center gap-3">
                        <Avatar className="h-12 w-12 border border-gray-200 shadow-sm">
                            <AvatarFallback className="text-xs font-black bg-gray-900 text-white">
                                {initials}
                            </AvatarFallback>
                        </Avatar>
                        <div className="min-w-0 flex-1">
                            {user ? (
                                <>
                                    <p className="text-sm font-bold text-gray-900 truncate">
                                        {user?.full_name || 'Responder'}
                                    </p>
                                    <p className="text-[10px] font-bold text-gray-500 uppercase tracking-widest flex items-center gap-1 mt-0.5">
                                        <Shield className="w-2.5 h-2.5" aria-hidden />
                                        {user?.role || 'Personnel'}
                                    </p>
                                </>
                            ) : (
                                <>
                                    <div className="h-3.5 w-32 bg-gray-100 animate-pulse rounded mb-1.5" />
                                    <div className="h-2.5 w-20 bg-gray-50 animate-pulse rounded" />
                                </>
                            )}
                        </div>
                    </div>
                </SheetHeader>

                {/* Nav items */}
                <nav className="flex-1 overflow-y-auto px-3 py-3 custom-scrollbar">
                    <p className="text-[10px] font-bold uppercase tracking-widest text-gray-400 px-3 pb-2 pt-1">
                        Workspace
                    </p>
                    <ul className="space-y-1">
                        {visibleItems.map((item) => {
                            const isActive = pathname.startsWith(item.href)
                            return (
                                <li key={item.href}>
                                    <Link
                                        href={item.href}
                                        onClick={() => onOpenChange(false)}
                                        className={cn(
                                            'flex items-center gap-3 px-3 py-3 rounded-xl min-h-[56px]',
                                            'motion-safe:transition-colors',
                                            'hover:bg-gray-50 active:bg-gray-100',
                                            isActive && 'bg-red-50',
                                            mFocus,
                                        )}
                                    >
                                        <div
                                            className={cn(
                                                'w-10 h-10 rounded-xl flex items-center justify-center shrink-0 border',
                                                isActive
                                                    ? 'bg-red-600 text-white border-red-600 shadow-sm shadow-red-200'
                                                    : 'bg-white text-gray-600 border-gray-100',
                                            )}
                                        >
                                            <item.icon className="w-5 h-5" aria-hidden />
                                        </div>
                                        <div className="flex-1 min-w-0">
                                            <p
                                                className={cn(
                                                    'text-sm font-bold truncate',
                                                    isActive ? 'text-red-700' : 'text-gray-900',
                                                )}
                                            >
                                                {item.label}
                                            </p>
                                            <p className="text-[11px] text-gray-500 truncate">
                                                {item.description}
                                            </p>
                                        </div>
                                        <ChevronRight
                                            className={cn(
                                                'w-4 h-4 shrink-0',
                                                isActive ? 'text-red-500' : 'text-gray-300',
                                            )}
                                            aria-hidden
                                        />
                                    </Link>
                                </li>
                            )
                        })}
                    </ul>

                    {user?.role === 'admin' && (
                        <div className="mt-5 mx-3 p-3 rounded-xl bg-blue-50/60 border border-blue-100">
                            <div className="flex items-center gap-2">
                                <ShieldCheck className="w-4 h-4 text-blue-700" aria-hidden />
                                <p className="text-[11px] font-bold text-blue-900 uppercase tracking-wider">
                                    Admin access
                                </p>
                            </div>
                            <p className="text-[11px] text-blue-800/80 mt-1">
                                You can manage users, inventory, and system reports.
                            </p>
                        </div>
                    )}
                </nav>

                {/* Logout */}
                <div className="flex-none border-t border-gray-100 p-3 bg-white">
                    <button
                        onClick={handleLogout}
                        disabled={isLoggingOut}
                        className={cn(
                            'w-full h-12 rounded-xl flex items-center justify-center gap-2',
                            'bg-rose-50 text-rose-700 hover:bg-rose-100 active:bg-rose-100',
                            'text-xs font-bold uppercase tracking-widest disabled:opacity-60',
                            'motion-safe:transition-colors',
                            mFocus,
                        )}
                    >
                        <LogOut className={cn('w-4 h-4', isLoggingOut && 'animate-spin')} aria-hidden />
                        {isLoggingOut ? 'Signing out…' : 'Sign out'}
                    </button>
                </div>
            </SheetContent>
        </Sheet>
    )
}
