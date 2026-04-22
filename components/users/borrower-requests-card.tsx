'use client'

import { useState } from 'react'
import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/card'
import { Button } from '@/components/ui/button'
import { Avatar, AvatarFallback } from '@/components/ui/avatar'
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
import { CheckCircle, XCircle, Clock, Mail, Calendar, Smartphone } from 'lucide-react'
import { UserProfile } from '@/hooks/use-user-management'
import { formatDistanceToNow } from 'date-fns'

interface BorrowerRequestsCardProps {
    borrowers: UserProfile[]
    isLoading: boolean
    onApprove: (userId: string) => Promise<boolean>
    onReject: (userId: string) => Promise<boolean>
}

export function BorrowerRequestsCard({ borrowers, isLoading, onApprove, onReject }: BorrowerRequestsCardProps) {
    if (isLoading) {
        return (
            <Card className="bg-white border border-gray-200/60 rounded-xl shadow-sm">
                <CardHeader className="border-b border-gray-100 p-4">
                    <CardTitle className="text-sm font-semibold text-gray-900 flex items-center gap-2">
                        <Smartphone className="h-4 w-4" />
                        Borrower Requests
                    </CardTitle>
                </CardHeader>
                <CardContent className="p-6 text-center text-gray-500">
                    <Clock className="h-8 w-8 mx-auto mb-2 animate-spin text-gray-300" />
                    <p>Loading requests...</p>
                </CardContent>
            </Card>
        )
    }

    if (borrowers.length === 0) {
        return (
            <Card className="bg-white border border-gray-200/60 rounded-xl shadow-sm">
                <CardHeader className="border-b border-gray-100 p-4">
                    <CardTitle className="text-sm font-semibold text-gray-900 flex items-center gap-2">
                        <Smartphone className="h-4 w-4" />
                        Borrower Requests
                    </CardTitle>
                </CardHeader>
                <CardContent className="p-8 text-center">
                    <div className="bg-emerald-50 h-16 w-16 rounded-full mx-auto mb-4 flex items-center justify-center">
                        <CheckCircle className="h-8 w-8 text-emerald-600" />
                    </div>
                    <h3 className="text-lg font-semibold text-gray-900 mb-1">All Caught Up!</h3>
                    <p className="text-sm text-gray-500">No pending mobile app requests at the moment.</p>
                </CardContent>
            </Card>
        )
    }

    return (
        <Card className="bg-white border border-gray-200/60 rounded-xl shadow-sm overflow-hidden">
            <CardHeader className="border-b border-gray-100 p-4">
                <div className="flex items-center justify-between">
                    <CardTitle className="text-sm font-semibold text-gray-900 flex items-center gap-2">
                        <Smartphone className="h-4 w-4" />
                        Borrower Requests
                    </CardTitle>
                    <div className="flex items-center gap-2 text-xs text-orange-600 font-medium bg-orange-50 px-2 py-1 rounded-md">
                        <Clock className="h-3 w-3" />
                        {borrowers.length} Pending
                    </div>
                </div>
            </CardHeader>
            <CardContent className="p-0">
                <div className="divide-y divide-gray-50">
                    {borrowers.map((borrower) => {
                        const initials = borrower.email.substring(0, 2).toUpperCase()
                        const timeAgo = formatDistanceToNow(new Date(borrower.created_at), { addSuffix: true })

                        return (
                            <div key={borrower.id} className="p-4 hover:bg-gray-50/30 transition-colors">
                                <div className="flex items-start gap-3">
                                    <Avatar className="h-10 w-10 bg-orange-50 border border-orange-100 mt-0.5">
                                        <AvatarFallback className="text-orange-600 text-xs font-bold">
                                            {initials}
                                        </AvatarFallback>
                                    </Avatar>
                                    <div className="flex-1 min-w-0">
                                        <div className="font-medium text-sm text-gray-900">
                                            {borrower.full_name || borrower.email.split('@')[0]}
                                        </div>
                                        <div className="flex items-center gap-1 text-xs text-gray-500 mt-0.5">
                                            <Mail className="h-3 w-3" />
                                            {borrower.email}
                                        </div>
                                        <div className="flex items-center gap-1.5 text-xs text-gray-400 mt-1">
                                            <Calendar className="h-3 w-3" />
                                            <span>{timeAgo}</span>
                                        </div>
                                    </div>
                                    <div className="flex items-center gap-2">
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
                                                    <AlertDialogTitle>Approve Borrower</AlertDialogTitle>
                                                    <AlertDialogDescription>
                                                        Grant <strong>{borrower.email}</strong> access to the mobile app as a <strong>Borrower</strong>?
                                                        They will be able to scan items and view their borrowing history.
                                                    </AlertDialogDescription>
                                                </AlertDialogHeader>
                                                <AlertDialogFooter>
                                                    <AlertDialogCancel>Cancel</AlertDialogCancel>
                                                    <AlertDialogAction
                                                        onClick={() => onApprove(borrower.id)}
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
                                                    <AlertDialogTitle>Reject Borrower Request</AlertDialogTitle>
                                                    <AlertDialogDescription>
                                                        Are you sure you want to deny access to <strong>{borrower.email}</strong>?
                                                        They will be marked as suspended and cannot use the mobile app.
                                                    </AlertDialogDescription>
                                                </AlertDialogHeader>
                                                <AlertDialogFooter>
                                                    <AlertDialogCancel>Cancel</AlertDialogCancel>
                                                    <AlertDialogAction
                                                        onClick={() => onReject(borrower.id)}
                                                        className="bg-red-600 hover:bg-red-700"
                                                    >
                                                        Reject
                                                    </AlertDialogAction>
                                                </AlertDialogFooter>
                                            </AlertDialogContent>
                                        </AlertDialog>
                                    </div>
                                </div>
                            </div>
                        )
                    })}
                </div>
            </CardContent>
        </Card>
    )
}
