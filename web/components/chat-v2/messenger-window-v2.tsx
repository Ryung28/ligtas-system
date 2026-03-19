'use client'

import React, { useState, useRef, useEffect } from 'react'
import { Send, MessageSquare, Clock, Shield, Info, Trash2, CheckCircle2 } from 'lucide-react'
import { useChatV2 } from '@/hooks/use-chat-v2'
import { markAsRead, deleteRoom } from '@/app/actions/chat'
import { Button } from '@/components/ui/button'
import { ChatMessageTimestamp } from '../chat/chat-message-timestamp'
import { toast } from 'sonner'
import { cn } from '@/lib/utils'

interface MessengerWindowV2Props {
    roomId: string
    title: string
    participant: {
        id: string
        full_name: string | null
        role: string
        last_seen: string | null
    } | null
}

/**
 * Messenger Window V2 (2026 Kinetic Build)
 * Decoupled Identity Resolution. Parent provides user objects directly.
 * Zero initial load-latency for headers. Optimistic injection for messages.
 */
export function MessengerWindowV2({ roomId, title, participant }: MessengerWindowV2Props) {
    const { messages, isLoadingHistory, presence, currentUserId, sendOptimisticMessage } = useChatV2(roomId)
    const [input, setInput] = useState('')
    const scrollRef = useRef<HTMLDivElement>(null)

    useEffect(() => {
        if (roomId) markAsRead(roomId)
    }, [roomId])

    const handleDelete = async () => {
        if (!window.confirm('Are you sure you want to delete this conversation? This will bypass Vault protections.')) return
        const result = await deleteRoom(roomId)
        if (result.success) {
            toast.success('Conversation wiped from systems.')
            window.location.reload()
        } else {
            toast.error(result.error || 'Wipe failed')
        }
    }

    const handleSend = async () => {
        const payload = input.trim()
        if (!payload) return
        
        // Wipe input field FIRST (UI rules over network)
        setInput('')
        // Blast the optimistic state to the hook
        await sendOptimisticMessage(payload)
    }

    return (
        <div className="flex-1 flex flex-col h-full bg-slate-50/30 overflow-hidden relative">
            {/* Header: Zero Load Time. Data is passed statically from the React Parent tree via V2 Sidebar cache */}
            <div className="p-4 bg-white border-b border-slate-100 flex items-center justify-between sticky top-0 z-10 shadow-sm">
                <div className="flex items-center gap-3">
                    <div className="h-10 w-10 rounded-2xl bg-blue-600 flex items-center justify-center text-white shadow-[0_4px_12px_rgba(37,99,235,0.3)]">
                        <Shield className="h-5 w-5" />
                    </div>
                    <div>
                        <h3 className="text-sm font-bold text-slate-900 tracking-tight">{title}</h3>
                        <div className="flex items-center gap-1.5 pt-0.5">
                            {(Object.keys(presence).length > 1 || (participant?.last_seen && new Date().getTime() - new Date(participant.last_seen).getTime() < 1000 * 60 * 5)) ? (
                                <>
                                    <span className="relative flex h-2 w-2">
                                        <span className="animate-ping absolute inline-flex h-full w-full rounded-full bg-emerald-400 opacity-75"></span>
                                        <span className="relative inline-flex rounded-full h-2 w-2 bg-emerald-500"></span>
                                    </span>
                                    <span className="text-[10px] font-black text-emerald-600 uppercase tracking-widest">Active Link</span>
                                </>
                            ) : (
                                <>
                                    <span className="h-2 w-2 rounded-full bg-slate-300" />
                                    <span className="text-[10px] font-bold text-slate-400 uppercase tracking-widest">Disconnected</span>
                                </>
                            )}
                        </div>
                    </div>
                </div>

                <div className="flex items-center gap-2">
                    <Button
                        variant="ghost"
                        size="icon"
                        onClick={handleDelete}
                        className="text-slate-400 hover:bg-red-50 hover:text-red-500 transition-colors rounded-xl"
                    >
                        <Trash2 className="h-4 w-4" />
                    </Button>
                    <Button variant="ghost" size="icon" className="text-slate-400 hover:bg-blue-50 hover:text-blue-600 rounded-xl">
                        <Info className="h-4 w-4" />
                    </Button>
                </div>
            </div>

            <div ref={scrollRef} className="flex-1 overflow-y-auto p-6 flex flex-col-reverse gap-4 custom-scrollbar bg-white">
                {isLoadingHistory ? (
                    <div className="flex flex-col items-center justify-center h-full text-slate-300 animate-pulse">
                        <Clock className="h-10 w-10 opacity-20 mb-2 animate-spin" />
                        <p className="text-[10px] font-bold uppercase tracking-widest text-slate-400">Syncing node records...</p>
                    </div>
                ) : messages.length === 0 ? (
                    <div className="flex flex-col items-center justify-center h-full text-slate-300">
                        <MessageSquare className="h-16 w-16 opacity-10 mb-4" />
                        <p className="text-xs font-bold uppercase tracking-widest">Awaiting Handshake</p>
                    </div>
                ) : (
                    messages.map((m) => {
                        const isMe = !!currentUserId && m.sender_id === currentUserId
                        const isOptimistic = m.status === 'sending'

                        return (
                            <div
                                key={m.id}
                                className={cn(
                                    "flex w-full animate-in fade-in slide-in-from-bottom-2 duration-300", 
                                    isMe ? 'justify-end' : 'justify-start'
                                )}
                            >
                                <div className={cn("flex items-end gap-2 max-w-[85%]", isMe ? 'flex-row-reverse ml-12' : 'flex-row mr-12')}>
                                    <div
                                        className={cn(
                                            "px-4 py-3 rounded-2xl text-[13px] font-medium leading-relaxed shadow-[0_2px_8px_rgba(0,0,0,0.04)]",
                                            isMe ? 'bg-zinc-950 text-white rounded-br-[4px]' : 'bg-slate-100/80 text-slate-900 border border-slate-200/50 rounded-bl-[4px]',
                                            isOptimistic && "opacity-60 grayscale blur-[0.2px] scale-95"
                                        )}
                                    >
                                        {m.content}
                                    </div>
                                    <div className="flex flex-col items-end px-1.5 pb-0.5">
                                        <ChatMessageTimestamp timestamp={m.created_at} className="text-[10px] text-slate-400 font-bold mb-0.5" />
                                        {isMe && !isOptimistic && <CheckCircle2 className="w-3 h-3 text-emerald-500/70" />}
                                    </div>
                                </div>
                            </div>
                        )
                    })
                )}
            </div>

            {/* Kinetic Input Area */}
            <div className="p-4 sm:p-6 bg-white border-t border-slate-100/50 backdrop-blur-xl z-10">
                <div className="max-w-4xl mx-auto flex gap-3">
                    <div className="flex-1 relative">
                        <textarea
                            value={input}
                            onChange={(e) => setInput(e.target.value)}
                            onKeyDown={(e) => {
                                if (e.key === 'Enter' && !e.shiftKey) {
                                    e.preventDefault()
                                    handleSend()
                                }
                            }}
                            placeholder="Initialize transmission..."
                            className="w-full bg-slate-50 border border-slate-200/60 rounded-2xl px-5 py-3.5 text-sm font-medium focus:ring-4 focus:ring-blue-500/10 focus:border-blue-500 outline-none resize-none min-h-[50px] max-h-[120px] custom-scrollbar transition-all"
                        />
                    </div>
                    <Button
                        size="icon"
                        onClick={handleSend}
                        disabled={!input.trim()}
                        className={cn(
                            "rounded-2xl h-[50px] w-[50px] shadow-lg transition-all duration-300 flex-shrink-0 border-0",
                            input.trim() 
                                ? "bg-blue-600 hover:bg-blue-700 hover:scale-105 shadow-[0_8px_24px_rgba(37,99,235,0.25)]" 
                                : "bg-slate-100 text-slate-400 shadow-none hover:bg-slate-200"
                        )}
                    >
                        <Send className={cn("h-5 w-5", input.trim() && "ml-1")} />
                    </Button>
                </div>
            </div>
        </div>
    )
}
