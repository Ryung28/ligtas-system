'use client'

import React, { useMemo } from 'react'
import { formatContextualTimestamp } from '@/lib/date-utils'
import { cn } from '@/lib/utils'

interface ChatMessageTimestampProps {
    timestamp: string | Date | null | undefined
    className?: string
}

/**
 * Optimized timestamp component for Chat Messages.
 * Uses memoization to avoid redundant date calculations across re-renders.
 */
export const ChatMessageTimestamp = React.memo(({ timestamp, className }: ChatMessageTimestampProps) => {
    const formattedTime = useMemo(() => {
        return formatContextualTimestamp(timestamp)
    }, [timestamp])

    return (
        <span className={cn("text-[10px] font-bold uppercase tracking-tight", className)}>
            {formattedTime}
        </span>
    )
})

ChatMessageTimestamp.displayName = 'ChatMessageTimestamp'
