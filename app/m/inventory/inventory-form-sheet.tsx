'use client'

import React, { useEffect, useMemo, useState } from 'react'
import { toast } from 'sonner'
import { Loader2, Save, Package, Image as ImageIcon, MapPin, Minus, Plus, Calendar, Bell } from 'lucide-react'
import { addItem, updateItem } from '@/src/features/catalog'
import {
    BottomSheet,
    FormField,
    MInput,
    MTextarea,
} from '@/components/mobile/primitives'
import { cn } from '@/lib/utils'
import { resolveCategoryIcon } from '@/lib/category-icons'
import { mFocus } from '@/lib/mobile/tokens'
import type { InventoryItem } from '@/lib/supabase'

interface InventoryFormSheetProps {
    open: boolean
    onOpenChange: (open: boolean) => void
    /** Pass an existing item to edit; omit to create. */
    item?: InventoryItem | null
    /** Known categories from current inventory for quick-pick chips. */
    knownCategories?: string[]
    onSuccess?: () => void
}

type ItemType = 'equipment' | 'consumable'

interface FormState {
    name: string
    category: string
    item_type: ItemType
    description: string
    storage_location: string
    image_url: string
    qty_good: number
    qty_damaged: number
    qty_maintenance: number
    qty_lost: number
    low_stock_threshold: number
    expiry_date: string
    expiry_alert_days: number
}

const BLANK: FormState = {
    name: '',
    category: '',
    item_type: 'equipment',
    description: '',
    storage_location: '',
    image_url: '',
    qty_good: 0,
    qty_damaged: 0,
    qty_maintenance: 0,
    qty_lost: 0,
    low_stock_threshold: 20,
    expiry_date: '',
    expiry_alert_days: 15,
}

export function InventoryFormSheet({
    open,
    onOpenChange,
    item,
    knownCategories = [],
    onSuccess,
}: InventoryFormSheetProps) {
    const isEdit = !!item
    const [form, setForm] = useState<FormState>(BLANK)
    const [errors, setErrors] = useState<Partial<Record<keyof FormState, string>>>({})
    const [saving, setSaving] = useState(false)

    useEffect(() => {
        if (!open) return
        if (item) {
            setForm({
                name: item.item_name ?? '',
                category: item.category ?? '',
                item_type: ((item as any).item_type as ItemType) || 'equipment',
                description: item.description ?? '',
                storage_location: item.storage_location ?? '',
                image_url: item.image_url ?? '',
                qty_good: item.qty_good ?? 0,
                qty_damaged: item.qty_damaged ?? 0,
                qty_maintenance: item.qty_maintenance ?? 0,
                qty_lost: item.qty_lost ?? 0,
                low_stock_threshold: item.low_stock_threshold ?? 20,
                expiry_date: item.expiry_date ? new Date(item.expiry_date).toISOString().split('T')[0] : '',
                expiry_alert_days: (item as any).expiry_alert_days ?? 15,
            })
        } else {
            setForm(BLANK)
        }
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
        if (totalStock < 1 && !isEdit) {
            next.qty_good = 'Total units must be at least 1.'
        }
        setErrors(next)
        return Object.keys(next).length === 0
    }

    const handleSubmit = async () => {
        if (!validate()) return
        setSaving(true)
        try {
            const fd = new FormData()
            if (isEdit && item) fd.set('id', String(item.id))
            fd.set('name', form.name.trim())
            fd.set('category', form.category.trim())
            fd.set('item_type', form.item_type)
            fd.set('description', form.description.trim())
            fd.set('storage_location', form.storage_location.trim())
            fd.set('image_url', form.image_url.trim())
            fd.set('qty_good', String(form.qty_good))
            fd.set('qty_damaged', String(form.qty_damaged))
            fd.set('qty_maintenance', String(form.qty_maintenance))
            fd.set('qty_lost', String(form.qty_lost))
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

                <FormField
                    label="Description"
                    htmlFor="inv-description"
                    optional
                    hint="Purpose, specs, or any field-critical notes."
                >
                    <MTextarea
                        id="inv-description"
                        value={form.description}
                        onChange={(e) => setField('description', e.target.value)}
                        placeholder="Describe this asset…"
                        rows={3}
                    />
                </FormField>

                {/* Location & Image */}
                <FormField
                    label="Storage location"
                    htmlFor="inv-location"
                    optional
                    hint="Where this asset physically lives."
                >
                    <div className="relative">
                        <MapPin
                            className="absolute left-4 top-1/2 -translate-y-1/2 w-4 h-4 text-gray-400 pointer-events-none"
                            aria-hidden
                        />
                        <MInput
                            id="inv-location"
                            value={form.storage_location}
                            onChange={(e) => setField('storage_location', e.target.value)}
                            placeholder="e.g. Lower Warehouse"
                            className="pl-10"
                        />
                    </div>
                </FormField>

                <FormField
                    label="Image URL"
                    htmlFor="inv-image"
                    optional
                    hint="Paste a public image URL or a storage path."
                >
                    <div className="relative">
                        <ImageIcon
                            className="absolute left-4 top-1/2 -translate-y-1/2 w-4 h-4 text-gray-400 pointer-events-none"
                            aria-hidden
                        />
                        <MInput
                            id="inv-image"
                            value={form.image_url}
                            onChange={(e) => setField('image_url', e.target.value)}
                            placeholder="https://… or item-images/path.png"
                            className="pl-10"
                            inputMode="url"
                            autoCapitalize="none"
                            autoCorrect="off"
                        />
                    </div>
                </FormField>

                {/* Status buckets */}
                <section className="space-y-3">
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

                <FormField
                    label="Low-stock threshold (%)"
                    htmlFor="inv-threshold"
                    hint="Alert fires when available units drop below this percentage."
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

type QtyTone = 'success' | 'warning' | 'info' | 'danger'

function QtyStepper({
    id,
    label,
    value,
    onChange,
    tone,
    error,
}: {
    id: string
    label: string
    value: number
    onChange: (v: number) => void
    tone: QtyTone
    error?: string
}) {
    const toneMap: Record<QtyTone, string> = {
        success: 'bg-emerald-50 border-emerald-100',
        warning: 'bg-amber-50 border-amber-100',
        info: 'bg-blue-50 border-blue-100',
        danger: 'bg-rose-50 border-rose-100',
    }
    const dotMap: Record<QtyTone, string> = {
        success: 'bg-emerald-500',
        warning: 'bg-amber-500',
        info: 'bg-blue-500',
        danger: 'bg-rose-500',
    }

    return (
        <div>
            <div className={cn('rounded-2xl border p-3 flex items-center gap-3', toneMap[tone])}>
                <span className={cn('w-2 h-2 rounded-full shrink-0', dotMap[tone])} aria-hidden />
                <label htmlFor={id} className="flex-1 text-sm font-semibold text-gray-900 min-w-0 truncate">
                    {label}
                </label>
                <div className="flex items-center gap-1">
                    <button
                        type="button"
                        onClick={() => onChange(Math.max(0, value - 1))}
                        className={cn(
                            'w-9 h-9 rounded-xl bg-white border border-gray-200 flex items-center justify-center',
                            'text-gray-700 hover:bg-gray-50 disabled:opacity-40',
                            'motion-safe:transition-colors',
                            mFocus,
                        )}
                        disabled={value <= 0}
                        aria-label={`Decrease ${label}`}
                    >
                        <Minus className="w-4 h-4" />
                    </button>
                    <input
                        id={id}
                        type="number"
                        inputMode="numeric"
                        min={0}
                        value={value}
                        onChange={(e) => onChange(Math.max(0, Number(e.target.value) || 0))}
                        className={cn(
                            'w-14 h-9 rounded-xl bg-white border border-gray-200 text-center text-sm font-bold tabular-nums',
                            'focus:outline-none focus:ring-2 focus:ring-red-500/20 focus:border-red-500',
                        )}
                        aria-label={`${label} quantity`}
                    />
                    <button
                        type="button"
                        onClick={() => onChange(value + 1)}
                        className={cn(
                            'w-9 h-9 rounded-xl bg-white border border-gray-200 flex items-center justify-center',
                            'text-gray-700 hover:bg-gray-50 motion-safe:transition-colors',
                            mFocus,
                        )}
                        aria-label={`Increase ${label}`}
                    >
                        <Plus className="w-4 h-4" />
                    </button>
                </div>
            </div>
            {error && (
                <p className="text-xs text-rose-600 mt-1 ml-1" role="alert">
                    {error}
                </p>
            )}
        </div>
    )
}
