import { Package, LayoutGrid, Info, ListTree, Loader2 } from 'lucide-react'
import { resolveCategoryIcon } from '@/lib/category-icons'
import { Input } from '@/components/ui/input'
import { Label } from '@/components/ui/label'
import {
    Select,
    SelectContent,
    SelectItem,
    SelectTrigger,
    SelectValue,
} from '@/components/ui/select'
import { Checkbox } from '@/components/ui/checkbox'
import { InventoryItem } from '@/lib/supabase'

interface BasicInfoFieldsProps {
    itemNameValue: string
    onItemNameChange: (value: string) => void
    existingItem?: InventoryItem
    categories: any[]
    isLoadingCategories: boolean
    categoryId: string | null
    onCategoryIdChange: (value: string | null) => void
    hasVariants: boolean
    onToggleVariants: (value: boolean) => void
    variantLabel: string
    onVariantLabelChange: (value: string) => void
    customVariant: string
    onCustomVariantChange: (value: string) => void
    itemType: 'equipment' | 'consumable'
    parentId?: string | null
    parentItems: InventoryItem[]
    isLoadingParents?: boolean
}

export function BasicInfoFields({
    itemNameValue,
    onItemNameChange,
    categories,
    isLoadingCategories,
    categoryId,
    onCategoryIdChange,
    hasVariants,
    onToggleVariants,
    parentId,
    parentItems,
    isLoadingParents,
}: BasicInfoFieldsProps) {
    return (
        <div className="space-y-4">
            {/* Header: Identity */}
            <div className="flex items-center gap-2 mb-1">
                <Info className="h-3.5 w-3.5 text-slate-400" strokeWidth={2.5} />
                <p className="text-[10px] font-black text-slate-400 uppercase tracking-widest">Item Basics</p>
            </div>

            {/* Name & Basic Info Group */}
            <div className="space-y-3.5">
                <div className="space-y-1.5 px-0.5">
                    <Label htmlFor="name" className="text-[11px] font-bold text-slate-500 uppercase tracking-widest">
                        Item Name
                    </Label>
                    <div className="relative">
                        <Package className="absolute left-2.5 top-1/2 -translate-y-1/2 h-4 w-4 text-slate-300" strokeWidth={2.5} />
                        <Input
                            id="name"
                            placeholder="e.g. Standard Radio Pack"
                            value={itemNameValue}
                            onChange={(e) => onItemNameChange(e.target.value)}
                            className="h-10 pl-9 rounded-xl border border-slate-200 bg-white text-[14px] font-bold text-slate-900 focus:ring-4 focus:ring-blue-500/10 focus:border-blue-500 transition-all placeholder:text-slate-300"
                        />
                    </div>
                </div>

                <div className={hasVariants ? "grid grid-cols-2 gap-3 px-0.5" : "space-y-3.5 px-0.5"}>
                    <div className="space-y-1.5">
                        <Label className="text-[11px] font-bold text-slate-500 uppercase tracking-widest">Type of Item</Label>
                        <Select value={categoryId || ''} onValueChange={onCategoryIdChange}>
                            <SelectTrigger className="h-10 rounded-xl border border-slate-200 bg-white text-[13px] font-bold text-slate-900">
                                <div className="flex min-w-0 flex-1 items-center gap-2">
                                    {isLoadingCategories ? (
                                        <Loader2 className="h-3.5 w-3.5 shrink-0 animate-spin text-blue-500" />
                                    ) : (
                                        !categoryId && (
                                            <LayoutGrid className="h-3.5 w-3.5 shrink-0 text-slate-400" strokeWidth={2} />
                                        )
                                    )}
                                    <SelectValue placeholder={isLoadingCategories ? 'Loading...' : 'Select type...'} />
                                </div>
                            </SelectTrigger>
                            <SelectContent className="rounded-xl shadow-2xl bg-white border border-slate-200 z-[100]">
                                {isLoadingCategories ? (
                                    <div className="flex items-center justify-center py-4">
                                        <Loader2 className="h-5 w-5 animate-spin text-slate-400" />
                                    </div>
                                ) : categories.length === 0 ? (
                                    <div className="text-[12px] font-bold text-slate-400 text-center py-4">No types defined</div>
                                ) : (
                                    categories.map((cat) => {
                                        const CatIcon = resolveCategoryIcon(cat.category_name)
                                        return (
                                            <SelectItem
                                                key={cat.id}
                                                value={cat.id}
                                                className="cursor-pointer py-3 text-[13px] font-bold text-slate-900 focus:bg-blue-50 focus:text-blue-700"
                                            >
                                                <span className="flex items-center gap-2.5">
                                                    <CatIcon className="h-4 w-4 shrink-0 text-slate-500" strokeWidth={2} />
                                                    {cat.category_name}
                                                </span>
                                            </SelectItem>
                                        )
                                    })
                                )}
                            </SelectContent>
                        </Select>
                    </div>

                    {/* ONLY SHOW IF IT'S A VARIATION */}
                    {hasVariants && (
                        <div className="space-y-1.5 animate-in fade-in slide-in-from-right-2 duration-300">
                            <Label className="text-[11px] font-bold text-slate-500 uppercase tracking-widest">Belongs to which set?</Label>
                            <Select 
                                value={parentId || 'NONE'} 
                                onValueChange={(val) => onCategoryIdChange(val === 'NONE' ? null : val)}
                                disabled={isLoadingParents}
                            >
                                <SelectTrigger className="h-10 rounded-xl border border-slate-200 bg-white text-[13px] font-bold text-slate-900">
                                    <div className="flex items-center gap-2">
                                        <ListTree className="h-3.5 w-3.5 text-slate-400" />
                                        <SelectValue placeholder="Select main item..." />
                                    </div>
                                </SelectTrigger>
                                <SelectContent className="rounded-xl shadow-2xl bg-white border border-slate-200">
                                    <SelectItem value="NONE" className="font-bold text-[13px] py-3 text-slate-400 italic">No set (Main item)</SelectItem>
                                    {parentItems.map((item) => (
                                        <SelectItem key={item.id} value={String(item.id)} className="font-bold text-[13px] py-3 text-slate-900">
                                            {item.item_name}
                                        </SelectItem>
                                    ))}
                                </SelectContent>
                            </Select>
                        </div>
                    )}
                </div>
            </div>

            {/* Special Version (Variations) Toggle */}
            <div className="flex items-center gap-3 px-1 py-1">
                <Checkbox 
                    id="variants" 
                    checked={hasVariants} 
                    onCheckedChange={(checked) => onToggleVariants(!!checked)}
                    className="border-slate-300 rounded data-[state=checked]:bg-blue-600"
                />
                <Label htmlFor="variants" className="text-[11px] font-bold text-slate-500 uppercase tracking-widest cursor-pointer select-none">
                    This is a <span className="text-blue-600">special version</span> (e.g. Size or Color)
                </Label>
            </div>
        </div>
    )
}
