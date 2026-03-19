'use server'

import { unstable_noStore as noStore } from 'next/cache'
import { revalidateTag } from 'next/cache'
import { z } from 'zod'
import { NotificationRepository } from '@/lib/repositories/notification-repository'

// 🛡️ TACTICAL VALIDATION: Relaxed to string to support polymorphic intel packets
const NotificationIdSchema = z.object({
  id: z.coerce.string().min(1, { message: "Identifier cannot be empty" })
})

/**
 * 🛰️ SERVER ACTION: GET INBOX
 * Fetches the user's notification inbox via the Server Intel Sink.
 */
export async function getInboxAction(limit: number = 20, _timestamp?: number) {
    noStore(); // 🛡️ CACHE BUSTING: Force a fresh database fetch on every hit
    try {
        // 🛡️ TACTICAL SILO: Delegate to Repository (Server-Only environment)
        const result = await NotificationRepository.getInbox(limit)
        return result
    } catch (error: any) {
        console.error('[Action:GetInbox] Boundary Failure:', error.message)
        return { 
            success: false, 
            data: [], 
            message: 'Critical intel retrieval failure.',
            error: error.message 
        }
    }
}

/**
 * Marks a specific notification as read in the Isolated Intel Sink.
 * @param notificationId - The identifier of the specific notification
 */
export async function markAsReadAction(notificationId: any) {
  // 🛡️ TACTICAL PRE-FLIGHT: Guard against ghost payloads from stale UI state
  if (!notificationId) {
    console.error('[Action:MarkRead] 🚨 CRITICAL: Received UNDEFINED ID from Client');
    return { success: false, message: 'Sync failed: Payload corrupted.' }
  }

  const validation = NotificationIdSchema.safeParse({ id: notificationId })
  
  if (!validation.success) {
    console.error('[Sync Failure] Validation Detail:', JSON.stringify(validation.error, null, 2));
    return { success: false, message: 'Invalid identifier', errors: validation.error.flatten() }
  }

  // 🛡️ TACTICAL SILO: Delegate to Repository for Sink consistency
  const result = await NotificationRepository.markAsRead(notificationId)

  if (result.success) {
    revalidateTag('notifications')
  }
  
  return result
}

/**
 * Marks all reachable notifications as read for this specific operator.
 */
export async function markAllReadAction() {
  // 🛡️ TACTICAL SILO: Delegate to Repository for Bulk Sink consistency
  const result = await NotificationRepository.markAllRead()

  if (result.success) {
    revalidateTag('notifications')
  }

  return result
}

/**
 * Hard deletes a specific notification.
 */
export async function deleteNotificationAction(notificationId: any) {
  // 🛡️ TACTICAL PRE-FLIGHT: Guard against ghost payloads
  if (!notificationId) {
    return { success: false, message: 'Delete failed: Payload corrupted.' }
  }

  const validation = NotificationIdSchema.safeParse({ id: notificationId })
  if (!validation.success) {
    return { success: false, message: 'Invalid identifier', errors: validation.error.flatten() }
  }

  // 🛡️ TACTICAL SILO: Delegate delete to Repository
  const result = await NotificationRepository.deleteNotification(notificationId)

  if (result.success) {
    revalidateTag('notifications')
  }
  
  return result
}
