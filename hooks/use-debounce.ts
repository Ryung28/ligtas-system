'use client'

import { useEffect, useState } from 'react'

/**
 * Tactical Debounce: Prevents database thrashing by delaying state updates
 * until the user has stopped typing for a specified duration.
 */
export function useDebounce<T>(value: T, delay?: number): T {
    const [debouncedValue, setDebouncedValue] = useState<T>(value)

    useEffect(() => {
        const timer = setTimeout(() => setDebouncedValue(value), delay || 500)

        return () => {
            clearTimeout(timer)
        }
    }, [value, delay])

    return debouncedValue
}
