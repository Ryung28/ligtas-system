import { MessageSquare } from 'lucide-react'

export default function ChatLoading() {
    return (
        <div className="flex bg-white h-[calc(100vh-140px)] 14in:h-[calc(100vh-160px)] xl:h-[calc(100vh-180px)] rounded-3xl shadow-2xl overflow-hidden border border-slate-200/50 select-none opacity-40 transition-opacity">
            {/* Sidebar Mirror */}
            <div className="w-[320px] 14in:w-[360px] lg:w-[400px] bg-slate-50 border-r border-slate-100 flex flex-col pt-6 px-4">
                <div className="h-4 w-24 bg-slate-200 rounded-full mb-6" />
                <div className="h-10 w-full bg-white rounded-xl border border-slate-100 mb-6" />
                
                <div className="space-y-4">
                    {[1, 2, 3, 4, 5, 6].map(i => (
                        <div key={i} className="flex gap-3 items-center">
                            <div className="h-12 w-12 bg-slate-200 rounded-full shrink-0" />
                            <div className="flex-1 space-y-2">
                                <div className="h-3 w-32 bg-slate-200 rounded-full" />
                                <div className="h-2 w-24 bg-slate-100 rounded-full" />
                            </div>
                        </div>
                    ))}
                </div>
            </div>

            {/* Messenger Mirror */}
            <div className="flex-1 flex flex-col bg-slate-50/20">
                <div className="flex-1 flex flex-col items-center justify-center p-12 text-center">
                    <div className="h-16 w-16 bg-slate-50 border border-slate-200 rounded-2xl flex items-center justify-center text-slate-200 mb-6">
                        <MessageSquare className="h-8 w-8 stroke-[1.5px]" />
                    </div>

                    <h2 className="text-xl font-semibold text-slate-200 mb-1 uppercase tracking-tight italic font-black">
                        LIGTAS Chat
                    </h2>
                    <div className="h-3 w-48 bg-slate-100 rounded-full mx-auto" />
                </div>
            </div>
        </div>
    )
}
