import dynamic from 'next/dynamic'
import { Suspense } from 'react'
import ChatLoading from './loading'

const ChatClient = dynamic(() => import('./chat-client'), {
    loading: () => <ChatLoading />
})

export default function AdminMessengerPage() {
    return (
        <Suspense fallback={<ChatLoading />}>
            <ChatClient />
        </Suspense>
    )
}
