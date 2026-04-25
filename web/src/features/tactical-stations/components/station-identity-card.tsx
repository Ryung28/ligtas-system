'use client'

import { QRCodeSVG } from 'qrcode.react'
import { Download } from 'lucide-react'
import { Button } from '@/components/ui/button'
import type { Station } from '../types'

interface StationIdentityCardProps {
    station: Station
    onDownload: () => void
}

export function StationIdentityCard({ station, onDownload }: StationIdentityCardProps) {
    return (
        <div className="flex items-center gap-3 bg-slate-50 p-3 rounded-xl border border-slate-100 h-[100px]">
            <div className="bg-white p-1 rounded-lg border border-slate-200 shadow-sm shrink-0 h-full aspect-square flex items-center justify-center">
                <QRCodeSVG
                    id={`station-qr-${station.id}`}
                    value={`ligtas://station/${station.station_code || station.id}?name=${encodeURIComponent(station.station_name || station.location_name)}`}
                    size={80}
                    includeMargin={false}
                />
            </div>
            <div className="flex-1 min-w-0 flex flex-col justify-between h-full py-0.5">
                <div>
                    <p className="text-[10px] font-black text-blue-600 uppercase tracking-widest leading-none">
                        IDENTITY STICKER
                    </p>
                    <p className="text-[14px] font-black text-slate-900 truncate uppercase italic mt-1 leading-none">
                        {station.station_code}
                    </p>
                    <p className="text-[9px] font-bold text-slate-400 mt-1 uppercase leading-none opacity-60">
                        {station.location_name.replace(/_/g, ' ')}
                    </p>
                </div>
                <Button 
                    size="sm" 
                    variant="outline"
                    onClick={onDownload}
                    className="h-7 border-slate-200 text-slate-600 font-bold text-[9px] uppercase tracking-widest gap-2 bg-white hover:bg-slate-50 transition-all active:scale-95"
                >
                    <Download className="h-3 w-3" />
                    Download Label
                </Button>
            </div>
        </div>
    )
}
