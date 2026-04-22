'use client'

import React, { useMemo } from 'react'
import { formatContextualTimestamp } from '@/lib/date-utils'
import { cn } from '@/lib/utils'

interface ChatMessageTimestampV3Props {
    timestamp: string | Date | null | undefined
    className?: string
}

/**
 * Optimized timestamp component for Chat Messages.
 * Uses memoization to avoid redundant date calculations.
 */
export const ChatMessageTimestampV3 = React.memo(({ timestamp, className }: ChatMessageTimestampV3Props) => {
    const formattedTime = useMemo(() => {
        return formatContextualTimestamp(timestamp)
    }, [timestamp])

    return (
        <span className={cn("text-[10px] font-bold uppercase tracking-tight", className)}>
            {formattedTime}
        </span>
    )
})

ChatMessageTimestampV3.displayName = 'ChatMessageTimestampV3'
