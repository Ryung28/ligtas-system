import { z } from 'zod'

// 🛡️ TACTICAL SCHEMA: Enforce mission-critical data integrity
// Centralized for reuse in hooks, components, and future server actions.
export const NotificationItemSchema = z.object({
    id: z.string(),
    userId: z.string().uuid().nullable().optional(), // 🛡️ BROADCAST SILO: Null for org-wide alerts
    referenceId: z.string().nullable().optional(), // 🛡️ POLYMORPHIC: Align with TEXT column
    title: z.string(),
    message: z.string(),
    time: z.string().or(z.date()), // 🛡️ PERMISSIVE: Accept both DB strings and ISO dates
    type: z.string(), // 🛡️ RELAXED: Accept any categorical string to prevent validation drops
    isRead: z.boolean(),
    action: z.object({
        label: z.string(),
        type: z.enum(['link', 'rpc', 'dialog']),
        target: z.string(),
        payload: z.record(z.any()).optional()
    }).nullable().optional()
})

export type NotificationItem = z.infer<typeof NotificationItemSchema>
