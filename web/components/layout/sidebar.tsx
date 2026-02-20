'use client'

import Link from 'next/link'
import Image from 'next/image'
import { usePathname } from 'next/navigation'
import { Shield, LogOut } from 'lucide-react'
import { navItems, type NavItem } from '@/lib/nav-config'
import { cn } from '@/lib/utils'
import { Button } from '@/components/ui/button'
import { useRouter } from 'next/navigation'
import { signOut, getCurrentUser } from '@/lib/auth'
import { useEffect, useState } from 'react'
import { Avatar, AvatarFallback } from '@/components/ui/avatar'
import { NotificationBell } from './notification-bell'
import { preload } from 'swr'

interface SidebarProps {
    className?: string
    onNavigate?: () => void
}

export function Sidebar({ className, onNavigate }: SidebarProps) {
    const pathname = usePathname()
    const router = useRouter()
    const [user, setUser] = useState<any>(null)
    const [isLoggingOut, setIsLoggingOut] = useState(false)

    useEffect(() => {
        getCurrentUser().then(u => {
            if (u) setUser(u)
        })

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
                    {navItems.filter(i => ['Overview'].includes(i.label)).map((item) => (
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
                    {navItems.filter(i => ['Inventory', 'Pending Requests', 'Borrow/Return Logs', 'Print Reports'].includes(i.label)).map((item) => (
                        <SidebarItem
                            key={item.href}
                            item={item}
                            active={isActive(item.href)}
                            onNavigate={onNavigate}
                        />
                    ))}
                </div>

                {/* ADMIN SECTION */}
                {user?.role === 'admin' && (
                    <div className="space-y-1.5">
                        <p className="px-3 pb-2 text-[10px] font-bold text-slate-400 uppercase tracking-[0.2em] opacity-70">Personnel</p>
                        {navItems.filter(i => ['Borrower Registry', 'System Users'].includes(i.label)).map((item) => (
                            <SidebarItem
                                key={item.href}
                                item={item}
                                active={isActive(item.href)}
                                onNavigate={onNavigate}
                            />
                        ))}
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

function SidebarItem({ item, active, onNavigate }: { item: NavItem, active: boolean, onNavigate?: () => void }) {
    const Icon = item.icon
    const { requests } = usePendingRequests()
    const pendingCount = item.label === 'Pending Requests' ? requests.length : 0

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
            className={cn(
                'flex items-center gap-3 px-3 py-2 14in:py-2.5 rounded-xl text-xs 14in:text-sm transition-all duration-300 group relative',
                active
                    ? 'bg-blue-600 text-white font-semibold shadow-lg shadow-blue-200/50'
                    : 'text-slate-500 hover:bg-slate-50 hover:text-slate-900 font-medium'
            )}
        >
            <Icon className={cn('h-4 w-4 14in:h-5 14in:w-5 flex-shrink-0 transition-colors', active ? 'text-white' : 'text-slate-400 group-hover:text-slate-600')} />
            <span className="truncate">{item.label}</span>

            {/* LIVE NOTIFICATION BADGE (Senior Dev UX) */}
            {pendingCount > 0 && (
                <span className="absolute right-3 flex h-5 w-5 items-center justify-center rounded-full bg-amber-500 text-[10px] font-black text-white shadow-lg animate-bounce border-2 border-white">
                    {pendingCount}
                </span>
            )}

            {active && pendingCount === 0 && (
                <div className="absolute right-2 h-1.5 w-1.5 rounded-full bg-white/40 blur-[1px]" />
            )}
        </Link>
    )
}
