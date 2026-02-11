'use client'

import { Table, TableBody, TableCell, TableHead, TableHeader, TableRow } from '@/components/ui/table'
import { Avatar, AvatarFallback } from '@/components/ui/avatar'
import { Button } from '@/components/ui/button'
import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/card'
import { Input } from '@/components/ui/input'
import { Search, Mail, Building2, Settings2, Shield } from 'lucide-react'

interface UserTableProps {
    users: any[]
    isLoading: boolean
    searchQuery: string
    onSearchChange: (value: string) => void
}

export function UserTable({ users, isLoading, searchQuery, onSearchChange }: UserTableProps) {
    return (
        <Card className="border-none ring-1 ring-slate-100 shadow-xl rounded-[2.5rem] overflow-hidden bg-white/80 backdrop-blur-xl">
            <CardHeader className="bg-white/50 border-b border-slate-50 p-4 14in:p-5">
                <div className="flex flex-col sm:flex-row justify-between items-start sm:items-center gap-4">
                    <CardTitle className="text-sm font-bold font-heading text-slate-900 uppercase tracking-wide">Staff List</CardTitle>
                    <div className="relative w-full sm:w-64 group">
                        <Search className="absolute left-3 top-1/2 h-4 w-4 -translate-y-1/2 text-slate-400 group-focus-within:text-blue-500 transition-colors" />
                        <Input
                            placeholder="Find a staff member..."
                            className="pl-10 h-10 bg-slate-50/50 border-slate-100 rounded-xl text-sm focus:ring-blue-500 transition-all"
                            value={searchQuery}
                            onChange={(e) => onSearchChange(e.target.value)}
                        />
                    </div>
                </div>
            </CardHeader>
            <CardContent className="p-0">
                <div className="overflow-x-auto">
                    <Table>
                        <TableHeader>
                            <TableRow className="bg-slate-50/30 hover:bg-slate-50/30 border-slate-50">
                                <TableHead className="px-6 py-4 font-bold text-slate-400 uppercase text-[9px] tracking-[0.15em]">Staff Name</TableHead>
                                <TableHead className="font-bold text-slate-400 uppercase text-[9px] tracking-[0.15em]">Department</TableHead>
                                <TableHead className="font-bold text-slate-400 uppercase text-[9px] tracking-[0.15em]">Role</TableHead>
                                <TableHead className="font-bold text-slate-400 uppercase text-[9px] tracking-[0.15em]">Status</TableHead>
                                <TableHead className="text-right px-6 font-bold text-slate-400 uppercase text-[9px] tracking-[0.15em]">Settings</TableHead>
                            </TableRow>
                        </TableHeader>
                        <TableBody>
                            {isLoading ? (
                                <TableRow>
                                    <TableCell colSpan={5} className="h-40 text-center text-slate-400 font-bold uppercase text-[10px] tracking-widest animate-pulse">
                                        Scanning personnel records...
                                    </TableCell>
                                </TableRow>
                            ) : users.length === 0 ? (
                                <TableRow>
                                    <TableCell colSpan={5} className="h-48 text-center">
                                        <div className="flex flex-col items-center justify-center text-slate-500">
                                            <Shield className="h-10 w-10 text-slate-200 mb-2" />
                                            <p className="font-medium text-slate-400">No results matched your search criteria</p>
                                        </div>
                                    </TableCell>
                                </TableRow>
                            ) : (
                                users.map((user) => (
                                    <TableRow key={user.id} className="hover:bg-slate-50/50 group transition-colors border-slate-50">
                                        <TableCell className="px-6 py-4">
                                            <div className="flex items-center gap-3">
                                                <Avatar className="h-10 w-10 border-2 border-white shadow-md ring-1 ring-slate-100">
                                                    <AvatarFallback className="bg-gradient-to-br from-blue-600 to-blue-700 text-white text-[10px] font-bold">
                                                        {user.email?.substring(0, 2).toUpperCase()}
                                                    </AvatarFallback>
                                                </Avatar>
                                                <div className="flex flex-col">
                                                    <span className="font-heading font-bold text-slate-900 tracking-tight text-sm 14in:text-base leading-tight">
                                                        {user.full_name || 'Incognito User'}
                                                    </span>
                                                    <span className="text-[10px] font-bold text-slate-400 uppercase tracking-tighter flex items-center gap-1 mt-0.5">
                                                        <Mail className="h-3 w-3" /> {user.email}
                                                    </span>
                                                </div>
                                            </div>
                                        </TableCell>
                                        <TableCell>
                                            <div className="flex items-center gap-2 text-sm text-slate-600 font-medium">
                                                <Building2 className="h-3.5 w-3.5 text-slate-400" />
                                                {user.department || 'CDRRMO'}
                                            </div>
                                        </TableCell>
                                        <TableCell>
                                            <div className="flex items-center gap-2">
                                                <span className={`inline-flex items-center px-2.5 py-0.5 rounded-full text-[10px] font-bold ring-1 ${user.role === 'admin' ? 'bg-purple-500/10 text-purple-700 ring-purple-500/20' :
                                                    user.role === 'editor' ? 'bg-blue-500/10 text-blue-700 ring-blue-500/20' :
                                                        'bg-slate-500/10 text-slate-700 ring-slate-500/20'
                                                    }`}>
                                                    {user.role || 'viewer'}
                                                </span>
                                            </div>
                                        </TableCell>
                                        <TableCell>
                                            <div className="flex items-center gap-1.5">
                                                <div className="h-1.5 w-1.5 rounded-full bg-emerald-500 animate-pulse" />
                                                <span className="inline-flex items-center px-2 py-0.5 rounded-full text-[9px] font-bold bg-emerald-500/10 text-emerald-700 ring-1 ring-emerald-500/20 uppercase tracking-widest">Active</span>
                                            </div>
                                        </TableCell>
                                        <TableCell className="text-right px-6">
                                            <Button variant="ghost" size="sm" className="h-9 w-9 p-0 hover:bg-slate-100 rounded-xl transition-all active:scale-95">
                                                <Settings2 className="h-4 w-4 text-slate-500" />
                                                <span className="sr-only">Settings</span>
                                            </Button>
                                        </TableCell>
                                    </TableRow>
                                ))
                            )}
                        </TableBody>
                    </Table>
                </div>
            </CardContent>
        </Card>
    )
}
