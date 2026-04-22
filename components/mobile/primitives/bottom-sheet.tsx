'use client'

import React from 'react'
import {
    Sheet,
    SheetContent,
    SheetHeader,
    SheetTitle,
    SheetDescription,
} from '@/components/ui/sheet'
import { cn } from '@/lib/utils'

interface BottomSheetProps {
    open: boolean
    onOpenChange: (open: boolean) => void
    title: string
    description?: string
    children: React.ReactNode
    footer?: React.ReactNode
    /** Snap height — "auto" lets content define size; "full" is near full-screen. */
    size?: 'auto' | 'half' | 'full'
    className?: string
}

const sizeMap: Record<NonNullable<BottomSheetProps['size']>, string> = {
    auto: 'max-h-[85dvh]',
    half: 'h-[60dvh]',
    full: 'h-[92dvh]',
}

/**
 * Mobile bottom sheet wrapper over shadcn Sheet with enterprise defaults:
 * - rounded top, grip handle, safe-area padding
 * - sticky header, scrollable body, sticky footer for primary actions
 * - traps focus, restores on close (from Radix Dialog under the hood)
 */
export function BottomSheet({
    open,
    onOpenChange,
    title,
    description,
    children,
    footer,
    size = 'auto',
    className,
}: BottomSheetProps) {
    return (
        <Sheet open={open} onOpenChange={onOpenChange}>
            <SheetContent
                side="bottom"
                className={cn(
                    'p-0 rounded-t-3xl border-t-0 flex flex-col',
                    'pb-[env(safe-area-inset-bottom)]',
                    sizeMap[size],
                    className,
                )}
            >
                <div className="pt-2 pb-1 flex justify-center flex-none">
                    <div className="w-10 h-1.5 rounded-full bg-gray-200" aria-hidden />
                </div>

                <SheetHeader className="px-5 pt-2 pb-4 flex-none text-left border-b border-gray-100">
                    <SheetTitle className="text-base font-bold text-gray-900">{title}</SheetTitle>
                    <SheetDescription className={cn("text-xs text-gray-500", !description && "sr-only")}>
                        {description || `Tactical details for ${title}`}
                    </SheetDescription>
                </SheetHeader>

                <div className="flex-1 overflow-y-auto px-5 py-4 custom-scrollbar">{children}</div>

                {footer && (
                    <div className="flex-none border-t border-gray-100 px-5 py-3 bg-white">
                        {footer}
                    </div>
                )}
            </SheetContent>
        </Sheet>
    )
}
