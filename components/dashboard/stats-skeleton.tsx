import React from 'react'

/**
 * 🛰️ Tactical Premium: Identity/Stats Skeleton
 * 🏛️ ENTERPRISE DESIGN: Asymmetrical rounding and Neumorphism depth.
 */
export function DashboardStatsSkeleton() {
    return (
        <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6 animate-pulse">
            {[1, 2, 3, 4].map((i) => (
                <div 
                    key={i}
                    className="h-32 bg-white/50 backdrop-blur-sm 
                        rounded-tr-2xl rounded-bl-2xl rounded-tl-sm rounded-br-sm 
                        border border-white/20
                        shadow-[4px_4px_10px_rgba(0,0,0,0.05),-4px_-4px_10px_rgba(255,255,255,0.8)]
                        flex flex-col p-6 gap-3"
                >
                    <div className="w-24 h-4 bg-gray-200 rounded-full" />
                    <div className="w-16 h-8 bg-gray-300 rounded-lg" />
                    <div className="w-full h-2 bg-gray-100 rounded-full mt-auto" />
                </div>
            ))}
        </div>
    )
}
