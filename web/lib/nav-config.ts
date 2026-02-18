import {
    LayoutDashboard,
    Package,
    ClipboardList,
    Printer,
    Users,
    Shield,
    LucideIcon,
} from 'lucide-react'

export interface NavItem {
    label: string
    href: string
    icon: LucideIcon
}

/**
 * Core MVP Navigation Items
 * Only 4 essential features for the LIGTAS CDRRMO system
 */
export const navItems: NavItem[] = [
    {
        label: 'Overview',
        href: '/dashboard',
        icon: LayoutDashboard,
    },
    {
        label: 'Inventory',
        href: '/dashboard/inventory',
        icon: Package,
    },
    {
        label: 'Borrow/Return Logs',
        href: '/dashboard/logs',
        icon: ClipboardList,
    },
    {
        label: 'Print Reports',
        href: '/dashboard/reports',
        icon: Printer,
    },
    {
        label: 'Borrower Registry',
        href: '/dashboard/borrowers',
        icon: Users,
    },
    {
        label: 'System Users',
        href: '/dashboard/users',
        icon: Users,
    },
] as const
