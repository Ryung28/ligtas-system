import React from 'react'
import { MobileHeader } from '@/components/mobile/mobile-header'
import { MobileNav } from '@/components/mobile/mobile-nav'
import { Metadata, Viewport } from 'next'

export const metadata: Metadata = {
    title: 'LIGTAS Tactical',
    description: 'Unified Logistics & Disaster Response Information System',
    manifest: '/manifest.json',
    appleWebApp: {
        capable: true,
        statusBarStyle: 'default',
        title: 'LIGTAS',
    },
}

export const viewport: Viewport = {
    themeColor: '#b91c1c',
    width: 'device-width',
    initialScale: 1,
    maximumScale: 1,
    userScalable: false,
}

/**
 * 📱 LIGTAS Mobile Root Layout
 * 🛡️ THE STEEL CAGE: Absolute Viewport Clamping
 * This layout ensures the mobile interface remains locked to the device height
 * and prevents unwanted scrolling behaviors outside the main content area.
 */
export default function MobileLayout({
    children,
}: {
    children: React.ReactNode
}) {
    return (
        <div className="fixed inset-0 flex flex-col bg-white overflow-hidden select-none transform-gpu">
            {/* Main Interactive Field: The "Steel Cage" scrollable area */}
            <main className="flex-1 overflow-y-auto mb-[calc(64px+env(safe-area-inset-bottom))] p-4 bg-gray-50/50 animate-in fade-in duration-300 ease-out">
                <div className="max-w-screen-md mx-auto min-h-full">
                    {children}
                </div>
            </main>

            {/* Bottom Strategic Navigation Layer */}
            <MobileNav />
            
            {/* Visual Feedback Overlays (Optional reserved space for Toast/Notifications) */}
        </div>
    )
}
