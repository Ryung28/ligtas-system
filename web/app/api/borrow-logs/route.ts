import { NextResponse } from 'next/server'
import { createSupabaseServer } from '@/lib/supabase-server'
import { getInventoryImageUrl } from '@/lib/supabase'
import type { BorrowLog } from '@/lib/types/inventory'

const DEFAULT_LIMIT = 100
const MAX_LIMIT = 200

function parseLimit(raw: string | null): number {
  const parsed = Number(raw)
  if (!Number.isFinite(parsed) || parsed <= 0) {
    return DEFAULT_LIMIT
  }
  return Math.min(Math.floor(parsed), MAX_LIMIT)
}

export async function GET(req: Request) {
  try {
    const supabase = await createSupabaseServer()
    const {
      data: { user },
      error: userError,
    } = await supabase.auth.getUser()

    if (userError || !user) {
      return NextResponse.json(
        { success: false, error: 'Unauthorized.' },
        { status: 401 },
      )
    }

    const url = new URL(req.url)
    const limit = parseLimit(url.searchParams.get('limit'))

    const { data, error } = await supabase
      .from('borrow_logs')
      .select(
        `
          id,
          inventory_id,
          item_name,
          borrower_name,
          borrower_email,
          borrower_organization,
          borrower_contact,
          borrower_user_id,
          quantity,
          status,
          borrow_date,
          expected_return_date,
          actual_return_date,
          return_condition,
          return_notes,
          received_by_name,
          returned_by_name,
          approved_by_name,
          released_by_name,
          platform_origin,
          created_origin,
          pickup_scheduled_at,
          return_scheduled_at,
          purpose,
          created_at,
          updated_at,
          inventory:inventory_id (
            item_name,
            image_url,
            item_type
          )
        `,
      )
      .order('created_at', { ascending: false })
      .limit(limit)

    if (error) {
      return NextResponse.json(
        { success: false, error: error.message || 'Failed to fetch logs.' },
        { status: 500 },
      )
    }

    const logs = ((data || []) as any[]).map((log) => ({
      ...log,
      item_name:
        log.item_name && log.item_name !== 'Unknown Item'
          ? log.item_name
          : log.inventory?.item_name || log.item_name || 'Unknown Item',
      image_url: getInventoryImageUrl(log.inventory?.image_url || null),
    })) as BorrowLog[]

    return NextResponse.json({ success: true, data: logs }, { status: 200 })
  } catch {
    return NextResponse.json(
      { success: false, error: 'Internal Server Error' },
      { status: 500 },
    )
  }
}
