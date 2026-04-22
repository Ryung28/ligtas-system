'use client'

import { useState, useTransition, useEffect } from 'react'
import { CheckCircle2, AlertCircle, Loader2, User } from 'lucide-react'
import { toast } from 'sonner'
import { Button } from '@/components/ui/button'
import { Input } from '@/components/ui/input'
import { Label } from '@/components/ui/label'
import { Textarea } from '@/components/ui/textarea'
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from '@/components/ui/select'
import {
    Dialog,
    DialogContent,
    DialogDescription,
    DialogFooter,
    DialogHeader,
    DialogTitle,
    DialogTrigger,
} from '@/components/ui/dialog'
import { returnItem } from '@/src/features/transactions'
import { createBrowserClient } from '@supabase/ssr'

interface ReturnDialogProps {
    logId: number
    itemName: string
    borrowerName: string
    quantity: number
}

export function ReturnDialog({ logId, itemName, borrowerName, quantity }: ReturnDialogProps) {
    const [open, setOpen] = useState(false)
    const [isPending, startTransition] = useTransition()
    const [receivedByName, setReceivedByName] = useState('')
    const [returnCondition, setReturnCondition] = useState<'good' | 'fair' | 'damaged'>('good')
    const [returnNotes, setReturnNotes] = useState('')

    // Auto-fill received by name from logged-in user
    useEffect(() => {
        async function loadUserName() {
            const supabase = createBrowserClient(
                process.env.NEXT_PUBLIC_SUPABASE_URL!,
                process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY!
            )
            const { data: { user } } = await supabase.auth.getUser()
            if (user) {
                const { data: profile } = await supabase
                    .from('users')
                    .select('full_name')
                    .eq('id', user.id)
                    .single()
                
                if (profile?.full_name) {
                    setReceivedByName(profile.full_name)
                }
            }
        }
        if (open) {
            loadUserName()
        }
    }, [open])

    const handleReturn = () => {
        // Validate required fields
        if (!receivedByName.trim()) {
            toast.error('Please enter the name of the staff member receiving the item')
            return
        }

        startTransition(async () => {
            const result = await returnItem(logId, {
                receivedByName: receivedByName.trim(),
                returnCondition,
                returnNotes: returnNotes.trim() || null
            })
            if (result.success) {
                toast.success(result.message)
                setOpen(false)
                // Reset form
                setReceivedByName('')
                setReturnCondition('good')
                setReturnNotes('')
            } else {
                toast.error(result.error)
            }
        })
    }

    return (
        <Dialog open={open} onOpenChange={setOpen}>
            <DialogTrigger asChild>
                <Button size="sm" variant="outline" className="h-8 gap-1 text-blue-600 hover:text-blue-700 hover:bg-blue-50 border-blue-200">
                    <CheckCircle2 className="h-3.5 w-3.5" />
                    Return
                </Button>
            </DialogTrigger>
            <DialogContent className="sm:max-w-[600px] max-h-[90vh] overflow-y-auto">
                <DialogHeader>
                    <DialogTitle className="flex items-center gap-2 text-xl">
                        <CheckCircle2 className="h-6 w-6 text-blue-600" />
                        Confirm Return
                    </DialogTitle>
                    <DialogDescription>
                        Mark this transaction as returned and restore stock to inventory?
                    </DialogDescription>
                </DialogHeader>

                <div className="grid grid-cols-2 gap-4">
                    {/* Left Column - Transaction Info */}
                    <div className="space-y-4">
                        <div className="bg-gray-50 p-3 rounded-lg space-y-2 text-sm border border-gray-100">
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
                            <p>Stock will be automatically restored.</p>
                        </div>
                    </div>

                    {/* Right Column - Audit Fields */}
                    <div className="space-y-3">
                        <div className="space-y-2">
                            <Label htmlFor="received-by" className="text-xs font-bold text-gray-700 uppercase tracking-wide flex items-center gap-1">
                                <User className="h-3 w-3" />
                                Received by *
                            </Label>
                            <Input
                                id="received-by"
                                value={receivedByName}
                                onChange={(e) => setReceivedByName(e.target.value)}
                                placeholder="Staff name"
                                className="h-9 text-sm"
                                required
                            />
                        </div>

                        <div className="space-y-2">
                            <Label className="text-xs font-bold text-gray-700 uppercase tracking-wide">
                                Condition *
                            </Label>
                            <Select value={returnCondition} onValueChange={(value: any) => setReturnCondition(value)}>
                                <SelectTrigger className="h-9 text-sm">
                                    <SelectValue />
                                </SelectTrigger>
                                <SelectContent>
                                    <SelectItem value="good">
                                        <div className="flex items-center gap-2">
                                            <div className="h-2 w-2 rounded-full bg-green-500" />
                                            <span>Good</span>
                                        </div>
                                    </SelectItem>
                                    <SelectItem value="fair">
                                        <div className="flex items-center gap-2">
                                            <div className="h-2 w-2 rounded-full bg-yellow-500" />
                                            <span>Fair</span>
                                        </div>
                                    </SelectItem>
                                    <SelectItem value="damaged">
                                        <div className="flex items-center gap-2">
                                            <div className="h-2 w-2 rounded-full bg-red-500" />
                                            <span>Damaged</span>
                                        </div>
                                    </SelectItem>
                                </SelectContent>
                            </Select>
                        </div>

                        <div className="space-y-2">
                            <Label htmlFor="return-notes" className="text-xs font-bold text-gray-700 uppercase tracking-wide">
                                Notes
                            </Label>
                            <Textarea
                                id="return-notes"
                                value={returnNotes}
                                onChange={(e) => setReturnNotes(e.target.value)}
                                placeholder="Damage or observations..."
                                className="min-h-[70px] resize-none text-sm"
                            />
                        </div>
                    </div>
                </div>

                <DialogFooter className="gap-2 mt-4">
                    <Button variant="outline" onClick={() => setOpen(false)} disabled={isPending}>
                        Cancel
                    </Button>
                    <Button onClick={handleReturn} disabled={isPending} className="bg-blue-600 hover:bg-blue-700 text-white gap-2">
                        {isPending ? <Loader2 className="h-4 w-4 animate-spin" /> : <CheckCircle2 className="h-4 w-4" />}
                        Confirm Return
                    </Button>
                </DialogFooter>
            </DialogContent>
        </Dialog>
    )
}
