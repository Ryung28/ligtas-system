'use client'

import React, { useState, useEffect } from 'react'
import { MessageSquare, X } from 'lucide-react'
import { ChatWindow } from './chat-window'
import { usePendingRequests } from '@/hooks/use-pending-requests'
import { getOrCreateRoom } from '@/app/actions/chat'
import { toast } from 'sonner'

// Global event bus for triggering chat from other components
export const CHAT_EVENT = 'ligtas:open_chat'

interface OpenChatEvent {
    id: number
    name: string
}

export function ChatFab() {
    const [isOpen, setIsOpen] = useState(false)
    const [activeRoom, setActiveRoom] = useState<{ id: string; title: string } | null>(null)
    const { requests } = usePendingRequests()

    const openChatForRequest = async (target: { id: number, name: string }) => {
        const result = await getOrCreateRoom(target.id)
        if (result.success && result.data) {
            setActiveRoom({ id: result.data.id, title: `Coordination: ${target.name}` })
            setIsOpen(true)
        } else {
            // Safety Net: Diagnostic toast for faster debugging
            toast.error(result.error || 'Coordination Link Failure', {
                description: result.code ? `Error Code: ${result.code}` : 'System handshake failed.'
            })
        }
    }

    useEffect(() => {
        const handleOpenChat = (e: CustomEvent<OpenChatEvent>) => {
            openChatForRequest(e.detail)
        }
        window.addEventListener(CHAT_EVENT as any, handleOpenChat as any)
        return () => window.removeEventListener(CHAT_EVENT as any, handleOpenChat as any)
    }, [])

    const toggleChat = async () => {
        if (!isOpen) {
            if (requests.length > 0) {
                const first = requests[0]
                await openChatForRequest({ id: first.id, name: first.borrower_name })
            } else {
                toast.info('No active operational logs for coordination.')
            }
        } else {
            setIsOpen(false)
        }
    }

    return (
        <>
            <button
                onClick={toggleChat}
                className={`fixed bottom-8 right-8 w-16 h-16 rounded-3xl flex items-center justify-center shadow-2xl transition-all duration-500 z-[60] group ${isOpen
                    ? 'bg-slate-800 rotate-90 scale-90'
                    : 'bg-blue-600 hover:bg-blue-700 hover:scale-110 active:scale-95'
                    }`}
            >
                {isOpen ? (
                    <X className="h-6 w-6 text-white" />
                ) : (
                    <span className="relative">
                        <MessageSquare className="h-6 w-6 text-white" />
                        {requests.length > 0 && (
                            <span className="absolute -top-1 -right-1 h-3 w-3 bg-red-500 rounded-full border-2 border-blue-600 animate-pulse" />
                        )}
                    </span>
                )}

                {/* Visual Glow Effect */}
                <div className={`absolute inset-0 rounded-3xl bg-blue-400 blur-xl opacity-20 group-hover:opacity-40 transition-opacity ${isOpen ? 'hidden' : ''}`} />
            </button>

            {isOpen && activeRoom && (
                <ChatWindow
                    roomId={activeRoom.id}
                    title={activeRoom.title}
                    onClose={() => setIsOpen(false)}
                />
            )}
        </>
    )
}
