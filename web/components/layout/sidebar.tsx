'use client'

import Link from 'next/link'
import Image from 'next/image'
import { usePathname } from 'next/navigation'
import { LogOut } from 'lucide-react'
import { navItems, type NavItem } from '@/lib/nav-config'
import { cn } from '@/lib/utils'
import { Button } from '@/components/ui/button'
import { logoutAction } from '@/app/actions/auth-actions'
import { useState } from 'react'
import { Avatar, AvatarFallback } from '@/components/ui/avatar'
import { TACTICAL_THEME } from '@/lib/theme-config'
import { preload } from 'swr'
import { useUser } from '@/providers/auth-provider'

interface SidebarProps {
    className?: string
    onNavigate?: () => void
}

export function Sidebar({ className, onNavigate }: SidebarProps) {
    const { user, isLoading } = useUser()
    const pathname = usePathname()
    const [isLoggingOut, setIsLoggingOut] = useState(false)

    // 🛡️ SIMPLICITY PROTOCOL: We removed the dynamic pre-hydration block.
    // The global Providers and Next.js prefetching handle data warming efficiently.

    const isActive = (href: string): boolean => {
        if (href === '/dashboard') {
            return pathname === '/dashboard'
        }
        return pathname.startsWith(href)
    }

    const handleLogout = async () => {
        try {
            setIsLoggingOut(true)
            // Clear SW cache before server-side redirect
            if ('serviceWorker' in navigator && navigator.serviceWorker.controller) {
                navigator.serviceWorker.controller.postMessage({ type: 'LOGOUT' })
            }
            await logoutAction()
        } catch (error) {
            console.error('Logout failed:', error)
            setIsLoggingOut(false)
        }
    }

    const initials = user?.email?.substring(0, 2).toUpperCase() || 'AD'

    return (
        <div className={cn('flex h-full flex-col bg-white/95 backdrop-blur-xl border-r border-slate-100', className)}>
            {/* Logo/Header - Horizontal Tactical Layout */}
            <div className="flex items-center gap-3 px-4 py-3 border-b border-slate-50">
                {/* Logo */}
                <div className="relative h-14 w-14 flex-shrink-0 rounded-full bg-white p-0.5 border border-slate-100 shadow-sm">
                    <Image
                        src="/resqtrack-logo.jpg"
                        alt="CDRRMO Logo"
                        fill
                        className="object-contain p-0.5"
                        priority
                    />
                </div>
                
                {/* Vertical Accent Bar */}
                <div className="h-12 w-0.5 bg-gradient-to-b from-red-500 via-yellow-500 to-red-500 rounded-full" />
                
                {/* Text */}
                <div className="flex-1 min-w-0">
                    <h2 className="text-sm font-bold text-slate-900 tracking-tight leading-tight">
                        CDRRMO
                    </h2>
                    <p className="text-[10px] font-semibold text-slate-500 uppercase tracking-wider leading-tight">
                        ResQTrack
                    </p>
                </div>
            </div>

            {/* Navigation Links */}
            <nav className="flex-1 px-4 py-6 space-y-1 overflow-y-auto custom-scrollbar">
                {/* MAIN SECTION */}
                <div className="space-y-1.5">
                    {navItems.filter(i => i.category === 'main').map((item) => (
                        <SidebarItem
                            key={item.href}
                            item={item}
                            active={isActive(item.href)}
                            onNavigate={onNavigate}
                        />
                    ))}
                </div>

                {/* COMMUNICATION SECTION */}
                <div className="pt-4">
                    <div className="px-3 mb-2">
                        <p className="text-[9px] font-bold text-slate-400 uppercase tracking-[0.2em]">Communication</p>
                    </div>
                    <div className="space-y-1.5">
                        {navItems.filter(i => i.category === 'communication').map((item) => (
                            <SidebarItem
                                key={item.href}
                                item={item}
                                active={isActive(item.href)}
                                onNavigate={onNavigate}
                            />
                        ))}
                    </div>
                </div>

                {/* OPERATIONS SECTION */}
                <div className="pt-4">
                    <div className="px-3 mb-2">
                        <p className="text-[9px] font-bold text-slate-400 uppercase tracking-[0.2em]">Operations</p>
                    </div>
                    <div className="space-y-1.5">
                        {navItems.filter(i => i.category === 'operations').map((item) => (
                            <SidebarItem
                                key={item.href}
                                item={item}
                                active={isActive(item.href)}
                                onNavigate={onNavigate}
                            />
                        ))}
                    </div>
                </div>

                {/* REPORTS & ADMIN SECTION */}
                {(isLoading || user?.role === 'admin' || user?.role === 'editor') && (
                    <div className="pt-4">
                        <div className="px-3 mb-2">
                            <p className="text-[9px] font-bold text-slate-400 uppercase tracking-[0.2em]">Reports & Admin</p>
                        </div>
                        <div className="space-y-1.5">
                            {isLoading ? (
                                // Skeleton for report items
                                <>
                                    <div className="h-9 w-full bg-slate-50 animate-pulse rounded-lg mx-3" />
                                    <div className="h-9 w-full bg-slate-50 animate-pulse rounded-lg mx-3 mt-2" />
                                </>
                            ) : (
                                navItems.filter(i => i.category === 'reports').map((item) => {
                                    // 🔒 ROLE GUARD: System Users is Admin-only
                                    if (item.label === 'System Users' && user?.role !== 'admin') return null;

                                    return (
                                        <SidebarItem
                                            key={item.href}
                                            item={item}
                                            active={isActive(item.href)}
                                            onNavigate={onNavigate}
                                        />
                                    );
                                })
                            )}
                        </div>
                    </div>
                )}
            </nav>


            {/* User Profile & Logout */}
            <div className="p-4 border-t border-gray-200 bg-gray-50/50">
                <Link
                    href="/dashboard/profile"
                    onClick={onNavigate}
                    className="flex items-center gap-3 p-2 rounded-xl hover:bg-white hover:shadow-sm hover:ring-1 hover:ring-gray-200 transition-all duration-200 group mb-2 cursor-pointer"
                >
                    <Avatar className="h-10 w-10 border border-white shadow-sm bg-white">
                        <AvatarFallback className="text-blue-700 font-semibold bg-blue-50">{initials}</AvatarFallback>
                    </Avatar>
                    <div className="flex-1 min-w-0 text-left">
                        {isLoading ? (
                            <>
                                <div className="h-4 w-24 bg-slate-200 rounded animate-pulse mb-1" />
                                <div className="h-3 w-16 bg-slate-100 rounded animate-pulse" />
                            </>
                        ) : (
                            <>
                                <p className="text-sm font-semibold text-gray-900 truncate group-hover:text-blue-700 transition-colors">
                                    {user?.email?.split('@')[0] || 'User'}
                                </p>
                                <p className="text-[10px] text-gray-500 truncate">View Profile</p>
                            </>
                        )}
                    </div>
                </Link>


                <Button
                    onClick={handleLogout}
                    disabled={isLoggingOut}
                    variant="ghost"
                    size="sm"
                    className="w-full justify-start gap-2 text-gray-500 hover:text-red-600 hover:bg-red-50/50 h-8 px-2 font-medium"
                >
                    <LogOut className={cn("h-3.5 w-3.5", isLoggingOut && "animate-spin")} />
                    <span className="text-xs">
                        {isLoggingOut ? 'Logging out...' : 'Safe Logout'}
                    </span>
                </Button>
            </div>
        </div>
    )
}

import { usePendingRequests } from '@/hooks/use-pending-requests'
import { useUnreadChat } from '@/hooks/use-unread-chat'

function SidebarItem({ item, active, onNavigate }: { item: NavItem, active: boolean, onNavigate?: () => void }) {
    const Icon = item.icon
    const { requests } = usePendingRequests()
    const { unreadCount } = useUnreadChat()
    
    const pendingCount = item.label === 'Pending Requests' ? requests.length : 0
    const isMessages = item.label === 'Messages'

    const handleInternalNavigate = () => {
        if (onNavigate) onNavigate()
    }

    return (
        <Link
            href={item.href}
            onClick={handleInternalNavigate}
            prefetch={true}
            className={cn(
                'flex items-center gap-3 px-3 py-2 14in:py-2.5 text-xs 14in:text-sm transition-all duration-300 group relative active:scale-[0.98]',
                active
                    ? 'bg-blue-50/60 text-blue-900 font-bold'
                    : 'text-slate-500 hover:bg-slate-50 hover:text-slate-900 font-medium'
            )}
        >
            {/* 📍 Left-Side Accent Bar (The Professional Standard) */}
            {active && (
                <div className="absolute left-0 top-1/2 -translate-y-1/2 w-1 h-6 bg-blue-600 rounded-r-full shadow-[2px_0_8px_rgba(37,99,235,0.4)]" />
            )}

            <div className="relative">
                <item.icon className={cn('h-5 w-5 shrink-0 transition-colors duration-300', active ? 'text-blue-600' : 'text-slate-400 group-hover:text-slate-600')} />
            </div>
            
            <span className={cn('truncate transition-all', active ? 'translate-x-0.5' : '')}>{item.label}</span>

            {/* LIVE NOTIFICATION BADGE (Pending Requests) */}
            {pendingCount > 0 && !active && (
                <span className="absolute right-3 flex h-5 min-w-[20px] px-1.5 items-center justify-center rounded-full bg-blue-600 text-[10px] font-bold text-white shadow-sm">
                    {pendingCount > 99 ? '99+' : pendingCount}
                </span>
            )}
            
            {/* Active Indicator for Pending Items */}
            {item.label === 'Pending Requests' && pendingCount > 0 && active && (
                <div className="absolute right-3 h-2 w-2 rounded-full bg-blue-600 ring-4 ring-blue-100" />
            )}

            {/* Messages Badge */}
            {isMessages && unreadCount > 0 && !active && (
                <span className="absolute right-3 flex h-5 min-w-[20px] px-1.5 items-center justify-center rounded-full bg-rose-500 text-[10px] font-bold text-white shadow-sm">
                    {unreadCount > 99 ? '99+' : unreadCount}
                </span>
            )}

            {isMessages && unreadCount > 0 && active && (
                <div className="absolute right-3 h-2 w-2 rounded-full bg-rose-500 ring-4 ring-rose-100" />
            )}
        </Link>
    )
}
