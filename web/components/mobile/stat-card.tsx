'use client'

import React from 'react'
import { LucideIcon } from 'lucide-react'
import { cn } from '@/lib/utils'

interface StatCardProps {
    label: string
    value: string | number
    icon: LucideIcon
    trend?: string
    color: 'red' | 'blue' | 'amber' | 'green' | 'purple'
    isLoading?: boolean
}

const colorMap = {
    red: 'bg-red-50 text-red-600 border-red-100',
    blue: 'bg-blue-50 text-blue-600 border-blue-100',
    amber: 'bg-amber-50 text-amber-600 border-amber-100',
    green: 'bg-green-50 text-green-600 border-green-100',
    purple: 'bg-purple-50 text-purple-600 border-purple-100',
}

/**
 * 📱 LIGTAS Mobile Stat Card
 * 🏛️ ARCHITECTURE: Compact, high-signal information tile.
 */
export function StatCard({ label, value, icon: Icon, color, isLoading }: StatCardProps) {
    return (
        <div className={cn(
            "p-4 rounded-2xl border bg-white flex flex-col gap-3 transition-all active:scale-[0.98]",
            "shadow-sm shadow-gray-100/50"
        )}>
            <div className="flex items-center justify-between">
                <div className={cn("p-2 rounded-xl border", colorMap[color])}>
                    <Icon className="w-5 h-5" />
                </div>
                {isLoading && (
                    <div className="w-4 h-4 rounded-full border-2 border-gray-100 border-t-gray-300 animate-spin" />
                )}
            </div>
            
            <div className="space-y-0.5">
                <p className="text-xs font-medium text-gray-500 uppercase tracking-wider">
                    {label}
                </p>
                <p className="text-2xl font-bold text-gray-900 tabular-nums">
                    {isLoading ? "---" : value}
                </p>
            </div>
        </div>
    )
}
