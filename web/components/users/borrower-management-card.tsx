'use client'

import { useState } from 'react'
import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/card'
import { Button } from '@/components/ui/button'
import { Avatar, AvatarFallback } from '@/components/ui/avatar'
import { Badge } from '@/components/ui/badge'
import { Tabs, TabsContent, TabsList, TabsTrigger } from '@/components/ui/tabs'
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
import { CheckCircle, XCircle, Clock, Mail, Calendar, Smartphone, Users, Trash2, Search } from 'lucide-react'
import { UserProfile } from '@/hooks/use-user-management'
import { formatDistanceToNow } from 'date-fns'
import { Input } from '@/components/ui/input'

interface BorrowerManagementCardProps {
    pendingBorrowers: UserProfile[]
    activeBorrowers: UserProfile[]
    isLoading: boolean
    onApprove: (userId: string) => Promise<boolean>
    onReject: (userId: string) => Promise<boolean>
    onRemove: (userId: string) => Promise<boolean>
}

export function BorrowerManagementCard({
    pendingBorrowers,
    activeBorrowers,
    isLoading,
    onApprove,
    onReject,
    onRemove
}: BorrowerManagementCardProps) {
    const [searchQuery, setSearchQuery] = useState('')

    const filteredActiveBorrowers = activeBorrowers.filter(borrower =>
        (borrower.full_name?.toLowerCase() || '').includes(searchQuery.toLowerCase()) ||
        borrower.email.toLowerCase().includes(searchQuery.toLowerCase())
    )

    if (isLoading) {
        return (
            <Card className="bg-white border border-gray-200/60 rounded-xl shadow-sm h-full">
                <CardHeader className="border-b border-gray-100 p-4">
                    <CardTitle className="text-sm font-semibold text-gray-900 flex items-center gap-2">
                        <Smartphone className="h-4 w-4" />
                        Mobile App Users
                    </CardTitle>
                </CardHeader>
                <CardContent className="p-6 text-center text-gray-500">
                    <Clock className="h-8 w-8 mx-auto mb-2 animate-spin text-gray-300" />
                    <p>Loading users...</p>
                </CardContent>
            </Card>
        )
    }

    return (
        <Card className="bg-white border border-gray-200/60 rounded-xl shadow-sm overflow-hidden h-full flex flex-col">
            <Tabs defaultValue="requests" className="flex-1 flex flex-col">
                <CardHeader className="border-b border-gray-100 p-4 pb-0">
                    <div className="flex items-center justify-between mb-4">
                        <CardTitle className="text-sm font-semibold text-gray-900 flex items-center gap-2">
                            <Smartphone className="h-4 w-4" />
                            Mobile App Users
                        </CardTitle>
                    </div>
                    <TabsList className="w-full grid grid-cols-2 bg-slate-100/50 p-1 rounded-lg">
                        <TabsTrigger value="requests" className="text-xs font-medium relative">
                            Pending Requests
                            {pendingBorrowers.length > 0 && (
                                <Badge variant="destructive" className="ml-2 h-4 w-4 p-0 flex items-center justify-center rounded-full text-[9px]">
                                    {pendingBorrowers.length}
                                </Badge>
                            )}
                        </TabsTrigger>
                        <TabsTrigger value="active" className="text-xs font-medium">
                            Active Directory
                            <Badge variant="secondary" className="ml-2 bg-slate-200 text-slate-600 h-4 px-1 rounded-md text-[9px]">
                                {activeBorrowers.length}
                            </Badge>
                        </TabsTrigger>
                    </TabsList>
                </CardHeader>

                <CardContent className="p-0 flex-1 overflow-hidden flex flex-col">
                    {/* REQUESTS TAB */}
                    <TabsContent value="requests" className="flex-1 m-0 overflow-y-auto max-h-[600px]">
                        {pendingBorrowers.length === 0 ? (
                            <div className="p-8 text-center flex flex-col items-center justify-center h-full min-h-[300px]">
                                <div className="bg-emerald-50 h-16 w-16 rounded-full mx-auto mb-4 flex items-center justify-center">
                                    <CheckCircle className="h-8 w-8 text-emerald-600" />
                                </div>
                                <h3 className="text-lg font-semibold text-gray-900 mb-1">All Caught Up!</h3>
                                <p className="text-sm text-gray-500">No pending mobile app requests.</p>
                            </div>
                        ) : (
                            <div className="divide-y divide-gray-50">
                                {pendingBorrowers.map((borrower) => {
                                    const initials = borrower.email.substring(0, 2).toUpperCase()
                                    const timeAgo = formatDistanceToNow(new Date(borrower.created_at), { addSuffix: true })

                                    return (
                                        <div key={borrower.id} className="p-4 hover:bg-orange-50/10 transition-colors">
                                            <div className="flex items-start gap-3">
                                                <Avatar className="h-10 w-10 bg-orange-50 border border-orange-100 mt-0.5">
                                                    <AvatarFallback className="text-orange-600 text-xs font-bold">
                                                        {initials}
                                                    </AvatarFallback>
                                                </Avatar>
                                                <div className="flex-1 min-w-0">
                                                    <div className="flex items-center gap-2">
                                                        <span className="font-semibold text-sm text-gray-900 truncate">
                                                            {borrower.full_name || borrower.email.split('@')[0]}
                                                        </span>
                                                        <Badge variant="outline" className="text-[10px] bg-orange-50 text-orange-700 border-orange-100 h-5">
                                                            New
                                                        </Badge>
                                                    </div>
                                                    <div className="flex items-center gap-1 text-xs text-gray-500 mt-0.5">
                                                        <Mail className="h-3 w-3" />
                                                        {borrower.email}
                                                    </div>
                                                    <div className="flex items-center gap-1.5 text-xs text-gray-400 mt-1">
                                                        <Calendar className="h-3 w-3" />
                                                        <span>Requested {timeAgo}</span>
                                                    </div>
                                                </div>
                                            </div>
                                            <div className="flex items-center gap-2 mt-3 pl-14">
                                                <AlertDialog>
                                                    <AlertDialogTrigger asChild>
                                                        <Button size="sm" className="h-8 bg-emerald-600 hover:bg-emerald-700 text-white text-xs flex-1">
                                                            <CheckCircle className="h-3 w-3 mr-1.5" />
                                                            Approve
                                                        </Button>
                                                    </AlertDialogTrigger>
                                                    <AlertDialogContent>
                                                        <AlertDialogHeader>
                                                            <AlertDialogTitle>Approve Request</AlertDialogTitle>
                                                            <AlertDialogDescription>
                                                                Grant <strong>{borrower.email}</strong> access to the mobile app?
                                                            </AlertDialogDescription>
                                                        </AlertDialogHeader>
                                                        <AlertDialogFooter>
                                                            <AlertDialogCancel>Cancel</AlertDialogCancel>
                                                            <AlertDialogAction onClick={() => onApprove(borrower.id)} className="bg-emerald-600">
                                                                Approve
                                                            </AlertDialogAction>
                                                        </AlertDialogFooter>
                                                    </AlertDialogContent>
                                                </AlertDialog>

                                                <AlertDialog>
                                                    <AlertDialogTrigger asChild>
                                                        <Button size="sm" variant="outline" className="h-8 border-red-200 text-red-700 hover:bg-red-50 text-xs flex-1">
                                                            <XCircle className="h-3 w-3 mr-1.5" />
                                                            Reject
                                                        </Button>
                                                    </AlertDialogTrigger>
                                                    <AlertDialogContent>
                                                        <AlertDialogHeader>
                                                            <AlertDialogTitle>Reject Request</AlertDialogTitle>
                                                            <AlertDialogDescription>
                                                                Deny access to <strong>{borrower.email}</strong>?
                                                            </AlertDialogDescription>
                                                        </AlertDialogHeader>
                                                        <AlertDialogFooter>
                                                            <AlertDialogCancel>Cancel</AlertDialogCancel>
                                                            <AlertDialogAction onClick={() => onReject(borrower.id)} className="bg-red-600">
                                                                Reject
                                                            </AlertDialogAction>
                                                        </AlertDialogFooter>
                                                    </AlertDialogContent>
                                                </AlertDialog>
                                            </div>
                                        </div>
                                    )
                                })}
                            </div>
                        )}
                    </TabsContent>

                    {/* ACTIVE DIRECTORY TAB */}
                    <TabsContent value="active" className="flex-1 m-0 overflow-y-auto max-h-[600px] flex flex-col">
                        <div className="p-3 border-b border-gray-50 bg-white sticky top-0 z-10">
                            <div className="relative">
                                <Search className="absolute left-3 top-1/2 -translate-y-1/2 h-3.5 w-3.5 text-gray-400" />
                                <Input
                                    placeholder="Search borrowers..."
                                    value={searchQuery}
                                    onChange={(e) => setSearchQuery(e.target.value)}
                                    className="pl-9 h-9 bg-gray-50 border-gray-200 text-xs focus-visible:ring-1 focus-visible:ring-emerald-500"
                                />
                            </div>
                        </div>

                        {filteredActiveBorrowers.length === 0 ? (
                            <div className="p-8 text-center flex flex-col items-center justify-center flex-1">
                                <div className="bg-gray-50 h-16 w-16 rounded-full mx-auto mb-4 flex items-center justify-center">
                                    <Users className="h-8 w-8 text-gray-300" />
                                </div>
                                <h3 className="text-lg font-semibold text-gray-900 mb-1">No Active Users</h3>
                                <p className="text-sm text-gray-500">
                                    {searchQuery ? 'No users match your search.' : 'Approved mobile app users will appear here.'}
                                </p>
                            </div>
                        ) : (
                            <div className="divide-y divide-gray-50">
                                {filteredActiveBorrowers.map((borrower) => {
                                    const initials = borrower.email.substring(0, 2).toUpperCase()
                                    return (
                                        <div key={borrower.id} className="p-3 hover:bg-emerald-50/10 transition-colors group">
                                            <div className="flex items-center gap-3">
                                                <Avatar className="h-9 w-9 border border-gray-100 bg-white">
                                                    <AvatarFallback className="bg-emerald-50 text-emerald-700 text-[10px] font-bold">
                                                        {initials}
                                                    </AvatarFallback>
                                                </Avatar>
                                                <div className="flex-1 min-w-0">
                                                    <div className="flex items-center justify-between">
                                                        <div className="font-semibold text-sm text-gray-900 truncate">
                                                            {borrower.full_name || borrower.email.split('@')[0]}
                                                        </div>
                                                        <Badge variant="secondary" className="bg-emerald-50 text-emerald-700 text-[9px] px-1.5 h-4 border border-emerald-100/50">
                                                            Active
                                                        </Badge>
                                                    </div>
                                                    <div className="flex items-center gap-1 text-xs text-gray-500 mt-0.5">
                                                        <Mail className="h-3 w-3" />
                                                        {borrower.email}
                                                    </div>
                                                </div>
                                                <AlertDialog>
                                                    <AlertDialogTrigger asChild>
                                                        <Button variant="ghost" size="icon" className="h-8 w-8 text-gray-400 hover:text-red-600 hover:bg-red-50 opacity-0 group-hover:opacity-100 transition-all">
                                                            <Trash2 className="h-4 w-4" />
                                                        </Button>
                                                    </AlertDialogTrigger>
                                                    <AlertDialogContent>
                                                        <AlertDialogHeader>
                                                            <AlertDialogTitle>Suspend Access</AlertDialogTitle>
                                                            <AlertDialogDescription>
                                                                Are you sure you want to suspend access for <strong>{borrower.email}</strong>?
                                                            </AlertDialogDescription>
                                                        </AlertDialogHeader>
                                                        <AlertDialogFooter>
                                                            <AlertDialogCancel>Cancel</AlertDialogCancel>
                                                            <AlertDialogAction onClick={() => onRemove(borrower.id)} className="bg-red-600 hover:bg-red-700">
                                                                Suspend Access
                                                            </AlertDialogAction>
                                                        </AlertDialogFooter>
                                                    </AlertDialogContent>
                                                </AlertDialog>
                                            </div>
                                        </div>
                                    )
                                })}
                            </div>
                        )}
                    </TabsContent>
                </CardContent>
            </Tabs>
        </Card>
    )
}
