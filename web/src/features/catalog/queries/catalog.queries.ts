import { supabase, getInventoryImageUrl } from '@/lib/supabase'

/**
 * CATALOG DOMAIN - Query Actions
 * 
 * Read-only operations for fetching inventory data.
 * These queries power the inventory dashboard and dropdowns.
 */

export async function getInventoryItems(options: { 
    category?: string, 
    status?: 'all' | 'pending',
    search?: string
} = {}) {
    try {
        let query = supabase
            .from('inventory_catalog')
            .select('*')

        // Apply Category Filter
        if (options.category && options.category !== 'All') {
            query = query.eq('category', options.category)
        }

        // Apply Status Filter (THE PENDING INBOX)
        if (options.status === 'pending') {
            // When in triage mode, only show items with active requests
            query = query.gt('stock_pending', 0)
        } else {
            // Default view usually shows items with actual stock, 
            // but for Admin Dashboard 'all' should show everything not archived.
        }

        // Apply Search
        if (options.search) {
            query = query.ilike('item_name', `%${options.search}%`)
        }

        const { data, error } = await query.order('item_name')

        if (error) throw error

        return {
            success: true,
            data: data || [],
        }
    } catch (error: any) {
        console.error('Error fetching inventory:', error)
        return {
            success: false,
            data: [],
            error: error.message || 'Failed to fetch inventory'
        }
    }
}

/**
 * Helper function to get available items for dropdown with pending awareness
 */
export async function getAvailableItems() {
    try {
        const { data, error } = await supabase
            .from('inventory')
            .select(`
                id,
                item_name,
                stock_available,
                stock_total,
                category,
                item_type,
                image_url,
                storage_location,
                parent_id,
                unit
            `)
            .is('deleted_at', null)
            .order('item_name', { ascending: true })

        if (error) throw error
        return { success: true, data: data || [] }
    } catch (error: any) {
        console.error('Catalog Sync Error:', error)
        return {
            success: false,
            data: [],
            error: error.message || 'Failed to sync catalog'
        }
    }
}

/**
 * Fetch distinct categories from database
 */
export async function getCategories() {
    try {
        const { data, error } = await supabase
            .from('inventory')
            .select('category')
            .order('category')

        if (error) throw error

        // Predefined categories to always show (Cold-Start Protection)
        const predefinedCategories = ['Medical', 'Tools', 'Rescue', 'PPE', 'Logistics', 'Goods', 'System', 'Equipment']
        
        // Get unique categories from database
        const dbCategoriesSet = new Set(data?.map(item => item.category).filter(Boolean) || [])
        const dbCategories = Array.from(dbCategoriesSet)
        
        // Merge and deduplicate
        const allCategoriesSet = new Set([...predefinedCategories, ...dbCategories])
        const allCategories = Array.from(allCategoriesSet)
        
        return {
            success: true,
            data: allCategories.sort(),
        }
    } catch (error) {
        console.error('Error fetching categories:', error)
        return {
            success: false,
            data: ['Medical', 'Tools', 'Rescue', 'PPE', 'Logistics', 'Goods'],
            error: 'Failed to fetch categories',
        }
    }
}
