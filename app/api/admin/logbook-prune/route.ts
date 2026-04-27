import { NextResponse } from 'next/server'
import { createLogbookPruneAction } from '@/app/actions/logbook-reset-actions'

function statusFromErrorCode(errorCode?: string): number {
  switch (errorCode) {
    case 'UNAUTHORIZED':
      return 401
    case 'FORBIDDEN':
      return 403
    case 'VALIDATION':
      return 400
    default:
      return 500
  }
}

export async function POST(req: Request) {
  try {
    const body = await req.json().catch(() => ({}))
    const keepLatest =
      typeof body?.keepLatest === 'number' ? body.keepLatest : undefined
    const keepDays = typeof body?.keepDays === 'number' ? body.keepDays : undefined

    const result = await createLogbookPruneAction({ keepLatest, keepDays })
    if (!result.success) {
      return NextResponse.json(result, { status: statusFromErrorCode(result.errorCode) })
    }

    return NextResponse.json(result, { status: 200 })
  } catch {
    return NextResponse.json(
      { success: false, error: 'Invalid request payload.' },
      { status: 400 },
    )
  }
}
