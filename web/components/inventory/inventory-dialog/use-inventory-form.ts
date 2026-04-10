import { useState, useTransition, useEffect, useRef, useMemo } from 'react'
import { useRouter } from 'next/navigation'
import { toast } from 'sonner'
import { createBrowserClient } from '@supabase/ssr'
import { addItem, updateItem, getCategories } from '@/src/features/catalog'
import { getStorageLocations, addStorageLocation, deleteStorageLocation } from '@/app/actions/storage-locations'
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
    const [savedLocations, setSavedLocations] = useState<any[]>([])
    const [isLoadingLocations, setIsLoadingLocations] = useState(true)
    const [isSavingLocation, setIsSavingLocation] = useState(false)
    const [hasVariants, setHasVariants] = useState(false)
    const [parentId, setParentId] = useState<string>('new')
    const [variantLabel, setVariantLabel] = useState<string>('')
    const [customVariant, setCustomVariant] = useState<string>('')
    const [parentItems, setParentItems] = useState<any[]>([])
    const [isLoadingParents, setIsLoadingParents] = useState(false)
    const [itemNameValue, setItemNameValue] = useState<string>(existingItem?.item_name || '')
    // 🏛️ STATE-BASED ALLOCATION: Distribution across multiple sites
    const [siteDistributions, setSiteDistributions] = useState<any[]>([])
    
    // 🏛️ COMPUTED LOGISTICAL TOTALS: Derived from site distributions
    const qtyGood = useMemo(() => siteDistributions.reduce((sum, d) => sum + (Number(d.qtyGood) || 0), 0), [siteDistributions])
    const qtyDamaged = useMemo(() => siteDistributions.reduce((sum, d) => sum + (Number(d.qtyDamaged) || 0), 0), [siteDistributions])
    const qtyMaintenance = useMemo(() => siteDistributions.reduce((sum, d) => sum + (Number(d.qtyMaintenance) || 0), 0), [siteDistributions])
    const qtyLost = useMemo(() => siteDistributions.reduce((sum, d) => sum + (Number(d.qtyLost) || 0), 0), [siteDistributions])

    // AUTO-BALANCING: aggregate of all computed status buckets
    const stockTotalValue = qtyGood + qtyDamaged + qtyMaintenance + qtyLost
    const stockAvailableValue = qtyGood
    
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
            setItemNameValue('')
            setPreviewUrl(null)
            setStoredPath(null)
            setSiteDistributions([])
            return
        }

        if (existingItem) {
            setItemNameValue(existingItem.item_name || '')
            setCategoryId(existingItem.category || '')
            setItemType((existingItem as any).item_type || 'equipment')
            
            setIsSplitMode(false)
            
            setPreviewUrl(existingItem.image_url || null)
            setStoredPath(existingItem.image_url || null)
            
            // 🏛️ Initialize State-Based Allocation
            const variants = (existingItem as any).variants || []
            if (variants.length > 0) {
                setSiteDistributions(variants.map((v: any) => ({
                    id: v.id,
                    locationId: v.location_id,
                    locationName: v.location,
                    qtyGood: v.qty_good ?? 0,
                    qtyDamaged: v.qty_damaged ?? 0,
                    qtyMaintenance: v.qty_maintenance ?? 0,
                    qtyLost: v.qty_lost ?? 0
                })))
            } else {
                // Initialize with current item as the first site
                setSiteDistributions([{
                    id: existingItem.id,
                    locationId: (existingItem as any).location_registry_id,
                    locationName: existingItem.storage_location || 'lower_warehouse',
                    qtyGood: existingItem.qty_good || 0,
                    qtyDamaged: existingItem.qty_damaged || 0,
                    qtyMaintenance: existingItem.qty_maintenance || 0,
                    qtyLost: existingItem.qty_lost || 0
                }])
            }
            
            const location = (existingItem as any)?.storage_location || 'lower_warehouse'
            const locationInRegistry = savedLocations.some(loc => 
                loc.location_name === location || loc.id?.toString() === location
            )
            
            if (savedLocations.length > 0 && !locationInRegistry) {
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
            setCategoryId('')
            setItemNameValue('')
            setItemType('equipment')
            setStorageLocation('lower_warehouse')
            setSiteDistributions([{
                locationName: 'lower_warehouse',
                qtyGood: 0,
                qtyDamaged: 0,
                qtyMaintenance: 0,
                qtyLost: 0
            }])
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
            { name: 'category', label: 'Category', ref: form.category },
        ]

        // Location Check
        const cleanLocation = storageLocation === 'custom' ? customLocation.trim() : storageLocation.trim()
        if (!cleanLocation || cleanLocation === 'Select location') {
            toast.error('Please select a storage location.')
            return
        }

        // Add variant validation if variants are enabled
        if (hasVariants && !variantLabel) {
            toast.error('Please select a variant type')
            return
        }

        // Standard Field Validation
        for (const field of requiredFields) {
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

        // 🏛️ Pass the complete site distribution state
        formData.set('site_distributions', JSON.stringify(siteDistributions))

        if (isEditMode && existingItem) {
            formData.append('id', existingItem.id.toString())
        }

        if (storedPath) {
            formData.append('image_url', storedPath)
        }

        // 🏛️ GEOGRAPHIC RESOLUTION: Map internal state to DB fields
        // If storageLocation is a number, it's a registry ID. If it's text, it's a manual entry.
        const isNumericId = /^\d+$/.test(storageLocation)
        if (isNumericId) {
            formData.set('location_id', storageLocation)
            // Also find the name for redundancy if possible
            const locObj = savedLocations.find((l) => l.id?.toString() === storageLocation)
            if (locObj) formData.set('storage_location', locObj.location_name)
        } else if (storageLocation === 'custom' && customLocation.trim()) {
            formData.set('storage_location', customLocation.trim())
            formData.delete('location_id')
        } else {
            formData.set('storage_location', storageLocation)
            formData.delete('location_id')
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

    // Storage Location Delete Handler
    const handleDeleteLocation = async (id: number) => {
        if (!confirm('Are you sure you want to remove this site from the registry?')) return
        
        startTransition(async () => {
            const result = await deleteStorageLocation(id)
            if (result.success) {
                toast.success(result.message)
                setSavedLocations(savedLocations.filter(loc => loc.id !== id))
            } else {
                toast.error(result.error)
            }
        })
    }

    // 🏛️ BUCKET TRANSFER ENGINE: Reconciliation via Site Distribution
    const handleBucketUpdate = (
        bucket: string,
        newVal: number | string
    ) => {
        if (siteDistributions.length === 0) return

        const currentVal = Number(bucket === 'qtyDamaged' ? qtyDamaged : bucket === 'qtyMaintenance' ? qtyMaintenance : qtyLost)
        const delta = Number(newVal) - currentVal
        const currentGood = qtyGood
        
        // Safety Guard
        if (delta > currentGood) {
            toast.error(`Error: You only have ${currentGood} items left to move.`)
            return
        }

        // Application of shift with typing resilience
        const valToSet = newVal === '' ? '' : Number(newVal)
        const newDist = [...siteDistributions]
        newDist[0] = { 
            ...newDist[0], 
            [bucket]: valToSet,
            qtyGood: Number(newDist[0].qtyGood || 0) - delta
        }
        setSiteDistributions(newDist)
    }

    // 🏛️ SITE ALLOCATION HANDLERS
    const addSiteDistribution = (location: any) => {
        const locName = location.location_name || location
        const locId = location.id || null
        
        // Prevent duplicates
        if (siteDistributions.some(d => d.locationName === locName || d.locationId === locId)) {
            toast.error('Site already added to distribution')
            return
        }

        setSiteDistributions([...siteDistributions, {
            locationId: locId,
            locationName: locName,
            qtyGood: 0,
            qtyDamaged: 0,
            qtyMaintenance: 0,
            qtyLost: 0
        }])
    }

    const removeSiteDistribution = (index: number) => {
        if (siteDistributions.length <= 1) {
            toast.error('Item must be at minimum one location')
            return
        }
        setSiteDistributions(siteDistributions.filter((_, i) => i !== index))
    }

    const updateSiteQty = (index: number, bucket: string, value: number | string) => {
        const newDist = [...siteDistributions]
        const valToSet = value === '' ? '' : Number(value)
        newDist[index] = { ...newDist[index], [bucket]: valToSet }
        setSiteDistributions(newDist)
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
        handleDeleteLocation,
        
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

        // Site Allocation
        siteDistributions,
        addSiteDistribution,
        removeSiteDistribution,
        updateSiteQty,

        // Bucket States
        qtyGood,
        qtyDamaged,
        qtyMaintenance,
        qtyLost,
        // 🏛️ SMART SETTERS: Redirect to Site Logic
        setQtyGood: (val: number | string) => {
            const newDist = [...siteDistributions]
            if (newDist[0]) {
                newDist[0] = { ...newDist[0], qtyGood: val === '' ? '' : Number(val) }
                setSiteDistributions(newDist)
            }
        },
        setQtyDamaged: (val: number | string) => handleBucketUpdate('qtyDamaged', val),
        setQtyMaintenance: (val: number | string) => handleBucketUpdate('qtyMaintenance', val),
        setQtyLost: (val: number | string) => handleBucketUpdate('qtyLost', val)
    }
}
