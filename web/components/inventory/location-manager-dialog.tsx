'use client'

import { useState, useEffect } from 'react'
import { 
    Dialog, 
    DialogContent, 
    DialogHeader, 
    DialogTitle, 
    DialogTrigger,
    DialogDescription
} from '@/components/ui/dialog'
import { Button } from '@/components/ui/button'
import { Input } from '@/components/ui/input'
import { MapPin, Plus, Trash2, Loader2, Settings2 } from 'lucide-react'
import { getStorageLocations, addStorageLocation, deleteStorageLocation } from '@/app/actions/storage-locations'
import { toast } from 'sonner'
import { cn } from '@/lib/utils'

export function LocationManagerDialog() {
    const [locations, setLocations] = useState<any[]>([])
    const [newLocation, setNewLocation] = useState('')
    const [isLoading, setIsLoading] = useState(false)
    const [isAdding, setIsAdding] = useState(false)

    const fetchLocations = async () => {
        setIsLoading(true)
        const result = await getStorageLocations()
        if (result.success) {
            setLocations(result.data)
        }
        setIsLoading(false)
    }

    useEffect(() => {
        fetchLocations()
    }, [])

    const handleAdd = async () => {
        if (!newLocation.trim()) return
        setIsAdding(true)
        const result = await addStorageLocation(newLocation)
        if (result.success) {
            toast.success(result.message)
            setNewLocation('')
            fetchLocations()
        } else {
            toast.error(result.error)
        }
        setIsAdding(false)
    }

    const handleDelete = async (id: number, name: string) => {
        const result = await deleteStorageLocation(id)
        if (result.success) {
            toast.success(`Location "${name}" removed`)
            fetchLocations()
        } else {
            toast.error(result.error)
        }
    }

    return (
        <Dialog>
            <DialogTrigger asChild>
                <Button variant="outline" size="sm" className="h-9 gap-2 rounded-xl border-zinc-200 text-slate-600 hover:bg-slate-50 transition-all font-bold text-[12px] uppercase tracking-tight">
                    <Settings2 className="h-3.5 w-3.5" />
                    Manage Rooms
                </Button>
            </DialogTrigger>
            <DialogContent className="sm:max-w-[425px] rounded-2xl border-zinc-200 shadow-2xl">
                <DialogHeader>
                    <DialogTitle className="text-lg font-black text-slate-900 uppercase tracking-tight">Office & Warehouse Registry</DialogTitle>
                    <DialogDescription className="text-xs text-slate-400 font-bold uppercase tracking-widest">
                        Define physical rooms, shelves, or satellite offices.
                    </DialogDescription>
                </DialogHeader>

                <div className="space-y-6 py-4">
                    {/* ADD NEW LOCATION */}
                    <div className="flex gap-2">
                        <div className="relative flex-1">
                            <MapPin className="absolute left-3 top-1/2 -translate-y-1/2 h-4 w-4 text-slate-400" />
                            <Input 
                                placeholder="e.g. Warehouse 2, Shelf B..." 
                                value={newLocation}
                                onChange={(e) => setNewLocation(e.target.value)}
                                className="pl-10 h-10 rounded-xl border-zinc-200 focus:ring-blue-500/20 text-sm font-semibold"
                                onKeyDown={(e) => e.key === 'Enter' && handleAdd()}
                            />
                        </div>
                        <Button 
                            onClick={handleAdd} 
                            disabled={isAdding || !newLocation.trim()}
                            className="bg-blue-600 hover:bg-blue-700 text-white rounded-xl h-10 px-4 font-black text-[11px] uppercase tracking-widest"
                        >
                            {isAdding ? <Loader2 className="h-4 w-4 animate-spin" /> : <Plus className="h-4 w-4" />}
                        </Button>
                    </div>

                    {/* LOCATION LIST */}
                    <div className="space-y-2 max-h-[300px] overflow-y-auto pr-2 scrollbar-hide">
                        {isLoading ? (
                            <div className="flex flex-col items-center justify-center py-10 gap-3">
                                <Loader2 className="h-6 w-6 animate-spin text-blue-500" />
                                <p className="text-[10px] font-black text-slate-400 uppercase tracking-widest">Scanning Registry...</p>
                            </div>
                        ) : locations.length === 0 ? (
                            <div className="text-center py-10 bg-slate-50 rounded-2xl border-2 border-dashed border-slate-100">
                                <MapPin className="h-8 w-8 text-slate-200 mx-auto mb-2" />
                                <p className="text-[11px] font-bold text-slate-400 uppercase">No locations defined yet</p>
                            </div>
                        ) : (
                            locations.map((loc) => (
                                <div 
                                    key={loc.id} 
                                    className="group flex items-center justify-between p-3 rounded-xl bg-white border border-zinc-100 hover:border-blue-200 hover:shadow-sm transition-all duration-200"
                                >
                                    <div className="flex items-center gap-3">
                                        <div className="h-8 w-8 rounded-lg bg-blue-50 flex items-center justify-center">
                                            <MapPin className="h-4 w-4 text-blue-600" />
                                        </div>
                                        <span className="text-sm font-bold text-slate-700">{loc.location_name}</span>
                                    </div>
                                    <Button 
                                        variant="ghost" 
                                        size="icon" 
                                        onClick={() => handleDelete(loc.id, loc.location_name)}
                                        className="h-8 w-8 text-slate-300 hover:text-rose-600 hover:bg-rose-50 opacity-0 group-hover:opacity-100 transition-all rounded-lg"
                                    >
                                        <Trash2 className="h-3.5 w-3.5" />
                                    </Button>
                                </div>
                            ))
                        )}
                    </div>
                </div>

                <div className="pt-2 border-t border-zinc-100">
                    <p className="text-[9px] font-black text-slate-300 uppercase tracking-[0.2em] text-center">
                        LIGTAS Logistics Registry v1.0
                    </p>
                </div>
            </DialogContent>
        </Dialog>
    )
}
