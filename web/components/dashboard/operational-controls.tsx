'use client'

import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/card'
import { Button } from '@/components/ui/button'
import { Box, ClipboardList, Activity, ShieldCheck } from 'lucide-react'

export function OperationalControls() {
    return (
        <Card className="bg-white/90 backdrop-blur-xl border-none rounded-[1.5rem] p-1 overflow-hidden relative group shadow-xl shadow-slate-200/40 ring-1 ring-slate-100/50">
            <div className="absolute -top-4 -right-4 h-24 w-24 bg-blue-50 rounded-full blur-2xl opacity-50 group-hover:bg-blue-100 transition-all duration-700" />
            <CardHeader className="p-4 pb-1 relative z-10">
                <CardTitle className="text-[10px] font-heading font-semibold text-slate-400 uppercase tracking-[0.15em] flex items-center gap-2">
                    <Activity className="h-3 w-3 text-blue-500" /> Dashboard Links
                </CardTitle>
            </CardHeader>
            <CardContent className="grid grid-cols-3 gap-2 p-2 relative z-10">
                <Button asChild variant="outline" className="h-[58px] rounded-xl flex flex-col gap-1 items-center justify-center bg-white border-slate-100 hover:bg-blue-50 hover:border-blue-100 transition-all group shadow-sm hover:shadow-md">
                    <a href="/dashboard/inventory" className="flex flex-col items-center gap-0.5">
                        <Box className="h-4 w-4 text-blue-600 group-hover:scale-110 transition-transform" />
                        <span className="text-[9px] font-medium text-slate-600 uppercase tracking-wide">Inventory</span>
                    </a>
                </Button>
                <Button asChild variant="outline" className="h-[58px] rounded-xl flex flex-col gap-1 items-center justify-center bg-white border-slate-100 hover:bg-amber-50 hover:border-amber-100 transition-all group shadow-sm hover:shadow-md">
                    <a href="/dashboard/approvals" className="flex flex-col items-center gap-0.5">
                        <ShieldCheck className="h-4 w-4 text-amber-600 group-hover:scale-110 transition-transform" />
                        <span className="text-[9px] font-medium text-slate-600 uppercase tracking-wide">Approvals</span>
                    </a>
                </Button>
                <Button asChild variant="outline" className="h-[58px] rounded-xl flex flex-col gap-1 items-center justify-center bg-white border-slate-100 hover:bg-indigo-50 hover:border-indigo-100 transition-all group shadow-sm hover:shadow-md">
                    <a href="/dashboard/logs" className="flex flex-col items-center gap-0.5">
                        <ClipboardList className="h-4 w-4 text-indigo-600 group-hover:scale-110 transition-transform" />
                        <span className="text-[9px] font-medium text-slate-600 uppercase tracking-wide">Logs</span>
                    </a>
                </Button>
            </CardContent>
        </Card>
    )
}
