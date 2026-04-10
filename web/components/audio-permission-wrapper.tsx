'use client'

import { useEffect, useState } from 'react'

export function AudioPermissionWrapper({ children }: { children: React.ReactNode }) {
    const [showOverlay, setShowOverlay] = useState(false)
    const [audioEnabled, setAudioEnabled] = useState(false)

    useEffect(() => {
        // Check if audio was previously enabled
        const enabled = localStorage.getItem('audio_enabled')
        if (enabled !== 'true') {
            setShowOverlay(true)
        } else {
            setAudioEnabled(true)
        }
    }, [])

    const handleEnable = () => {
        // 🛡️ TACTICAL PRIMING: Execute the acoustic handshake during the user's gesture
        if (typeof (window as any).LIGTAS_UNLOCK_AUDIO === 'function') {
            (window as any).LIGTAS_UNLOCK_AUDIO();
        }
        
        localStorage.setItem('audio_enabled', 'true')
        setShowOverlay(false)
        setAudioEnabled(true)
    }

    return (
        <>
            {showOverlay && (
                <div className="fixed bottom-4 right-4 z-50 max-w-sm rounded-lg bg-white p-4 shadow-2xl border border-gray-200">
                    <div className="flex items-start gap-3">
                        <div className="mt-1 flex h-8 w-8 flex-shrink-0 items-center justify-center rounded-full bg-blue-100 text-blue-600">
                            <svg xmlns="http://www.w3.org/2000/svg" className="h-5 w-5" viewBox="0 0 20 20" fill="currentColor">
                                <path fillRule="evenodd" d="M10 18a8 8 0 100-16 8 8 0 000 16zm6.707-10.293a1 1 0 00-1.414-1.414L11 10.586 9.707 9.293a1 1 0 00-1.414 1.414l2 2a1 1 0 001.414 0l4-4z" clipRule="evenodd" />
                            </svg>
                        </div>
                        <div className="flex-1">
                            <h3 className="font-semibold text-gray-900">Enable Audio Notifications</h3>
                            <p className="mt-1 text-sm text-gray-600">
                                Get sound alerts for new requests, messages, and low stock warnings.
                            </p>
                            <button
                                onClick={handleEnable}
                                className="mt-3 rounded-md bg-blue-600 px-4 py-2 text-sm font-semibold text-white hover:bg-blue-700 focus:outline-none focus:ring-2 focus:ring-blue-500 focus:ring-offset-2 transition-all active:scale-95"
                            >
                                Enable Now
                            </button>
                            <button
                                onClick={() => {
                                    // 🛡️ TACTICAL BYPASS: Still try to unlock even if they choose later
                                    if (typeof (window as any).LIGTAS_UNLOCK_AUDIO === 'function') {
                                        (window as any).LIGTAS_UNLOCK_AUDIO();
                                    }
                                    localStorage.setItem('audio_enabled', 'true')
                                    setShowOverlay(false)
                                    setAudioEnabled(true)
                                }}
                                className="ml-2 text-sm text-gray-500 hover:text-gray-700"
                            >
                                Maybe later
                            </button>
                        </div>
                    </div>
                </div>
            )}
            {children}
        </>
    )
}
