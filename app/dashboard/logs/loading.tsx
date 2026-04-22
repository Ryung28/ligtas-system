export default function LogsLoading() {
    return (
        <div className="max-w-screen-3xl mx-auto space-y-4 p-1 14in:p-2 opacity-40 transition-opacity">
            {/* Page Header Mirror */}
            <div className="flex flex-col gap-4 md:flex-row md:items-center md:justify-between bg-white/80 backdrop-blur-md p-3 14in:p-4 rounded-xl border border-slate-100 shadow-sm">
                <h1 className="text-2xl 14in:text-3xl font-black tracking-tight text-slate-200 font-heading uppercase italic">
                    Borrow/Return Logs
                </h1>
                <div className="h-10 w-32 bg-slate-50 rounded-xl border border-slate-100" />
            </div>
            
            {/* Triage Hook Mirror */}
            <div className="h-14 bg-slate-50/50 rounded-2xl border border-slate-100 border-dashed" />

            {/* Stats Cards Mirror */}
            <div className="grid grid-cols-1 md:grid-cols-4 gap-4">
                {[1, 2, 3, 4].map(i => (
                    <div key={i} className="h-28 bg-white rounded-3xl border border-slate-100" />
                ))}
            </div>

            {/* Main Log Section Mirror */}
            <div className="bg-white rounded-[2.5rem] border border-slate-100 overflow-hidden flex flex-col">
                <div className="bg-white/50 border-b border-slate-50 p-4 14in:p-5 flex gap-4">
                    <div className="h-10 flex-1 bg-slate-50 rounded-xl" />
                    <div className="h-10 w-40 bg-slate-50 rounded-xl" />
                </div>

                <div className="p-0">
                    {[1, 2, 3, 4, 5].map(i => (
                        <div key={i} className="h-20 border-b border-slate-50 bg-white/50" />
                    ))}
                </div>
            </div>
        </div>
    )
}
