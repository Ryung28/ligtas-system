'use client'

import { useEffect, useState } from 'react'

export function AudioPermissionOverlay({ onEnable }: { onEnable: () => void }) {
    const [show, setShow] = useState(false)

    useEffect(() => {
        // Check if audio was previously enabled
        const enabled = localStorage.getItem('audio_enabled')
        if (enabled !== 'true') {
            setShow(true)
        }
    }, [])

    const handleEnable = () => {
        localStorage.setItem('audio_enabled', 'true')
        setShow(false)
        onEnable()
    }

    if (!show) return null

    return (
        <div className="fixed inset-0 z-50 flex items-center justify-center bg-black/80 backdrop-blur-sm">
            <div className="rounded-lg bg-white p-8 max-w-md mx-4 text-center shadow-2xl">
                <h2 className="mb-4 text-2xl font-bold text-gray-900">Enable Notifications</h2>
                <p className="mb-6 text-gray-600">
                    LIGTAS needs permission to play audio notifications for:
                    <br />
                    • New borrow requests
                    <br />
                    • Chat messages
                    <br />
                    • Critical low stock alerts
                </p>
                <button
                    onClick={handleEnable}
                    className="rounded-md bg-blue-600 px-6 py-3 font-semibold text-white hover:bg-blue-700 focus:outline-none focus:ring-2 focus:ring-blue-500 focus:ring-offset-2"
                >
                    Enable Audio Notifications
                </button>
            </div>
        </div>
    )
}
