'use client'

import { useState } from 'react'
import { Loader2 } from 'lucide-react'
import { Button } from '@/components/ui/button'
import { Input } from '@/components/ui/input'
import { TACTICAL_THEME } from '@/lib/theme-config'
import { toast } from 'sonner'
import { restockInventoryAction } from '@/app/actions/notifications'
import type { NotificationItem } from '@/lib/validations/notifications'

interface RestockFormProps {
    n: NotificationItem
    onSuccess: () => void
}

export function RestockForm({ n, onSuccess }: RestockFormProps) {
    const [quantity, setQuantity] = useState('10')
    const [isSubmitting, setIsSubmitting] = useState(false)

    const handleSubmit = async () => {
        // 🛡️ CLIENT-SIDE GUARD: Catches missing config before hitting the server
        if (!n.action?.payload?.itemId) {
            return toast.error('Missing ID configuration', {
                description: 'The inventory item ID is not configured for this alert.'
            })
        }

        const count = parseInt(quantity)
        if (isNaN(count) || count <= 0) {
            toast.error('INVALID QUANTITY', {
                description: 'Please enter a positive integer for restock.'
            })
            return
        }

        setIsSubmitting(true)
        try {
            // 🛡️ ARCHITECTURAL SHIFT: Delegates to Server Action (no direct Supabase RPC on client)
            const result = await restockInventoryAction(
                n.action.payload.itemId as string,
                count,
            )

            if (!result.success) {
                toast.error('OPERATION FAILED', { description: result.message })
                return
            }

            const itemName = n.message.split(' is running low')[0]
            toast.success('RESTOCK COMPLETE', {
                description: `Successfully added ${count} units to ${itemName}.`
            })

            onSuccess()
        } catch (err: unknown) {
            const message = err instanceof Error ? err.message : 'Could not contact server.'
            toast.error('OPERATION FAILED', { description: message })
        } finally {
            setIsSubmitting(false)
        }
    }

    return (
        <div className="space-y-6">
            <div className="space-y-2.5">
                <label className="text-xs font-semibold text-slate-500 tracking-tight">
                    Additional Quantity
                </label>
                <Input
                    type="number"
                    value={quantity}
                    onChange={(e) => setQuantity(e.target.value)}
                    className="bg-slate-50/50 border-slate-200/60 text-sm font-medium h-12 focus:ring-slate-900 rounded-xl transition-all"
                />
            </div>
            <Button
                onClick={handleSubmit}
                disabled={isSubmitting}
                className="w-full bg-slate-900 hover:bg-slate-800 text-white font-semibold text-sm h-12 rounded-xl shadow-lg shadow-slate-200/50 transition-all active:scale-[0.98]"
            >
                {isSubmitting ? <Loader2 className="h-4 w-4 animate-spin" /> : 'Confirm Restock'}
            </Button>
        </div>
    )
}
