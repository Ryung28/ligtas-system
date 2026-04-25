'use client'

import { QRCodeSVG } from 'qrcode.react'
import type { Station } from '../types'

interface PrintLabelSheetProps {
    stations: Station[]
}

export function PrintLabelSheet({ stations }: PrintLabelSheetProps) {
    return (
        <div className="hidden print:block fixed inset-0 bg-white z-[9999]">
            {stations.map((stn) => (
                <div 
                    key={stn.id} 
                    className="w-full h-screen flex flex-col items-center justify-center p-20 page-break-after-always"
                    style={{ breakAfter: 'page' }}
                >
                    {/* High-fidelity Station Identity Sticker (matching mobile/web UI) */}
                    <div className="w-[500px] border-[3px] border-slate-900 rounded-[40px] p-12 flex flex-col items-center space-y-10">
                        <div className="bg-white p-4 rounded-3xl border-2 border-slate-100 shadow-sm">
                            <QRCodeSVG
                                value={`ligtas://station/${stn.station_code || stn.id}?name=${encodeURIComponent(stn.station_name || stn.location_name)}`}
                                size={280}
                                includeMargin={false}
                                level="H"
                            />
                        </div>
                        
                        <div className="text-center space-y-4 w-full">
                            <div className="space-y-1">
                                <p className="text-[14px] font-black text-blue-600 uppercase tracking-[0.3em]">
                                    STATION IDENTITY
                                </p>
                                <h1 className="text-[64px] font-black text-slate-900 uppercase italic tracking-tighter leading-none">
                                    {stn.station_code || 'PENDING'}
                                </h1>
                            </div>
                            
                            <div className="h-px w-full bg-slate-200" />
                            
                            <div className="pt-4">
                                <p className="text-[12px] font-bold text-slate-400 uppercase tracking-widest mb-2 opacity-60">
                                    LOCATION / ASSIGNMENT
                                </p>
                                <p className="text-[24px] font-black text-slate-800 uppercase italic">
                                    {stn.station_name || stn.location_name.replace(/_/g, ' ')}
                                </p>
                            </div>
                        </div>

                        <div className="pt-10 w-full flex items-center justify-between border-t border-slate-100 pt-8 mt-4">
                            <div className="flex items-center gap-2">
                                <div className="h-3 w-3 rounded-full bg-emerald-500" />
                                <span className="text-[10px] font-black text-slate-400 uppercase tracking-[0.2em]">OPERATIONAL</span>
                            </div>
                            <span className="text-[10px] font-black text-slate-400 uppercase tracking-[0.2em]">LIGTAS TERMINAL SYNC</span>
                        </div>
                    </div>
                </div>
            ))}
            
            <style jsx global>{`
                @media print {
                    @page {
                        size: portrait;
                        margin: 0;
                    }
                    body * {
                        visibility: hidden;
                    }
                    .print-label-sheet, .print-label-sheet * {
                        visibility: visible;
                    }
                    .print-label-sheet {
                        position: absolute;
                        left: 0;
                        top: 0;
                    }
                }
            `}</style>
        </div>
    )
}
