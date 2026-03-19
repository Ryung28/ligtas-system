// ─── Types & Models ───────────────────────────────────────────────────────────
export type Category = "ALL" | "LOGS" | "AUTH" | "ALERTS"

export interface NotificationItem {
  id: string
  type: string
  title: string
  message?: string
  description?: string
  time: string | Date
  isRead: boolean
  metadata?: Record<string, any>
  action?: {
    label: string
    type: 'link' | 'rpc' | 'dialog'
    target: string
    payload?: Record<string, any>
  } | null
}

export interface NotificationCardProps {
  notif: NotificationItem
  index: number
  onMarkRead: (id: string) => void
  onDelete?: (id: string) => void
}

export interface TypeConfig {
  icon: React.ReactNode
  label: string
  accent: string
  bg: string
  border: string
}
