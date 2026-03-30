import { useState, useTransition, useEffect, useRef, useMemo } from 'react'
import { useRouter } from 'next/navigation'
import { toast } from 'sonner'
import { createBrowserClient } from '@supabase/ssr'
import { addItem, updateItem, getCategories } from '@/src/features/catalog'
import { getStorageLocations, addStorageLocation } from '@/app/actions/storage-locations'
import { InventoryItem } from '@/lib/supabase'
import { optimizeImage } from '@/lib/image-optimizer'

interface UseInventoryFormProps {
    existingItem?: InventoryItem
    isOpen: boolean
    onClose: () => void
    onSuccess?: () => void
}

export function useInventoryForm({ existingItem, isOpen, onClose, onSuccess }: UseInventoryFormProps) {
    // State Management
    const [isPending, startTransition] = useTransition()
    const [isUploading, setIsUploading] = useState(false)
    const [previewUrl, setPreviewUrl] = useState<string | null>(existingItem?.image_url || null)
    const [storedPath, setStoredPath] = useState<string | null>(existingItem?.image_url || null)
    const [categories, setCategories] = useState<string[]>([])
    const [isLoadingCategories, setIsLoadingCategories] = useState(true)
    const [itemType, setItemType] = useState<'equipment' | 'consumable'>('equipment')
    const [storageLocation, setStorageLocation] = useState<string>((existingItem as any)?.storage_location || 'lower_warehouse')
    const [customLocation, setCustomLocation] = useState<string>('')
    const [savedLocations, setSavedLocations] = useState<string[]>([])
    const [isLoadingLocations, setIsLoadingLocations] = useState(true)
    const [isSavingLocation, setIsSavingLocation] = useState(false)
    const [hasVariants, setHasVariants] = useState(false)
    const [parentId, setParentId] = useState<string>('new')
    const [variantLabel, setVariantLabel] = useState<string>('')
    const [customVariant, setCustomVariant] = useState<string>('')
    const [parentItems, setParentItems] = useState<any[]>([])
    const [isLoadingParents, setIsLoadingParents] = useState(false)
    const [itemNameValue, setItemNameValue] = useState<string>(existingItem?.item_name || '')
    
    const fileInputRef = useRef<HTMLInputElement>(null)
    const formRef = useRef<HTMLFormElement>(null)
    const router = useRouter()

    // MEMOIZED CLIENT: Senior Dev tip - don't recreate clients on every re-render
    const supabase = useMemo(() => createBrowserClient(
        process.env.NEXT_PUBLIC_SUPABASE_URL!,
        process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY!
    ), [])

    const isEditMode = !!existingItem

    // Fetch categories, saved locations, and parent items when dialog opens
    useEffect(() => {
        async function loadData() {
            if (!isOpen) return
            
            try {
                setIsLoadingCategories(true)
                setIsLoadingLocations(true)
                setIsLoadingParents(true)
                
                const [categoriesResult, locationsResult] = await Promise.all([
                    getCategories(),
                    getStorageLocations()
                ])
                
                setCategories(categoriesResult.data || [])
                if (locationsResult.success) {
                    setSavedLocations(locationsResult.data)
                }
                
                // Fetch parent items (items without parent_id)
                const { data: parents } = await supabase
                    .from('inventory_items')
                    .select('id, item_name, base_name')
                    .is('parent_id', null)
                    .order('item_name')
                
                setParentItems(parents || [])
            } catch (error) {
                console.error('Error loading form data:', error)
                // Set fallback categories on error
                setCategories(['Medical', 'Tools', 'Rescue', 'PPE', 'Logistics', 'Goods'])
            } finally {
                setIsLoadingCategories(false)
                setIsLoadingLocations(false)
                setIsLoadingParents(false)
            }
        }
        loadData()
    }, [isOpen, supabase])

    // Initialize item type, storage location, and variant data when dialog opens
    useEffect(() => {
        if (isOpen && existingItem) {
            setItemType((existingItem as any)?.item_type || 'equipment')
            setItemNameValue(existingItem.item_name)
            const location = (existingItem as any)?.storage_location || 'lower_warehouse'
            
            // Check if location exists in saved locations list
            if (savedLocations.length > 0) {
                if (savedLocations.includes(location)) {
                    setStorageLocation(location)
                    setCustomLocation('')
                } else {
                    // It's a custom location not in the saved list
                    setStorageLocation('custom')
                    setCustomLocation(location)
                }
            } else {
                // Locations not loaded yet, set the value directly
                setStorageLocation(location)
            }
            
            // Initialize variant data
            const itemParentId = (existingItem as any)?.parent_id
            const itemVariantLabel = (existingItem as any)?.variant_label
            if (itemParentId && itemVariantLabel) {
                setHasVariants(true)
                setParentId(itemParentId.toString())
                setVariantLabel(itemVariantLabel)
            } else {
                setHasVariants(false)
                setParentId('new')
                setVariantLabel('')
            }
        } else if (isOpen) {
            setItemType('equipment')
            setStorageLocation('lower_warehouse')
            setCustomLocation('')
            setHasVariants(false)
            setParentId('new')
            setVariantLabel('')
            setCustomVariant('')
            setItemNameValue('')
        }
    }, [isOpen, existingItem, savedLocations])

    // MEMORY MANAGEMENT: Cleanup object URLs to prevent leaks
    useEffect(() => {
        return () => {
            if (previewUrl?.startsWith('blob:')) {
                URL.revokeObjectURL(previewUrl)
            }
        }
    }, [previewUrl])

    // Reset preview URL when dialog opens
    useEffect(() => {
        if (isOpen) setPreviewUrl(existingItem?.image_url || null)
    }, [isOpen, existingItem])

    // Image Upload Handler
    const handleImageChange = async (e: React.ChangeEvent<HTMLInputElement>) => {
        const rawFile = e.target.files?.[0]
        if (!rawFile) return

        try {
            setIsUploading(true)

            // SENIOR DEV OPTIMIZATION: Compress before upload
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

    // Form Submission Handler
    const handleSubmit = async (event: React.FormEvent<HTMLFormElement>) => {
        event.preventDefault()
        
        // Validate required fields
        const form = event.currentTarget
        const requiredFields = [
            { name: 'name', label: 'Item Name', ref: form.name },
            { name: 'category', label: 'Category', ref: form.category },
            { name: 'stock_total', label: 'Fixed Total Stock', ref: form.stock_total },
            { name: 'stock_available', label: 'Current Stock', ref: form.stock_available },
        ]

        // Add variant validation if variants are enabled
        if (hasVariants && !variantLabel) {
            toast.error('Please select a variant type')
            const variantSection = document.getElementById('variant-section')
            if (variantSection) {
                variantSection.scrollIntoView({ behavior: 'smooth', block: 'center' })
                variantSection.classList.add('animate-shake')
                setTimeout(() => variantSection.classList.remove('animate-shake'), 500)
            }
            return
        }

        // Check custom variant input
        if (hasVariants && variantLabel === 'custom' && !customVariant.trim()) {
            toast.error('Please enter a custom variant name')
            return
        }

        // Validate required fields
        for (const field of requiredFields) {
            if (!field.ref || !field.ref.value || field.ref.value.trim() === '') {
                toast.error(`${field.label} is required`)
                field.ref?.focus()
                field.ref?.scrollIntoView({ behavior: 'smooth', block: 'center' })
                field.ref?.classList.add('animate-shake', 'border-red-500')
                setTimeout(() => {
                    field.ref?.classList.remove('animate-shake', 'border-red-500')
                }, 500)
                return
            }
        }

        // Validate that current stock doesn't exceed total stock
        const totalStock = parseInt(form.stock_total.value)
        const currentStock = parseInt(form.stock_available.value)
        if (currentStock > totalStock) {
            toast.error('Current stock cannot exceed fixed total stock')
            form.stock_available?.focus()
            return
        }

        const formData = new FormData(event.currentTarget)

        if (isEditMode && existingItem) {
            formData.append('id', existingItem.id.toString())
        }

        if (storedPath) {
            formData.append('image_url', storedPath)
        }

        // Handle custom location
        if (storageLocation === 'custom' && customLocation.trim()) {
            formData.set('storage_location', customLocation.trim())
        }

        // Handle variant data
        if (hasVariants && variantLabel) {
            const finalVariantLabel = variantLabel === 'custom' ? customVariant : variantLabel
            if (finalVariantLabel) {
                formData.set('variant_label', finalVariantLabel)
            }
        }

        startTransition(async () => {
            const action = isEditMode ? updateItem : addItem
            const result = await action(formData)

            if (result.success) {
                toast.success(result.message)
                onClose()
                if (onSuccess) onSuccess()
                router.refresh()
            } else {
                toast.error(result.error || 'Operation failed')
            }
        })
    }

    // Storage Location Save Handler
    const handleSaveLocation = async () => {
        if (!customLocation.trim()) {
            toast.error('Enter a location first')
            return
        }
        setIsSavingLocation(true)
        const result = await addStorageLocation(customLocation.trim())
        if (result.success) {
            toast.success(result.message)
            setSavedLocations([customLocation.trim(), ...savedLocations])
        } else {
            toast.error(result.error)
        }
        setIsSavingLocation(false)
    }

    return {
        // State
        isPending,
        isUploading,
        previewUrl,
        categories,
        isLoadingCategories,
        itemType,
        storageLocation,
        customLocation,
        savedLocations,
        isLoadingLocations,
        isSavingLocation,
        hasVariants,
        parentId,
        variantLabel,
        customVariant,
        parentItems,
        isLoadingParents,
        itemNameValue,
        isEditMode,
        
        // Refs
        fileInputRef,
        formRef,
        
        // Handlers
        handleImageChange,
        removeImage,
        handleSubmit,
        handleSaveLocation,
        
        // Setters
        setItemType,
        setStorageLocation,
        setCustomLocation,
        setHasVariants,
        setParentId,
        setVariantLabel,
        setCustomVariant,
        setItemNameValue,
    }
}
