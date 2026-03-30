import { Package, ShoppingBag } from 'lucide-react'

interface ItemTypeSelectorProps {
    itemType: 'equipment' | 'consumable'
    onItemTypeChange: (value: 'equipment' | 'consumable') => void
}

export function ItemTypeSelector({ itemType, onItemTypeChange }: ItemTypeSelectorProps) {
    return (
        <div className="space-y-3">
            <div>
                <h3 className="text-sm font-bold text-gray-900 mb-1">What type of item?</h3>
                <p className="text-xs text-gray-500">This determines which fields you&apos;ll need to fill</p>
            </div>
            
            <div className="grid grid-cols-2 gap-3">
                {/* Equipment Card */}
                <button
                    type="button"
                    onClick={() => onItemTypeChange('equipment')}
                    className={`
                        relative p-4 rounded-xl border-2 transition-all duration-200
                        ${itemType === 'equipment' 
                            ? 'border-blue-500 bg-blue-50 shadow-lg shadow-blue-100' 
                            : 'border-gray-200 bg-white hover:border-gray-300 hover:bg-gray-50'
                        }
                    `}
                >
                    <div className="flex flex-col items-center gap-2 text-center">
                        <div className={`
                            p-2 rounded-lg transition-colors
                            ${itemType === 'equipment' ? 'bg-blue-500' : 'bg-gray-200'}
                        `}>
                            <Package className={`h-5 w-5 ${itemType === 'equipment' ? 'text-white' : 'text-gray-600'}`} />
                        </div>
                        <div>
                            <p className={`text-sm font-bold ${itemType === 'equipment' ? 'text-blue-900' : 'text-gray-700'}`}>
                                Equipment
                            </p>
                            <p className="text-xs text-gray-500 mt-0.5">Returnable items</p>
                        </div>
                    </div>
                    {itemType === 'equipment' && (
                        <div className="absolute top-2 right-2">
                            <div className="h-5 w-5 rounded-full bg-blue-500 flex items-center justify-center">
                                <svg className="h-3 w-3 text-white" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                                    <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={3} d="M5 13l4 4L19 7" />
                                </svg>
                            </div>
                        </div>
                    )}
                </button>

                {/* Consumable Card */}
                <button
                    type="button"
                    onClick={() => onItemTypeChange('consumable')}
                    className={`
                        relative p-4 rounded-xl border-2 transition-all duration-200
                        ${itemType === 'consumable' 
                            ? 'border-emerald-500 bg-emerald-50 shadow-lg shadow-emerald-100' 
                            : 'border-gray-200 bg-white hover:border-gray-300 hover:bg-gray-50'
                        }
                    `}
                >
                    <div className="flex flex-col items-center gap-2 text-center">
                        <div className={`
                            p-2 rounded-lg transition-colors
                            ${itemType === 'consumable' ? 'bg-emerald-500' : 'bg-gray-200'}
                        `}>
                            <ShoppingBag className={`h-5 w-5 ${itemType === 'consumable' ? 'text-white' : 'text-gray-600'}`} />
                        </div>
                        <div>
                            <p className={`text-sm font-bold ${itemType === 'consumable' ? 'text-emerald-900' : 'text-gray-700'}`}>
                                Consumable
                            </p>
                            <p className="text-xs text-gray-500 mt-0.5">One-time use</p>
                        </div>
                    </div>
                    {itemType === 'consumable' && (
                        <div className="absolute top-2 right-2">
                            <div className="h-5 w-5 rounded-full bg-emerald-500 flex items-center justify-center">
                                <svg className="h-3 w-3 text-white" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                                    <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={3} d="M5 13l4 4L19 7" />
                                </svg>
                            </div>
                        </div>
                    )}
                </button>
            </div>

            {/* Hidden input for form submission */}
            <input type="hidden" name="item_type" value={itemType} />
        </div>
    )
}
