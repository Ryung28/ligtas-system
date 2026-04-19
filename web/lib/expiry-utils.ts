/**
 * EXPIRY URGENCY HELPER (SSOT)
 *
 * Centralises "how urgent is this expiry?" logic so every surface
 * (web table row, web card, reports, notifications) uses identical
 * bands and colours.
 *
 * Rule:  expiry_alert_days  (default 30 when absent)
 *   ─────────────────────────────────────────────────
 *   Expired  ≤ 0 days remaining           → red
 *   Critical ≤ 7 days remaining           → red (urgent, but not yet gone)
 *   Warning  ≤ expiry_alert_days days     → amber
 *   Ok       > expiry_alert_days days     → green
 *   None     no expiry_date set           → (no badge)
 */

export type ExpiryStatus = 'expired' | 'critical' | 'warning' | 'ok' | 'none'

export interface ExpiryInfo {
    status: ExpiryStatus
    daysRemaining: number | null
    label: string
    /** Tailwind bg+text+border token string for the badge */
    badgeClass: string
    /** Tailwind border-left colour token for row stripe */
    rowStripeClass: string
}

const DEFAULT_ALERT_DAYS = 30

/**
 * Derive the urgency tier for an inventory item.
 *
 * @param expiryDate  ISO date string from the DB, or null/undefined
 * @param alertDays   expiry_alert_days column value (null → 30)
 * @param now         override "today" for testing; defaults to Date.now()
 */
export function getExpiryInfo(
    expiryDate: string | null | undefined,
    alertDays: number | null | undefined,
    now: number = Date.now(),
): ExpiryInfo {
    if (!expiryDate) {
        return { status: 'none', daysRemaining: null, label: '', badgeClass: '', rowStripeClass: '' }
    }

    const window = alertDays != null && alertDays > 0 ? alertDays : DEFAULT_ALERT_DAYS
    const msRemaining = new Date(expiryDate).getTime() - now
    const daysRemaining = Math.floor(msRemaining / (1000 * 60 * 60 * 24))

    if (daysRemaining < 0) {
        return {
            status: 'expired',
            daysRemaining,
            label: 'EXPIRED',
            badgeClass: 'bg-red-100 text-red-700 border-red-200',
            rowStripeClass: 'border-l-4 border-l-red-500',
        }
    }

    if (daysRemaining <= 7) {
        return {
            status: 'critical',
            daysRemaining,
            label: `${daysRemaining}D LEFT`,
            badgeClass: 'bg-red-50 text-red-600 border-red-200',
            rowStripeClass: 'border-l-4 border-l-red-400',
        }
    }

    if (daysRemaining <= window) {
        return {
            status: 'warning',
            daysRemaining,
            label: `${daysRemaining}D LEFT`,
            badgeClass: 'bg-amber-50 text-amber-700 border-amber-200',
            rowStripeClass: 'border-l-4 border-l-amber-400',
        }
    }

    return {
        status: 'ok',
        daysRemaining,
        label: 'GOOD',
        badgeClass: 'bg-emerald-50 text-emerald-700 border-emerald-200',
        rowStripeClass: '',
    }
}

/** True when the item should appear in expiry-related filter/alert counts. */
export function isExpiringSoon(
    expiryDate: string | null | undefined,
    alertDays: number | null | undefined,
    now: number = Date.now(),
): boolean {
    const { status } = getExpiryInfo(expiryDate, alertDays, now)
    return status === 'warning' || status === 'critical' || status === 'expired'
}
