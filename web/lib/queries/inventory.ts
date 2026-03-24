import { createSupabaseServer } from '@/lib/supabase-server'
import { InventoryItem } from '@/lib/supabase'

/**
 * Server-side inventory fetcher
 * Fetches inventory with active borrow data
 */
export async function getInitialInventory() {
    try {
        const supabase = await createSupabaseServer()

        // Fetch inventory
        const { data: items, error: invError } = await supabase
            .from('inventory')
            .select('*')
            .is('deleted_at', null)
            .order('item_name', { ascending: true })

        if (invError) throw invError

        // Fetch active borrows
        const { data: logs } = await supabase
            .from('borrow_logs')
            .select('*')
            .eq('status', 'borrowed')

        // Generate signed URLs and attach active borrows
        const itemsWithData = await Promise.all((items || []).map(async (item) => {
            let imageUrl = item.image_url

            // Generate signed URL if image exists
            if (imageUrl) {
                try {
                    let path = imageUrl
                    if (path.includes('/storage/v1/object/')) {
                        const parts = path.split('item-images/')
                        if (parts.length > 1) {
                            path = parts[1].split('?')[0]
                        }
                    }

                    if (!path.startsWith('http')) {
                        const { data, error: storageError } = await supabase.storage
                            .from('item-images')
                            .createSignedUrl(path, 60 * 60 * 24) // 24 hours

                        if (!storageError && data?.signedUrl) {
                            imageUrl = data.signedUrl
                        }
                    }
                } catch (err) {
                    // Keep original URL on error
                }
            }

            // Attach active borrows
            const activeBorrows = (logs || [])
                .filter(l => l.inventory_id === item.id)
                .map(b => ({
                    name: b.borrower_name,
                    quantity: b.quantity,
                    org: b.borrower_organization
                }))

            return {
                ...item,
                image_url: imageUrl,
                active_borrows: activeBorrows
            }
        }))

        return itemsWithData as InventoryItem[]
    } catch (error) {
        console.error('Failed to fetch inventory:', error)
        return []
    }
}
