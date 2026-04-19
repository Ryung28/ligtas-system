import React from 'react'

export function ReportsSkeleton() {
    return (
        <div className="space-y-6 animate-pulse">
            {/* Header Skeleton */}
            <div className="h-10 w-48 bg-gray-200 rounded-lg mb-2" />
            
            {/* Stats Grid */}
            <div className="grid grid-cols-2 gap-3">
                {[1, 2, 3, 4].map(i => (
                    <div key={i} className="h-24 bg-white rounded-2xl border border-gray-100 shadow-sm" />
                ))}
            </div>

            {/* List Skeleton */}
            <div className="space-y-3">
                <div className="h-4 w-32 bg-gray-100 rounded" />
                {[1, 2, 3, 4, 5].map(i => (
                    <div key={i} className="h-16 bg-white rounded-xl border border-gray-100 shadow-sm" />
                ))}
            </div>
        </div>
    )
}
