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
import { addItem } from '@/src/features/catalog'

import { useStorageLocations } from '@/hooks/use-storage-locations'

const CATEGORIES = ['Rescue', 'Medical', 'Comms', 'Vehicles'] as const

export function AddItemDialog() {
    const [open, setOpen] = useState(false)
    const [isPending, startTransition] = useTransition()
    const { locations, isLoading: isLocationsLoading } = useStorageLocations()
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
                <Button className="gap-2 bg-blue-600 hover:bg-blue-700 rounded-xl shadow-lg hover:shadow-blue-200 transition-all">
                    <Plus className="h-4 w-4" />
                    Add New Item
                </Button>
            </DialogTrigger>
            <DialogContent className="sm:max-w-[500px] rounded-2xl border-zinc-200">
                <form onSubmit={handleSubmit}>
                    <DialogHeader>
                        <DialogTitle className="text-2xl font-black text-slate-900 uppercase tracking-tight">
                            Strategic Resource Entry
                        </DialogTitle>
                        <DialogDescription className="text-xs font-bold text-slate-400 uppercase tracking-widest">
                            Provision a new equipment asset in the logistics vault.
                        </DialogDescription>
                    </DialogHeader>

                    <div className="grid gap-6 py-6">
                        {/* Item Name */}
                        <div className="grid gap-2">
                            <Label htmlFor="name" className="text-[10px] font-black text-slate-500 uppercase tracking-widest">
                                Item Name <span className="text-rose-500">*</span>
                            </Label>
                            <Input
                                id="name"
                                name="name"
                                placeholder="E.g., Fire Extinguisher, First Aid Kit"
                                required
                                minLength={2}
                                disabled={isPending}
                                className="h-11 rounded-xl border-zinc-200 focus:ring-blue-500/20 text-sm font-semibold shadow-sm"
                            />
                        </div>

                        {/* DOUBLE ROW: Category & Location */}
                        <div className="grid grid-cols-2 gap-4">
                            {/* Category */}
                            <div className="grid gap-2">
                                <Label htmlFor="category" className="text-[10px] font-black text-slate-500 uppercase tracking-widest">
                                    Category <span className="text-rose-500">*</span>
                                </Label>
                                <Select name="category" required disabled={isPending}>
                                    <SelectTrigger className="h-11 rounded-xl border-zinc-200 shadow-sm font-semibold">
                                        <SelectValue placeholder="Select Category" />
                                    </SelectTrigger>
                                    <SelectContent className="rounded-xl border-zinc-100 shadow-2xl">
                                        {CATEGORIES.map((category) => (
                                            <SelectItem key={category} value={category} className="text-sm font-medium rounded-lg">
                                                {category}
                                            </SelectItem>
                                        ))}
                                    </SelectContent>
                                </Select>
                            </div>

                            {/* THE MASTER FIX: Storage Location Registry */}
                            <div className="grid gap-2">
                                <Label htmlFor="location_id" className="text-[10px] font-black text-slate-500 uppercase tracking-widest">
                                    Storage Site <span className="text-rose-500">*</span>
                                </Label>
                                <Select name="location_id" required disabled={isPending || isLocationsLoading}>
                                    <SelectTrigger className="h-11 rounded-xl border-zinc-200 shadow-sm font-bold text-blue-600 bg-blue-50/10">
                                        <SelectValue placeholder={isLocationsLoading ? "Loading Sites..." : "Select Site"} />
                                    </SelectTrigger>
                                    <SelectContent className="rounded-xl border-zinc-100 shadow-2xl">
                                        {locations.map((loc) => (
                                            <SelectItem key={loc.id} value={String(loc.id)} className="text-sm font-bold text-slate-700 rounded-lg">
                                                {loc.location_name}
                                            </SelectItem>
                                        ))}
                                    </SelectContent>
                                </Select>
                            </div>
                        </div>

                        {/* Stock Total */}
                        <div className="grid gap-2">
                            <Label htmlFor="stock_total" className="text-[10px] font-black text-slate-500 uppercase tracking-widest">
                                Initial Capacity <span className="text-rose-500">*</span>
                            </Label>
                            <Input
                                id="stock_total"
                                name="stock_total"
                                type="number"
                                placeholder="E.g., 50"
                                required
                                min={1}
                                disabled={isPending}
                                className="h-11 rounded-xl border-zinc-200 focus:ring-blue-500/20 text-sm font-bold tabular-nums shadow-sm"
                            />
                            <p className="text-[9px] font-bold text-slate-400 uppercase tracking-tighter">This quantity will be initialized as &quot;Ready for Deployment&quot;</p>
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
