import { NextResponse } from 'next/server'
import { getLogbookAdminStatusAction } from '@/app/actions/logbook-reset-actions'

export async function GET() {
  const result = await getLogbookAdminStatusAction()
  if (!result.success) {
    const message = (result.error || '').toLowerCase()
    const status =
      message.includes('unauthorized') ? 401 : message.includes('admin access') ? 403 : 500
    return NextResponse.json(result, { status })
  }
  return NextResponse.json(result, { status: 200 })
}
