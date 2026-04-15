'use client'

import React from 'react'
import { Shield, Trash2, Info } from 'lucide-react'
import { Button } from '@/components/ui/button'
import { deleteRoomV3 } from '@/app/actions/chat-v3'
import { toast } from 'sonner'

interface ChatHeaderV3Props {
    title: string
    participant: {
        id: string
        full_name: string | null
        last_seen: string | null
    } | null
    presence: Record<string, any>
    roomId: string
}

export function ChatHeaderV3({ title, participant, presence, roomId }: ChatHeaderV3Props) {
    const handleDelete = async () => {
        if (!window.confirm('Erase conversation from LIGTAS logs?')) return
        const result = await deleteRoomV3(roomId)
        if (result.success) {
            toast.success('Record purged')
            window.location.reload()
        }
    }

    const isOnline = Object.keys(presence).length > 1 || 
        (participant?.last_seen && new Date().getTime() - new Date(participant.last_seen).getTime() < 1000 * 60 * 5)

    return (
        <div className="p-4 bg-white border-b border-slate-100 flex items-center justify-between sticky top-0 z-10 shadow-sm">
            <div className="flex items-center gap-3">
                <div className="h-10 w-10 rounded-2xl bg-blue-600 flex items-center justify-center text-white shadow-[0_4px_12px_rgba(37,99,235,0.3)]">
                    <Shield className="h-5 w-5" />
                </div>
                <div>
                    <h3 className="text-sm font-bold text-slate-900 tracking-tight">{title}</h3>
                    <div className="flex items-center gap-1.5 pt-0.5">
                        <span className={`relative flex h-2 w-2`}>
                            {isOnline && <span className="animate-ping absolute inline-flex h-full w-full rounded-full bg-emerald-400 opacity-75"></span>}
                            <span className={`relative inline-flex rounded-full h-2 w-2 ${isOnline ? 'bg-emerald-500' : 'bg-slate-300'}`}></span>
                        </span>
                        <span className={`text-[10px] font-black uppercase tracking-widest ${isOnline ? 'text-emerald-600' : 'text-slate-400'}`}>
                            {isOnline ? 'Online' : 'Offline'}
                        </span>
                    </div>
                </div>
            </div>

            <div className="flex items-center gap-2">
                <Button variant="ghost" size="icon" onClick={handleDelete} className="text-slate-400 hover:bg-red-50 hover:text-red-500 transition-colors rounded-xl">
                    <Trash2 className="h-4 w-4" />
                </Button>
                <Button variant="ghost" size="icon" className="text-slate-400 hover:bg-blue-50 hover:text-blue-600 rounded-xl">
                    <Info className="h-4 w-4" />
                </Button>
            </div>
        </div>
    )
}
