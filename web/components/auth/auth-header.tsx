'use client'

import Image from 'next/image'

interface AuthHeaderProps {
    title: string
    description: string
}

export function AuthHeader({ title, description }: AuthHeaderProps) {
    return (
        <div className="flex flex-col items-center mb-8 animate-in fade-in slide-in-from-top-4 duration-500">
            {/* Logo — visible on mobile, hidden on desktop (shown on left panel) */}
            <div className="relative h-10 w-32 mb-5 lg:hidden">
                <Image
                    src="/ligtaslogo.png"
                    alt="LIGTAS Logo"
                    fill
                    className="object-contain"
                    priority
                />
            </div>

            {/* Icon Mark for Desktop */}
            <div className="hidden lg:flex mb-5">
                <div className="w-10 h-10 relative">
                    {/* Cross/Plus Pattern Icon matching reference image */}
                    <svg viewBox="0 0 40 40" fill="none" xmlns="http://www.w3.org/2000/svg" className="w-full h-full">
                        {/* Center cross */}
                        <rect x="17" y="4" width="6" height="32" rx="1" fill="#1A1A2E" />
                        <rect x="4" y="17" width="32" height="6" rx="1" fill="#1A1A2E" />
                        {/* Corner dots */}
                        <circle cx="9" cy="9" r="2.5" fill="#1A1A2E" />
                        <circle cx="31" cy="9" r="2.5" fill="#1A1A2E" />
                        <circle cx="9" cy="31" r="2.5" fill="#1A1A2E" />
                        <circle cx="31" cy="31" r="2.5" fill="#1A1A2E" />
                    </svg>
                </div>
            </div>

            <h1 className="text-[1.55rem] font-extrabold tracking-tight text-[#1A1A2E] font-heading text-center">
                {title}
            </h1>
            <p className="text-[13px] text-slate-400 mt-1.5 font-medium text-center">
                {description}
            </p>
        </div>
    )
}
