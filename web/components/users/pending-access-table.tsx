'use client'

import { useState } from 'react'
import { Card, CardContent } from '@/components/ui/card'
import { Button } from '@/components/ui/button'
import { Badge } from '@/components/ui/badge'
import { Avatar, AvatarFallback } from '@/components/ui/avatar'
import {
    Select,
    SelectContent,
    SelectItem,
    SelectTrigger,
    SelectValue,
} from '@/components/ui/select'
import {
    AlertDialog,
    AlertDialogAction,
    AlertDialogCancel,
    AlertDialogContent,
    AlertDialogDescription,
    AlertDialogFooter,
    AlertDialogHeader,
    AlertDialogTitle,
    AlertDialogTrigger,
} from '@/components/ui/alert-dialog'
import { CheckCircle, XCircle, Clock, Mail, Calendar } from 'lucide-react'
import { UserProfile } from '@/hooks/use-user-management'
import { formatDistanceToNow } from 'date-fns'

interface PendingAccessTableProps {
    pendingUsers: UserProfile[]
    isLoading: boolean
    onApprove: (userId: string, role: 'admin' | 'editor' | 'viewer') => Promise<boolean>
    onReject: (userId: string) => Promise<boolean>
}

export function PendingAccessTable({ pendingUsers, isLoading, onApprove, onReject }: PendingAccessTableProps) {
    const [selectedRole, setSelectedRole] = useState<Record<string, 'admin' | 'editor' | 'viewer'>>({})

    const handleApprove = async (userId: string) => {
        const role = selectedRole[userId] || 'viewer'
        await onApprove(userId, role)
    }

    if (isLoading) {
        return (
            <Card className="bg-white border border-gray-200/60 rounded-xl shadow-sm">
                <CardContent className="p-6 text-center text-gray-500">
                    <Clock className="h-8 w-8 mx-auto mb-2 animate-spin text-gray-300" />
                    <p>Loading access requests...</p>
                </CardContent>
            </Card>
        )
    }

    if (pendingUsers.length === 0) {
        return (
            <Card className="bg-white border border-gray-200/60 rounded-xl shadow-sm">
                <CardContent className="p-8 text-center">
                    <div className="bg-emerald-50 h-16 w-16 rounded-full mx-auto mb-4 flex items-center justify-center">
                        <CheckCircle className="h-8 w-8 text-emerald-600" />
                    </div>
                    <h3 className="text-lg font-semibold text-gray-900 mb-1">All Caught Up!</h3>
                    <p className="text-sm text-gray-500">No pending access requests at the moment.</p>
                </CardContent>
            </Card>
        )
    }

    return (
        <Card className="bg-white border border-gray-200/60 rounded-xl shadow-sm overflow-hidden">
            <CardContent className="p-0">
                <div className="overflow-x-auto">
                    <table className="w-full">
                        <thead className="bg-gray-50/50 border-b border-gray-100">
                            <tr>
                                <th className="px-6 py-3 text-left">
                                    <span className="text-[9px] font-bold text-gray-400 uppercase tracking-[0.15em]">User</span>
                                </th>
                                <th className="px-6 py-3 text-left">
                                    <span className="text-[9px] font-bold text-gray-400 uppercase tracking-[0.15em]">Requested</span>
                                </th>
                                <th className="px-6 py-3 text-left">
                                    <span className="text-[9px] font-bold text-gray-400 uppercase tracking-[0.15em]">Assign Role</span>
                                </th>
                                <th className="px-6 py-3 text-right">
                                    <span className="text-[9px] font-bold text-gray-400 uppercase tracking-[0.15em]">Actions</span>
                                </th>
                            </tr>
                        </thead>
                        <tbody className="divide-y divide-gray-50">
                            {pendingUsers.map((user) => {
                                const initials = user.email.substring(0, 2).toUpperCase()
                                const timeAgo = formatDistanceToNow(new Date(user.created_at), { addSuffix: true })

                                return (
                                    <tr key={user.id} className="hover:bg-gray-50/30 transition-colors">
                                        <td className="px-6 py-4">
                                            <div className="flex items-center gap-3">
                                                <Avatar className="h-9 w-9 bg-blue-50 border border-blue-100">
                                                    <AvatarFallback className="text-blue-600 text-xs font-bold">{initials}</AvatarFallback>
                                                </Avatar>
                                                <div>
                                                    <div className="font-medium text-sm text-gray-900">
                                                        {user.full_name || user.email.split('@')[0]}
                                                    </div>
                                                    <div className="flex items-center gap-1 text-xs text-gray-500">
                                                        <Mail className="h-3 w-3" />
                                                        {user.email}
                                                    </div>
                                                </div>
                                            </div>
                                        </td>
                                        <td className="px-6 py-4">
                                            <div className="flex items-center gap-1.5 text-xs text-gray-500">
                                                <Calendar className="h-3 w-3" />
                                                <span>{timeAgo}</span>
                                            </div>
                                        </td>
                                        <td className="px-6 py-4">
                                            <Select
                                                value={selectedRole[user.id] || 'viewer'}
                                                onValueChange={(value: 'admin' | 'editor' | 'viewer') => {
                                                    setSelectedRole(prev => ({ ...prev, [user.id]: value }))
                                                }}
                                            >
                                                <SelectTrigger className="w-[140px] h-8 text-sm">
                                                    <SelectValue />
                                                </SelectTrigger>
                                                <SelectContent>
                                                    <SelectItem value="viewer">
                                                        <div className="flex flex-col">
                                                            <span className="font-semibold text-gray-900">Borrower (Mobile App)</span>
                                                            <span className="text-[10px] text-gray-400">Can borrow items & view history</span>
                                                        </div>
                                                    </SelectItem>
                                                    <SelectItem value="editor">
                                                        <div className="flex flex-col">
                                                            <span className="font-semibold text-blue-600">Inventory Manager</span>
                                                            <span className="text-[10px] text-blue-400">Can manage items & logs</span>
                                                        </div>
                                                    </SelectItem>
                                                    <SelectItem value="admin">
                                                        <div className="flex flex-col">
                                                            <span className="font-semibold text-purple-600">Admin</span>
                                                            <span className="text-[10px] text-purple-400">Full access</span>
                                                        </div>
                                                    </SelectItem>
                                                </SelectContent>
                                            </Select>
                                        </td>
                                        <td className="px-6 py-4">
                                            <div className="flex items-center justify-end gap-2">
                                                <AlertDialog>
                                                    <AlertDialogTrigger asChild>
                                                        <Button
                                                            size="sm"
                                                            variant="outline"
                                                            className="h-8 border-emerald-200 text-emerald-700 hover:bg-emerald-50 hover:text-emerald-800 text-xs"
                                                        >
                                                            <CheckCircle className="h-3 w-3 mr-1" />
                                                            Approve
                                                        </Button>
                                                    </AlertDialogTrigger>
                                                    <AlertDialogContent>
                                                        <AlertDialogHeader>
                                                            <AlertDialogTitle>Approve Access Request</AlertDialogTitle>
                                                            <AlertDialogDescription>
                                                                Grant <strong>{user.email}</strong> access as a <strong>{((selectedRole[user.id] || 'viewer') === 'viewer' ? 'borrower' : (selectedRole[user.id] === 'editor' ? 'manager' : selectedRole[user.id]))}</strong>?
                                                            </AlertDialogDescription>
                                                        </AlertDialogHeader>
                                                        <AlertDialogFooter>
                                                            <AlertDialogCancel>Cancel</AlertDialogCancel>
                                                            <AlertDialogAction
                                                                onClick={() => handleApprove(user.id)}
                                                                className="bg-emerald-600 hover:bg-emerald-700"
                                                            >
                                                                Approve
                                                            </AlertDialogAction>
                                                        </AlertDialogFooter>
                                                    </AlertDialogContent>
                                                </AlertDialog>

                                                <AlertDialog>
                                                    <AlertDialogTrigger asChild>
                                                        <Button
                                                            size="sm"
                                                            variant="outline"
                                                            className="h-8 border-red-200 text-red-700 hover:bg-red-50 hover:text-red-800 text-xs"
                                                        >
                                                            <XCircle className="h-3 w-3 mr-1" />
                                                            Reject
                                                        </Button>
                                                    </AlertDialogTrigger>
                                                    <AlertDialogContent>
                                                        <AlertDialogHeader>
                                                            <AlertDialogTitle>Reject Access Request</AlertDialogTitle>
                                                            <AlertDialogDescription>
                                                                Are you sure you want to deny access to <strong>{user.email}</strong>? They will be marked as suspended.
                                                            </AlertDialogDescription>
                                                        </AlertDialogHeader>
                                                        <AlertDialogFooter>
                                                            <AlertDialogCancel>Cancel</AlertDialogCancel>
                                                            <AlertDialogAction
                                                                onClick={() => onReject(user.id)}
                                                                className="bg-red-600 hover:bg-red-700"
                                                            >
                                                                Reject
                                                            </AlertDialogAction>
                                                        </AlertDialogFooter>
                                                    </AlertDialogContent>
                                                </AlertDialog>
                                            </div>
                                        </td>
                                    </tr>
                                )
                            })}
                        </tbody>
                    </table>
                </div>
            </CardContent>
        </Card>
    )
}
