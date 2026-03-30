import { Input } from '@/components/ui/input'
import { Label } from '@/components/ui/label'
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from '@/components/ui/select'

interface VariantFieldsProps {
    itemNameValue: string
    hasVariants: boolean
    onToggleVariants: (enabled: boolean) => void
    variantLabel: string
    onVariantLabelChange: (value: string) => void
    customVariant: string
    onCustomVariantChange: (value: string) => void
}

export function VariantFields({
    itemNameValue,
    hasVariants,
    onToggleVariants,
    variantLabel,
    onVariantLabelChange,
    customVariant,
    onCustomVariantChange
}: VariantFieldsProps) {
    return (
        <div className="space-y-4">
            <div className="flex items-center justify-between">
                <div>
                    <Label className="text-xs font-bold text-gray-700 uppercase tracking-wide">
                        Item Variants
                    </Label>
                    <p className="text-xs text-gray-500 mt-1">
                        Create size or type variations (e.g., Child/Adult, Small/Large)
                    </p>
                </div>
                {hasVariants && (
                    <button
                        type="button"
                        onClick={() => onToggleVariants(false)}
                        className="text-xs text-blue-600 hover:text-blue-700 font-semibold transition-colors"
                    >
                        ✕ Remove
                    </button>
                )}
            </div>
            
            {!hasVariants ? (
                <button
                    type="button"
                    onClick={() => onToggleVariants(true)}
                    className="w-full h-12 px-4 rounded-lg border-2 border-dashed border-gray-300 bg-gray-50 hover:bg-gray-100 hover:border-gray-400 text-sm text-gray-600 font-medium transition-all"
                >
                    + Add Variant (Child, Adult, Small, etc.)
                </button>
            ) : (
                <div className="space-y-3 p-4 bg-blue-50/50 rounded-lg border-2 border-blue-100 animate-in fade-in slide-in-from-top-2 duration-200" id="variant-section">
                    <Select 
                        name="variant_label" 
                        value={variantLabel}
                        onValueChange={onVariantLabelChange}
                        required
                    >
                        <SelectTrigger className="h-11 rounded-lg border-2 border-blue-200 bg-white text-sm">
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
                            onChange={(e) => onCustomVariantChange(e.target.value)}
                            placeholder="Enter custom variant (e.g., Teen, Infant)"
                            className="h-11 rounded-lg border-2 border-blue-200 bg-white text-sm"
                            required
                        />
                    )}

                    {/* Display Name Preview */}
                    {(variantLabel && variantLabel !== 'custom') || (variantLabel === 'custom' && customVariant) ? (
                        <div className="p-3 bg-white rounded-lg border border-blue-200">
                            <p className="text-xs text-gray-500 mb-1">Display Name Preview:</p>
                            <p className="text-sm font-semibold text-gray-900">
                                {itemNameValue || 'Item Name'} ({variantLabel === 'custom' ? customVariant : variantLabel})
                            </p>
                        </div>
                    ) : null}
                </div>
            )}
        </div>
    )
}
