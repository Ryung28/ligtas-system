import { Warehouse, Loader2, Trash2, X } from 'lucide-react'
import { Input } from '@/components/ui/input'
import { Label } from '@/components/ui/label'
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from '@/components/ui/select'
import { toast } from 'sonner'

interface StorageLocationSelectProps {
    storageLocation: string
    onStorageLocationChange: (value: string) => void
    customLocation: string
    onCustomLocationChange: (value: string) => void
    savedLocations: any[]
    isLoadingLocations: boolean
    isSavingLocation: boolean
    onSaveLocation: () => Promise<void>
    onDeleteLocation: (id: number) => Promise<void>
}

export function StorageLocationSelect({
    storageLocation,
    onStorageLocationChange,
    customLocation,
    onCustomLocationChange,
    savedLocations,
    isLoadingLocations,
    isSavingLocation,
    onSaveLocation,
    onDeleteLocation
}: StorageLocationSelectProps) {
    return (
        <div className="grid gap-2">
            <Label className="text-xs font-bold text-gray-700 uppercase tracking-wide">Storage Location</Label>
            <div className="relative">
                <Warehouse className="absolute left-3 top-1/2 -translate-y-1/2 h-4 w-4 text-gray-400 z-10 pointer-events-none" />
                <Select 
                    name="storage_location" 
                    value={storageLocation}
                    onValueChange={onStorageLocationChange}
                >
                    <SelectTrigger className="h-11 pl-10 rounded-lg border-2 border-gray-200 bg-white text-sm transition-all duration-200 focus:ring-2 focus:ring-blue-500/20 focus:border-blue-500 hover:border-gray-300">
                        <SelectValue placeholder="Select location" />
                    </SelectTrigger>
                    <SelectContent className="rounded-xl border-gray-200 shadow-xl">
                        {isLoadingLocations ? (
                            <div className="p-2 text-center text-xs text-gray-500">Loading locations...</div>
                        ) : (
                            <>
                                {savedLocations.map(loc => {
                                    const locName = loc.location_name;
                                    const value = loc.id?.toString() || locName;
                                    return (
                                        <div key={value} className="flex items-center justify-between group px-1">
                                            <SelectItem value={value} className="text-sm flex-1">
                                                {locName}
                                            </SelectItem>
                                            {loc.id && (
                                                <button
                                                    type="button"
                                                    onClick={(e) => {
                                                        e.stopPropagation();
                                                        e.preventDefault();
                                                        onDeleteLocation(loc.id);
                                                    }}
                                                    className="opacity-0 group-hover:opacity-100 p-1.5 hover:bg-red-50 text-gray-400 hover:text-red-500 rounded-md transition-all mr-1"
                                                    title="Remove from registry"
                                                >
                                                    <Trash2 className="h-3 w-3" />
                                                </button>
                                            )}
                                        </div>
                                    );
                                })}
                                <SelectItem value="custom" className="text-sm font-semibold text-blue-600">
                                    + Custom Location...
                                </SelectItem>
                            </>
                        )}
                    </SelectContent>
                </Select>
            </div>
            {storageLocation === 'custom' && (
                <div className="relative animate-in fade-in slide-in-from-top-2 duration-200 space-y-2">
                    <div className="flex gap-2">
                        <Input
                            value={customLocation}
                            onChange={(e) => onCustomLocationChange(e.target.value)}
                            placeholder="e.g. Conference Room, Vehicle Bay, Storage Shed..."
                            className="h-11 pl-3 rounded-lg border-2 border-blue-200 bg-blue-50/50 text-sm transition-all duration-200 focus:ring-2 focus:ring-blue-500/20 focus:border-blue-500 focus:shadow-[0_4px_20px_rgba(59,130,246,0.15)] hover:border-blue-300 flex-1"
                            onKeyDown={(e) => {
                                if (e.key === 'Enter') {
                                    e.preventDefault()
                                    const form = e.currentTarget.form
                                    if (form) {
                                        const submitButton = form.querySelector('button[type="submit"]') as HTMLButtonElement
                                        submitButton?.click()
                                    }
                                }
                            }}
                            required
                        />
                        <button
                            type="button"
                            onClick={onSaveLocation}
                            disabled={isSavingLocation || !customLocation.trim()}
                            className="px-4 h-11 bg-emerald-500 hover:bg-emerald-600 disabled:opacity-50 disabled:cursor-not-allowed text-white text-sm font-semibold rounded-lg transition-all"
                        >
                            {isSavingLocation ? <Loader2 className="h-4 w-4 animate-spin" /> : 'Save'}
                        </button>
                    </div>
                    <p className="text-[11px] text-gray-500">
                        Enter a specific location for scattered items • Press Enter to save item • Click Save to add to list
                    </p>
                </div>
            )}
        </div>
    )
}
