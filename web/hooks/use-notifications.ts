'use client'

import { useEffect, useState } from 'react'
import useSWR from 'swr'
// 🛰️ TACTICAL BROWSER CLIENT: Used exclusively for Realtime sync
import { createClient } from '@/lib/supabase-browser'
import { type NotificationItem } from '@/lib/validations/notifications'
// 🛰️ SERVER ACTIONS: Strict architectural boundary between client and server
import { 
    getInboxAction, 
    markAsReadAction, 
    markAllReadAction,
    deleteNotificationAction
} from '@/actions/notification-actions'
import { toast } from 'sonner'

/**
 * 🛰️ ENTERPRISE NOTIFICATION HOOK
 * Leverages the 'Sink' architecture for high-performance real-time sync.
 * Severed from direct repository imports to prevent boundary leaks.
 */
export function useNotifications() {
    const [limit, setLimit] = useState(20)
    
    // 🛡️ TACTICAL FETCHER: Uses Server Actions instead of Direct Repository calls
    const fetcher = async ([, limit]: [string, number]) => {
        const result = await getInboxAction(limit, Date.now()) // 🛡️ CACHE NUKE: Dynamic timestamp forces unique action signature
        
        console.log('[Hook] Action Response:', result)
        
        if (!result.success) {
            console.error('[Inbox Hook] Action Failed:', result.message, result.error)
            throw new Error(result.error || result.message || 'Intel sync failure.')
        }
        
        return result.data || []
    }

    const { data: notifications = [], mutate, isLoading, error } = useSWR(['notifications', limit], fetcher, {
        revalidateOnFocus: true,
        refreshInterval: 120000, // 2m safety net (we rely on Realtime)
        keepPreviousData: true, // 🛡️ ELIMINATES PAGINATION FLASH
    })

    useEffect(() => {
        // 🛡️ BROWSER-SIDE INTEL: Instantiate client only for Realtime stream
        const supabase = createClient()

        const channel = supabase
            .channel('system_notifications_sync')
            // 📡 STREAM A: Full-spectrum intel sync (Catches INSERT + DELETE from Restock purge)
            .on('postgres_changes', { 
                event: '*', // 🛡️ CRITICAL FIX: Watches all mutations, including backend DELETES
                schema: 'public', 
                table: 'system_notifications' 
            }, () => {
                console.log('[Sink] Intel table mutation detected. Resyncing.')
                mutate()
            })
            // 📡 STREAM B: Read-receipt synchronization (Junction table)
            .on('postgres_changes', {
                event: 'INSERT',
                schema: 'public',
                table: 'notification_reads'
            }, () => {
                console.log('[Sink] Junction sync: Intel marked as read.')
                mutate()
            })
            .subscribe()

        return () => {
            supabase.removeChannel(channel)
        }
    }, [mutate])

    const loadMore = () => setLimit(prev => prev + 20)

    /**
     * Marks a specific intel packet as read (Vercel Optimistic Pattern).
     * The card dims instantly on click before the server responds.
     */
    const markAsRead = async (notificationId: string) => {
        if (!notificationId) return;

        // 🛡️ THE VERCEL WAY: Instant in-place optimistic mutation — no waiting for network
        mutate(
            (currentData: any) => {
                if (!currentData) return currentData;
                return currentData.map((n: any) =>
                    n.id === notificationId ? { ...n, isRead: true } : n
                );
            },
            { revalidate: false } // Don't re-fetch yet — let the DB action confirm it
        );

        try {
            const result = await markAsReadAction(notificationId);
            if (!result.success) throw new Error(result.message);
            await mutate(); // 🔄 Background confirmation sync with DB
        } catch (error: any) {
            console.error('[Sync Failure]', error);
            toast.error('Mission control sync error: ' + error.message);
            await mutate(); // 🔙 Rollback UI to true DB state on failure
        }
    }

    /**
     * Bulk-marks all visible intel as read (Optimistic UI update).
     */
    const markAllRead = async () => {
        const optimisticData = notifications.map((n: NotificationItem) => ({ ...n, isRead: true }));
        mutate(optimisticData, false);

        try {
            const result = await markAllReadAction();
            if (!result.success) throw new Error(result.message);
            mutate(); // 🔄 Forced SWR re-fetch for database consistency
        } catch (error: any) {
            toast.error('Sync failed: ' + error.message);
            mutate(); // Revert on failure
        }
    }

    /**
     * Hard deletes a specific intel packet.
     */
    const deleteNotification = async (notificationId: string) => {
        if (!notificationId) return;

        // 🛡️ THE VERCEL WAY: Instant in-place optimistic removal
        mutate(
            (currentData: any) => {
                if (!currentData) return currentData;
                return currentData.filter((n: any) => n.id !== notificationId);
            },
            { revalidate: false }
        );

        try {
            const result = await deleteNotificationAction(notificationId);
            if (!result.success) throw new Error(result.message);
            await mutate(); // 🔄 Background confirmation
        } catch (error: any) {
            console.error('[Sync Deletion Failure]', error);
            toast.error('Mission control sync error: ' + error.message);
            await mutate(); // 🔙 Rollback
        }
    }

    return {
        notifications,
        unreadCount: notifications.filter((n: NotificationItem) => !n.isRead).length,
        markAsRead,
        markAllRead,
        deleteNotification,
        isLoading,
        error,
        refresh: mutate,
        limit,
        loadMore
    }
}
