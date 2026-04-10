import { z } from 'zod'
import { createSupabaseServer } from '@/lib/supabase-server'
import { NotificationItemSchema, type NotificationItem } from '@/lib/validations/notifications'

/**
 * 🛰️ NOTIFICATION REPOSITORY: TACTICAL INTEL SINK
 * Enacts strict separation between Data Sink and Presentation Layer.
 * EXCLUSIVITY: Server-Side Execution Only. Never import in Client Components.
 */
export class NotificationRepository {
  /**
   * Fetches the polymorphic inbox for the current session user.
   */
  static async getInbox(limit: number = 20): Promise<{ success: boolean; data: NotificationItem[]; message?: string; error?: any }> {
    const supabase = await createSupabaseServer()
    
    // 🛡️ TACTICAL JOIN: Using RPC to fetch computed read states
    const { data, error } = await supabase.rpc('get_user_inbox', { p_limit: limit })

    if (error) {
      console.error('[NotificationRepository] RPC Error:', error)
      return { success: false, data: [], message: error.message }
    }

    // 🛡️ DOMAIN MAPPING: Transform Sink payload to UI Entity
    const entities = (data || []).map((n: any) => this.mapToEntity(n))
    
    const validation = z.array(NotificationItemSchema).safeParse(entities)
    if (!validation.success) {
      const flattenedError = validation.error.flatten()
      console.error('[NotificationRepository] Validation Failure:', JSON.stringify(flattenedError, null, 2))
      return { 
          success: false, 
          data: [], 
          message: 'Data integrity breach.',
          error: flattenedError
      }
    }

    return { success: true, data: validation.data }
  }

  /**
   * Records a read-receipt in the Isolated Sink state.
   */
  static async markAsRead(notificationId: string): Promise<{ success: boolean; message: string }> {
    const supabase = await createSupabaseServer()
    const { data: { user } } = await supabase.auth.getUser()

    if (!user) return { success: false, message: 'Unauthorized' }

    // 🛡️ TACTICAL INSERT: We only need to record that the user SAW it.
    // Insert into notification_reads. PRIMARY KEY (notification_id, user_id) ensures idempotency.
    const { error } = await supabase
      .from('notification_reads')
      .upsert({ 
          notification_id: notificationId, 
          user_id: user.id 
      })

    if (error) {
      console.error('[NotificationRepository] MarkRead Error:', error)
      return { success: false, message: error.message }
    }

    return { success: true, message: 'Intel synchronized.' }
  }

  /**
   * Bulk-marks all visible notifications as read for the operator.
   */
  static async markAllRead(): Promise<{ success: boolean; message: string }> {
    const supabase = await createSupabaseServer()
    const { data: { user } } = await supabase.auth.getUser()

    if (!user) return { success: false, message: 'Unauthorized' }

    // 1. Fetch unread IDs from the inbox view
    const { data: inbox, error: fetchError } = await supabase
      .rpc('get_user_inbox', { p_limit: 1000 })
    
    if (fetchError) return { success: false, message: fetchError.message }

    const unreadIds = (inbox || [])
      .filter((n: any) => !n.is_read)
      .map((n: any) => ({ notification_id: n.id, user_id: user.id }))

    if (unreadIds.length === 0) return { success: true, message: 'Inbox is already operational.' }

    // 2. Perform bulk junction update
    const { error } = await supabase
      .from('notification_reads')
      .upsert(unreadIds)

    if (error) return { success: false, message: error.message }

    return { success: true, message: 'Full inbox sync complete.' }
  }

  /**
   * Hard deletes a notification from the Sink.
   */
  static async deleteNotification(notificationId: string): Promise<{ success: boolean; message: string }> {
    const supabase = await createSupabaseServer()
    
    // 🛡️ TACTICAL DELETE: Hard deletion from system_notifications to prevent bloat.
    const { error } = await supabase
      .from('system_notifications')
      .delete()
      .eq('id', notificationId)

    if (error) {
      console.error('[NotificationRepository] Delete Error:', error)
      return { success: false, message: error.message }
    }

    return { success: true, message: 'Intel erased.' }
  }

  /**
   * Manual mapping for dynamic Action UI elements.
   */
  private static mapToEntity(n: any): any {
    let action
    
    switch (n.type) {
      case 'stock_low':
      case 'stock_out':
        action = { label: 'RESTOCK', type: 'dialog' as const, target: 'restock_modal', payload: { itemId: n.reference_id } }
        break
      case 'user_pending':
        action = { label: 'REVIEW ACCESS', type: 'link' as const, target: '/dashboard/users?tab=requests' }
        break
      case 'chat_message':
        action = { label: 'OPEN CHAT', type: 'link' as const, target: `/chat/${n.reference_id}` }
        break
      case 'borrow_request':
        action = { label: 'MANAGE LOG', type: 'link' as const, target: '/dashboard/logs' }
        break
      case 'system_alert':
        action = { label: 'VIEW INTEL', type: 'link' as const, target: '/dashboard' }
        break
      default:
        action = undefined
    }

    return {
      // 🛡️ RECOVERY GATE: Ensure ID is never undefined to prevent key-mapping collisions in UI
      id: String(n.id || `err-packet-${Math.random().toString(36).substr(2, 9)}`),
      userId: n.user_id || null,             // 🛡️ CRITICAL: camelCase for DTO consistency
      referenceId: n.reference_id || null,   // 🛡️ CRITICAL: camelCase for DTO consistency
      title: n.title || 'System Alert',
      message: n.message || 'Mission status information update.',
      time: n.created_at || new Date().toISOString(),
      type: n.type || 'system_alert',
      isRead: !!n.is_read, // 🛡️ COERCION GATE: Map DB NULL or FALSE to strictly FALSE
      metadata: n.metadata || {}, // 🛡️ PAYLOAD RECOVERY: Inject contextual data for UI routing
      action
    }
  }
}
