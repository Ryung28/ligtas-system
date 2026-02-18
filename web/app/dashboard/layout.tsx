import { ReactNode } from 'react'
import { Sidebar } from '@/components/layout/sidebar'
import { Header } from '@/components/layout/header'

interface DashboardLayoutProps {
    children: ReactNode
}

export default function DashboardLayout({ children }: DashboardLayoutProps) {
    return (
        <div className="min-h-screen bg-gradient-to-br from-gray-50 to-blue-50">
            {/* Desktop Sidebar - Progressive sizing for ultra-wide monitors */}
            <aside className="hidden lg:fixed lg:inset-y-0 lg:z-50 lg:flex lg:w-60 14in:w-64 xl:w-72 2xl:w-80 4xl:w-96 lg:flex-col select-none">
                <Sidebar />
            </aside>

            {/* Main Content Area */}
            <div className="lg:pl-60 14in:pl-64 xl:pl-72 2xl:pl-80 4xl:pl-96">
                {/* Mobile Header */}
                <Header />

                {/* Page Content - Adaptive spacing for diverse displays */}
                <main className="py-2 px-3 sm:py-3 sm:px-4 md:py-4 md:px-5 lg:py-4 lg:px-5 14in:py-5 14in:px-6 xl:py-6 xl:px-8 2xl:py-8 2xl:px-12 3xl:px-16 4xl:px-24">
                    {/* Adaptive max-width: Scales from standard 14" laptops to 4K Command Centers */}
                    <div className="mx-auto w-full max-w-[980px] 14in:max-w-[1100px] xl:max-w-[1300px] 2xl:max-w-[1500px] 3xl:max-w-[1800px] 4xl:max-w-[2200px]">
                        {children}
                    </div>
                </main>
            </div>
        </div>
    )
}
