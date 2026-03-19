import {
    LayoutDashboard,
    Package,
    ClipboardList,
    Printer,
    Users,
    Shield,
    LucideIcon,
    MessageSquare,
} from 'lucide-react'

export interface NavItem {
    label: string
    href: string
    icon: LucideIcon
    category: 'main' | 'logistics' | 'personnel'
}

/**
 * Core MVP Navigation Items
 * Grouped by Tactical Category for Dynamic Sidebar Rendering
 */
export const navItems: NavItem[] = [
    {
        label: 'Overview',
        href: '/dashboard',
        icon: LayoutDashboard,
        category: 'main',
    },
    {
        label: 'Inventory',
        href: '/dashboard/inventory',
        icon: Package,
        category: 'logistics',
    },
    {
        label: 'Pending Requests',
        href: '/dashboard/approvals',
        icon: ClipboardList,
        category: 'logistics',
    },
    {
        label: 'Borrow/Return Logs',
        href: '/dashboard/logs',
        icon: ClipboardList,
        category: 'logistics',
    },
    {
        label: 'Print Reports',
        href: '/dashboard/reports',
        icon: Printer,
        category: 'logistics',
    },
    {
        label: 'Borrower Registry',
        href: '/dashboard/borrowers',
        icon: Users,
        category: 'personnel',
    },
    {
        label: 'System Users',
        href: '/dashboard/users',
        icon: Users,
        category: 'personnel',
    },
    {
        label: 'Messages',
        href: '/dashboard/chat',
        icon: MessageSquare,
        category: 'main',
    },
] as const

