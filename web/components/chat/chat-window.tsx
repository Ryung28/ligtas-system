'use client'

import React, { useState, useRef, useEffect } from 'react'
import { Send, X, MessageSquare, Clock, User } from 'lucide-react'
import { useChat } from '@/hooks/use-chat'
import { sendMessage, markAsRead } from '@/app/actions/chat'
import { Button } from '@/components/ui/button'
import { ChatMessageTimestamp } from './chat-message-timestamp'
import { toast } from 'sonner'

interface ChatWindowProps {
    roomId: string
    title: string
    onClose: () => void
}

export function ChatWindow({ roomId, title, onClose }: ChatWindowProps) {
    const { messages, isLoadingHistory: isLoading, presence, currentUserId } = useChat(roomId)
    const [input, setInput] = useState('')
    const [isSending, setIsSending] = useState(false)
    const scrollRef = useRef<HTMLDivElement>(null)

    // Presence Logic: Is anyone else online in this room?
    const isOnline = Object.keys(presence).length > 0

    useEffect(() => {
        if (roomId) markAsRead(roomId)
    }, [roomId])

    useEffect(() => {
        if (scrollRef.current) {
            scrollRef.current.scrollTop = scrollRef.current.scrollHeight
        }
    }, [messages])

    const handleSend = async () => {
        if (!input.trim() || isSending) return
        setIsSending(true)
        const result = await sendMessage(roomId, input.trim())
        if (result.success) {
            setInput('')
        } else {
            toast.error(result.error || 'Failed to send')
        }
        setIsSending(false)
    }

    return (
        <div className="fixed bottom-6 right-6 w-96 h-[500px] bg-white rounded-3xl shadow-2xl border border-slate-100 flex flex-col overflow-hidden animate-in slide-in-from-bottom-4 duration-300 z-50">
            {/* Header */}
            <div className="p-4 bg-blue-900 text-white flex items-center justify-between">
                <div className="flex items-center gap-3">
                    <div className="h-10 w-10 rounded-xl bg-blue-800 flex items-center justify-center">
                        <MessageSquare className="h-5 w-5" />
                    </div>
                    <div>
                        <h3 className="text-sm font-bold uppercase tracking-tight truncate max-w-[180px]">{title}</h3>
                        <div className="flex items-center gap-1">
                            <div className={`h-1.5 w-1.5 rounded-full ${isOnline ? 'bg-emerald-400 animate-pulse' : 'bg-slate-400'}`} />
                            <span className="text-[10px] opacity-70 uppercase font-bold tracking-widest">
                                {isOnline ? 'Active Link' : 'Standby'}
                            </span>
                        </div>
                    </div>
                </div>
                <button onClick={onClose} className="p-2 hover:bg-white/10 rounded-lg transition-colors">
                    <X className="h-5 w-5" />
                </button>
            </div>

            {/* Messages Area */}
            <div ref={scrollRef} className="flex-1 overflow-y-auto p-4 space-y-4 bg-slate-50/50">
                {isLoading ? (
                    <div className="flex items-center justify-center h-full text-slate-400 text-xs font-bold uppercase tracking-widest">
                        Syncing encrypted channel...
                    </div>
                ) : messages.length === 0 ? (
                    <div className="flex flex-col items-center justify-center h-full text-slate-400 space-y-2">
                        <MessageSquare className="h-8 w-8 opacity-20" />
                        <span className="text-[10px] font-bold uppercase tracking-widest">No communication log</span>
                    </div>
                ) : (
                    messages.map((m) => {
                        const isMe = !!currentUserId && m.sender_id === currentUserId
                        return (
                            <div key={m.id} className={`flex w-full ${isMe ? 'justify-end' : 'justify-start'}`}>
                                <div className={`flex ${isMe ? 'flex-row-reverse ml-12' : 'flex-row mr-12'} items-end gap-2 max-w-[85%]`}>
                                    <div
                                        className={`p-3 rounded-2xl text-sm ${isMe
                                            ? 'bg-blue-600 text-white rounded-tr-none'
                                            : 'bg-white border border-slate-100 text-slate-900 rounded-tl-none shadow-sm'
                                            }`}
                                    >
                                        {m.content}
                                    </div>
                                    <div className={`mt-1 flex items-center gap-1 opacity-40 ${isMe ? 'flex-row-reverse' : ''}`}>
                                        <Clock className="h-2 w-2" />
                                        <ChatMessageTimestamp
                                            timestamp={m.created_at}
                                            className="text-[8px] tracking-tighter"
                                        />
                                    </div>
                                </div>
                            </div>
                        )
                    })
                )}
            </div>

            {/* Input Area */}
            <div className="p-4 bg-white border-t border-slate-100 flex gap-2">
                <input
                    type="text"
                    value={input}
                    onChange={(e) => setInput(e.target.value)}
                    onKeyDown={(e) => e.key === 'Enter' && handleSend()}
                    placeholder="Type coordination message..."
                    className="flex-1 bg-slate-100 border-none rounded-xl px-4 py-2 text-sm focus:ring-2 focus:ring-blue-500 outline-none"
                />
                <Button
                    size="icon"
                    onClick={handleSend}
                    disabled={isSending || !input.trim()}
                    className="rounded-xl h-10 w-10 bg-blue-600 hover:bg-blue-700"
                >
                    <Send className="h-4 w-4" />
                </Button>
            </div>
        </div>
    )
}
