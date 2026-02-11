'use client'

import { useState, useTransition } from 'react'
import { useRouter } from 'next/navigation'
import { Plus, Loader2 } from 'lucide-react'
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
import { Input } from '@/components/ui/input'
import { Label } from '@/components/ui/label'
import {
    Select,
    SelectContent,
    SelectItem,
    SelectTrigger,
    SelectValue,
} from '@/components/ui/select'
import { addItem } from '@/app/actions/inventory'

const CATEGORIES = ['Rescue', 'Medical', 'Comms', 'Vehicles'] as const

export function AddItemDialog() {
    const [open, setOpen] = useState(false)
    const [isPending, startTransition] = useTransition()
    const router = useRouter()

    const handleSubmit = async (event: React.FormEvent<HTMLFormElement>) => {
        event.preventDefault()

        const formData = new FormData(event.currentTarget)

        startTransition(async () => {
            const result = await addItem(formData)

            if (result.success) {
                toast.success(result.message || 'Item added successfully!')
                setOpen(false)
                router.refresh()
                    // Reset form
                    ; (event.target as HTMLFormElement).reset()
            } else {
                toast.error(result.error || 'Failed to add item')
            }
        })
    }

    return (
        <Dialog open={open} onOpenChange={setOpen}>
            <DialogTrigger asChild>
                <Button className="gap-2 bg-blue-600 hover:bg-blue-700 rounded-xl">
                    <Plus className="h-4 w-4" />
                    Add New Item
                </Button>
            </DialogTrigger>
            <DialogContent className="sm:max-w-[500px]">
                <form onSubmit={handleSubmit}>
                    <DialogHeader>
                        <DialogTitle className="text-2xl font-bold text-gray-900">
                            Add New Inventory Item
                        </DialogTitle>
                        <DialogDescription className="text-gray-600">
                            Fill in the details to add a new item to the inventory system.
                        </DialogDescription>
                    </DialogHeader>

                    <div className="grid gap-4 py-4">
                        {/* Item Name */}
                        <div className="grid gap-2">
                            <Label htmlFor="name" className="text-sm font-semibold text-gray-700">
                                Item Name <span className="text-red-500">*</span>
                            </Label>
                            <Input
                                id="name"
                                name="name"
                                placeholder="E.g., Fire Extinguisher, First Aid Kit"
                                required
                                minLength={2}
                                disabled={isPending}
                                className="rounded-lg border-gray-300 focus:border-blue-500 focus:ring-blue-500"
                            />
                        </div>

                        {/* Category */}
                        <div className="grid gap-2">
                            <Label htmlFor="category" className="text-sm font-semibold text-gray-700">
                                Category <span className="text-red-500">*</span>
                            </Label>
                            <Select name="category" required disabled={isPending}>
                                <SelectTrigger className="rounded-lg border-gray-300">
                                    <SelectValue placeholder="Select a category" />
                                </SelectTrigger>
                                <SelectContent>
                                    {CATEGORIES.map((category) => (
                                        <SelectItem key={category} value={category}>
                                            {category}
                                        </SelectItem>
                                    ))}
                                </SelectContent>
                            </Select>
                        </div>

                        {/* Stock Total */}
                        <div className="grid gap-2">
                            <Label htmlFor="stock_total" className="text-sm font-semibold text-gray-700">
                                Initial Stock Quantity <span className="text-red-500">*</span>
                            </Label>
                            <Input
                                id="stock_total"
                                name="stock_total"
                                type="number"
                                placeholder="E.g., 50"
                                required
                                min={1}
                                disabled={isPending}
                                className="rounded-lg border-gray-300 focus:border-blue-500 focus:ring-blue-500"
                            />
                            <p className="text-xs text-gray-500">This will be set as both total and available stock</p>
                        </div>
                    </div>

                    <DialogFooter className="gap-2">
                        <Button
                            type="button"
                            variant="outline"
                            onClick={() => setOpen(false)}
                            disabled={isPending}
                            className="rounded-lg"
                        >
                            Cancel
                        </Button>
                        <Button
                            type="submit"
                            disabled={isPending}
                            className="gap-2 bg-blue-600 hover:bg-blue-700 rounded-lg min-w-[120px]"
                        >
                            {isPending ? (
                                <>
                                    <Loader2 className="h-4 w-4 animate-spin" />
                                    Adding...
                                </>
                            ) : (
                                <>
                                    <Plus className="h-4 w-4" />
                                    Add Item
                                </>
                            )}
                        </Button>
                    </DialogFooter>
                </form>
            </DialogContent>
        </Dialog>
    )
}
