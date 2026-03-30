import { Printer } from 'lucide-react'

export function ReportsHeader() {
    return (
        <div className="flex flex-col gap-4 md:flex-row md:items-center md:justify-between bg-white/80 backdrop-blur-md p-3 14in:p-4 rounded-xl border border-slate-100 shadow-sm">
            <div className="relative z-10">
                <div className="flex items-center gap-2 mb-1">
                </div>
                <h1 className="text-2xl 14in:text-3xl font-black tracking-tight text-slate-900 font-heading uppercase italic leading-none">
                    Print Reports
                </h1>
            </div>
            <div className="flex items-center gap-1.5 px-3 py-1.5 bg-slate-50 rounded-lg border border-slate-100">
                <Printer className="h-3.5 w-3.5 text-slate-400" />
                <p className="text-[9px] font-bold text-slate-500 uppercase tracking-widest">Ready to Print</p>
            </div>
        </div>
    )
}
