'use client'

import { useState, useTransition, useEffect, useRef, useMemo } from 'react'
import { useRouter } from 'next/navigation'
import { Loader2, Package, Save, Plus, Edit, Image as ImageIcon, X, UploadCloud, Cpu } from 'lucide-react'
import { toast } from 'sonner'
import { createBrowserClient } from '@supabase/ssr'

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
import { Badge } from '@/components/ui/badge'
import { addItem, updateItem, getCategories } from '@/app/actions/inventory'
import { InventoryItem } from '@/lib/supabase'
import { optimizeImage } from '@/lib/image-optimizer'

interface InventoryItemDialogProps {
    existingItem?: InventoryItem
    trigger?: React.ReactNode
    open?: boolean
    onOpenChange?: (open: boolean) => void
    onSuccess?: () => void
}

export function InventoryItemDialog({ existingItem, trigger, open: controlledOpen, onOpenChange, onSuccess }: InventoryItemDialogProps) {
    const [internalOpen, setInternalOpen] = useState(false)
    const [isPending, startTransition] = useTransition()
    const [isUploading, setIsUploading] = useState(false)
    const [previewUrl, setPreviewUrl] = useState<string | null>(existingItem?.image_url || null)
    const [storedPath, setStoredPath] = useState<string | null>(existingItem?.image_url || null)
    const [categories, setCategories] = useState<string[]>([])
    const [isLoadingCategories, setIsLoadingCategories] = useState(true)
    const fileInputRef = useRef<HTMLInputElement>(null)
    const router = useRouter()

    // MEMOIZED CLIENT: Senior Dev tip - don't recreate clients on every re-render
    const supabase = useMemo(() => createBrowserClient(
        process.env.NEXT_PUBLIC_SUPABASE_URL!,
        process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY!
    ), [])

    const isEditMode = !!existingItem
    const isOpen = controlledOpen !== undefined ? controlledOpen : internalOpen
    const setOpen = onOpenChange || setInternalOpen

    // Fetch categories when dialog opens
    useEffect(() => {
        async function loadCategories() {
            if (!isOpen) return
            setIsLoadingCategories(true)
            const result = await getCategories()
            setCategories(result.data)
            setIsLoadingCategories(false)
        }
        loadCategories()
    }, [isOpen])

    // MEMORY MANAGEMENT: Cleanup object URLs to prevent leaks
    useEffect(() => {
        return () => {
            if (previewUrl?.startsWith('blob:')) {
                URL.revokeObjectURL(previewUrl)
            }
        }
    }, [previewUrl])

    const handleImageChange = async (e: React.ChangeEvent<HTMLInputElement>) => {
        const rawFile = e.target.files?.[0]
        if (!rawFile) return

        try {
            setIsUploading(true)

            // SENIOR DEV OPTIMIZATION: Compress before upload
            // This turns a 5MB phone photo into a ~150KB high-performance WebP
            const optimizedFile = await optimizeImage(rawFile)

            // Set local preview for instant feedback
            const objectUrl = URL.createObjectURL(optimizedFile)
            setPreviewUrl(objectUrl)

            const fileName = `${Math.random().toString(36).substring(2)}-${Date.now()}.webp`
            const filePath = `items/${fileName}`

            const { error } = await supabase.storage
                .from('item-images')
                .upload(filePath, optimizedFile)

            if (error) throw error

            // Generate a signed URL that works for both public and private buckets
            const { data, error: urlError } = await supabase.storage
                .from('item-images')
                .createSignedUrl(filePath, 60 * 60 * 24) // 24 hours expiry

            if (urlError || !data) throw urlError || new Error('Failed to generate signed URL')

            setPreviewUrl(data.signedUrl)
            setStoredPath(filePath)
            toast.success('Asset visual optimized & encoded')
        } catch (error: any) {
            console.error('Upload Error:', error)
            toast.error(`Sync Failed: ${error.message || 'Check RLS/Network'}`)
            setPreviewUrl(existingItem?.image_url || null)
        } finally {
            setIsUploading(false)
        }
    }

    const removeImage = () => {
        setPreviewUrl(null)
        if (fileInputRef.current) fileInputRef.current.value = ''
    }

    const handleSubmit = async (event: React.FormEvent<HTMLFormElement>) => {
        event.preventDefault()
        const formData = new FormData(event.currentTarget)

        if (isEditMode && existingItem) {
            formData.append('id', existingItem.id.toString())
        }

        if (storedPath) {
            formData.append('image_url', storedPath)
        }

        startTransition(async () => {
            const action = isEditMode ? updateItem : addItem
            const result = await action(formData)

            if (result.success) {
                toast.success(result.message)
                setOpen(false)
                if (onSuccess) onSuccess()
                router.refresh()
            } else {
                toast.error(result.error || 'Operation failed')
            }
        })
    }

    useEffect(() => {
        if (isOpen) setPreviewUrl(existingItem?.image_url || null)
    }, [isOpen, existingItem])

    return (
        <Dialog open={isOpen} onOpenChange={setOpen}>
            {trigger && <DialogTrigger asChild>{trigger}</DialogTrigger>}
            <DialogContent className="sm:max-w-[420px] max-h-[95vh] overflow-y-auto rounded-2xl p-0 border-none shadow-[0_8px_32px_rgba(0,0,0,0.12)] ring-1 ring-gray-100 bg-white">
                <form onSubmit={handleSubmit}>
                    <div className="p-6 pb-4">
                        <DialogHeader>
                            <DialogTitle className="text-lg font-bold flex items-center gap-2 text-gray-900 tracking-tight">
                                {isEditMode ? <Cpu className="h-5 w-5 text-blue-600" /> : <Plus className="h-5 w-5 text-emerald-600" />}
                                {isEditMode ? 'Modify Resource' : 'Catalog Asset'}
                            </DialogTitle>
                            <DialogDescription className="text-gray-500 text-sm font-medium">
                                Technical registry update for field logistics.
                            </DialogDescription>
                        </DialogHeader>
                    </div>

                    <div className="px-6 space-y-5">
                        {/* Visualization Zone */}
                        <div className="relative group rounded-xl border border-gray-200 bg-gray-50 flex items-center justify-center overflow-hidden transition-all duration-300 aspect-[21/9] hover:border-gray-300 hover:shadow-sm">
                            {previewUrl ? (
                                <>
                                    <div className="absolute inset-0 bg-gray-100/50 backdrop-blur-sm" />
                                    <img
                                        src={previewUrl}
                                        alt="Preview"
                                        className="relative z-10 w-full h-full object-contain p-2 hover:scale-105 transition-transform duration-500 cursor-zoom-in"
                                        onClick={() => window.open(previewUrl, '_blank')}
                                    />
                                    <div className="absolute inset-0 bg-gray-900/40 opacity-0 group-hover:opacity-100 transition-all flex items-center justify-center gap-2 backdrop-blur-[2px] z-20">
                                        <Button type="button" variant="secondary" size="sm" onClick={() => fileInputRef.current?.click()} className="h-7 rounded-lg text-[10px] font-semibold bg-white/90 shadow-sm">
                                            <UploadCloud className="w-3 h-3 mr-1" /> Change
                                        </Button>
                                        <Button type="button" variant="destructive" size="icon" onClick={removeImage} className="h-7 w-7 rounded-lg shadow-sm">
                                            <X className="w-3.5 h-3.5" />
                                        </Button>
                                    </div>
                                    <div className="absolute bottom-2 right-2 z-30 opacity-0 group-hover:opacity-100 transition-opacity">
                                        <Badge className="bg-white/90 text-gray-900 text-[8px] border-none font-bold py-0 h-4 shadow-sm">Full Detail Available</Badge>
                                    </div>
                                </>
                            ) : (
                                <div
                                    className="flex flex-col items-center gap-2 text-gray-400 w-full h-full justify-center cursor-pointer hover:bg-gray-100/80 transition-all duration-300 group/upload"
                                    onClick={() => fileInputRef.current?.click()}
                                >
                                    {isUploading ? (
                                        <Loader2 className="w-6 h-6 animate-spin text-blue-500" />
                                    ) : (
                                        <ImageIcon className="w-6 h-6 opacity-30 group-hover/upload:text-blue-500 group-hover/upload:opacity-100 group-hover/upload:scale-110 transition-all duration-300" />
                                    )}
                                    <span className="text-[9px] font-black uppercase tracking-[0.2em] group-hover/upload:text-blue-600 transition-colors duration-300">
                                        {isUploading ? 'Encoding...' : 'Attach Visual Reference'}
                                    </span>
                                </div>
                            )}
                            <input type="file" ref={fileInputRef} onChange={handleImageChange} className="hidden" accept="image/*" />
                        </div>

                        <div className="space-y-4">
                            <div className="grid gap-2">
                                <Label htmlFor="name" className="text-xs font-semibold text-gray-700">Asset Designation</Label>
                                <Input
                                    id="name"
                                    name="name"
                                    defaultValue={existingItem?.item_name}
                                    placeholder="Resource Name"
                                    className="h-11 rounded-lg border-gray-300 bg-white text-sm transition-all duration-200 focus:ring-2 focus:ring-blue-500/20 focus:border-blue-500 focus:shadow-[0_4px_12px_rgba(59,130,246,0.1)]"
                                    required
                                />
                            </div>

                            <div className="grid gap-2">
                                <Label htmlFor="description" className="text-xs font-semibold text-gray-700">Technical Specs</Label>
                                <Input
                                    id="description"
                                    name="description"
                                    defaultValue={existingItem?.description}
                                    placeholder="Model, Size, Serial..."
                                    className="h-11 rounded-lg border-gray-300 bg-white text-sm transition-all duration-200 focus:ring-2 focus:ring-blue-500/20 focus:border-blue-500 focus:shadow-[0_4px_12px_rgba(59,130,246,0.1)]"
                                />
                            </div>

                            <div className="grid grid-cols-2 gap-4">
                                <div className="grid gap-2">
                                    <Label htmlFor="serial_number" className="text-xs font-semibold text-gray-700">Equipment ID</Label>
                                    <Input
                                        id="serial_number"
                                        name="serial_number"
                                        defaultValue={existingItem?.serial_number}
                                        placeholder="e.g. LIG-2024-001"
                                        className="h-11 rounded-lg border-gray-300 bg-white text-sm transition-all duration-200 focus:ring-2 focus:ring-blue-500/20 focus:border-blue-500 focus:shadow-[0_4px_12px_rgba(59,130,246,0.1)]"
                                    />
                                </div>
                                <div className="grid gap-2">
                                    <Label htmlFor="equipment_type" className="text-xs font-semibold text-gray-700">Model/Type</Label>
                                    <Input
                                        id="equipment_type"
                                        name="equipment_type"
                                        defaultValue={existingItem?.equipment_type}
                                        placeholder="e.g. Digital, Gas, etc"
                                        className="h-11 rounded-lg border-gray-300 bg-white text-sm transition-all duration-200 focus:ring-2 focus:ring-blue-500/20 focus:border-blue-500 focus:shadow-[0_4px_12px_rgba(59,130,246,0.1)]"
                                    />
                                </div>
                            </div>

                            <div className="grid grid-cols-2 gap-4">
                                <div className="grid gap-2">
                                    <Label className="text-xs font-semibold text-gray-700">Category</Label>
                                    <Select name="category" defaultValue={existingItem?.category || categories[0]} disabled={isLoadingCategories}>
                                        <SelectTrigger className="h-11 rounded-lg border-gray-300 bg-white text-sm transition-all duration-200 focus:ring-2 focus:ring-blue-500/20 focus:border-blue-500">
                                            <SelectValue placeholder={isLoadingCategories ? "Loading..." : "Select category"} />
                                        </SelectTrigger>
                                        <SelectContent className="rounded-xl border-gray-200 shadow-xl">
                                            {categories.map(c => (
                                                <SelectItem key={c} value={c} className="text-sm">{c}</SelectItem>
                                            ))}
                                        </SelectContent>
                                    </Select>
                                </div>
                                <div className="grid gap-2">
                                    <Label className="text-xs font-semibold text-gray-700">Item Type</Label>
                                    <Select name="item_type" defaultValue={(existingItem as any)?.item_type || 'equipment'}>
                                        <SelectTrigger className="h-11 rounded-lg border-gray-300 bg-white text-sm transition-all duration-200 focus:ring-2 focus:ring-blue-500/20 focus:border-blue-500">
                                            <SelectValue placeholder="Select type" />
                                        </SelectTrigger>
                                        <SelectContent className="rounded-xl border-gray-200 shadow-xl">
                                            <SelectItem value="equipment" className="text-sm">Equipment (Returnable)</SelectItem>
                                            <SelectItem value="consumable" className="text-sm">Consumable (One-time)</SelectItem>
                                        </SelectContent>
                                    </Select>
                                </div>
                            </div>

                            <div className="grid gap-2">
                                <Label className="text-xs font-semibold text-gray-700">Status</Label>
                                <Select name="status" defaultValue={existingItem?.status || 'Good'}>
                                    <SelectTrigger className="h-11 rounded-lg border-gray-300 bg-white text-sm transition-all duration-200 focus:ring-2 focus:ring-blue-500/20 focus:border-blue-500">
                                        <SelectValue placeholder="Select status" />
                                    </SelectTrigger>
                                    <SelectContent className="rounded-xl border-gray-200 shadow-xl">
                                        <SelectItem value="Good" className="text-sm text-emerald-600">Operational</SelectItem>
                                        <SelectItem value="Maintenance" className="text-sm text-amber-600">Under Maintenance</SelectItem>
                                        <SelectItem value="Damaged" className="text-sm text-red-600">Damaged</SelectItem>
                                        <SelectItem value="Lost" className="text-sm text-gray-600">Lost/Missing</SelectItem>
                                    </SelectContent>
                                </Select>
                            </div>

                            <div className="grid gap-2">
                                <Label htmlFor="stock_total" className="text-xs font-semibold text-gray-700">Total Quantity</Label>
                                <Input
                                    id="stock_total"
                                    name="stock_total"
                                    type="number"
                                    min="1"
                                    defaultValue={existingItem?.stock_total || 1}
                                    placeholder="Enter quantity"
                                    className="h-11 rounded-lg border-gray-300 bg-white text-sm transition-all duration-200 focus:ring-2 focus:ring-blue-500/20 focus:border-blue-500 focus:shadow-[0_4px_12px_rgba(59,130,246,0.1)]"
                                    required
                                />
                            </div>
                        </div>
                    </div>

                    <DialogFooter className="bg-gray-50/50 p-6 mt-6 border-t border-gray-100 flex items-center justify-between">
                        <Button type="button" variant="ghost" onClick={() => setOpen(false)} disabled={isPending || isUploading} className="text-gray-600 text-sm font-medium hover:text-gray-900 transition-colors">
                            Cancel
                        </Button>
                        <Button 
                            type="submit" 
                            disabled={isPending || isUploading} 
                            className="rounded-xl h-10 px-6 font-semibold text-sm shadow-lg transition-all duration-200 hover:shadow-xl hover:-translate-y-0.5 active:scale-95 bg-blue-600 hover:bg-blue-700 text-white"
                        >
                            {isPending ? <Loader2 className="h-4 w-4 animate-spin" /> : (isEditMode ? 'Apply Sync' : 'Record Asset')}
                        </Button>
                    </DialogFooter>
                </form>
            </DialogContent>
        </Dialog>
    )
}
