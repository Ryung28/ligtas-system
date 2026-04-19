'use client'

import React from 'react'
import Link from 'next/link'
import { ArrowRight } from 'lucide-react'
import { cn } from '@/lib/utils'

interface SectionHeaderProps {
    icon?: React.ComponentType<{ className?: string }>
    title: string
    action?: { label: string; href: string } | { label: string; onClick: () => void }
    className?: string
}

/**
 * Standardised section eyebrow used on dashboard home and list pages.
 * Pattern: icon + uppercase title + optional right-aligned action link.
 */
export function SectionHeader({ icon: Icon, title, action, className }: SectionHeaderProps) {
    return (
        <div className={cn('flex items-center justify-between px-1', className)}>
            <h2 className="text-sm font-bold text-gray-900 uppercase tracking-tight flex items-center gap-2">
                {Icon && <Icon className="w-4 h-4 text-red-600" aria-hidden />}
                {title}
            </h2>
            {action && 'href' in action ? (
                <Link
                    href={action.href}
                    className="text-xs font-semibold text-red-600 flex items-center gap-0.5 focus-visible:underline focus-visible:outline-none"
                >
                    {action.label}
                    <ArrowRight className="w-3 h-3" aria-hidden />
                </Link>
            ) : action ? (
                <button
                    onClick={action.onClick}
                    className="text-xs font-semibold text-red-600 flex items-center gap-0.5 focus-visible:underline focus-visible:outline-none"
                >
                    {action.label}
                    <ArrowRight className="w-3 h-3" aria-hidden />
                </button>
            ) : null}
        </div>
    )
}
