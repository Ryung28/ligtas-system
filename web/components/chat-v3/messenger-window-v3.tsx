'use client'

import React from 'react'
import { useChatV3 } from '@/hooks/use-chat-v3'
import { ChatHeaderV3 } from './_components/chat-header-v3'
import { MessageListV3 } from './_components/message-list-v3'
import { ChatInputV3 } from './_components/chat-input-v3'
import { QuickSwitchV3 } from './_components/quick-switch-v3'

interface MessengerWindowV3Props {
    roomId: string
    title: string
    participant: {
        id: string
        full_name: string | null
        role: string
        last_seen: string | null
    } | null
    recentRooms?: { id: string; name: string }[]
    onSwitchRoom?: (id: string) => void
}

/**
 * Messenger Window V3 (LIGTAS Platinum Standard)
 * Decomposed into _components to satisfy the 150-line protocol.
 */
export function MessengerWindowV3({ roomId, title, participant, recentRooms = [], onSwitchRoom }: MessengerWindowV3Props) {
    const { 
        messages, 
        isLoadingHistory, 
        presence, 
        currentUserId, 
        sendOptimisticMessage 
    } = useChatV3(roomId)

    return (
        <div className="flex-1 flex flex-col h-full bg-slate-50/30 overflow-hidden relative">
            {/* Awareness Bar */}
            {onSwitchRoom && (
                <QuickSwitchV3 
                    rooms={recentRooms} 
                    activeRoomId={roomId} 
                    onSwitch={onSwitchRoom} 
                />
            )}

            {/* Header: Zero Load Time */}
            <ChatHeaderV3 
                roomId={roomId}
                title={title}
                participant={participant}
                presence={presence}
            />

            {/* Message Stream */}
            <MessageListV3 
                messages={messages}
                currentUserId={currentUserId}
                isLoading={isLoadingHistory}
            />

            {/* Kinetic Input Area */}
            <ChatInputV3 onSend={sendOptimisticMessage} />
        </div>
    )
}
