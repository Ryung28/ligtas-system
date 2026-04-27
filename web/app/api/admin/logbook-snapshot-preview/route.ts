import { NextResponse } from 'next/server'
import { getLogbookSnapshotPreviewAction } from '@/app/actions/logbook-reset-actions'

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
    const body = await req.json()
    const snapshotId = typeof body?.snapshotId === 'string' ? body.snapshotId : ''
    const result = await getLogbookSnapshotPreviewAction({ snapshotId })

    if (!result.success) {
      return NextResponse.json(result, {
        status: statusFromErrorCode(result.errorCode),
      })
    }

    return NextResponse.json(result, { status: 200 })
  } catch {
    return NextResponse.json(
      { success: false, error: 'Invalid request payload.' },
      { status: 400 },
    )
  }
}
