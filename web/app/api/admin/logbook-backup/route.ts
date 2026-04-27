import { NextResponse } from 'next/server'
import { createLogbookBackupAction } from '@/app/actions/logbook-reset-actions'

function statusFromErrorCode(errorCode?: string): number {
  switch (errorCode) {
    case 'UNAUTHORIZED':
      return 401
    case 'FORBIDDEN':
      return 403
    case 'VALIDATION':
      return 400
    case 'PRECONDITION':
      return 409
    case 'CONFLICT':
      return 409
    default:
      return 500
  }
}

export async function POST(req: Request) {
  try {
    const body = await req.json()
    const confirmation =
      typeof body?.confirmation === 'string' ? body.confirmation : ''
    const reason = typeof body?.reason === 'string' ? body.reason : ''

    const result = await createLogbookBackupAction({ confirmation, reason })

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
