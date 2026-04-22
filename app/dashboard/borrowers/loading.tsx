import { Users, FileText, CheckCircle2, AlertCircle, Plus, Search, Filter } from 'lucide-react'

export default function BorrowersLoading() {
    return (
        <div className="space-y-4">
            {/* Real Header Frame */}
            <div className="flex flex-col gap-3 sm:flex-row sm:items-center sm:justify-between mb-4">
                <div className="space-y-1">
                    <h1 className="text-xl 14in:text-2xl font-black tracking-tight text-slate-900 uppercase italic leading-none">
                        Borrower Registry
                    </h1>
                    <div className="h-4 w-48 bg-slate-100 rounded-full" />
                </div>
                <div className="flex items-center gap-2 opacity-50 grayscale pointer-events-none">
                    <div className="h-9 w-32 bg-slate-50 border border-slate-200 rounded-lg" />
                    <div className="h-9 w-32 bg-blue-50 border border-blue-100 rounded-xl" />
                </div>
            </div>

            {/* Quick Stats Frame */}
            <div className="grid gap-3 grid-cols-2 lg:grid-cols-4">
                {[
                    { label: 'Total Borrowers', icon: Users },
                    { label: 'Active Loans', icon: FileText },
                    { label: 'Returned', icon: CheckCircle2 },
                    { label: 'Overdue', icon: AlertCircle }
                ].map((stat, i) => (
                    <div key={i} className="bg-white border ring-1 ring-zinc-200/60 p-4 rounded-2xl flex items-center justify-between">
                        <div className="space-y-2">
                            <p className="text-[10px] font-bold text-zinc-400 uppercase tracking-widest">{stat.label}</p>
                            <div className="h-6 w-12 bg-slate-100 rounded" />
                        </div>
                        <stat.icon className="h-5 w-5 text-slate-200" />
                    </div>
                ))}
            </div>

            {/* Register Frame */}
            <div className="bg-white rounded-2xl border border-zinc-200/60 overflow-hidden shadow-sm">
                <div className="p-4 border-b border-zinc-100 flex items-center gap-4">
                    <div className="h-10 flex-1 bg-slate-50 border border-slate-200 rounded-lg" />
                    <div className="h-10 w-32 bg-slate-50 border border-slate-200 rounded-lg" />
                </div>
                <div className="p-4 space-y-4">
                    {[1, 2, 3, 4, 5].map(i => (
                        <div key={i} className="flex items-center justify-between py-4 border-b border-slate-50 last:border-0">
                            <div className="flex items-center gap-4">
                                <div className="h-12 w-12 bg-slate-100 rounded-full" />
                                <div className="space-y-2">
                                    <div className="h-4 w-48 bg-slate-100 rounded" />
                                    <div className="h-3 w-32 bg-slate-50 rounded" />
                                </div>
                            </div>
                            <div className="h-8 w-16 bg-slate-50 rounded-full" />
                        </div>
                    ))}
                </div>
            </div>
        </div>
    )
}
