import { useState, useTransition, useEffect, useRef, useMemo } from 'react'
import { useRouter } from 'next/navigation'
import { toast } from 'sonner'
import { createBrowserClient } from '@supabase/ssr'
import { addItem, updateItem, getCategories } from '@/src/features/catalog'
import { getStorageLocations, addStorageLocation } from '@/app/actions/storage-locations'
import { InventoryItem } from '@/lib/supabase'
import { optimizeImage } from '@/lib/image-optimizer'

interface AdditionalDetailsFieldsProps {
    existingItem?: InventoryItem
    isSplitMode?: boolean
    setIsSplitMode?: (value: boolean) => void
    splitQty?: number | string
    setSplitQty?: (value: number | string) => void
    totalStock?: number | string
}

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
    const [categoryId, setCategoryId] = useState<string>('')
    const [storageLocation, setStorageLocation] = useState<string>('')
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
    // Enterprise Sub-Buckets State
    const [qtyGood, setQtyGood] = useState<number | string>(existingItem?.qty_good || 0)
    const [qtyDamaged, setQtyDamaged] = useState<number | string>(existingItem?.qty_damaged || 0)
    const [qtyMaintenance, setQtyMaintenance] = useState<number | string>(existingItem?.qty_maintenance || 0)
    const [qtyLost, setQtyLost] = useState<number | string>(existingItem?.qty_lost || 0)

    // AUTO-BALANCING (THE ENTERPRISE WAY): stock_total is the aggregate of all status buckets
    const stockTotalValue = Number(qtyGood) + Number(qtyDamaged) + Number(qtyMaintenance) + Number(qtyLost)
    const stockAvailableValue = Number(qtyGood)
    
    // Split Mode State (DEPRECATED - Kept for reverse compatibility during refactor)
    const [isSplitMode, setIsSplitMode] = useState(false)
    const [splitQty, setSplitQty] = useState<number | string>(1)
    
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

    // INITIALIZE FORM ON OPEN (THE SENIOR WAY): Single-pass initialization
    useEffect(() => {
        if (!isOpen) {
            // Clean up when dialog closes
            setQtyGood(0)
            setQtyDamaged(0)
            setQtyMaintenance(0)
            setQtyLost(0)
            setItemNameValue('')
            setPreviewUrl(null)
            setStoredPath(null)
            return
        }

        if (isOpen && existingItem) {
            setItemNameValue(existingItem.item_name || '')
            setCategoryId(existingItem.category || '')
            setItemType((existingItem as any).item_type || 'equipment')
            setStorageLocation(existingItem.storage_location || '')
            
            // Initialize Buckets
            setQtyGood(existingItem.qty_good || 0)
            setQtyDamaged(existingItem.qty_damaged || 0)
            setQtyMaintenance(existingItem.qty_maintenance || 0)
            setQtyLost(existingItem.qty_lost || 0)

            setIsSplitMode(false)
            
            setPreviewUrl(existingItem.image_url || null)
            setStoredPath(existingItem.image_url || null)
            
            const location = (existingItem as any)?.storage_location || 'lower_warehouse'
            if (savedLocations.length > 0 && !savedLocations.includes(location)) {
                setStorageLocation('custom')
                setCustomLocation(location)
            } else {
                setStorageLocation(location)
                setCustomLocation('')
            }
            
            // Variant logic
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
            // New Item defaults
            setQtyGood(0)
            setQtyDamaged(0)
            setQtyMaintenance(0)
            setQtyLost(0)
            setCategoryId('')
            setItemNameValue('')
            setItemType('equipment')
            setStorageLocation('lower_warehouse')
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
            { name: 'category', label: 'Category', ref: form.category }
        ]

        // Add variant validation if variants are enabled
        if (hasVariants && !variantLabel) {
            toast.error('Please select a variant type')
            return
        }

        // Validate required fields
        for (const field of requiredFields.filter(f => !['stock_total', 'stock_available'].includes(f.name))) {
            if (!field.ref || !field.ref.value || field.ref.value.trim() === '') {
                toast.error(`${field.label} is required`)
                field.ref?.focus()
                return
            }
        }

        const formData = new FormData(event.currentTarget)
        
        // Append buckets explicitly to ensure they reach the server action
        formData.set('qty_good', qtyGood.toString())
        formData.set('qty_damaged', qtyDamaged.toString())
        formData.set('qty_maintenance', qtyMaintenance.toString())
        formData.set('qty_lost', qtyLost.toString())
        formData.set('stock_total', stockTotalValue.toString())
        formData.set('stock_available', qtyGood.toString())

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

        // Handle variant data: Reset identity if status is 'Good'
        if (hasVariants && variantLabel) {
            const finalVariantLabel = variantLabel === 'custom' ? customVariant : variantLabel
            if (finalVariantLabel && formData.get('status') !== 'Good') {
                formData.set('variant_label', finalVariantLabel)
            } else if (formData.get('status') === 'Good') {
                formData.delete('variant_label')
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
        
        // Data & Setters
        categoryId,
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
        stockTotalValue,
        
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
        setCategoryId,
        setStorageLocation,
        setCustomLocation,
        setHasVariants,
        setParentId,
        setVariantLabel,
        setCustomVariant,
        setItemNameValue,

        // Bucket States
        qtyGood,
        qtyDamaged,
        qtyMaintenance,
        qtyLost,
        // Bucket Setters
        setQtyGood,
        setQtyDamaged,
        setQtyMaintenance,
        setQtyLost
    }
}
