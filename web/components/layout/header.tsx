'use client'

import { Menu, Bell } from 'lucide-react'
import { Button } from '@/components/ui/button'
import { Sheet, SheetContent, SheetTrigger } from '@/components/ui/sheet'
import { Sidebar } from './sidebar'
import { NotificationBell } from './notification-bell'
import { SmartScanner } from './smart-scanner'
import { useState } from 'react'

export function Header() {
    const [open, setOpen] = useState(false)

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
                    <Sidebar onNavigate={() => setOpen(false)} />
                </SheetContent>
            </Sheet>

            {/* Mobile Logo / Desktop Spacer */}
            <div className="flex items-center gap-2 flex-1">
                <div className="flex items-center gap-2 lg:hidden">
                    <div className="w-8 h-8 bg-gradient-to-br from-blue-600 to-blue-700 rounded-lg flex items-center justify-center">
                        <span className="text-white font-semibold text-sm">L</span>
                    </div>
                    <span className="font-semibold text-gray-900">LIGTAS</span>
                </div>
            </div>

            {/* Right Actions */}
            <div className="flex items-center gap-3">
                <SmartScanner />
                <NotificationBell />
            </div>
        </header>
    )
}
