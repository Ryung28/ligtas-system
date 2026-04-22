import { ClipboardList, ShieldCheck } from 'lucide-react'

export default function ApprovalsLoading() {
    return (
        <div className="space-y-6 14in:space-y-4 opacity-40 transition-opacity">
            {/* Header Section Mirror */}
            <header className="flex flex-col gap-4 sm:flex-row sm:items-center sm:justify-between bg-white/80 backdrop-blur-md p-4 14in:p-4 rounded-3xl border border-slate-100 shadow-sm relative overflow-hidden">
                <div className="absolute top-0 right-0 p-4 opacity-[0.02]">
                    <ShieldCheck className="h-24 w-24 text-blue-900" />
                </div>

                <div className="relative z-10">
                    <h1 className="text-2xl 14in:text-2xl font-black tracking-tight text-slate-200 font-heading uppercase italic">
                        Command Queue
                    </h1>
                    <div className="h-3 w-48 bg-slate-100 rounded-full mt-2" />
                </div>

                <div className="flex items-center gap-4 relative z-10">
                    <div className="h-14 w-40 bg-slate-50 rounded-2xl border border-slate-100" />
                    <div className="h-10 w-28 bg-slate-50 rounded-xl border border-slate-100" />
                </div>
            </header>

            {/* Main Content Interface Mirror */}
            <div className="space-y-8 14in:space-y-6">
                <div className="space-y-3">
                    <div className="flex items-center gap-2 px-2">
                        <div className="h-2 w-2 rounded-full bg-slate-200" />
                        <div className="h-3 w-40 bg-slate-100 rounded-full" />
                    </div>
                    {/* Table Skeleton */}
                    <div className="bg-white rounded-[2.5rem] border border-slate-100 p-6 space-y-4">
                        {[1, 2, 3].map(i => (
                            <div key={i} className="h-20 bg-slate-50/50 rounded-2xl border border-slate-100" />
                        ))}
                    </div>
                </div>
            </div>

            {/* Advisory Skeleton */}
            <div className="bg-slate-50/50 border border-slate-100 rounded-2xl p-4 flex items-center gap-4">
                <div className="h-10 w-10 bg-slate-100 rounded-xl shrink-0" />
                <div className="space-y-1.5">
                    <div className="h-2 w-24 bg-slate-200 rounded-full" />
                    <div className="h-2 w-64 bg-slate-100 rounded-full" />
                </div>
            </div>
        </div>
    )
}
