'use client'

import React from 'react'
import Link from 'next/link'
import { usePathname } from 'next/navigation'
import { Home, Package, AlertCircle, Settings, QrCode } from 'lucide-react'
import { cn } from '@/lib/utils'
import { ScannerDialog } from '@/src/features/scanner/components/scanner-dialog'

/**
 * 📱 ResQTrack Mobile Navigation
 * 🏛️ ARCHITECTURE: Fixed bottom bar for high-reachability touch targets.
 */
export function MobileNav() {
    const pathname = usePathname()

    const leftTabs = [
        {
            label: 'Home',
            icon: Home,
            href: '/m',
            active: pathname === '/m'
        },
        {
            label: 'Alerts',
            icon: AlertCircle,
            href: '/m/alerts',
            active: pathname.startsWith('/m/alerts')
        }
    ]

    const rightTabs = [
        {
            label: 'Inventory',
            icon: Package,
            href: '/m/inventory',
            active: pathname.startsWith('/m/inventory')
        },
        {
            label: 'Settings',
            icon: Settings,
            href: '/m/profile',
            active: pathname.startsWith('/m/profile')
        }
    ]

    return (
        <nav className="fixed bottom-0 left-0 right-0 h-[calc(64px+env(safe-area-inset-bottom))] bg-white border-t border-gray-100 z-50 pb-[env(safe-area-inset-bottom)]">
            <div className="flex w-full h-16 items-center">
                {/* Left Tabs */}
                {leftTabs.map((tab) => (
                    <Link
                        key={tab.label}
                        href={tab.href}
                        className={cn(
                            "flex-1 flex flex-col items-center justify-center gap-1 transition-all active:scale-95 relative",
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
                        {tab.active && (
                            <div className="absolute top-1 right-1/2 translate-x-[12px] w-1.5 h-1.5 bg-red-600 rounded-full border border-white" />
                        )}
                    </Link>
                ))}

                {/* Center QR Scanner FAB */}
                <div className="flex-1 flex flex-col items-center justify-center -mt-6">
                    <ScannerDialog 
                        trigger={
                            <button className="w-14 h-14 bg-slate-950 rounded-full flex items-center justify-center shadow-xl shadow-slate-200 active:scale-90 transition-all border-4 border-white">
                                <QrCode className="w-6 h-6 text-white" />
                            </button>
                        }
                    />
                    <span className="text-[10px] font-bold text-slate-400 uppercase tracking-widest mt-1.5">Scan</span>
                </div>

                {/* Right Tabs */}
                {rightTabs.map((tab) => (
                    <Link
                        key={tab.label}
                        href={tab.href}
                        className={cn(
                            "flex-1 flex flex-col items-center justify-center gap-1 transition-all active:scale-95 relative",
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
                        {tab.active && (
                            <div className="absolute top-1 right-1/2 translate-x-[12px] w-1.5 h-1.5 bg-red-600 rounded-full border border-white" />
                        )}
                    </Link>
                ))}
            </div>
        </nav>
    )
}
