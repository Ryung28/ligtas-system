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
    category: 'main' | 'operations' | 'reports' | 'communication'
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
        label: 'Messages',
        href: '/dashboard/chat',
        icon: MessageSquare,
        category: 'communication',
    },
    {
        label: 'Inventory',
        href: '/dashboard/inventory',
        icon: Package,
        category: 'operations',
    },
    {
        label: 'Pending Requests',
        href: '/dashboard/approvals',
        icon: ClipboardList,
        category: 'operations',
    },
    {
        label: 'Borrow/Return Logs',
        href: '/dashboard/logs',
        icon: ClipboardList,
        category: 'operations',
    },
    {
        label: 'Print Reports',
        href: '/dashboard/reports',
        icon: Printer,
        category: 'reports',
    },
    {
        label: 'Borrower Registry',
        href: '/dashboard/borrowers',
        icon: Users,
        category: 'reports',
    },
    {
        label: 'System Users',
        href: '/dashboard/users',
        icon: Users,
        category: 'reports',
    },
] as const

