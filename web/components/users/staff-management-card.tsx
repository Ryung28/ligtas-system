'use client'

import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/card'
import { Avatar, AvatarFallback } from '@/components/ui/avatar'
import { Badge } from '@/components/ui/badge'
import { Button } from '@/components/ui/button'
import { Shield, UserCog, Trash2, Mail, Building2, UserPlus } from 'lucide-react'
import { UserProfile } from '@/hooks/use-user-management'
import { InviteStaffDialog } from './invite-staff-dialog'

interface StaffManagementCardProps {
    staff: UserProfile[]
    isLoading: boolean
    onRemove: (userId: string) => void
    onInvite: (email: string, role: string) => Promise<boolean>
}

export function StaffManagementCard({ staff, isLoading, onRemove, onInvite }: StaffManagementCardProps) {
    if (isLoading) {
        return (
            <Card className="bg-white border border-gray-200/60 rounded-xl shadow-sm">
                <CardHeader className="border-b border-gray-100 p-4">
                    <div className="flex items-center justify-between">
                        <CardTitle className="text-sm font-semibold text-gray-900 flex items-center gap-2">
                            <UserCog className="h-4 w-4" />
                            Staff Members
                        </CardTitle>
                    </div>
                </CardHeader>
                <CardContent className="p-6 text-center text-gray-500">
                    <Shield className="h-8 w-8 mx-auto mb-2 animate-spin text-gray-300" />
                    <p>Loading staff...</p>
                </CardContent>
            </Card>
        )
    }

    if (staff.length === 0) {
        return (
            <Card className="bg-white border border-gray-200/60 rounded-xl shadow-sm">
                <CardHeader className="border-b border-gray-100 p-4">
                    <div className="flex items-center justify-between">
                        <CardTitle className="text-sm font-semibold text-gray-900 flex items-center gap-2">
                            <UserCog className="h-4 w-4" />
                            Staff Members
                        </CardTitle>
                        <InviteStaffDialog onInvite={onInvite} />
                    </div>
                </CardHeader>
                <CardContent className="p-8 text-center">
                    <div className="bg-blue-50 h-16 w-16 rounded-full mx-auto mb-4 flex items-center justify-center">
                        <Shield className="h-8 w-8 text-blue-600" />
                    </div>
                    <h3 className="text-lg font-semibold text-gray-900 mb-1">No Staff Yet</h3>
                    <p className="text-sm text-gray-500 mb-4">Use "INVITE STAFF" to add administrators and managers.</p>
                </CardContent>
            </Card>
        )
    }

    return (
        <Card className="bg-white border border-gray-200/60 rounded-xl shadow-sm overflow-hidden">
            <CardHeader className="border-b border-gray-100 p-4">
                <div className="flex items-center justify-between">
                    <CardTitle className="text-sm font-semibold text-gray-900 flex items-center gap-2">
                        <UserCog className="h-4 w-4" />
                        Staff Members
                        <Badge variant="secondary" className="ml-2">{staff.length}</Badge>
                    </CardTitle>
                    <InviteStaffDialog onInvite={onInvite} />
                </div>
            </CardHeader>
            <CardContent className="p-0">
                <div className="divide-y divide-gray-50">
                    {staff.map((member) => {
                        const initials = member.email.substring(0, 2).toUpperCase()
                        const isAdmin = member.role === 'admin'

                        return (
                            <div key={member.id} className="p-4 hover:bg-gray-50/30 transition-colors group">
                                <div className="flex items-center gap-3">
                                    <Avatar className={`h-10 w-10 border-2 border-white shadow-sm ring-1 ${isAdmin ? 'ring-purple-100' : 'ring-blue-100'}`}>
                                        <AvatarFallback className={`${isAdmin ? 'bg-purple-50 text-purple-700' : 'bg-blue-50 text-blue-700'} text-xs font-bold`}>
                                            {initials}
                                        </AvatarFallback>
                                    </Avatar>
                                    <div className="flex-1 min-w-0">
                                        <div className="flex items-center gap-2">
                                            <span className="font-semibold text-sm text-gray-900 truncate">
                                                {member.full_name || member.email.split('@')[0]}
                                            </span>
                                            <Badge
                                                variant={isAdmin ? 'default' : 'secondary'}
                                                className={`text-[10px] ${isAdmin ? 'bg-purple-100 text-purple-700' : 'bg-blue-100 text-blue-700'}`}
                                            >
                                                {isAdmin ? 'Admin' : 'Manager'}
                                            </Badge>
                                        </div>
                                        <div className="flex items-center gap-3 mt-1 text-xs text-gray-500">
                                            <span className="flex items-center gap-1">
                                                <Mail className="h-3 w-3" />
                                                {member.email}
                                            </span>
                                            {member.department && (
                                                <span className="flex items-center gap-1">
                                                    <Building2 className="h-3 w-3" />
                                                    {member.department}
                                                </span>
                                            )}
                                        </div>
                                    </div>
                                    <Button
                                        variant="ghost"
                                        size="icon"
                                        onClick={() => onRemove(member.id)}
                                        className="h-8 w-8 rounded-md text-gray-400 hover:text-red-600 hover:bg-red-50 transition-colors opacity-0 group-hover:opacity-100"
                                    >
                                        <Trash2 className="h-3.5 w-3.5" />
                                    </Button>
                                </div>
                            </div>
                        )
                    })}
                </div>
            </CardContent>
        </Card>
    )
}
