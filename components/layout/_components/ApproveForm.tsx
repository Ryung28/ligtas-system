'use client'

import { useState } from 'react'
import { Loader2 } from 'lucide-react'
import { Button } from '@/components/ui/button'
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from '@/components/ui/select'
import { toast } from 'sonner'
import { approveUserAction } from '@/app/actions/notifications'
import type { NotificationItem } from '@/lib/validations/notifications'

interface ApproveFormProps {
    n: NotificationItem
    onSuccess: () => void
}

type RoleType = 'admin' | 'editor' | 'viewer'

export function ApproveForm({ n, onSuccess }: ApproveFormProps) {
    const [role, setRole] = useState<RoleType>('viewer')
    const [isSubmitting, setIsSubmitting] = useState(false)

    const handleSubmit = async () => {
        if (!n.action?.payload?.userId) {
            return toast.error('Missing ID configuration', {
                description: 'The user ID is not configured for this alert.'
            })
        }

        setIsSubmitting(true)
        try {
            const result = await approveUserAction(
                n.action.payload.userId as string,
                role,
            )

            if (!result.success) {
                toast.error('Approval Failed', { description: result.message })
                return
            }

            const userName = n.message.split(' is requesting')[0]
            toast.success('Approval Complete', {
                description: `${userName} has been granted ${role} access.`
            })

            onSuccess()
        } catch (err: unknown) {
            const message = err instanceof Error ? err.message : 'Could not contact server.'
            toast.error('Approval Failed', { description: message })
        } finally {
            setIsSubmitting(false)
        }
    }

    return (
        <div className="space-y-6">
            <div className="space-y-2.5">
                <label className="text-xs font-semibold text-slate-500 tracking-tight">
                    Assign Tactical Role
                </label>
                <Select value={role} onValueChange={(v) => setRole(v as RoleType)}>
                    <SelectTrigger className="bg-slate-50/50 border-slate-200/60 text-sm font-medium h-12 rounded-xl focus:ring-slate-900 transition-all">
                        <SelectValue placeholder="Select Role" />
                    </SelectTrigger>
                    <SelectContent className="rounded-xl border-slate-200 shadow-xl">
                        <SelectItem value="admin">Admin</SelectItem>
                        <SelectItem value="editor">Editor</SelectItem>
                        <SelectItem value="viewer">Viewer</SelectItem>
                    </SelectContent>
                </Select>
            </div>
            <Button
                onClick={handleSubmit}
                disabled={isSubmitting}
                className="w-full bg-slate-900 hover:bg-slate-800 text-white font-semibold text-sm h-12 rounded-xl shadow-lg shadow-slate-200/50 transition-all active:scale-[0.98]"
            >
                {isSubmitting ? <Loader2 className="h-4 w-4 animate-spin" /> : 'Complete Approval'}
            </Button>
        </div>
    )
}
