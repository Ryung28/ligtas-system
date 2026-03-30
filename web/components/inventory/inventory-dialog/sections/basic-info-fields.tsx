import { Package, FileText, Tag, X, Plus } from 'lucide-react'
import { Input } from '@/components/ui/input'
import { Label } from '@/components/ui/label'
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from '@/components/ui/select'
import { InventoryItem } from '@/lib/supabase'

interface BasicInfoFieldsProps {
    itemNameValue: string
    onItemNameChange: (value: string) => void
    existingItem?: InventoryItem
    categories: string[]
    isLoadingCategories: boolean
    // Variant badge props
    hasVariants?: boolean
    variantLabel?: string
    customVariant?: string
    onToggleVariants?: (enabled: boolean) => void
    onVariantLabelChange?: (value: string) => void
    onCustomVariantChange?: (value: string) => void
    itemType?: 'equipment' | 'consumable'
}

export function BasicInfoFields({
    itemNameValue,
    onItemNameChange,
    existingItem,
    categories,
    isLoadingCategories,
    hasVariants = false,
    variantLabel = '',
    customVariant = '',
    onToggleVariants,
    onVariantLabelChange,
    onCustomVariantChange,
    itemType = 'equipment'
}: BasicInfoFieldsProps) {
    // Compute the display variant text
    const displayVariant = variantLabel === 'custom' ? customVariant : variantLabel
    const showBadge = hasVariants && displayVariant
    return (
        <div className="space-y-4">
            <div className="flex items-center gap-2 pb-2 border-b border-gray-200">
                <Package className="h-4 w-4 text-blue-600" />
                <h3 className="text-sm font-bold text-gray-900 uppercase tracking-wide">Basic Information</h3>
            </div>

            {/* Item Name with Variant Badge */}
            <div className="grid gap-2">
                <Label htmlFor="name" className="text-xs font-bold text-gray-700 uppercase tracking-wide">
                    Item Name
                </Label>
                <div className="relative">
                    <Package className="absolute left-3 top-1/2 -translate-y-1/2 h-4 w-4 text-gray-400 z-10" />
                    <Input
                        id="name"
                        name="name"
                        value={itemNameValue}
                        onChange={(e) => onItemNameChange(e.target.value)}
                        placeholder="e.g. Fire Extinguisher, Canned Goods"
                        className={`h-11 pl-10 rounded-lg border-2 border-gray-200 bg-white text-sm transition-all duration-200 focus:ring-2 focus:ring-blue-500/20 focus:border-blue-500 focus:shadow-[0_4px_20px_rgba(59,130,246,0.15)] hover:border-gray-300 ${showBadge ? 'pr-24' : ''}`}
                        required
                    />
                    {/* Variant Badge */}
                    {showBadge && (
                        <div className={`absolute right-2 top-1/2 -translate-y-1/2 flex items-center gap-1 px-2 py-1 rounded-md text-xs font-semibold transition-all ${
                            itemType === 'equipment' 
                                ? 'bg-blue-100 text-blue-700 border border-blue-200' 
                                : 'bg-emerald-100 text-emerald-700 border border-emerald-200'
                        }`}>
                            <span>{displayVariant}</span>
                            {onToggleVariants && (
                                <button
                                    type="button"
                                    onClick={() => onToggleVariants(false)}
                                    className={`hover:bg-white/50 rounded-full p-0.5 transition-colors ${
                                        itemType === 'equipment' ? 'hover:text-blue-900' : 'hover:text-emerald-900'
                                    }`}
                                    title="Remove variant"
                                >
                                    <X className="h-3 w-3" />
                                </button>
                            )}
                        </div>
                    )}
                </div>
                
                {/* Variant Controls - Inline below Item Name */}
                {!hasVariants ? (
                    <button
                        type="button"
                        onClick={() => onToggleVariants?.(true)}
                        className="flex items-center gap-1.5 text-xs text-blue-600 hover:text-blue-700 font-semibold transition-colors w-fit"
                    >
                        <Plus className="h-3 w-3" />
                        <span>Add variant (Child, Adult, etc.)</span>
                    </button>
                ) : (
                    <div className="space-y-2 animate-in fade-in slide-in-from-top-2 duration-200">
                        <Select 
                            name="variant_label" 
                            value={variantLabel}
                            onValueChange={onVariantLabelChange}
                            required
                        >
                            <SelectTrigger className="h-10 rounded-lg border-2 border-blue-200 bg-blue-50/50 text-sm">
                                <SelectValue placeholder="Select variant type" />
                            </SelectTrigger>
                            <SelectContent className="rounded-xl border-gray-200 shadow-xl">
                                <SelectItem value="Child" className="text-sm">Child</SelectItem>
                                <SelectItem value="Adult" className="text-sm">Adult</SelectItem>
                                <SelectItem value="Small" className="text-sm">Small</SelectItem>
                                <SelectItem value="Medium" className="text-sm">Medium</SelectItem>
                                <SelectItem value="Large" className="text-sm">Large</SelectItem>
                                <SelectItem value="Extra Large" className="text-sm">Extra Large</SelectItem>
                                <SelectItem value="custom" className="text-sm font-semibold text-blue-600">Custom...</SelectItem>
                            </SelectContent>
                        </Select>
                        
                        {variantLabel === 'custom' && (
                            <Input
                                value={customVariant}
                                onChange={(e) => onCustomVariantChange?.(e.target.value)}
                                placeholder="Enter custom variant (e.g., Teen, Infant)"
                                className="h-10 rounded-lg border-2 border-blue-200 bg-blue-50/50 text-sm"
                                required
                            />
                        )}
                    </div>
                )}
            </div>

            {/* Description */}
            <div className="grid gap-2">
                <Label htmlFor="description" className="text-xs font-bold text-gray-700 uppercase tracking-wide">
                    Description
                </Label>
                <div className="relative">
                    <FileText className="absolute left-3 top-1/2 -translate-y-1/2 h-4 w-4 text-gray-400" />
                    <Input
                        id="description"
                        name="description"
                        defaultValue={existingItem?.description}
                        placeholder="Model, specifications, notes..."
                        className="h-11 pl-10 rounded-lg border-2 border-gray-200 bg-white text-sm transition-all duration-200 focus:ring-2 focus:ring-blue-500/20 focus:border-blue-500 focus:shadow-[0_4px_20px_rgba(59,130,246,0.15)] hover:border-gray-300"
                    />
                </div>
            </div>

            {/* Category */}
            <div className="grid gap-2">
                <Label className="text-xs font-bold text-gray-700 uppercase tracking-wide">Category</Label>
                <div className="relative">
                    <Tag className="absolute left-3 top-1/2 -translate-y-1/2 h-4 w-4 text-gray-400 z-10 pointer-events-none" />
                    <Select name="category" defaultValue={existingItem?.category || categories[0]} disabled={isLoadingCategories}>
                        <SelectTrigger className="h-11 pl-10 rounded-lg border-2 border-gray-200 bg-white text-sm transition-all duration-200 focus:ring-2 focus:ring-blue-500/20 focus:border-blue-500 hover:border-gray-300">
                            <SelectValue placeholder={isLoadingCategories ? "Loading..." : "Select category"} />
                        </SelectTrigger>
                        <SelectContent className="rounded-xl border-gray-200 shadow-xl">
                            {categories.map(c => (
                                <SelectItem key={c} value={c} className="text-sm">{c}</SelectItem>
                            ))}
                        </SelectContent>
                    </Select>
                </div>
            </div>
        </div>
    )
}
