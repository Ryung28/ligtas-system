'use client'

import React, { useState, useMemo, useEffect } from 'react'
import { useSearchParams, useRouter } from 'next/navigation'
import { useChatRoomsV3 } from '@/hooks/use-chat-rooms-v3'
import { MessengerWindowV3 } from '@/components/chat-v3/messenger-window-v3'
import { MobileHeader } from '@/components/mobile/mobile-header'
import { Shield, ChevronRight, MessageSquare, ChevronLeft, Search } from 'lucide-react'
import { cn } from '@/lib/utils'
import { formatDistanceToNow } from 'date-fns'
import { getOrCreateRoomV3 } from '@/app/actions/chat-v3'
import { toast } from 'sonner'

/**
 * 💬 MOBILE CHAT CLIENT (V3)
 * Dual-mode view: Inbox (Rooms) or active Messenger.
 */
export default function MobileChatClient() {
    const searchParams = useSearchParams()
    const router = useRouter()
    const roomId = searchParams.get('roomId')
    const borrowId = searchParams.get('borrowId')
    
    const { rooms, isLoading, refresh } = useChatRoomsV3()
    const activeRoom = rooms.find(r => r.id === roomId)
    const activeParticipant = activeRoom?.borrower || null

    const [searchTerm, setSearchTerm] = useState('')

    // ── Deep Link Handler ──
    useEffect(() => {
        if (borrowId && !roomId) {
            const establishRoom = async () => {
                const result = await getOrCreateRoomV3(parseInt(borrowId))
                if (result.success && result.data) {
                    const params = new URLSearchParams(searchParams)
                    params.delete('borrowId')
                    params.set('roomId', result.data.id)
                    router.replace(`/m/chat?${params.toString()}`)
                } else {
                    toast.error('Failed to open communication channel')
                }
            }
            establishRoom()
        }
    }, [borrowId, roomId, router, searchParams])

    // ── Search Logic ──
    const filteredRooms = useMemo(() => {
        if (!searchTerm) return rooms
        const lower = searchTerm.toLowerCase()
        return rooms.filter(r => 
            r.borrower?.full_name?.toLowerCase().includes(lower) ||
            r.lastMessage?.content?.toLowerCase().includes(lower)
        )
    }, [rooms, searchTerm])

    const getInitials = (name: string | null) => {
        if (!name) return '?'
        return name.split(' ').map(n => n[0]).join('').toUpperCase().substring(0, 2)
    }

    const handleSelectRoom = (id: string) => {
        const params = new URLSearchParams(searchParams)
        params.set('roomId', id)
        router.push(`/m/chat?${params.toString()}`)
    }

    const handleBackToInbox = () => {
        const params = new URLSearchParams(searchParams)
        params.delete('roomId')
        router.push(`/m/chat?${params.toString()}`)
    }

    // 🏛️ CHAT VIEW: Active conversation
    if (roomId && activeRoom) {
        return (
            <div className="fixed inset-0 bg-white z-[60] flex flex-col pt-[env(safe-area-inset-top)] animate-in slide-in-from-right duration-200">
                <div className="px-4 py-3 border-b border-gray-100 flex items-center gap-3 bg-white/90 backdrop-blur-md sticky top-0">
                    <button 
                        onClick={handleBackToInbox}
                        className="p-2 -ml-2 text-gray-700 active:scale-95"
                    >
                        <ChevronLeft className="w-6 h-6" />
                    </button>
                    <div className="flex-1 min-w-0">
                        <h3 className="text-sm font-bold text-gray-900 truncate">
                            {activeParticipant?.full_name || 'Operations'}
                        </h3>
                        <p className="text-[10px] font-bold text-gray-400 uppercase tracking-widest">
                            {activeParticipant?.role || 'ResQTrack STAFF'}
                        </p>
                    </div>
                </div>

                <div className="flex-1 overflow-hidden">
                    <MessengerWindowV3 
                        roomId={roomId}
                        title={activeParticipant?.full_name || 'Operations'}
                        participant={activeParticipant}
                    />
                </div>
            </div>
        )
    }

    // 🏛️ INBOX VIEW: Room List
    return (
        <div className="space-y-4">
            <MobileHeader title="Chat" onRefresh={() => refresh()} isLoading={isLoading} />

            {/* Search Bar */}
            <div className="px-1">
                <div className="relative">
                    <Search className="absolute left-4 top-1/2 -translate-y-1/2 w-4 h-4 text-gray-400" />
                    <input 
                        type="search"
                        placeholder="Search messages..."
                        value={searchTerm}
                        onChange={(e) => setSearchTerm(e.target.value)}
                        className="w-full h-12 pl-11 pr-4 bg-gray-50 border-none rounded-2xl text-sm focus:ring-2 focus:ring-red-500/20 transition-all placeholder:text-gray-400"
                    />
                </div>
            </div>

            <div className="space-y-2">
                {filteredRooms.length > 0 ? (
                    filteredRooms.map((room) => (
                        <button
                            key={room.id}
                            onClick={() => handleSelectRoom(room.id)}
                            className="w-full flex items-center gap-4 p-4 bg-white rounded-2xl border border-gray-100 shadow-sm active:bg-gray-50 transition-colors text-left relative"
                        >
                            <div className="w-12 h-12 rounded-xl bg-gray-900 flex items-center justify-center text-white shrink-0 shadow-sm font-black text-xs tracking-tighter">
                                {getInitials(room.borrower?.full_name ?? null)}
                            </div>
                            <div className="flex-1 min-w-0">
                                <div className="flex items-center justify-between gap-2 mb-0.5">
                                    <p className="font-bold text-gray-900 truncate">
                                        {room.borrower?.full_name || 'Field Operator'}
                                    </p>
                                    <span className="text-[10px] font-medium text-gray-400">
                                        {room.lastMessage?.created_at ? formatDistanceToNow(new Date(room.lastMessage.created_at), { addSuffix: false }) : ''}
                                    </span>
                                </div>
                                <p className="text-xs text-gray-500 truncate italic pr-2">
                                    {room.lastMessage?.content || 'Open conversation...'}
                                </p>
                            </div>
                            {room.unread_count > 0 && (
                                <div className="absolute top-3 left-3 w-4 h-4 bg-red-600 rounded-full border-2 border-white flex items-center justify-center">
                                    <span className="text-[8px] font-black text-white">{room.unread_count}</span>
                                </div>
                            )}
                            <ChevronRight className="w-5 h-5 text-gray-300" />
                        </button>
                    ))
                ) : (
                    <div className="py-20 flex flex-col items-center justify-center text-center px-6">
                        <div className="w-16 h-16 bg-gray-50 rounded-2xl flex items-center justify-center text-gray-300 mb-4 border border-gray-100">
                            <MessageSquare className="w-8 h-8" />
                        </div>
                        <h3 className="text-lg font-bold text-gray-900">
                            {searchTerm ? 'No results found' : 'Quiet Sector'}
                        </h3>
                        <p className="text-xs text-gray-500 mt-2">
                            {searchTerm ? `No messages matching "${searchTerm}"` : 'No active communications.'}
                        </p>
                    </div>
                )}
            </div>
        </div>
    )
}

