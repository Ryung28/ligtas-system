'use client'

import React, { useEffect } from 'react'
import { ChatSidebarV3 } from '@/components/chat-v3/chat-sidebar-v3'
import { MessengerWindowV3 } from '@/components/chat-v3/messenger-window-v3'
import { useChatRoomsV3 } from '@/hooks/use-chat-rooms-v3'
import { MessageSquare } from 'lucide-react'
import { z } from 'zod'
import { useSearchParams, useRouter } from 'next/navigation'
import { getOrCreateRoomV3 } from '@/app/actions/chat-v3'
import { toast } from 'sonner'

const roomIdSchema = z.string().uuid().nullable()

/**
 * Platinum Chat Client (V3)
 * Full isolation and optimized rendering.
 */
export default function AdminMessengerPage() {
    const searchParams = useSearchParams()
    const router = useRouter()
    const rawRoomId = searchParams.get('roomId')
    const borrowId = searchParams.get('borrowId')

    const roomId = roomIdSchema.safeParse(rawRoomId).success ? rawRoomId : null
    const { rooms, isLoading, refresh } = useChatRoomsV3()
    const activeRoom = rooms.find(r => r.id === roomId)
    const activeParticipant = activeRoom?.borrower || null

    useEffect(() => {
        if (borrowId && !roomId) {
            const establishRoom = async () => {
                const result = await getOrCreateRoomV3(parseInt(borrowId))
                if (result.success && result.data) {
                    router.replace(`/dashboard/chat?roomId=${result.data.id}`)
                } else {
                    toast.error(result.error || 'Failed to open chat')
                }
            }
            establishRoom()
        }
    }, [borrowId, roomId, router])

    const handleSelectRoom = (id: string) => {
        const params = new URLSearchParams()
        params.set('roomId', id)
        router.push(`/dashboard/chat?${params.toString()}`)
    }

    return (
        <div className="flex bg-white h-[calc(100vh-140px)] 14in:h-[calc(100vh-160px)] xl:h-[calc(100vh-180px)] rounded-3xl shadow-2xl overflow-hidden border border-slate-200/50 select-none animate-in fade-in duration-200">
            <ChatSidebarV3 
                selectedRoomId={roomId} 
                onSelectRoom={handleSelectRoom} 
                rooms={rooms}
                isLoading={isLoading}
                refresh={refresh}
            />

            <div className="flex-1 flex flex-col bg-slate-50/20">
                {roomId ? (
                    <MessengerWindowV3
                        key={roomId}
                        roomId={roomId}
                        title={activeParticipant?.full_name || 'ResQTrack Operations'}
                        participant={activeParticipant}
                    />
                ) : (
                    <div className="flex-1 flex flex-col items-center justify-center p-12 text-center bg-gradient-to-b from-white/0 to-slate-50/30">
                        {/* 🛡️ TACTICAL ICON — Glassmorphism Effect */}
                        <div className="relative group mb-8">
                            <div className="absolute -inset-4 bg-blue-500/10 rounded-full blur-2xl group-hover:bg-blue-500/20 transition-all duration-700" />
                            <div className="relative h-24 w-24 bg-white/40 backdrop-blur-md border border-white/50 rounded-3xl shadow-[0_8px_32px_rgba(0,0,0,0.04)] flex items-center justify-center text-blue-600 transition-transform duration-500 hover:scale-105">
                                <MessageSquare className="h-10 w-10 stroke-[1.25px]" />
                            </div>
                        </div>

                        {/* 📝 CONTENT */}
                        <h2 className="text-2xl font-bold text-slate-900 tracking-tight mb-2">ResQTrack Message</h2>
                        <p className="text-slate-500 font-medium max-w-[280px] leading-relaxed mb-8">
                            Select a conversation to begin operational coordination and dispatch.
                        </p>

                    </div>
                )}
            </div>
        </div>
    )
}
