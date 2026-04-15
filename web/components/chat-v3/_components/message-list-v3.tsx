'use client'

import React, { useRef, useEffect } from 'react'
import { MessageSquare, Clock, CheckCircle2 } from 'lucide-react'
import { ChatMessage } from '@/lib/types/chat'
import { ChatMessageTimestampV3 } from './chat-message-timestamp-v3'
import { cn } from '@/lib/utils'

interface MessageListV3Props {
    messages: ChatMessage[]
    currentUserId: string | null
    isLoading: boolean
}

export function MessageListV3({ messages, currentUserId, isLoading }: MessageListV3Props) {
    const scrollRef = useRef<HTMLDivElement>(null)

    useEffect(() => {
        if (scrollRef.current) {
            scrollRef.current.scrollTop = 0 // Using flex-col-reverse
        }
    }, [messages])

    if (isLoading) {
        return (
            <div className="flex-1 flex flex-col items-center justify-center text-slate-300 animate-pulse bg-white">
                <Clock className="h-10 w-10 opacity-20 mb-2 animate-spin" />
                <p className="text-[10px] font-bold uppercase tracking-widest text-slate-400">Syncing node records...</p>
            </div>
        )
    }

    if (messages.length === 0) {
        return (
            <div className="flex-1 flex flex-col items-center justify-center text-slate-300 bg-white">
                <MessageSquare className="h-16 w-16 opacity-10 mb-4" />
                <p className="text-xs font-bold uppercase tracking-widest">Awaiting Handshake</p>
            </div>
        )
    }

    return (
        <div ref={scrollRef} className="flex-1 overflow-y-auto p-6 flex flex-col-reverse gap-4 custom-scrollbar bg-white">
            {messages.map((m) => {
                const isMe = !!currentUserId && m.sender_id === currentUserId
                const isOptimistic = m.status === 'sending'

                return (
                    <div key={m.id} className={cn("flex w-full animate-in fade-in slide-in-from-bottom-2 duration-300", isMe ? 'justify-end' : 'justify-start')}>
                        <div className={cn("flex items-end gap-2 max-w-[85%]", isMe ? 'flex-row-reverse ml-12' : 'flex-row mr-12')}>
                            <div className={cn(
                                "px-4 py-3 rounded-2xl text-[13px] font-medium leading-relaxed shadow-sm",
                                isMe ? 'bg-zinc-950 text-white rounded-br-[4px]' : 'bg-slate-100/80 text-slate-900 border border-slate-200/50 rounded-bl-[4px]',
                                isOptimistic && "opacity-60 grayscale blur-[0.2px] scale-95"
                            )}>
                                {m.content}
                            </div>
                            <div className="flex flex-col items-end px-1.5 pb-0.5">
                                <ChatMessageTimestampV3 timestamp={m.created_at} className="text-[10px] text-slate-400 font-bold mb-0.5" />
                                {isMe && !isOptimistic && <CheckCircle2 className="w-3 h-3 text-emerald-500/70" />}
                            </div>
                        </div>
                    </div>
                )
            })}
        </div>
    )
}
