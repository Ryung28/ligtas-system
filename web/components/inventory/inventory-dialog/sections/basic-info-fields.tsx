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
    categoryId?: string
    onCategoryIdChange?: (value: string) => void
    // Variant badge props
    hasVariants?: boolean
    variantLabel?: string
    customVariant?: string
    onToggleVariants?: (enabled: boolean) => void
    onVariantLabelChange?: (value: string) => void
    onCustomVariantChange?: (value: string) => void
    itemType?: 'equipment' | 'consumable',
    parentId?: string,
    onParentIdChange?: (value: string) => void,
    parentItems?: any[],
    isLoadingParents?: boolean
}

export function BasicInfoFields({
    itemNameValue,
    onItemNameChange,
    existingItem,
    categories,
    isLoadingCategories,
    categoryId,
    onCategoryIdChange,
    hasVariants = false,
    variantLabel = '',
    customVariant = '',
    onToggleVariants,
    onVariantLabelChange,
    onCustomVariantChange,
    itemType = 'equipment',
    parentId,
    onParentIdChange,
    parentItems = [],
    isLoadingParents = false
}: BasicInfoFieldsProps) {
    // Compute the display variant text
    const displayVariant = variantLabel === 'custom' ? customVariant : variantLabel
    const showBadge = hasVariants && displayVariant
    return (
        <div className="space-y-6">
            <div className="flex items-center gap-2 pb-2 border-b border-gray-100">
                <Package className="h-4 w-4 text-blue-600" />
                <h3 className="text-sm font-black text-gray-900 uppercase tracking-tight">Basic Information</h3>
            </div>

            <div className="grid grid-cols-1 md:grid-cols-2 gap-x-8 gap-y-6">
                <div className="space-y-6">
                    {/* Item Name with Variant Badge */}
                    <div className="grid gap-2.5">
                        <Label htmlFor="name" className="text-[11px] font-black text-gray-500 uppercase tracking-widest">
                            Item Name
                        </Label>
                        <div className="relative">
                            <Package className="absolute left-3 top-1/2 -translate-y-1/2 h-4 w-4 text-gray-400 z-10" />
                            <Input
                                id="name"
                                name="name"
                                value={itemNameValue}
                                onChange={(e) => onItemNameChange(e.target.value)}
                                placeholder="e.g. Fire Extinguisher"
                                className={`h-12 pl-10 rounded-xl border-2 border-gray-100 bg-white text-sm transition-all duration-200 focus:ring-4 focus:ring-blue-500/5 focus:border-blue-500 font-bold text-gray-950 ${showBadge ? 'pr-24' : ''}`}
                                required
                            />
                            {/* Variant Badge */}
                            {showBadge && (
                                <div className={`absolute right-2 top-1/2 -translate-y-1/2 flex items-center gap-1 px-2.5 py-1 rounded-lg text-xs font-black transition-all ${
                                    itemType === 'equipment' 
                                        ? 'bg-blue-50 text-blue-700 border border-blue-100' 
                                        : 'bg-emerald-50 text-emerald-700 border border-emerald-100'
                                }`}>
                                    <span>{displayVariant}</span>
                                    {onToggleVariants && (
                                        <button
                                            type="button"
                                            onClick={() => onToggleVariants(false)}
                                            className="hover:bg-white rounded-md p-0.5 transition-colors"
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
                                className="flex items-center gap-1.5 text-[11px] text-blue-600 hover:text-blue-700 font-black uppercase tracking-wider transition-colors w-fit ml-1"
                            >
                                <Plus className="h-3 w-3" strokeWidth={3} />
                                <span>Add variant label</span>
                            </button>
                        ) : (
                            <div className="space-y-2 animate-in fade-in slide-in-from-top-2 duration-200">
                                <Select 
                                    name="variant_label" 
                                    value={variantLabel}
                                    onValueChange={onVariantLabelChange}
                                    required
                                >
                                    <SelectTrigger className="h-10 rounded-lg border-2 border-blue-50 bg-blue-50/50 text-sm font-bold text-blue-900">
                                        <SelectValue placeholder="Select variant type" />
                                    </SelectTrigger>
                                    <SelectContent className="rounded-xl border-gray-200 shadow-xl">
                                        <SelectItem value="Child" className="font-bold text-sm">Child</SelectItem>
                                        <SelectItem value="Adult" className="font-bold text-sm">Adult</SelectItem>
                                        <SelectItem value="Small" className="font-bold text-sm">Small</SelectItem>
                                        <SelectItem value="Medium" className="font-bold text-sm">Medium</SelectItem>
                                        <SelectItem value="Large" className="font-bold text-sm">Large</SelectItem>
                                        <SelectItem value="Extra Large" className="font-bold text-sm">Extra Large</SelectItem>
                                        <SelectItem value="custom" className="text-sm font-black text-blue-600">Custom label...</SelectItem>
                                    </SelectContent>
                                </Select>
                                
                                {variantLabel === 'custom' && (
                                    <Input
                                        value={customVariant}
                                        onChange={(e) => onCustomVariantChange?.(e.target.value)}
                                        placeholder="Enter custom (e.g. Teen)"
                                        className="h-10 rounded-lg border-2 border-blue-100 bg-blue-50/30 text-sm font-bold"
                                        required
                                    />
                                )}
                            </div>
                        )}
                    </div>

                    {/* Description */}
                    <div className="grid gap-2.5">
                        <Label htmlFor="description" className="text-[11px] font-black text-gray-500 uppercase tracking-widest">
                            Description
                        </Label>
                        <div className="relative">
                            <FileText className="absolute left-3 top-3 h-4 w-4 text-gray-400" />
                            <textarea
                                id="description"
                                name="description"
                                defaultValue={existingItem?.description}
                                placeholder="Model, technical specs, or specific storage notes..."
                                className="min-h-[100px] w-full pl-10 pr-4 py-2.5 rounded-xl border-2 border-gray-100 bg-white text-sm transition-all duration-200 focus:ring-4 focus:ring-blue-500/5 focus:border-blue-500 font-medium text-gray-950 resize-none"
                            />
                        </div>
                    </div>
                </div>

                <div className="space-y-6">
                    {/* Category */}
                    <div className="grid gap-2.5">
                        <Label className="text-[11px] font-black text-gray-500 uppercase tracking-widest">Category</Label>
                        <div className="relative">
                            <Tag className="absolute left-3 top-1/2 -translate-y-1/2 h-4 w-4 text-gray-400 z-10 pointer-events-none" />
                            <Select 
                                name="category" 
                                value={categoryId} 
                                onValueChange={onCategoryIdChange}
                                required
                            >
                                <SelectTrigger className="h-12 pl-10 rounded-xl border-2 border-gray-100 bg-white text-sm transition-all duration-200 focus:ring-4 focus:ring-blue-500/5 focus:border-blue-500 font-bold text-gray-950">
                                    <SelectValue placeholder={isLoadingCategories ? "Loading..." : "Assign Category"} />
                                </SelectTrigger>
                                <SelectContent className="rounded-xl border-gray-200 shadow-xl">
                                    {categories.map(c => (
                                        <SelectItem key={c} value={c} className="font-bold text-sm">{c}</SelectItem>
                                    ))}
                                </SelectContent>
                            </Select>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    )
}
