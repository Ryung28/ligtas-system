'use client'

import React, { useState, useEffect, useRef } from 'react'
import { MessageSquare, X } from 'lucide-react'
import { motion, AnimatePresence } from 'framer-motion'
import { MessengerWindowV3 } from './messenger-window-v3'
import { usePendingRequests } from '@/hooks/use-pending-requests'
import { getOrCreateRoomV3 } from '@/app/actions/chat-v3'
import { toast } from 'sonner'

export const CHAT_EVENT_V3 = 'ligtas:open_chat_v3'

/**
 * LIGTAS Platinum Draggable Chat Hub (V3.1 - Stable Anchor)
 * Uses absolute window positioning to prevent layout jumps during drag.
 */
export function ChatFabV3() {
    const [isOpen, setIsOpen] = useState(false)
    const [recentRooms, setRecentRooms] = useState<{ id: string; name: string }[]>([])
    const [activeRoomId, setActiveRoomId] = useState<string | null>(null)
    const { requests } = usePendingRequests()
    
    // Stable constraint reference
    const constraintsRef = useRef(null)

    const activeRoom = recentRooms.find(r => r.id === activeRoomId) || null

    const openChatForRequest = async (target: { id: number, name: string }) => {
        const result = await getOrCreateRoomV3(target.id)
        if (result.success && result.data) {
            const roomId = result.data.id
            const borrowerName = target.name

            setRecentRooms(prev => {
                const filtered = prev.filter(r => r.id !== roomId)
                return [{ id: roomId, name: borrowerName }, ...filtered].slice(0, 3)
            })
            
            setActiveRoomId(roomId)
            setIsOpen(true)
        } else {
            toast.error(result.error || 'Coordination Link Failure')
        }
    }

    useEffect(() => {
        const handleOpenChat = (e: CustomEvent<{ id: number; name: string }>) => {
            openChatForRequest(e.detail)
        }
        window.addEventListener(CHAT_EVENT_V3 as any, handleOpenChat as any)
        return () => window.removeEventListener(CHAT_EVENT_V3 as any, handleOpenChat as any)
    }, [])

    const toggleChat = async () => {
        if (!isOpen) {
            if (activeRoomId) {
                setIsOpen(true)
            } else if (requests.length > 0) {
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
            {/* Full-screen constraint area */}
            <div ref={constraintsRef} className="fixed inset-0 pointer-events-none z-[60]" />

            <motion.div
                drag
                dragConstraints={constraintsRef}
                dragElastic={0.1}
                dragMomentum={false}
                className="fixed bottom-8 right-8 z-[60] w-16 h-16 pointer-events-auto"
            >
                {/* 
                    ── STABLE ANCHOR WINDOW ──
                    Positioned absolute so it doesn't change the size of the draggable parent.
                    This prevents the 'teleport/jump' bug on close.
                */}
                <AnimatePresence>
                    {isOpen && activeRoomId && (
                        <motion.div 
                            initial={{ opacity: 0, y: -20, scale: 0.9, x: -320 }} // Offset to left of FAB
                            animate={{ opacity: 1, y: -520, scale: 1, x: -320 }}  // Float above FAB
                            exit={{ opacity: 0, y: -20, scale: 0.9, x: -320 }}
                            transition={{ type: 'spring', damping: 25, stiffness: 300 }}
                            className="absolute w-96 h-[500px] bg-white rounded-3xl shadow-[0_32px_64px_-12px_rgba(0,0,0,0.25)] border border-slate-100 flex flex-col overflow-hidden"
                        >
                            <MessengerWindowV3 
                                roomId={activeRoomId}
                                title={activeRoom?.name ? `Coordination: ${activeRoom.name}` : 'LIGTAS Operations'}
                                participant={null}
                                recentRooms={recentRooms}
                                onSwitchRoom={setActiveRoomId}
                            />
                        </motion.div>
                    )}
                </AnimatePresence>

                {/* The Anchor FAB (Static Size) */}
                <motion.button
                    onClick={toggleChat}
                    whileHover={{ scale: 1.05 }}
                    whileTap={{ scale: 0.95 }}
                    className={`w-16 h-16 rounded-3xl flex items-center justify-center shadow-2xl transition-transform duration-200 group cursor-grab active:cursor-grabbing ${isOpen
                        ? 'bg-slate-800'
                        : 'bg-blue-600 hover:bg-blue-700'
                    }`}
                >
                    {isOpen ? (
                        <X className="h-6 w-6 text-white rotate-0 animate-in spin-in-90 duration-300" />
                    ) : (
                        <span className="relative">
                            <MessageSquare className="h-6 w-6 text-white" />
                            {requests.length > 0 && (
                                <span className="absolute -top-1 -right-1 h-3 w-3 bg-red-500 rounded-full border-2 border-blue-600 animate-pulse" />
                            )}
                        </span>
                    )}
                    
                    {!isOpen && (
                        <div className="absolute inset-0 rounded-3xl bg-blue-400 blur-xl opacity-20 group-hover:opacity-40 transition-opacity" />
                    )}
                </motion.button>
            </motion.div>
        </>
    )
}
