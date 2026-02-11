'use client'

import { useState, useTransition } from 'react'
import { CheckCircle2, AlertCircle, Loader2 } from 'lucide-react'
import { toast } from 'sonner'
import { Button } from '@/components/ui/button'
import {
    Dialog,
    DialogContent,
    DialogDescription,
    DialogFooter,
    DialogHeader,
    DialogTitle,
    DialogTrigger,
} from '@/components/ui/dialog'
import { returnItem } from '@/app/actions/inventory'

interface ReturnDialogProps {
    logId: number
    itemName: string
    borrowerName: string
    quantity: number
}

export function ReturnDialog({ logId, itemName, borrowerName, quantity }: ReturnDialogProps) {
    const [open, setOpen] = useState(false)
    const [isPending, startTransition] = useTransition()

    const handleReturn = () => {
        startTransition(async () => {
            const result = await returnItem(logId)
            if (result.success) {
                toast.success(result.message)
                setOpen(false)
            } else {
                toast.error(result.error)
            }
        })
    }

    return (
        <Dialog open={open} onOpenChange={setOpen}>
            <DialogTrigger asChild>
                <Button size="sm" variant="outline" className="h-8 gap-1 text-green-600 hover:text-green-700 hover:bg-green-50 border-green-200">
                    <CheckCircle2 className="h-3.5 w-3.5" />
                    Return
                </Button>
            </DialogTrigger>
            <DialogContent className="sm:max-w-[425px]">
                <DialogHeader>
                    <DialogTitle className="flex items-center gap-2 text-xl">
                        <CheckCircle2 className="h-6 w-6 text-green-600" />
                        Confirm Return
                    </DialogTitle>
                    <DialogDescription>
                        Mark this transaction as returned and restore stock to inventory?
                    </DialogDescription>
                </DialogHeader>

                <div className="bg-gray-50 p-4 rounded-lg space-y-3 text-sm border border-gray-100 my-2">
                    <div className="flex justify-between">
                        <span className="text-gray-500">Item:</span>
                        <span className="font-medium text-gray-900">{itemName}</span>
                    </div>
                    <div className="flex justify-between">
                        <span className="text-gray-500">Quantity:</span>
                        <span className="font-medium text-gray-900">{quantity}</span>
                    </div>
                    <div className="flex justify-between">
                        <span className="text-gray-500">Borrower:</span>
                        <span className="font-medium text-gray-900">{borrowerName}</span>
                    </div>
                </div>

                <div className="flex items-start gap-2 p-3 bg-blue-50 text-blue-700 rounded-md text-xs">
                    <AlertCircle className="h-4 w-4 mt-0.5 shrink-0" />
                    <p>Stock will be automatically restored. Ensure the item is in good condition.</p>
                </div>

                <DialogFooter className="gap-2 mt-4">
                    <Button variant="outline" onClick={() => setOpen(false)} disabled={isPending}>
                        Cancel
                    </Button>
                    <Button onClick={handleReturn} disabled={isPending} className="bg-green-600 hover:bg-green-700 text-white gap-2">
                        {isPending ? <Loader2 className="h-4 w-4 animate-spin" /> : <CheckCircle2 className="h-4 w-4" />}
                        Confirm Return
                    </Button>
                </DialogFooter>
            </DialogContent>
        </Dialog>
    )
}
