'use client'

import { useMemo } from 'react'
import { Card, CardContent } from '@/components/ui/card'
import { Package, TrendingDown, AlertCircle } from 'lucide-react'
import { InventoryItem } from '@/lib/supabase'

interface InventoryStatsProps {
    items: InventoryItem[]
}

export function InventoryStats({ items }: InventoryStatsProps) {
    const stats = useMemo(() => {
        const totalItems = items.length
        const lowStockItems = items.filter(item => item.stock_available > 0 && item.stock_available < 5).length
        const outOfStockItems = items.filter(item => item.stock_available === 0).length
        const totalStock = items.reduce((sum, item) => sum + item.stock_available, 0)

        return { totalItems, lowStockItems, outOfStockItems, totalStock }
    }, [items])

    return (
        <div className="grid grid-cols-2 md:grid-cols-4 gap-3">
            <StatsCard
                title="Total Items"
                value={stats.totalItems}
                icon={<Package className="h-5 w-5 text-blue-600" />}
                bg="bg-blue-50"
                border="border-blue-100"
            />
            <StatsCard
                title="Total Stock"
                value={stats.totalStock}
                icon={<Package className="h-5 w-5 text-indigo-600" />}
                bg="bg-indigo-50"
                border="border-indigo-100"
            />
            <StatsCard
                title="Low Stock"
                value={stats.lowStockItems}
                icon={<TrendingDown className="h-5 w-5 text-orange-600" />}
                bg="bg-orange-50"
                textColor="text-orange-600"
                border="border-orange-100"
            />
            <StatsCard
                title="Out of Stock"
                value={stats.outOfStockItems}
                icon={<AlertCircle className="h-5 w-5 text-red-600" />}
                bg="bg-red-50"
                textColor="text-red-600"
                border="border-red-100"
            />
        </div>
    )
}

function StatsCard({ title, value, icon, bg, textColor = 'text-slate-900', border }: any) {
    return (
        <Card className={`bg-white shadow-sm border-none ring-1 ring-slate-100 hover:shadow-md transition-all duration-300 rounded-2xl group`}>
            <CardContent className="p-3 14in:p-4 flex items-center justify-between">
                <div className="min-w-0">
                    <p className="text-[9px] font-semibold tracking-[0.15em] text-slate-400 uppercase truncate">{title}</p>
                    <p className={`text-xl 14in:text-2xl font-heading font-bold mt-0.5 tracking-tight leading-none ${textColor}`}>{value}</p>
                </div>
                <div className={`p-2.5 14in:p-3 rounded-xl shadow-sm ${bg} group-hover:scale-110 transition-transform duration-300`}>{icon}</div>
            </CardContent>
        </Card>
    )
}
