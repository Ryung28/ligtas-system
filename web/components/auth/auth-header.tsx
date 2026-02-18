'use client'

import Image from 'next/image'

interface AuthHeaderProps {
    title: string
    description: string
}

export function AuthHeader({ title, description }: AuthHeaderProps) {
    return (
        <div className="flex flex-col items-center animate-in fade-in slide-in-from-top-4 duration-500">
            {/* Logo — visible on mobile, hidden on desktop (shown on left panel) */}
            <div className="relative h-16 w-16 mb-4 lg:hidden shadow-lg rounded-full overflow-hidden border-2 border-white bg-white">
                <Image
                    src="/oro-cervo.png"
                    alt="CDRRMO Logo"
                    fill
                    className="object-contain p-1"
                    priority
                />
            </div>

            {/* Icon Mark for Desktop */}
            <div className="hidden lg:flex mb-6">
                <div className="w-24 h-24 relative group">
                    <div className="absolute inset-0 bg-blue-500/10 rounded-full blur-2xl group-hover:bg-blue-500/20 transition-all duration-700" />
                    <Image
                        src="/oro-cervo.png"
                        alt="CDRRMO Official Logo"
                        fill
                        className="object-contain relative z-10 drop-shadow-2xl transition-transform duration-500 hover:scale-105"
                        priority
                    />
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
