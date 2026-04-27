'use server'

import { supabase } from '@/lib/supabase'

/**
 * TRANSACTIONS DOMAIN - Query Actions
 * 
 * Read-only operations for fetching borrow/return transaction data.
 */

export interface PendingRequest {
    id: number
    borrower_name: string
    quantity: number
    created_at: string
}

export interface ActiveLoan {
    id: number
    borrower_name: string
    quantity: number
    status: 'borrowed' | 'overdue' | 'dispensed'
    expected_return_date: string | null
    created_at: string
    purpose?: string | null
}

export async function getPendingRequestsByItemId(itemId: number): Promise<{ success: boolean; data?: PendingRequest[]; error?: string }> {
    try {
        const { data, error } = await supabase
            .from('borrow_logs')
            .select('id, borrower_name, quantity, created_at')
            .eq('inventory_id', itemId)
            .eq('status', 'pending')
            .order('created_at', { ascending: true })

        if (error) {
            console.error('Supabase error fetching pending requests:', error)
            throw error
        }

        return {
            success: true,
            data: data || [],
        }
    } catch (error: any) {
        console.error('Error in getPendingRequestsByItemId:', error)
        return {
            success: false,
            error: error.message || 'Failed to fetch pending requests',
        }
    }
}
export async function getActiveLoansByIds(itemIds: number[]): Promise<{ success: boolean; data?: ActiveLoan[]; error?: string }> {
    try {
        if (!itemIds || itemIds.length === 0) return { success: true, data: [] }
        
        const { data, error } = await supabase
            .from('borrow_logs')
            .select('id, borrower_name, quantity, status, expected_return_date, created_at, purpose')
            .in('inventory_id', itemIds)
            .in('status', ['borrowed', 'overdue', 'dispensed'])
            .order('created_at', { ascending: false })

        if (error) {
            console.error('Supabase error fetching active loans:', error)
            throw error
        }

        return {
            success: true,
            data: data || [],
        }
    } catch (error: any) {
        console.error('Error in getActiveLoansByIds:', error)
        return {
            success: false,
            error: error.message || 'Failed to fetch active loans',
        }
    }
}

export interface BorrowerPersonnel {
    id: string
    name: string
    contact: string
    office: string
}

/**
 * Unified Personnel Registry Search
 * Combines Official User Profiles and Historical Borrowers from Logs
 */
export async function searchPersonnel(query: string): Promise<{ success: boolean; data?: BorrowerPersonnel[]; error?: string }> {
    try {
        const cleanQuery = query.trim().toLowerCase();
        
        // 1. Fetch Official Profiles
        let profileQuery = supabase
            .from('user_profiles')
            .select('id, full_name, phone_number, department')
            .eq('status', 'active');
            
        if (cleanQuery) {
            profileQuery = profileQuery.ilike('full_name', `%${cleanQuery}%`);
        }
        
        const { data: profiles, error: pError } = await profileQuery.limit(10);
        if (pError) throw pError;

        // 2. Fetch Historical Borrowers (Unique by name)
        let logQuery = supabase
            .from('borrow_logs')
            .select('borrower_name, borrower_contact, borrower_organization')
            .order('created_at', { ascending: false });

        if (cleanQuery) {
            logQuery = logQuery.ilike('borrower_name', `%${cleanQuery}%`);
        }

        const { data: logs, error: lError } = await logQuery.limit(50);
        if (lError) throw lError;

        // 3. Merge and De-duplicate
        const registry = new Map<string, BorrowerPersonnel>();

        // Official Profiles have priority
        profiles?.forEach(p => {
            const name = p.full_name || '';
            if (!name) return;
            registry.set(name.toLowerCase(), {
                id: p.id,
                name: name,
                contact: p.phone_number || '',
                office: p.department || ''
            });
        });

        // Merge Logs
        logs?.forEach(l => {
            const name = l.borrower_name || '';
            if (!name) return;
            const key = name.toLowerCase();
            if (!registry.has(key)) {
                registry.set(key, {
                    id: `hist-${name}`,
                    name: name,
                    contact: l.borrower_contact || '',
                    office: l.borrower_organization || ''
                });
            }
        });

        return {
            success: true,
            data: Array.from(registry.values()).slice(0, 15)
        };
    } catch (error: any) {
        console.error('Personnel search error:', error);
        return { success: false, error: 'Registry search failed' };
    }
}
