'use client'

import { useState } from 'react'
import { useRouter } from 'next/navigation'
import { 
    Sheet, 
    SheetContent, 
    SheetDescription, 
    SheetHeader, 
    SheetTitle, 
    SheetTrigger 
} from '@/components/ui/sheet'
import { Button } from '@/components/ui/button'
import { FileText, QrCode, Monitor } from 'lucide-react'
import { TacticalStationsHub } from './tactical-stations-hub'
import { InventoryItem } from '@/lib/supabase'
import Link from 'next/link'

interface TacticalStationDialogProps {
    items: InventoryItem[]
}

export function TacticalStationDialog({ items }: TacticalStationDialogProps) {
    const [isOpen, setIsOpen] = useState(false)
    const router = useRouter()

    const handleLaunchBuilder = () => {
        setIsOpen(false)
        router.push('/dashboard/inventory/tactical-stations')
    }

    return (
        <Sheet open={isOpen} onOpenChange={setIsOpen}>
            <SheetTrigger asChild>
                <Button 
                    variant="outline" 
                    size="sm" 
                    className="h-9 border-gray-200 text-gray-700 hover:bg-gray-50 text-[13px] font-medium transition-colors rounded-lg px-3"
                >
                    <QrCode className="h-3.5 w-3.5 mr-1.5" />
                    Station Hub
                </Button>
            </SheetTrigger>
            <SheetContent side="right" className="w-[100vw] sm:max-w-[90vw] p-0 border-l-0 bg-[#f8fafc] flex flex-col">
                <div className="py-3 px-6 bg-white border-b border-slate-200 flex items-center justify-between shrink-0">
                    <div>
                        <SheetHeader className="text-left">
                            <SheetTitle className="text-lg font-black italic uppercase tracking-tight text-slate-900 leading-none">
                                Storage Hub
                            </SheetTitle>
                            <SheetDescription className="text-[10px] font-bold text-slate-400 uppercase tracking-widest leading-none mt-0.5">
                                Station Supply Overview
                            </SheetDescription>
                        </SheetHeader>
                    </div>
                    <Button 
                        onClick={handleLaunchBuilder}
                        className="bg-blue-600 hover:bg-blue-700 text-white font-bold text-xs uppercase tracking-widest gap-2 rounded-xl h-10 px-6 shadow-lg shadow-blue-200"
                    >
                        <Monitor className="h-4 w-4" />
                        Manage Stations
                    </Button>
                </div>
                <div className="flex-1 overflow-y-auto">
                    <TacticalStationsHub items={items} />
                </div>
            </SheetContent>
        </Sheet>
    )
}
