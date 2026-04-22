import { z } from 'zod'
import { createSupabaseServer } from '@/lib/supabase-server'
import { TrendingItemSchema, type TrendingItem } from '@/lib/validations/analytics'

/**
 * 📊 ANALYTICS REPOSITORY: LOGISTICAL INTEL HUB
 * Ensures isolation-aware trending insights for equipment managers.
 * EXCLUSIVITY: Server-Side Execution Only.
 */
export class AnalyticsRepository {
  /**
   * Fetches trending equipment most borrowed in the trailing 30 days.
   * COMPLIANCE: Silo Integrity / Multi-Tenant Isolation.
   */
  static async getTrendingItems(limit: number = 5): Promise<{ 
    success: boolean; 
    data: TrendingItem[]; 
    message?: string 
  }> {
    const supabase = await createSupabaseServer()
    
    // 🛡️ ID ENFORCEMENT: Identify operator session
    const { data: { user } } = await supabase.auth.getUser()
    if (!user) return { success: false, data: [], message: 'Unauthorized session.' }

    // 🛡️ SILO CHECK: Fetch warehouse assignment
    const { data: profile } = await supabase
      .from('user_profiles')
      .select('assigned_warehouse')
      .eq('id', user.id)
      .single()

    const warehouseId = profile?.assigned_warehouse

    // 🛡️ TACTICAL VIEW ACCESS
    // Admins (warehouseId === NULL) see full fleet trends.
    // Managers only see items from their assigned sector/warehouse.
    const query = supabase
      .from('trending_inventory_view')
      .select('*')

    if (warehouseId) {
      query.eq('warehouse_id', warehouseId)
    }

    const { data, error } = await query
      .order('borrow_count', { ascending: false })
      .limit(limit)

    if (error) {
      console.error('[AnalyticsRepository] Cache Read Failure:', error)
      return { success: false, data: [], message: 'Database latency detected.' }
    }

    // 🛡️ DOMAIN MAPPING: Transform Sink payload (snake_case) to UI Entity (camelCase)
    const entities = (data || []).map((item: any) => ({
      inventoryId: item.inventory_id,
      itemName: item.item_name,
      category: item.category,
      warehouseId: item.warehouse_id,
      borrowCount: Number(item.borrow_count),
      lastBorrowedAt: item.last_borrowed_at
    }))

    // 🛡️ SCHEMA ENFORCEMENT: Zero Null Pointer Exception strategy
    const validation = z.array(TrendingItemSchema).safeParse(entities)
    
    if (!validation.success) {
       console.error('[AnalyticsRepository] Validation Failure:', validation.error)
       return { success: false, data: [], message: 'Metadata corruption.' }
    }

    return { success: true, data: validation.data }
  }
}
