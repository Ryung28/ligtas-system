'use client'

import { Table, TableBody, TableCell, TableHead, TableHeader, TableRow } from '@/components/ui/table'
import { Avatar, AvatarFallback } from '@/components/ui/avatar'
import { Button } from '@/components/ui/button'
import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/card'
import { Input } from '@/components/ui/input'
import { Search, Mail, Building2, Shield, Trash2, Clock } from 'lucide-react'

interface UserTableProps {
    users: any[]
    isLoading: boolean
    searchQuery: string
    onSearchChange: (value: string) => void
    onRemove: (email: string) => void
    onSuspend: (userId: string) => void
    onReactivate: (userId: string) => void
}

export function UserTable({ users, isLoading, searchQuery, onSearchChange, onRemove, onSuspend, onReactivate }: UserTableProps) {
    return (
        <Card className="bg-white border border-gray-200/60 rounded-xl overflow-hidden flex flex-col shadow-sm">
            <CardHeader className="border-b border-gray-100 p-3 14in:p-4">
                <div className="flex flex-col md:flex-row justify-between items-start md:items-center gap-3">
                    <CardTitle className="text-[13px] font-semibold text-gray-900">Staff List</CardTitle>
                    <div className="relative w-full md:w-64">
                        <Search className="absolute left-3 top-1/2 h-3.5 w-3.5 -translate-y-1/2 text-gray-400" />
                        <Input
                            placeholder="Find a staff member..."
                            className="pl-9 h-9 text-[13px] bg-white border-gray-200 rounded-lg focus-visible:ring-1 focus-visible:ring-gray-300 focus-visible:border-gray-300 placeholder:text-gray-400"
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
                            <TableRow className="bg-gray-50/80 hover:bg-gray-50/80 border-b border-gray-100">
                                <TableHead className="pl-4 14in:pl-6 pr-3 py-3 font-medium text-gray-500 text-[11px] uppercase tracking-wider">Staff Name</TableHead>
                                <TableHead className="px-3 py-3 font-medium text-gray-500 text-[11px] uppercase tracking-wider">Department</TableHead>
                                <TableHead className="px-3 py-3 font-medium text-gray-500 text-[11px] uppercase tracking-wider">Role</TableHead>
                                <TableHead className="px-3 py-3 font-medium text-gray-500 text-[11px] uppercase tracking-wider">Status</TableHead>
                                <TableHead className="pl-3 pr-4 14in:pr-6 py-3 font-medium text-gray-500 text-[11px] uppercase tracking-wider text-right">Revoke Access</TableHead>
                            </TableRow>
                        </TableHeader>
                        <TableBody>
                            {isLoading ? (
                                <TableRow>
                                    <TableCell colSpan={5} className="h-72 text-center">
                                        <div className="flex flex-col items-center justify-center p-10">
                                            <div className="bg-gray-50 h-12 w-12 rounded-xl flex items-center justify-center mb-4">
                                                <Shield className="h-6 w-6 text-gray-300" />
                                            </div>
                                            <p className="text-gray-900 font-semibold text-sm">Scanning personnel records...</p>
                                        </div>
                                    </TableCell>
                                </TableRow>
                            ) : users.length === 0 ? (
                                <TableRow>
                                    <TableCell colSpan={5} className="h-72 text-center">
                                        <div className="flex flex-col items-center justify-center p-10">
                                            <div className="bg-gray-50 h-12 w-12 rounded-xl flex items-center justify-center mb-4">
                                                <Shield className="h-6 w-6 text-gray-300" />
                                            </div>
                                            <p className="text-gray-900 font-semibold text-sm">No results found</p>
                                            <p className="text-[13px] text-gray-400 mt-1 max-w-[280px]">
                                                Try adjusting your search criteria.
                                            </p>
                                        </div>
                                    </TableCell>
                                </TableRow>
                            ) : (
                                users.map((user) => (
                                    <TableRow key={user.email} className="hover:bg-gray-50/60 group transition-colors border-b border-gray-100/80">
                                        <TableCell className="pl-4 14in:pl-6 pr-3 py-3">
                                            <div className="flex items-center gap-3">
                                                <Avatar className="h-9 w-9 border-2 border-white shadow-sm ring-1 ring-gray-100 flex-shrink-0">
                                                    <AvatarFallback className={`${user.isPending ? 'bg-gray-100 text-gray-400' : 'bg-gradient-to-br from-blue-600 to-blue-700 text-white'} text-[10px] font-bold`}>
                                                        {user.email?.substring(0, 2).toUpperCase()}
                                                    </AvatarFallback>
                                                </Avatar>
                                                <div className="flex flex-col min-w-0">
                                                    <span className={`font-semibold text-sm 14in:text-base leading-tight truncate ${user.isPending ? 'text-gray-400' : 'text-gray-900'}`}>
                                                        {user.full_name || (user.isPending ? 'Invited Personnel' : 'Incognito User')}
                                                    </span>
                                                    <span className="text-[10px] text-gray-500 truncate flex items-center gap-1 mt-0.5">
                                                        <Mail className="h-2.5 w-2.5" /> {user.email}
                                                    </span>
                                                </div>
                                            </div>
                                        </TableCell>
                                        <TableCell className="px-3 py-3">
                                            <div className="flex items-center gap-2 text-sm text-gray-600">
                                                <Building2 className="h-3.5 w-3.5 text-gray-400 flex-shrink-0" />
                                                {user.department || 'CDRRMO'}
                                            </div>
                                        </TableCell>
                                        <TableCell className="px-3 py-3">
                                            <div className="flex items-center gap-2">
                                                <span className={`inline-flex items-center px-2 py-0.5 rounded-md text-[11px] font-medium ${user.role === 'admin' ? 'bg-purple-50 text-purple-700 ring-1 ring-purple-600/10' :
                                                    user.role === 'editor' ? 'bg-blue-50 text-blue-700 ring-1 ring-blue-600/10' :
                                                        'bg-slate-50 text-slate-700 ring-1 ring-slate-600/10'
                                                    }`}>
                                                    {user.role || 'viewer'}
                                                </span>
                                            </div>
                                        </TableCell>
                                        <TableCell className="px-3 py-3">
                                            <div className="flex items-center gap-1.5">
                                                {user.isPending ? (
                                                    <Clock className="h-3 w-3 text-amber-500 flex-shrink-0" />
                                                ) : (
                                                    <div className="h-1.5 w-1.5 rounded-full bg-emerald-500" />
                                                )}
                                                <span className={`inline-flex items-center px-2 py-0.5 rounded-md text-[11px] font-medium ${user.isPending ? 'bg-amber-50 text-amber-700 ring-1 ring-amber-600/10' : 'bg-emerald-50 text-emerald-700 ring-1 ring-emerald-600/10'}`}>
                                                    {user.isPending ? 'Pending' : 'Active'}
                                                </span>
                                            </div>
                                        </TableCell>
                                        <TableCell className="pl-3 pr-4 14in:pr-6 py-3 text-right">
                                            <Button
                                                variant="ghost"
                                                size="icon"
                                                onClick={() => onRemove(user.email)}
                                                className="h-8 w-8 rounded-md text-gray-400 hover:text-red-600 hover:bg-red-50 transition-colors"
                                            >
                                                <Trash2 className="h-3.5 w-3.5" />
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