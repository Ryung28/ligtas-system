'use client'

import { Menu, Bell } from 'lucide-react'
import { Button } from '@/components/ui/button'
import { Sheet, SheetContent, SheetDescription, SheetTitle, SheetTrigger } from '@/components/ui/sheet'
import { Sidebar } from './sidebar'
import { NotificationBellV2 } from './notification-bell-v2'
import { SmartScanner } from './smart-scanner'
import { useState, useEffect } from 'react'
import { useUser } from '@/providers/auth-provider'

export function Header() {
    const { user } = useUser()
    const [open, setOpen] = useState(false)
    const [mounted, setMounted] = useState(false)

    useEffect(() => {
        setMounted(true)
    }, [])

    const initials = user?.email?.substring(0, 2).toUpperCase() || 'AD'

    if (!mounted) {
        // ⚡️ PERFORMANCE GATE: Only render the placeholder layout during SSR
        return <header className="sticky top-0 z-30 flex h-16 items-center gap-4 border-b border-gray-200 bg-white/80 backdrop-blur-md px-6"></header>
    }

    return (
        <header className="sticky top-0 z-30 flex h-16 items-center gap-4 border-b border-gray-200 bg-white/80 backdrop-blur-md px-6">
            {/* Mobile Menu */}
            <Sheet open={open} onOpenChange={setOpen}>
                <SheetTrigger asChild>
                    <Button variant="outline" size="icon" className="lg:hidden shrink-0">
                        <Menu className="h-5 w-5" />
                        <span className="sr-only">Toggle navigation menu</span>
                    </Button>
                </SheetTrigger>
                <SheetContent side="left" className="p-0 w-64">
                    <SheetTitle className="sr-only">Navigation Menu</SheetTitle>
                    <SheetDescription className="sr-only">Access different sections of the ResQTrack dashboard.</SheetDescription>
                    <Sidebar onNavigate={() => setOpen(false)} />
                </SheetContent>
            </Sheet>

            {/* Mobile Logo / Desktop Spacer */}
            <div className="flex items-center gap-2 flex-1">
                <div className="flex items-center gap-2 lg:hidden">
                    <div className="w-8 h-8 bg-gradient-to-br from-blue-600 to-blue-700 rounded-lg flex items-center justify-center">
                        <span className="text-white font-semibold text-sm">L</span>
                    </div>
                    <span className="font-semibold text-gray-900">ResQTrack</span>
                </div>
            </div>

            {/* Right Actions */}
            <div className="flex items-center gap-3">
                <SmartScanner />
                <NotificationBellV2 />
            </div>
        </header>
    )
}
