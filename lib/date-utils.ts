import { isToday, isYesterday, isWithinInterval, subDays, startOfDay } from 'date-fns'

/**
 * Implements the 'Contextual Chronology' pattern for ResQTrack Chat.
 * Switches format based on how old the timestamp is.
 * 
 * @param dateStr - ISO string, Date object, or null/undefined
 * @returns Formatted string: Time today, 'Yesterday', 'Month Day Weekday' (last 7 days), or 'Month Day'
 */
export function formatContextualTimestamp(dateStr: string | Date | null | undefined): string {
    if (!dateStr) return 'N/A'

    const date = new Date(dateStr)
    if (isNaN(date.getTime())) return 'Invalid date'

    const now = new Date()

    // Cache boundaries for today and last week
    const startOfToday = startOfDay(now)
    const lastWeekRange = {
        start: subDays(startOfToday, 7),
        end: subDays(startOfToday, 1)
    }

    if (isToday(date)) {
        return new Intl.DateTimeFormat('en-US', {
            hour: 'numeric',
            minute: '2-digit',
            hour12: true
        }).format(date)
    }
    if (isYesterday(date)) {
        return 'Yesterday'
    }

    if (isWithinInterval(date, lastWeekRange)) {
        // Format: {Month} {Day} {Weekday} (e.g., 'March 3 Thursday')
        return new Intl.DateTimeFormat('en-US', {
            month: 'long',
            day: 'numeric',
            weekday: 'long'
        }).format(date)
    }

    return new Intl.DateTimeFormat('en-US', {
        month: 'short',
        day: 'numeric'
    }).format(date)
}
