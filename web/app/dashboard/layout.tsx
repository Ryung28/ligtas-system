import { ReactNode } from 'react'
import { redirect } from 'next/navigation'
import { Sidebar } from '@/components/layout/sidebar'
import { Header } from '@/components/layout/header'
import { getCachedUser } from '@/lib/auth-server'
import { PresenceHeartbeat } from '@/components/chat/presence-heartbeat'
import { ChatNotificationListener } from '@/components/chat/chat-notification-listener'
import { CacheWarmer } from '@/components/layout/cache-warmer'

interface DashboardLayoutProps {
    children: ReactNode
}

export default async function DashboardLayout({ children }: DashboardLayoutProps) {
    // 🛡️ Identity Singleton Handshake (Memoized across the whole request)
    const user = await getCachedUser()

    // ── Senior Arch Security Guard: Staff Only Access ──
    const isStaff = user && (user.role === 'admin' || user.role === 'editor')
    const isActive = user?.status === 'active'

    if (!user || !isActive || !isStaff) {
        console.warn(`[Security] Denied access to ${user?.email || 'Guest'}. Status: ${user?.status}. Role: ${user?.role}`)
        redirect('/login?error=UNAUTHORIZED: Staff access required.')
    }

    return (
        <div className="h-screen overflow-hidden flex bg-gradient-to-br from-gray-50 to-blue-50">
            {/* Desktop Sidebar - Progressive sizing for ultra-wide monitors */}
            <aside className="hidden lg:flex lg:relative lg:inset-y-0 lg:z-50 lg:w-60 14in:w-64 xl:w-72 2xl:w-80 4xl:w-96 lg:flex-col select-none">
                <Sidebar user={user} />
            </aside>

            {/* Main Content Area - Locked to Viewport Height */}
            <div className="flex-1 flex flex-col min-w-0 overflow-hidden">
                {/* Mobile Header / Desktop Top Bar */}
                <Header user={user} />
                <PresenceHeartbeat />
                <ChatNotificationListener />
                <CacheWarmer />

                {/* Page Content - Independent Scrollable Region */}
                <main className="flex-1 overflow-y-auto custom-scrollbar py-2 px-3 sm:py-3 sm:px-4 md:py-4 md:px-5 lg:py-4 lg:px-5 14in:py-5 14in:px-6 xl:py-6 xl:px-8 2xl:py-8 2xl:px-12 3xl:px-16 4xl:px-24">
                    {/* Adaptive max-width: Scales from standard 14" laptops to 4K Command Centers */}
                    <div className="mx-auto w-full max-w-[980px] 14in:max-w-[1100px] xl:max-w-[1300px] 2xl:max-w-[1500px] 3xl:max-w-[1800px] 4xl:max-w-[2200px]">
                        {children}
                    </div>
                </main>
            </div>

        </div>
    )
}
