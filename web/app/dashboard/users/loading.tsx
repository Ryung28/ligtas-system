import { Shield } from 'lucide-react'

export default function UsersLoading() {
    return (
        <div className="space-y-4 opacity-40 transition-opacity">
            {/* Header Mirror */}
            <div className="flex flex-col gap-3 sm:flex-row sm:items-center sm:justify-between bg-white/80 p-4 rounded-xl border border-slate-100 shadow-sm">
                <div className="space-y-1">
                    <h1 className="text-xl 14in:text-2xl font-black tracking-tight text-slate-200 uppercase italic leading-none">
                        Access Control
                    </h1>
                    <div className="h-3 w-48 bg-slate-100 rounded-full" />
                </div>
                <div className="h-10 w-32 bg-slate-50 border border-slate-100 rounded-xl" />
            </div>

            {/* Stats Mirror */}
            <div className="grid gap-4 grid-cols-2 md:grid-cols-4">
                {[1, 2, 3, 4].map(i => (
                    <div key={i} className="h-28 bg-white rounded-3xl border border-slate-100" />
                ))}
            </div>

            {/* Two-Column Interface Mirror */}
            <div className="grid grid-cols-1 lg:grid-cols-2 gap-4">
                <div className="h-[450px] bg-white rounded-[2.5rem] border border-slate-100 overflow-hidden" />
                <div className="h-[450px] bg-white rounded-[2.5rem] border border-slate-100 overflow-hidden" />
            </div>

            {/* Protocol Footer Mirror */}
            <div className="bg-gradient-to-br from-slate-900/5 to-blue-900/5 border border-slate-100 rounded-[1.5rem] p-5 flex items-start gap-4">
                <div className="h-10 w-10 rounded-xl bg-slate-200 flex items-center justify-center shrink-0" />
                <div className="flex-1 space-y-3">
                    <div className="h-3 w-40 bg-slate-200 rounded-full" />
                    <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
                        <div className="h-12 bg-white/50 rounded-xl border border-white" />
                        <div className="h-12 bg-white/50 rounded-xl border border-white" />
                    </div>
                </div>
            </div>
        </div>
    )
}
