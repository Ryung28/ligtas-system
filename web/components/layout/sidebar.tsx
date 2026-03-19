'use client'

import Link from 'next/link'
import Image from 'next/image'
import { usePathname } from 'next/navigation'
import { LogOut, ChevronRight } from 'lucide-react' // Modified: Shield removed, ChevronRight added
import { navItems, type NavItem } from '@/lib/nav-config'
import { cn } from '@/lib/utils'
import { Button } from '@/components/ui/button'
import { useRouter } from 'next/navigation'
import { signOut, getCurrentUser } from '@/lib/auth'
import { useEffect, useState } from 'react'
import { Avatar, AvatarFallback } from '@/components/ui/avatar'
import { NotificationBellV2 } from './notification-bell-v2'
import { TACTICAL_THEME } from '@/lib/theme-config'
import { preload } from 'swr'

interface SidebarProps {
    className?: string
    onNavigate?: () => void
    user: any // 🛡️ Senior Dev: Typed from RSC Handshake
}

export function Sidebar({ className, onNavigate, user }: SidebarProps) {
    const pathname = usePathname()
    const router = useRouter()
    const [isLoggingOut, setIsLoggingOut] = useState(false)

    useEffect(() => {
        // TIER-1 OPTIMIZATION: Background Hydration
        // Quietly fetch data for other pages while the user is looking at the current one
        const hydrateCache = async () => {
            try {
                // Pre-fetch Logs
                const { LOGS_CACHE_KEY, fetchLogs } = await import('@/hooks/use-borrow-logs')
                preload(LOGS_CACHE_KEY, fetchLogs)

                // Pre-fetch Inventory
                const { INVENTORY_CACHE_KEY, fetchInventory } = await import('@/hooks/use-inventory')
                preload(INVENTORY_CACHE_KEY, fetchInventory)
            } catch (e) {
                console.warn('Hydration failed:', e)
            }
        }

        // Use a small delay to ensure initial page load isn't blocked
        const timer = setTimeout(hydrateCache, 1500)
        return () => clearTimeout(timer)
    }, [])

    const isActive = (href: string): boolean => {
        if (href === '/dashboard') {
            return pathname === '/dashboard'
        }
        return pathname.startsWith(href)
    }

    const handleLogout = async () => {
        try {
            setIsLoggingOut(true)
            await signOut()
            // Force a full page reload to the login page to clear all memory states
            window.location.href = '/login'
        } catch (error) {
            console.error('Logout failed:', error)
            setIsLoggingOut(false)
        }
    }

    const initials = user?.email?.substring(0, 2).toUpperCase() || 'AD'

    return (
        <div className={cn('flex h-full flex-col bg-white/95 backdrop-blur-xl border-r border-slate-100', className)}>
            {/* Logo/Header */}
            <div className="flex flex-col gap-2 px-6 py-8 border-b border-slate-50 items-center">
                <div className="relative h-20 w-20 shadow-sm rounded-full bg-white p-1 border border-slate-100 mb-2">
                    <Image
                        src="/oro-cervo.png"
                        alt="CDRRMO Logo"
                        fill
                        className="object-contain p-1.5"
                        priority
                    />
                </div>
                <div>
                    <p className="text-[9px] font-bold text-slate-400 uppercase tracking-[0.25em] text-center opacity-80">CDRRMO SYSTEM</p>
                </div>
            </div>

            {/* Navigation Links */}
            <nav className="flex-1 px-4 py-6 space-y-6 overflow-y-auto custom-scrollbar">
                {/* CORE SECTION */}
                <div className="space-y-1.5">
                    <p className="px-3 pb-2 text-[10px] font-bold text-slate-400 uppercase tracking-[0.2em] opacity-70">Main Command</p>
                    {navItems.filter(i => i.category === 'main').map((item) => (
                        <SidebarItem
                            key={item.href}
                            item={item}
                            active={isActive(item.href)}
                            onNavigate={onNavigate}
                        />
                    ))}
                </div>

                {/* LOGISTICS SECTION */}
                <div className="space-y-1.5">
                    <p className="px-3 pb-2 text-[10px] font-bold text-slate-400 uppercase tracking-[0.2em] opacity-70">Logistics & Ops</p>
                    {navItems.filter(i => i.category === 'logistics').map((item) => (
                        <SidebarItem
                            key={item.href}
                            item={item}
                            active={isActive(item.href)}
                            onNavigate={onNavigate}
                        />
                    ))}
                </div>

                {/* PERSONNEL SECTION (Admin & Managers) */}
                {(user?.role === 'admin' || user?.role === 'editor') && (
                    <div className="space-y-1.5">
                        <p className="px-3 pb-2 text-[10px] font-bold text-slate-400 uppercase tracking-[0.2em] opacity-70">Personnel Control</p>

                        {navItems.filter(i => i.category === 'personnel').map((item) => {
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
                        })}
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
                        <p className="text-sm font-semibold text-gray-900 truncate group-hover:text-blue-700 transition-colors">
                            {user?.email?.split('@')[0] || 'Administrator'}
                        </p>
                        <p className="text-[10px] text-gray-500 truncate">View Profile</p>
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

    return (
        <Link
            href={item.href}
            onClick={onNavigate}
            onMouseEnter={() => {
                if (item.href === '/dashboard/logs') {
                    import('@/hooks/use-borrow-logs').then((mod) => {
                        preload(mod.LOGS_CACHE_KEY, mod.fetchLogs)
                    })
                }
                if (item.href === '/dashboard/inventory') {
                    import('@/hooks/use-inventory').then((mod) => {
                        preload(mod.INVENTORY_CACHE_KEY, mod.fetchInventory)
                    })
                }
            }}
            style={active ? { borderRadius: TACTICAL_THEME.borderRadius.asymmetric } : {}}
            className={cn(
                'flex items-center gap-3 px-3 py-2 14in:py-2.5 text-xs 14in:text-sm transition-all duration-300 group relative',
                active
                    ? 'bg-blue-600 text-white font-semibold shadow-lg'
                    : 'text-slate-500 hover:bg-slate-50 hover:text-slate-900 font-medium rounded-xl'
            )}
        >
            <Icon className={cn('h-4 w-4 14in:h-5 14in:w-5 flex-shrink-0 transition-colors', active ? 'text-white' : 'text-slate-400 group-hover:text-slate-600')} />
            <span className="truncate">{item.label}</span>

            {/* LIVE NOTIFICATION BADGE (Pending Requests) - Ops Domain (Indigo) */}
            {/* Active Concealment: Hides the big pill when already on the page, replacing with an ambient glow */}
            {pendingCount > 0 && !active && (
                <span className="absolute right-3 flex h-5 min-w-[20px] px-1.5 items-center justify-center rounded-full bg-gradient-to-br from-indigo-500 to-indigo-600 text-[10px] font-bold text-white shadow-[0_4px_12px_rgba(79,70,229,0.4)] border-2 border-white/95 ring-1 ring-slate-900/5 transition-all duration-300 hover:scale-110 hover:shadow-[0_6px_16px_rgba(79,70,229,0.6)] animate-in zoom-in-75 fade-in duration-500">
                    {pendingCount > 99 ? '99+' : pendingCount}
                </span>
            )}
            
            {/* Active Radiant Glow for Ops Domain when hiding the pill */}
            {item.label === 'Pending Requests' && pendingCount > 0 && active && (
                <div className="absolute right-3 h-2 w-2 rounded-full bg-indigo-500 shadow-[0_0_12px_4px_rgba(99,102,241,0.5)] animate-pulse" />
            )}

            {/* LIVE NOTIFICATION BADGE (Unread Chat) - Comms Domain (Rose) */}
            {isMessages && unreadCount > 0 && !active && (
                <span className="absolute right-3 flex h-5 min-w-[20px] px-1.5 items-center justify-center rounded-full bg-gradient-to-br from-rose-500 to-rose-600 text-[10px] font-bold text-white shadow-[0_4px_12px_rgba(244,63,94,0.4)] border-2 border-white/95 ring-1 ring-slate-900/5 transition-all duration-300 hover:scale-110 hover:shadow-[0_6px_16px_rgba(244,63,94,0.6)] animate-in zoom-in-75 fade-in duration-500">
                    {unreadCount > 99 ? '99+' : unreadCount}
                </span>
            )}

            {isMessages && unreadCount > 0 && active && (
                <div className="absolute right-3 h-2 w-2 rounded-full bg-rose-500 shadow-[0_0_12px_4px_rgba(244,63,94,0.5)] animate-pulse" />
            )}

            {/* Subtle Active Indicator when no notifications exist */}
            {active && (!isMessages || unreadCount === 0) && pendingCount === 0 && (
                <div className="absolute right-2 h-1.5 w-1.5 rounded-full bg-white/40 blur-[1px]" />
            )}
        </Link>
    )
}
