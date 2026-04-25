import React from 'react'
import { MobileHeader } from '@/components/mobile/mobile-header'
import { MobileNav } from '@/components/mobile/mobile-nav'
import { Metadata, Viewport } from 'next'
import { AdaptiveRoutingSentry } from '@/components/layout/adaptive-routing-sentry'
import { InventoryProvider } from '@/providers/inventory-provider'
import { TransactionDetailSheet } from '@/components/mobile/transactions/transaction-detail-sheet'

export const metadata: Metadata = {
    title: 'CDRRMO Oroquieta · ResQTrack',
    description: 'Unified Logistics & Disaster Response Information System',
    manifest: '/manifest.json',
    appleWebApp: {
        capable: true,
        statusBarStyle: 'default',
        title: 'CDRRMO · ResQTrack',
        startupImage: '/oro-cervo.png',
    },
    icons: {
        icon: [{ url: '/oro-cervo.png', type: 'image/png', sizes: '512x512' }],
        apple: [{ url: '/oro-cervo.png', sizes: '180x180', type: 'image/png' }],
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
                <main className="flex-1 overflow-y-auto mb-[calc(64px+env(safe-area-inset-bottom))] bg-gray-50/50 animate-in fade-in duration-300 ease-out custom-scrollbar">
                    <div className="min-h-full">
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
