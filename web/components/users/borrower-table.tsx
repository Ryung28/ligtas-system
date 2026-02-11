'use client'

import { Table, TableBody, TableCell, TableHead, TableHeader, TableRow } from '@/components/ui/table'
import { Avatar, AvatarFallback } from '@/components/ui/avatar'
import { Button } from '@/components/ui/button'
import { Card, CardContent } from '@/components/ui/card'
import { Package, ArrowRightCircle } from 'lucide-react'

interface BorrowerTableProps {
    borrowers: any[]
    isLoading: boolean
    onSelectBorrower: (borrower: any) => void
}

export function BorrowerTable({ borrowers, isLoading, onSelectBorrower }: BorrowerTableProps) {
    return (
        <Card className="border-none ring-1 ring-slate-100 shadow-xl rounded-[2rem] overflow-hidden bg-white/80 backdrop-blur-xl">
            <CardContent className="p-0">
                <Table>
                    <TableHeader>
                        <TableRow className="bg-slate-50/50 hover:bg-slate-50/50 border-slate-50">
                            <TableHead className="px-6 py-4 font-bold text-slate-400 uppercase text-[9px] tracking-[0.15em]">Borrower Identity</TableHead>
                            <TableHead className="font-bold text-slate-400 uppercase text-[9px] tracking-[0.15em]">Verification</TableHead>
                            <TableHead className="text-center font-bold text-slate-400 uppercase text-[9px] tracking-[0.15em]">Equipment Load</TableHead>
                            <TableHead className="font-bold text-slate-400 uppercase text-[9px] tracking-[0.15em]">Audit Status</TableHead>
                            <TableHead className="text-right px-6 font-bold text-slate-400 uppercase text-[9px] tracking-[0.15em]">Details</TableHead>
                        </TableRow>
                    </TableHeader>
                    <TableBody>
                        {isLoading ? (
                            <TableRow><TableCell colSpan={5} className="h-40 text-center text-slate-400 animate-pulse font-bold uppercase text-[10px] tracking-widest">Syncing with field data...</TableCell></TableRow>
                        ) : borrowers.length === 0 ? (
                            <TableRow>
                                <TableCell colSpan={5} className="h-64 text-center">
                                    <div className="flex flex-col items-center justify-center">
                                        <Package className="h-12 w-12 text-slate-100 mb-2" />
                                        <p className="text-slate-900 font-bold">No active borrowings found</p>
                                        <p className="text-xs text-slate-400 mt-1 uppercase tracking-widest">All equipment accounted for in storage.</p>
                                    </div>
                                </TableCell>
                            </TableRow>
                        ) : (
                            borrowers.map((borrower) => (
                                <TableRow
                                    key={borrower.name}
                                    className="hover:bg-blue-50/40 cursor-pointer group transition-all border-slate-50"
                                    onClick={() => onSelectBorrower(borrower)}
                                >
                                    <TableCell className="px-6 py-4">
                                        <div className="flex items-center gap-3">
                                            <Avatar className="h-10 w-10 14in:h-11 14in:w-11 border-2 border-white shadow-md ring-1 ring-slate-100">
                                                <AvatarFallback className={`font-bold text-[10px] text-white ${borrower.isStaff ? 'bg-gradient-to-br from-indigo-600 to-violet-700' : 'bg-gradient-to-br from-slate-400 to-slate-600'}`}>
                                                    {borrower.name.substring(0, 2).toUpperCase()}
                                                </AvatarFallback>
                                            </Avatar>
                                            <div>
                                                <p className="font-heading font-bold text-slate-900 group-hover:text-blue-600 transition-colors tracking-tight text-sm 14in:text-base leading-tight">
                                                    {borrower.name}
                                                </p>
                                                <p className="text-[9px] 14in:text-[10px] text-slate-400 font-bold uppercase tracking-[0.12em] mt-0.5 whitespace-nowrap">Verified Profile</p>
                                            </div>
                                        </div>
                                    </TableCell>
                                    <TableCell>
                                        <span className={`inline-flex items-center px-2.5 py-0.5 rounded-full text-[10px] font-bold ring-1 ${borrower.isStaff
                                            ? 'bg-indigo-500/10 text-indigo-700 ring-indigo-500/20'
                                            : 'bg-slate-500/10 text-slate-700 ring-slate-500/20'
                                            }`}>
                                            {borrower.isStaff ? 'LGU Staff' : 'Citizen'}
                                        </span>
                                    </TableCell>
                                    <TableCell className="text-center">
                                        <div className="inline-flex items-center gap-2 bg-slate-50 px-3 py-1.5 rounded-xl border border-slate-100/50 shadow-inner group-hover:bg-white transition-colors">
                                            <Package className="h-3.5 w-3.5 text-blue-500/70" />
                                            <span className="text-xs 14in:text-sm font-bold text-slate-700">{borrower.count} Units</span>
                                        </div>
                                    </TableCell>
                                    <TableCell>
                                        <div className="flex items-center gap-2">
                                            <span className={`h-1.5 w-1.5 rounded-full ${borrower.count > 0 ? 'bg-orange-500 animate-pulse' : 'bg-emerald-500'}`} />
                                            <span className={`inline-flex items-center px-2.5 py-0.5 rounded-full text-[10px] font-bold ring-1 ${borrower.count > 0
                                                ? 'bg-orange-500/10 text-orange-700 ring-orange-500/20'
                                                : 'bg-emerald-500/10 text-emerald-700 ring-emerald-500/20'
                                                }`}>
                                                {borrower.count > 0 ? 'In Field' : 'Accounted'}
                                            </span>
                                        </div>
                                    </TableCell>
                                    <TableCell className="text-right px-6">
                                        <Button variant="ghost" size="sm" className="text-blue-600 font-bold uppercase tracking-widest text-[10px] hover:bg-blue-50 group-hover:translate-x-1 transition-all rounded-xl h-9 px-4 flex items-center gap-2">
                                            Audit Log <ArrowRightCircle className="h-3.5 w-3.5 opacity-50" />
                                        </Button>
                                    </TableCell>
                                </TableRow>
                            )
                            ))}
                    </TableBody>
                </Table>
            </CardContent>
        </Card>
    )
}
