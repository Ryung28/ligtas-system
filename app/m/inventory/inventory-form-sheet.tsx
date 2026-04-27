'use client'

import React, { useEffect, useMemo, useState } from 'react'
import Image from 'next/image'
import { toast } from 'sonner'
import { Loader2, Save, Package, Image as ImageIcon, MapPin, Minus, Plus, Calendar, Bell, UploadCloud, Camera, X, Target, Barcode } from 'lucide-react'
import { addItem, updateItem } from '@/src/features/catalog'
import { createClient } from '@/lib/supabase-browser'
import { optimizeImage } from '@/lib/image-optimizer'
import { getInventoryImageUrl } from '@/lib/supabase'
import {
    BottomSheet,
    FormField,
    MInput,
} from '@/components/mobile/primitives'
import { cn } from '@/lib/utils'
import { resolveCategoryIcon } from '@/lib/category-icons'
import { mFocus } from '@/lib/mobile/tokens'
import type { InventoryItem } from '@/lib/supabase'
import { QtyStepper } from './qty-stepper'

interface InventoryFormSheetProps {
    open: boolean
    onOpenChange: (open: boolean) => void
    /** Pass an existing item to edit; omit to create. */
    item?: InventoryItem | null
    /** Known categories from current inventory for quick-pick chips. */
    knownCategories?: string[]
    /** Known admin-defined locations from inventory context. */
    knownLocations?: string[]
    /** 🎯 Tactical focus: Scroll to breakdown on open */
    triageMode?: 'restock' | 'none'
    onSuccess?: () => void
}

type ItemType = 'equipment' | 'consumable'

interface FormState {
    name: string
    category: string
    model_number: string
    item_type: ItemType
    storage_location: string
    image_url: string
    qty_good: number
    qty_damaged: number
    qty_maintenance: number
    qty_lost: number
    target_stock: number
    low_stock_threshold: number
    expiry_date: string
    expiry_alert_days: number
}

const BLANK: FormState = {
    name: '',
    category: '',
    model_number: '',
    item_type: 'equipment',
    storage_location: '',
    image_url: '',
    qty_good: 0,
    qty_damaged: 0,
    qty_maintenance: 0,
    qty_lost: 0,
    target_stock: 0,
    low_stock_threshold: 20,
    expiry_date: '',
    expiry_alert_days: 15,
}

export function InventoryFormSheet({
    open,
    onOpenChange,
    item,
    knownCategories = [],
    knownLocations = [],
    triageMode = 'none',
    onSuccess,
}: InventoryFormSheetProps) {
    const isEdit = !!item
    const [form, setForm] = useState<FormState>(BLANK)
    const [errors, setErrors] = useState<Partial<Record<keyof FormState, string>>>({})
    const [saving, setSaving] = useState(false)
    const [isUploadingImage, setIsUploadingImage] = useState(false)
    const [imagePreviewUrl, setImagePreviewUrl] = useState<string | null>(null)
    const breakdownRef = React.useRef<HTMLDivElement>(null)

    // 🎯 TACTICAL ANCHOR: Scroll to breakdown if in restock triage
    useEffect(() => {
        if (open && triageMode === 'restock') {
            const timer = setTimeout(() => {
                breakdownRef.current?.scrollIntoView({ behavior: 'smooth', block: 'start' })
            }, 300) // Small delay to wait for sheet animation
            return () => clearTimeout(timer)
        }
    }, [open, triageMode])

    useEffect(() => {
        if (!open) return
        if (item) {
            setForm({
                name: item.item_name ?? '',
                category: item.category ?? '',
                model_number: (item as any).model_number ?? '',
                item_type: ((item as any).item_type as ItemType) || 'equipment',
                storage_location: item.storage_location ?? '',
                image_url: item.image_url ?? '',
                qty_good: item.qty_good ?? 0,
                qty_damaged: item.qty_damaged ?? 0,
                qty_maintenance: item.qty_maintenance ?? 0,
                qty_lost: item.qty_lost ?? 0,
                target_stock: (item as any).target_stock ?? 0,
                low_stock_threshold: item.low_stock_threshold ?? 20,
                expiry_date: item.expiry_date ? new Date(item.expiry_date).toISOString().split('T')[0] : '',
                expiry_alert_days: (item as any).expiry_alert_days ?? 15,
            })
        } else {
            setForm(BLANK)
        }
        setImagePreviewUrl(getInventoryImageUrl(item?.image_url) || null)
        setErrors({})
    }, [open, item])

    const totalStock =
        form.qty_good + form.qty_damaged + form.qty_maintenance + form.qty_lost

    const uniqueCategories = useMemo(
        () =>
            Array.from(new Set(knownCategories.filter(Boolean))).sort((a, b) =>
                a.localeCompare(b),
            ),
        [knownCategories],
    )

    const setField = <K extends keyof FormState>(key: K, value: FormState[K]) => {
        setForm((f) => ({ ...f, [key]: value }))
        if (errors[key]) setErrors((e) => ({ ...e, [key]: undefined }))
    }

    const validate = () => {
        const next: Partial<Record<keyof FormState, string>> = {}
        if (!form.name.trim() || form.name.trim().length < 2) {
            next.name = 'Name must be at least 2 characters.'
        }
        if (!form.category.trim()) {
            next.category = 'Category is required.'
        }
        if (!form.storage_location.trim()) {
            next.storage_location = 'Storage location is required.'
        }
        if (totalStock < 1 && !isEdit) {
            next.qty_good = 'Total units must be at least 1.'
        }
        setErrors(next)
        return Object.keys(next).length === 0
    }

    const supabase = useMemo(() => createClient(), [])

    const uploadImage = async (file: File) => {
        try {
            setIsUploadingImage(true)
            const optimized = await optimizeImage(file)
            const fileName = `${Math.random().toString(36).substring(7)}-${Date.now()}.webp`
            const path = `items/${fileName}`
            const { error } = await supabase.storage.from('item-images').upload(path, optimized)
            if (error) throw error
            setField('image_url', path)
            setImagePreviewUrl(getInventoryImageUrl(path))
            toast.success('Image uploaded')
        } catch (err: any) {
            toast.error('Image upload failed', { description: err?.message || 'Please try again.' })
        } finally {
            setIsUploadingImage(false)
        }
    }

    const onImageFileChange = async (e: React.ChangeEvent<HTMLInputElement>) => {
        const file = e.target.files?.[0]
        if (!file) return
        await uploadImage(file)
        e.target.value = ''
    }

    const handleSubmit = async () => {
        if (!validate()) return
        setSaving(true)
        try {
            const fd = new FormData()
            if (isEdit && item) fd.set('id', String(item.id))
            fd.set('name', form.name.trim())
            fd.set('category', form.category.trim())
            fd.set('model_number', form.model_number.trim())
            fd.set('item_type', form.item_type)
            // Keep legacy DB compatibility while description field is hidden in UI.
            fd.set('description', isEdit ? (item?.description ?? '') : '')
            fd.set('storage_location', form.storage_location.trim())
            fd.set('image_url', form.image_url.trim())
            fd.set('qty_good', String(form.qty_good))
            fd.set('qty_damaged', String(form.qty_damaged))
            fd.set('qty_maintenance', String(form.qty_maintenance))
            fd.set('qty_lost', String(form.qty_lost))
            fd.set('target_stock', String(form.target_stock))
            fd.set('low_stock_threshold', String(form.low_stock_threshold))
            fd.set('stock_total', String(Math.max(totalStock, 1)))
            fd.set('stock_available', String(form.qty_good))
            fd.set('restock_alert_enabled', 'true')
            if (form.expiry_date) {
                fd.set('expiry_date', form.expiry_date)
                fd.set('expiry_alert_days', String(form.expiry_alert_days))
            }

            const result = isEdit ? await updateItem(fd) : await addItem(fd)

            if (result.success) {
                toast.success(
                    isEdit ? 'Item updated' : 'Item added',
                    { description: isEdit ? 'Your changes are live.' : `${form.name.trim()} is now in the registry.` },
                )
                onSuccess?.()
                onOpenChange(false)
            } else {
                toast.error(isEdit ? 'Update failed' : 'Add failed', {
                    description: (result as any).error || (result as any).message || 'Please try again.',
                })
            }
        } catch (err: any) {
            console.error('[/m/inventory] submit failed', err)
            toast.error('Something went wrong', {
                description: err?.message || 'Please retry in a moment.',
            })
        } finally {
            setSaving(false)
        }
    }

    return (
        <BottomSheet
            open={open}
            onOpenChange={onOpenChange}
            title={isEdit ? 'Edit item' : 'New item'}
            description={
                isEdit
                    ? 'Update details — changes sync immediately.'
                    : 'Register a new asset in the inventory ledger.'
            }
            size="full"
            footer={
                <div className="flex items-center gap-2">
                    <button
                        type="button"
                        onClick={() => onOpenChange(false)}
                        disabled={saving}
                        className={cn(
                            'flex-none h-11 px-4 rounded-xl text-xs font-bold uppercase tracking-wider',
                            'text-gray-700 hover:bg-gray-50 disabled:opacity-50',
                            'motion-safe:transition-colors',
                            mFocus,
                        )}
                    >
                        Cancel
                    </button>
                    <button
                        type="button"
                        onClick={handleSubmit}
                        disabled={saving}
                        className={cn(
                            'flex-1 h-11 rounded-xl text-sm font-semibold inline-flex items-center justify-center gap-2',
                            'bg-red-600 text-white hover:bg-red-700 active:bg-red-700',
                            'shadow-md shadow-red-200 disabled:opacity-60',
                            'motion-safe:transition-transform motion-safe:active:scale-[0.98]',
                            mFocus,
                        )}
                    >
                        {saving ? (
                            <>
                                <Loader2 className="w-4 h-4 animate-spin" aria-hidden />
                                Saving…
                            </>
                        ) : (
                            <>
                                <Save className="w-4 h-4" aria-hidden />
                                {isEdit ? 'Save changes' : 'Add item'}
                            </>
                        )}
                    </button>
                </div>
            }
        >
            <div className="space-y-5">
                {/* Image */}
                <FormField
                    label="Item photo"
                    htmlFor="inv-image-file"
                    optional
                    hint="Use camera or choose a file."
                >
                    <div className="rounded-2xl border border-gray-200 bg-gray-50/60 p-3 space-y-3">
                        <div className="relative h-36 rounded-xl overflow-hidden border border-gray-200 bg-white">
                            {imagePreviewUrl ? (
                                <Image
                                    src={imagePreviewUrl}
                                    alt="Item preview"
                                    fill
                                    className="object-cover"
                                />
                            ) : (
                                <div className="h-full w-full flex items-center justify-center text-gray-400">
                                    <ImageIcon className="w-8 h-8" />
                                </div>
                            )}
                        </div>
                        <div className="grid grid-cols-2 gap-2">
                            <label className={cn('h-10 rounded-xl bg-white border border-gray-200 text-xs font-bold uppercase tracking-wider flex items-center justify-center gap-2 cursor-pointer', mFocus)}>
                                <Camera className="w-4 h-4" />
                                Camera
                                <input
                                    id="inv-image-file"
                                    type="file"
                                    accept="image/*"
                                    capture="environment"
                                    className="hidden"
                                    onChange={onImageFileChange}
                                    disabled={isUploadingImage}
                                />
                            </label>
                            <label className={cn('h-10 rounded-xl bg-white border border-gray-200 text-xs font-bold uppercase tracking-wider flex items-center justify-center gap-2 cursor-pointer', mFocus)}>
                                <UploadCloud className="w-4 h-4" />
                                Choose file
                                <input
                                    type="file"
                                    accept="image/*"
                                    className="hidden"
                                    onChange={onImageFileChange}
                                    disabled={isUploadingImage}
                                />
                            </label>
                        </div>
                        {form.image_url && (
                            <button
                                type="button"
                                onClick={() => {
                                    setField('image_url', '')
                                    setImagePreviewUrl(null)
                                }}
                                className={cn('h-10 rounded-xl bg-white border border-gray-200 text-xs font-bold uppercase tracking-wider flex items-center justify-center gap-2', mFocus)}
                                disabled={isUploadingImage}
                            >
                                <X className="w-4 h-4" />
                                Remove photo
                            </button>
                        )}
                        {isUploadingImage && (
                            <p className="text-xs text-gray-500 inline-flex items-center gap-2">
                                <Loader2 className="w-3.5 h-3.5 animate-spin" />
                                Uploading image...
                            </p>
                        )}
                    </div>
                </FormField>

                {/* Identity */}
                <FormField label="Item name" htmlFor="inv-name" required error={errors.name}>
                    <MInput
                        id="inv-name"
                        value={form.name}
                        onChange={(e) => setField('name', e.target.value)}
                        placeholder="e.g. Portable Generator"
                        autoComplete="off"
                        invalid={!!errors.name}
                    />
                </FormField>
                
                <FormField label="Model name" htmlFor="inv-model" optional hint="Specific version or identifier.">
                    <div className="relative">
                        <Barcode className="absolute left-4 top-1/2 -translate-y-1/2 w-4 h-4 text-gray-400 pointer-events-none" />
                        <MInput
                            id="inv-model"
                            value={form.model_number}
                            onChange={(e) => setField('model_number', e.target.value)}
                            placeholder="e.g. X-Series, Gen 2"
                            className="pl-10"
                        />
                    </div>
                </FormField>

                <FormField label="Category" htmlFor="inv-category" required error={errors.category}>
                    <MInput
                        id="inv-category"
                        list="inv-category-options"
                        value={form.category}
                        onChange={(e) => setField('category', e.target.value)}
                        placeholder="e.g. Power & Energy"
                        invalid={!!errors.category}
                    />
                    {uniqueCategories.length > 0 && (
                        <>
                            <datalist id="inv-category-options">
                                {uniqueCategories.map((c) => (
                                    <option key={c} value={c} />
                                ))}
                            </datalist>
                            <div className="mt-2 flex flex-wrap gap-1.5">
                                {uniqueCategories.slice(0, 6).map((c) => {
                                    const ChipIcon = resolveCategoryIcon(c)
                                    return (
                                        <button
                                            key={c}
                                            type="button"
                                            onClick={() => setField('category', c)}
                                            className={cn(
                                                'inline-flex items-center gap-1 px-2.5 py-1 rounded-full text-[10px] font-bold uppercase tracking-wider border',
                                                'motion-safe:transition-colors',
                                                form.category === c
                                                    ? 'bg-red-50 text-red-700 border-red-200'
                                                    : 'bg-white text-gray-600 border-gray-200 hover:border-gray-300',
                                                mFocus,
                                            )}
                                        >
                                            <ChipIcon className="h-3 w-3 shrink-0 opacity-80" strokeWidth={2.5} aria-hidden />
                                            {c}
                                        </button>
                                    )
                                })}
                            </div>
                        </>
                    )}
                </FormField>

                {/* Type */}
                <FormField label="Item type" htmlFor="inv-type">
                    <div className="grid grid-cols-2 gap-2" id="inv-type" role="radiogroup" aria-label="Item type">
                        {(['equipment', 'consumable'] as const).map((opt) => (
                            <button
                                key={opt}
                                type="button"
                                role="radio"
                                aria-checked={form.item_type === opt}
                                onClick={() => setField('item_type', opt)}
                                className={cn(
                                    'h-11 rounded-xl text-sm font-bold capitalize border',
                                    'motion-safe:transition-colors',
                                    form.item_type === opt
                                        ? 'bg-gray-900 text-white border-gray-900'
                                        : 'bg-white text-gray-700 border-gray-200 hover:border-gray-300',
                                    mFocus,
                                )}
                            >
                                {opt}
                            </button>
                        ))}
                    </div>
                </FormField>

                {/* Location */}
                <FormField
                    label="Storage location"
                    htmlFor="inv-location"
                    required
                    hint="Where this asset physically lives."
                    error={errors.storage_location}
                >
                    <div className="relative space-y-2">
                        <MapPin
                            className="absolute left-4 top-1/2 -translate-y-1/2 w-4 h-4 text-gray-400 pointer-events-none"
                            aria-hidden
                        />
                        <select
                            id="inv-location"
                            value={form.storage_location}
                            onChange={(e) => setField('storage_location', e.target.value)}
                            className={cn(
                                'w-full h-12 rounded-2xl border px-10 text-sm font-medium',
                                'focus:outline-none focus:ring-2 focus:ring-red-500/20',
                                errors.storage_location ? 'border-rose-400 focus:border-rose-500' : 'border-gray-200 focus:border-red-500',
                                'bg-white text-gray-900',
                            )}
                        >
                            <option value="">Select location</option>
                            {knownLocations.map((loc) => (
                                <option key={loc} value={loc}>
                                    {loc.replaceAll('_', ' ')}
                                </option>
                            ))}
                        </select>
                        {knownLocations.length === 0 && (
                            <p className="text-xs text-amber-700">
                                No admin-defined locations found yet. Ask admin to configure locations.
                            </p>
                        )}
                    </div>
                </FormField>

                {/* Status buckets */}
                <section className="space-y-3" ref={breakdownRef}>
                    <div className="flex items-center justify-between px-1">
                        <h4 className="text-[10px] font-bold uppercase tracking-widest text-gray-600 flex items-center gap-1.5">
                            <Package className="w-3.5 h-3.5 text-red-600" aria-hidden />
                            Unit breakdown
                        </h4>
                        <span className="text-[10px] font-bold uppercase tracking-widest text-gray-500 tabular-nums">
                            Total: {totalStock}
                        </span>
                    </div>

                    <div className="space-y-2.5">
                        <QtyStepper
                            label="Good (ready for deployment)"
                            tone="success"
                            value={form.qty_good}
                            onChange={(v) => setField('qty_good', v)}
                            id="qty-good"
                            error={errors.qty_good}
                        />
                        <QtyStepper
                            label="Damaged"
                            tone="warning"
                            value={form.qty_damaged}
                            onChange={(v) => setField('qty_damaged', v)}
                            id="qty-damaged"
                        />
                        <QtyStepper
                            label="Under maintenance"
                            tone="info"
                            value={form.qty_maintenance}
                            onChange={(v) => setField('qty_maintenance', v)}
                            id="qty-maintenance"
                        />
                        <QtyStepper
                            label="Lost / written off"
                            tone="danger"
                            value={form.qty_lost}
                            onChange={(v) => setField('qty_lost', v)}
                            id="qty-lost"
                        />
                    </div>
                </section>

                <section className="space-y-4 pt-3 border-t border-gray-100">
                    <div className="flex items-center gap-2">
                        <Target className="w-4 h-4 text-blue-600" />
                        <h4 className="text-[10px] font-bold uppercase tracking-widest text-gray-500">
                            Stock strategy
                        </h4>
                    </div>

                    <div className="grid grid-cols-2 gap-3">
                        <FormField
                            label="Max stock goal"
                            htmlFor="inv-target"
                            hint="Ideal quantity."
                        >
                            <MInput
                                id="inv-target"
                                type="number"
                                inputMode="numeric"
                                min={0}
                                value={form.target_stock}
                                onChange={(e) =>
                                    setField('target_stock', Math.max(0, Number(e.target.value) || 0))
                                }
                            />
                        </FormField>

                        <FormField
                            label="Warn at (%)"
                            htmlFor="inv-threshold"
                            hint="Alert threshold."
                        >
                            <MInput
                                id="inv-threshold"
                                type="number"
                                inputMode="numeric"
                                min={0}
                                max={100}
                                value={form.low_stock_threshold}
                                onChange={(e) =>
                                    setField(
                                        'low_stock_threshold',
                                        Math.max(0, Math.min(100, Number(e.target.value) || 0)),
                                    )
                                }
                            />
                        </FormField>
                    </div>

                    {form.target_stock > 0 && (
                        <div className="bg-blue-50/80 p-3 rounded-2xl border border-blue-100 flex items-center gap-3">
                            <Bell className="w-4 h-4 text-blue-600" />
                            <p className="text-[10px] font-bold text-blue-800 leading-tight">
                                Restock alert will trigger at or below: <span className="text-blue-600 underline underline-offset-2">{Math.ceil(form.target_stock * (form.low_stock_threshold / 100))} units</span>
                            </p>
                        </div>
                    )}
                </section>

                {/* Consumable-only: expiry tracking */}
                {form.item_type === 'consumable' && (
                    <>
                        <FormField
                            label="Expiry date"
                            htmlFor="inv-expiry"
                            optional
                            hint="Leave blank for non-perishable items."
                        >
                            <div className="relative">
                                <Calendar
                                    className="absolute left-4 top-1/2 -translate-y-1/2 w-4 h-4 text-gray-400 pointer-events-none"
                                    aria-hidden
                                />
                                <MInput
                                    id="inv-expiry"
                                    type="date"
                                    value={form.expiry_date}
                                    onChange={(e) => setField('expiry_date', e.target.value)}
                                    className="pl-10"
                                />
                            </div>
                        </FormField>

                        {form.expiry_date && (
                            <FormField
                                label="Alert window (days before expiry)"
                                htmlFor="inv-expiry-alert"
                                hint="You'll be notified when this many days remain."
                            >
                                <div className="relative">
                                    <Bell
                                        className="absolute left-4 top-1/2 -translate-y-1/2 w-4 h-4 text-amber-500 pointer-events-none"
                                        aria-hidden
                                    />
                                    <MInput
                                        id="inv-expiry-alert"
                                        type="number"
                                        inputMode="numeric"
                                        min={1}
                                        max={365}
                                        value={form.expiry_alert_days}
                                        onChange={(e) =>
                                            setField('expiry_alert_days', Math.max(1, Number(e.target.value) || 15))
                                        }
                                        className="pl-10"
                                    />
                                </div>
                            </FormField>
                        )}
                    </>
                )}
            </div>
        </BottomSheet>
    )
}
