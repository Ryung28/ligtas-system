'use client'

import { useState, useRef, useEffect } from 'react'
import { ChevronRight } from 'lucide-react'

interface CollapsibleSectionProps {
    title: string
    subtitle?: string
    icon?: React.ReactNode
    defaultOpen?: boolean
    children: React.ReactNode
}

export function CollapsibleSection({ 
    title, 
    subtitle,
    icon, 
    defaultOpen = false, 
    children 
}: CollapsibleSectionProps) {
    const [isOpen, setIsOpen] = useState(defaultOpen)
    const contentRef = useRef<HTMLDivElement>(null)

    // Auto-scroll when section opens
    useEffect(() => {
        if (isOpen && contentRef.current) {
            // Small delay to allow animation to start
            setTimeout(() => {
                contentRef.current?.scrollIntoView({ 
                    behavior: 'smooth', 
                    block: 'center' // Changed from 'nearest' to 'center' for better visibility
                })
            }, 100)
        }
    }, [isOpen])

    return (
        <div 
            ref={contentRef}
            className="border-2 border-gray-200 rounded-xl overflow-hidden transition-all duration-200 hover:border-gray-300"
        >
            <button
                type="button"
                onClick={() => setIsOpen(!isOpen)}
                className="w-full px-4 py-3 flex items-center justify-between bg-gray-50 hover:bg-gray-100 transition-colors"
            >
                <div className="flex items-center gap-2">
                    {icon && <span className="text-gray-600">{icon}</span>}
                    <div className="text-left">
                        <p className="text-sm font-bold text-gray-900">{title}</p>
                        {subtitle && <p className="text-xs text-gray-500 mt-0.5">{subtitle}</p>}
                    </div>
                </div>
                <ChevronRight 
                    className={`h-4 w-4 text-gray-400 transition-transform duration-200 ${isOpen ? 'rotate-90' : ''}`} 
                />
            </button>
            
            {isOpen && (
                <div className="p-4 bg-white animate-in fade-in slide-in-from-top-2 duration-200">
                    {children}
                </div>
            )}
        </div>
    )
}
