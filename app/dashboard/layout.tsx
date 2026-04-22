import { ReactNode } from 'react'
import { Sidebar } from '@/components/layout/sidebar'
import { Header } from '@/components/layout/header'
import { PresenceHeartbeatV3 } from '@/components/chat-v3/presence-heartbeat-v3'
import { ChatNotificationListenerV3 } from '@/components/chat-v3/chat-notification-listener-v3'
import { ChatFabV3 } from '@/components/chat-v3/chat-fab-v3'
import { CacheWarmer } from '@/components/layout/cache-warmer'
import { AdaptiveRoutingSentry } from '@/components/layout/adaptive-routing-sentry'
import { InventoryProvider } from '@/providers/inventory-provider'
import { Suspense } from 'react'
import DashboardLoading from './loading'

interface DashboardLayoutProps {
    children: ReactNode
}

/**
 * ResQTrack Dashboard Layout (V3 Platinum Chat Integration)
 */
export default function DashboardLayout({ children }: DashboardLayoutProps) {
    return (
        <InventoryProvider>
        <div className="h-screen overflow-hidden flex bg-gradient-to-br from-gray-50 to-blue-50">
            {/* Desktop Sidebar */}
            <aside className="hidden lg:flex lg:relative lg:inset-y-0 lg:z-50 lg:w-60 14in:w-64 xl:w-72 2xl:w-80 4xl:w-96 lg:flex-col select-none">
                <Sidebar />
            </aside>

            {/* Main Content Area */}
            <div className="flex-1 flex flex-col min-w-0 overflow-hidden">
                <Header />
                <AdaptiveRoutingSentry />
                
                {/* ── Platinum Chat-V3 Infrastructure ── */}
                <PresenceHeartbeatV3 />
                <ChatNotificationListenerV3 />
                <ChatFabV3 />
                
                <CacheWarmer />

                <main className="flex-1 overflow-y-auto custom-scrollbar text-slate-900 transition-all duration-300" style={{ padding: 'var(--dashboard-padding)' }}>
                    <div className="mx-auto w-full transition-all duration-300" style={{ maxWidth: 'var(--dashboard-content-max-width)' }}>
                        <Suspense fallback={<DashboardLoading />}>
                            {children}
                        </Suspense>
                    </div>
                </main>
            </div>
        </div>
        </InventoryProvider>
    )
}
