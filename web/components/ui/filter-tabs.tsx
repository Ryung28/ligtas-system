'use client'

import { cn } from '@/lib/utils'

interface FilterTab {
    value: string
    label: string
    count?: number
}

interface FilterTabsProps {
    tabs: FilterTab[]
    activeTab: string
    onTabChange: (value: string) => void
    className?: string
}

export function FilterTabs({ tabs, activeTab, onTabChange, className }: FilterTabsProps) {
    return (
        <div className={cn("flex items-center gap-2 overflow-x-auto pb-2 scrollbar-hide", className)}>
            {tabs.map((tab) => (
                <button
                    key={tab.value}
                    onClick={() => onTabChange(tab.value)}
                    className={cn(
                        "px-4 py-2 rounded-lg text-[13px] font-medium transition-all duration-200 whitespace-nowrap",
                        activeTab === tab.value
                            ? "bg-gray-900 text-white shadow-sm"
                            : "bg-white text-gray-600 hover:bg-gray-50 border border-gray-200"
                    )}
                >
                    {tab.label}
                    {tab.count !== undefined && (
                        <span className={cn(
                            "ml-2 px-1.5 py-0.5 rounded-md text-[11px] font-semibold",
                            activeTab === tab.value
                                ? "bg-white/20 text-white"
                                : "bg-gray-100 text-gray-600"
                        )}>
                            {tab.count}
                        </span>
                    )}
                </button>
            ))}
        </div>
    )
}
