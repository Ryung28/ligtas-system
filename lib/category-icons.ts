import type { LucideIcon } from 'lucide-react'
import {
    LayoutGrid,
    Briefcase,
    ShoppingBag,
    Truck,
    Cross,
    Shield,
    LifeBuoy,
    Cpu,
    Wrench,
    Radio,
    Car,
} from 'lucide-react'

/** Maps canonical category labels (case-insensitive) to Lucide icons for selects and lists. */
const CATEGORY_ICON_MAP: Record<string, LucideIcon> = {
    equipment: Briefcase,
    goods: ShoppingBag,
    logistics: Truck,
    medical: Cross,
    ppe: Shield,
    rescue: LifeBuoy,
    system: Cpu,
    tools: Wrench,
    comms: Radio,
    vehicles: Car,
}

/** Lucide icon for an inventory category name; falls back to LayoutGrid when unknown. */
export function resolveCategoryIcon(categoryName: string | null | undefined): LucideIcon {
    if (!categoryName?.trim()) return LayoutGrid
    const key = categoryName.trim().toLowerCase()
    return CATEGORY_ICON_MAP[key] ?? LayoutGrid
}
