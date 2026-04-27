'use client'

import React from 'react'
import { Search, MessageSquare, Clock, CheckCheck, Mail, MailOpen } from 'lucide-react'
import { ChatRoomV3 } from '@/hooks/use-chat-rooms-v3'
import { markAsReadV3, markAllAsReadV3, markRoomAsUnreadV3 } from '@/app/actions/chat-v3'
import { toast } from 'sonner'
import { ChatMessageTimestampV3 } from './_components/chat-message-timestamp-v3'
import { cn } from '@/lib/utils'
import { Skeleton } from '@/components/ui/skeleton'

interface ChatSidebarV3Props {
    selectedRoomId: string | null
    onSelectRoom: (roomId: string) => void
    rooms: ChatRoomV3[]
    isLoading: boolean
    refresh: () => void
}

/**
 * Chat Sidebar V3 (2026 Gold Standard)
 * Full isolation and optimized search.
 */
export function ChatSidebarV3({ selectedRoomId, onSelectRoom, rooms, isLoading, refresh }: ChatSidebarV3Props) {
    const [searchTerm, setSearchTerm] = React.useState('')

    const filteredRooms = React.useMemo(() => {
        return rooms.filter(room => {
            const searchLower = searchTerm.toLowerCase();
            const fullName = room.borrower?.full_name?.toLowerCase() || '';
            const messageContent = room.lastMessage?.content?.toLowerCase() || '';
            const requestId = room.borrow_request_id?.toString() || '';

            return fullName.includes(searchLower) ||
                   messageContent.includes(searchLower) ||
                   requestId.includes(searchTerm);
        })
    }, [rooms, searchTerm])

    const getInitials = (name: string | null) => {
        if (!name) return '?'
        return name.split(' ').map(n => n[0]).join('').toUpperCase().substring(0, 2)
    }

    if (isLoading) {
        return (
            <div className="flex flex-col h-full border-r border-slate-200 w-80 bg-white">
                <div className="p-4 border-b border-slate-100 flex items-center gap-2">
                    <Skeleton className="h-10 flex-1 rounded-xl" />
                    <Skeleton className="h-10 w-10 rounded-xl" />
                </div>
                <div className="flex-1 overflow-y-auto p-2 space-y-2">
                    {[1, 2, 3, 4, 5].map(i => (
                        <div key={i} className="flex gap-3 p-3">
                            <Skeleton className="h-12 w-12 rounded-full flex-shrink-0" />
                            <div className="flex-1 space-y-2">
                                <Skeleton className="h-4 w-2/3" />
                                <Skeleton className="h-3 w-full" />
                            </div>
                        </div>
                    ))}
                </div>
            </div>
        )
    }

    return (
        <div className="flex flex-col h-full border-r border-slate-200 w-80 bg-white select-none">
            <div className="p-4 border-b border-slate-100 bg-white/50 backdrop-blur-sm sticky top-0 z-10 space-y-3">
                <div className="flex items-center justify-between">
                    <h2 className="text-xs font-bold text-slate-400 uppercase tracking-widest">Messages (V3)</h2>
                    <div className="flex items-center gap-1">
                        <button 
                            onClick={async () => {
                                const res = await markAllAsReadV3()
                                if (res.success) {
                                    toast.success('All messages marked as read')
                                    refresh()
                                }
                            }} 
                            title="Mark all as read"
                            className="p-1.5 hover:bg-blue-50 rounded-lg text-slate-400 hover:text-blue-600 transition-colors"
                        >
                            <CheckCheck className="h-3.5 w-3.5" />
                        </button>
                        <button onClick={refresh} className="p-1.5 hover:bg-slate-100 rounded-lg text-slate-400 hover:text-blue-600 transition-colors">
                            <Clock className="h-3.5 w-3.5" />
                        </button>
                    </div>
                </div>
                <div className="relative">
                    <Search className="absolute left-3 top-1/2 -translate-y-1/2 h-4 w-4 text-slate-400" />
                    <input
                        type="text"
                        value={searchTerm}
                        onChange={(e) => setSearchTerm(e.target.value)}
                        placeholder="Search rapid access..."
                        className="w-full pl-10 pr-4 py-2 bg-slate-100 border-none rounded-xl text-sm focus:ring-2 focus:ring-blue-500 outline-none transition-all"
                    />
                </div>
            </div>

            <div className="flex-1 overflow-y-auto custom-scrollbar">
                {filteredRooms.length === 0 ? (
                    <div className="flex flex-col items-center justify-center p-8 text-center h-full">
                        <MessageSquare className="h-12 w-12 text-slate-200 mb-4" />
                        <p className="text-sm font-medium text-slate-400">No messages found</p>
                    </div>
                ) : (
                    filteredRooms.map((room) => (
                        <div
                            key={room.id}
                            onClick={() => onSelectRoom(room.id)}
                            role="button"
                            tabIndex={0}
                            onKeyDown={(e) => {
                                if (e.key === 'Enter' || e.key === ' ') {
                                    onSelectRoom(room.id)
                                }
                            }}
                            className={cn(
                                "w-full text-left p-4 flex gap-3 transition-all border-b border-slate-50 group cursor-pointer relative",
                                // Selected priority
                                selectedRoomId === room.id 
                                    ? "bg-blue-50/90 border-l-4 border-l-blue-600 border-b-blue-100 z-10" 
                                    : "border-l-4 border-l-transparent",
                                // Unread Lift: Stand out from the crowd
                                room.unread_count > 0 && selectedRoomId !== room.id 
                                    ? "bg-white shadow-[0_4px_20px_rgba(0,0,0,0.08)] z-10 ring-1 ring-slate-100 scale-[1.02] mx-1 rounded-xl my-1 translate-x-1" 
                                    : "hover:bg-slate-50",
                                // Read Mute: Fade into background
                                room.unread_count === 0 && selectedRoomId !== room.id 
                                    ? "bg-slate-50/20 opacity-70" 
                                    : ""
                            )}
                        >
                            <div className="relative flex-shrink-0">
                                <div className={cn(
                                    "h-12 w-12 rounded-2xl flex items-center justify-center text-sm font-bold shadow-sm transition-transform",
                                    selectedRoomId === room.id ? "scale-105 bg-blue-600 text-white" : "bg-slate-200 text-slate-600"
                                )}>
                                    {getInitials(room.borrower?.full_name || null)}
                                </div>
                                {room.unread_count > 0 && selectedRoomId !== room.id && (
                                    <span className="absolute -top-1 -right-1 h-5 min-w-[20px] px-1.5 items-center justify-center rounded-full bg-rose-500 text-[10px] font-bold text-white border-2 border-white shadow-sm">
                                        {room.unread_count}
                                    </span>
                                )}
                            </div>

                            <div className="flex-1 min-w-0">
                                <div className="flex justify-between items-start mb-1">
                                    <div className="flex items-center gap-2 min-w-0">
                                        <h4 className={cn(
                                            "text-sm truncate pr-2 tracking-tight", 
                                            selectedRoomId === room.id ? "text-blue-900 font-black" : 
                                            room.unread_count > 0 ? "text-slate-900 font-black" : "text-slate-600 font-semibold"
                                        )}>
                                            {room.borrower?.full_name || 'LGU User'}
                                        </h4>
                                        {room.unread_count > 0 ? (
                                            <button 
                                                onClick={async (e) => {
                                                    e.stopPropagation()
                                                    const res = await markAsReadV3(room.id)
                                                    if (res.success) refresh()
                                                }}
                                                title="Mark as read"
                                                className="p-1 hover:bg-blue-100 rounded text-blue-500 opacity-0 group-hover:opacity-100 transition-opacity"
                                            >
                                                <MailOpen className="h-3 w-3" />
                                            </button>
                                        ) : (
                                            <button 
                                                onClick={async (e) => {
                                                    e.stopPropagation()
                                                    const res = await markRoomAsUnreadV3(room.id)
                                                    if (res.success) refresh()
                                                }}
                                                title="Mark as unread"
                                                className="p-1 hover:bg-slate-200 rounded text-slate-400 opacity-0 group-hover:opacity-100 transition-opacity"
                                            >
                                                <Mail className="h-3 w-3" />
                                            </button>
                                        )}
                                    </div>
                                    {room.lastMessage && (
                                        <ChatMessageTimestampV3 timestamp={room.lastMessage.created_at} className="text-slate-400 whitespace-nowrap pt-0.5" />
                                    )}
                                </div>
                                <p className={cn(
                                    "text-xs truncate transition-colors", 
                                    selectedRoomId === room.id ? "text-blue-700/70 font-medium" : 
                                    room.unread_count > 0 ? "text-slate-900 font-bold" : "text-slate-400 font-medium"
                                )}>
                                    {room.lastMessage?.content || 'No messages yet'}
                                </p>
                            </div>
                        </div>
                    ))
                )}
            </div>
        </div>
    )
}
