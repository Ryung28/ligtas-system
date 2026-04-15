'use client'

import React, { useState } from 'react'
import { Send } from 'lucide-react'
import { Button } from '@/components/ui/button'
import { cn } from '@/lib/utils'

interface ChatInputV3Props {
    onSend: (content: string) => Promise<void>
}

export function ChatInputV3({ onSend }: ChatInputV3Props) {
    const [input, setInput] = useState('')

    const handleSend = async () => {
        const payload = input.trim()
        if (!payload) return
        setInput('')
        await onSend(payload)
    }

    return (
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
    )
}
