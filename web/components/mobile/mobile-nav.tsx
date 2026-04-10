'use client'

import React from 'react'
import Link from 'next/link'
import { usePathname } from 'next/navigation'
import { Home, Package, CheckSquare, ClipboardList } from 'lucide-react'
import { cn } from '@/lib/utils'

/**
 * 📱 LIGTAS Mobile Navigation
 * 🏛️ ARCHITECTURE: Fixed bottom bar for high-reachability touch targets.
 */
export function MobileNav() {
    const pathname = usePathname()

    const tabs = [
        {
            label: 'Home',
            icon: Home,
            href: '/m',
            active: pathname === '/m'
        },
        {
            label: 'Inventory',
            icon: Package,
            href: '/m/inventory',
            active: pathname.startsWith('/m/inventory')
        },
        {
            label: 'Approvals',
            icon: CheckSquare,
            href: '/m/approvals',
            active: pathname.startsWith('/m/approvals')
        },
        {
            label: 'Logs',
            icon: ClipboardList,
            href: '/m/logs',
            active: pathname.startsWith('/m/logs')
        }
    ]

    return (
        <nav className="fixed bottom-0 left-0 right-0 h-[calc(64px+env(safe-area-inset-bottom))] bg-white border-t border-gray-100 flex items-start px-2 z-50 pb-[env(safe-area-inset-bottom)]">
            <div className="flex w-full h-16">
                {tabs.map((tab) => (
                    <Link
                        key={tab.label}
                        href={tab.href}
                        className={cn(
                            "flex-1 flex flex-col items-center justify-center gap-1 transition-all active:scale-95",
                            tab.active ? "text-red-600" : "text-gray-400"
                        )}
                    >
                        <tab.icon className={cn(
                            "w-6 h-6",
                            tab.active ? "stroke-[2.5px]" : "stroke-2"
                        )} />
                        <span className={cn(
                            "text-[10px] font-medium tracking-wide leading-none",
                            tab.active ? "text-red-700" : "text-gray-500"
                        )}>
                            {tab.label}
                        </span>
                        
                        {/* Active Indicator Dot */}
                        {tab.active && (
                            <div className="absolute top-1 right-1/2 translate-x-[12px] w-1.5 h-1.5 bg-red-600 rounded-full border border-white" />
                        )}
                    </Link>
                ))}
            </div>
        </nav>
    )
}
