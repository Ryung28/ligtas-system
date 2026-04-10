"use client"

import { useTransition } from 'react'
import { useRouter } from 'next/navigation'
import { toast } from 'sonner'
import { addItem, updateItem } from '@/src/features/catalog'

/**
 * LIGTAS V2 SUBMIT HOOK
 * Handles the "Boss" logic of committing data to Supabase via Server Actions.
 */
export function useInventorySubmitV2(onSuccess: () => void) {
    const [isPending, startTransition] = useTransition()
    const router = useRouter()

    const submit = async (formData: FormData, isEdit: boolean) => {
        startTransition(async () => {
            try {
                const action = isEdit ? updateItem : addItem
                const result = await action(formData)

                if (result.success) {
                    toast.success(result.message)
                    onSuccess()
                    router.refresh()
                } else {
                    toast.error(result.error || 'Check inventory permissions')
                }
            } catch (err) {
                console.error('LIGTAS_SUBMIT_FATAL:', err)
                toast.error('System failure during sync')
            }
        })
    }

    return { submit, isPending }
}
