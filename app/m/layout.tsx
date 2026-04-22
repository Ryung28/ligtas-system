import React from 'react'
import { MobileHeader } from '@/components/mobile/mobile-header'
import { MobileNav } from '@/components/mobile/mobile-nav'
import { Metadata, Viewport } from 'next'
import { AdaptiveRoutingSentry } from '@/components/layout/adaptive-routing-sentry'
import { InventoryProvider } from '@/providers/inventory-provider'
import { TransactionDetailSheet } from '@/components/mobile/transactions/transaction-detail-sheet'

export const metadata: Metadata = {
    title: 'ResQTrack',
    description: 'Unified Logistics & Disaster Response Information System',
    manifest: '/manifest.json',
    appleWebApp: {
        capable: true,
        statusBarStyle: 'default',
        title: 'ResQTrack',
        startupImage: '/resqtrack-logo.jpg',
    },
    icons: {
        apple: [
            { url: '/resqtrack-logo.jpg', sizes: '180x180', type: 'image/jpeg' },
        ],
    },
}

export const viewport: Viewport = {
    themeColor: '#b91c1c',
    width: 'device-width',
    initialScale: 1,
    maximumScale: 1,
    userScalable: false,
    viewportFit: 'cover',
}

/**
 * 📱 ResQTrack Mobile Root Layout
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
        <InventoryProvider>
            <div className="fixed inset-0 flex flex-col bg-white overflow-hidden select-none transform-gpu mobile-cage">
                <AdaptiveRoutingSentry />
                {/* Main Interactive Field: The "Steel Cage" scrollable area */}
                <main className="flex-1 overflow-y-auto mb-[calc(64px+env(safe-area-inset-bottom))] p-4 bg-gray-50/50 animate-in fade-in duration-300 ease-out custom-scrollbar">
                    <div className="max-w-screen-md mx-auto min-h-full">
                        {children}
                    </div>
                </main>

                {/* Bottom Strategic Navigation Layer */}
                <MobileNav />
                
                {/* 🎯 GLOBAL TRIAGE LAYER: Handles URL-driven detailed inspections */}
                <TransactionDetailSheet />
                
                {/* Visual Feedback Overlays (Optional reserved space for Toast/Notifications) */}
            </div>
        </InventoryProvider>
    )
}
