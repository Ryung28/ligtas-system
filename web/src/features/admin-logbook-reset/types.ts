export type LogbookResetStatus = 'started' | 'completed' | 'failed'

export interface LogbookResetResult {
  success: boolean
  jobId?: string
  snapshotId?: string
  error?: string
  errorCode?:
    | 'UNAUTHORIZED'
    | 'FORBIDDEN'
    | 'VALIDATION'
    | 'PRECONDITION'
    | 'CONFLICT'
    | 'INTERNAL'
}
