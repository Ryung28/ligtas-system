'use client'

import { useState, useTransition } from 'react'
import { Badge } from '@/components/ui/badge'
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from '@/components/ui/select'
import { Input } from '@/components/ui/input'
import { Warehouse, Loader2, MapPin } from 'lucide-react'
import { STORAGE_LOCATION_LABELS, StorageLocation } from '@/lib/supabase'
import { updateItemLocation } from '@/src/features/catalog'
import { toast } from 'sonner'

interface EditableStorageLocationProps {
    itemId: number
    itemName: string
    currentLocation: string
    onUpdate?: () => void
}

export function EditableStorageLocation({ 
    itemId, 
    itemName, 
    currentLocation, 
    onUpdate 
}: EditableStorageLocationProps) {
    const [isEditing, setIsEditing] = useState(false)
    const [isPending, startTransition] = useTransition()
    const [selectedLocation, setSelectedLocation] = useState<string>(currentLocation)
    const [customLocation, setCustomLocation] = useState<string>('')

    const predefinedLocations = ['lower_warehouse', '2nd_floor_warehouse', 'office', 'field']
    const isCustomLocation = !predefinedLocations.includes(currentLocation)

    const handleLocationChange = (newLocation: string) => {
        if (newLocation === 'custom') {
            setSelectedLocation('custom')
            return
        }

        startTransition(async () => {
            const result = await updateItemLocation(itemId, newLocation)
            
            if (result.success) {
                toast.success(`${itemName} moved to ${getLocationLabel(newLocation)}`)
                setIsEditing(false)
                if (onUpdate) onUpdate()
            } else {
                toast.error(result.error || 'Failed to update location')
            }
        })
    }

    const handleCustomLocationSubmit = () => {
        if (!customLocation.trim()) {
            toast.error('Please enter a location')
            return
        }

        startTransition(async () => {
            const result = await updateItemLocation(itemId, customLocation.trim())
            
            if (result.success) {
                toast.success(`${itemName} moved to ${customLocation.trim()}`)
                setIsEditing(false)
                setCustomLocation('')
                if (onUpdate) onUpdate()
            } else {
                toast.error(result.error || 'Failed to update location')
            }
        })
    }

    const getLocationLabel = (location: string) => {
        if (predefinedLocations.includes(location)) {
            return STORAGE_LOCATION_LABELS[location as StorageLocation]
        }
        return location
    }

    const getLocationColor = (location: string) => {
        switch (location) {
            case 'lower_warehouse':
                return 'bg-blue-50 border-blue-200 text-blue-700 hover:bg-blue-100'
            case '2nd_floor_warehouse':
                return 'bg-purple-50 border-purple-200 text-purple-700 hover:bg-purple-100'
            case 'office':
                return 'bg-gray-50 border-gray-200 text-gray-700 hover:bg-gray-100'
            case 'field':
                return 'bg-green-50 border-green-200 text-green-700 hover:bg-green-100'
            default:
                return 'bg-orange-50 border-orange-200 text-orange-700 hover:bg-orange-100'
        }
    }

    if (isEditing) {
        return (
            <div className="flex flex-col gap-2">
                <Select 
                    value={selectedLocation} 
                    onValueChange={handleLocationChange}
                    disabled={isPending}
                >
                    <SelectTrigger className="h-7 w-[160px] text-[11px] font-semibold border-blue-300 focus:ring-2 focus:ring-blue-500/20">
                        {isPending ? (
                            <div className="flex items-center gap-1.5">
                                <Loader2 className="h-3 w-3 animate-spin" />
                                <span>Updating...</span>
                            </div>
                        ) : (
                            <SelectValue />
                        )}
                    </SelectTrigger>
                    <SelectContent 
                        className="rounded-lg border-gray-200 shadow-xl"
                        onPointerDownOutside={() => setIsEditing(false)}
                    >
                        <SelectItem value="lower_warehouse" className="text-[12px]">
                            Lower Warehouse
                        </SelectItem>
                        <SelectItem value="2nd_floor_warehouse" className="text-[12px]">
                            2nd Floor Warehouse
                        </SelectItem>
                        <SelectItem value="office" className="text-[12px]">
                            Office
                        </SelectItem>
                        <SelectItem value="field" className="text-[12px]">
                            Field
                        </SelectItem>
                        <SelectItem value="custom" className="text-[12px] font-semibold text-blue-600">
                            Custom Location...
                        </SelectItem>
                    </SelectContent>
                </Select>
                
                {selectedLocation === 'custom' && (
                    <div className="flex gap-1 animate-in fade-in slide-in-from-top-2 duration-200">
                        <Input
                            value={customLocation}
                            onChange={(e) => setCustomLocation(e.target.value)}
                            placeholder="Enter location..."
                            className="h-7 text-[11px] border-blue-300 focus:ring-2 focus:ring-blue-500/20"
                            onKeyDown={(e) => {
                                if (e.key === 'Enter') handleCustomLocationSubmit()
                                if (e.key === 'Escape') setIsEditing(false)
                            }}
                            autoFocus
                            disabled={isPending}
                        />
                        <button
                            onClick={handleCustomLocationSubmit}
                            disabled={isPending || !customLocation.trim()}
                            className="px-2 text-[10px] font-bold bg-blue-500 text-white rounded hover:bg-blue-600 disabled:opacity-50 disabled:cursor-not-allowed"
                        >
                            Save
                        </button>
                    </div>
                )}
            </div>
        )
    }

    return (
        <Badge 
            variant="outline" 
            className={`text-[11px] font-semibold whitespace-nowrap cursor-pointer transition-all ${getLocationColor(currentLocation)}`}
            onClick={() => setIsEditing(true)}
        >
            {isCustomLocation ? (
                <MapPin className="h-3 w-3 mr-1" />
            ) : (
                <Warehouse className="h-3 w-3 mr-1" />
            )}
            {getLocationLabel(currentLocation)}
        </Badge>
    )
}
