'use client'

import React, { useState } from 'react'
import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/card'
import { Avatar, AvatarFallback } from '@/components/ui/avatar'
import { Badge } from '@/components/ui/badge'
import { Button } from '@/components/ui/button'
import { 
  AlertDialog,
  AlertDialogAction,
  AlertDialogCancel,
  AlertDialogContent,
  AlertDialogDescription,
  AlertDialogFooter,
  AlertDialogHeader,
  AlertDialogTitle,
} from "@/components/ui/alert-dialog"
import { Shield, UserCog, Trash2, Mail, Building2, UserPlus, UserMinus, ShieldAlert, ShieldOff, AlertTriangle, Warehouse } from 'lucide-react'
import { UserProfile } from '@/hooks/use-user-management'
import { InviteStaffDialog } from './invite-staff-dialog'
import { AssignWarehouseDialog } from './assign-warehouse-dialog'

interface StaffManagementCardProps {
    staff: UserProfile[]
    isLoading: boolean
    onRemove: (userId: string) => void
    onInvite: (email: string, role: 'admin' | 'editor' | 'viewer' | 'responder') => Promise<boolean>
    onRoleUpdate: (userId: string, newRole: 'admin' | 'editor' | 'viewer' | 'responder') => void
    onWarehouseAssign: (userId: string, warehouse: string | null) => Promise<boolean>
}

export function StaffManagementCard({ staff, isLoading, onRemove, onInvite, onRoleUpdate, onWarehouseAssign }: StaffManagementCardProps) {
    // ── STATE: Safety Interlock ──
    const [pendingAction, setPendingAction] = useState<{ 
        type: 'role_update' | 'remove', 
        userId: string,
        targetRole?: 'admin' | 'editor' | 'viewer' | 'responder'
    } | null>(null)

    const handleConfirm = () => {
        if (!pendingAction) return
        
        if (pendingAction.type === 'role_update' && pendingAction.targetRole) {
            onRoleUpdate(pendingAction.userId, pendingAction.targetRole)
        } else if (pendingAction.type === 'remove') {
            onRemove(pendingAction.userId)
        }
        
        setPendingAction(null)
    }

    if (isLoading) {
        return (
            <Card className="bg-white border border-gray-200/60 rounded-xl shadow-sm h-full min-h-[600px]">
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
            <Card className="bg-white border border-gray-200/60 rounded-xl shadow-sm h-full min-h-[600px]">
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
                    <p className="text-sm text-gray-500 mb-4">Use &quot;INVITE STAFF&quot; to add administrators and managers.</p>
                </CardContent>
            </Card>
        )
    }

    return (
        <>
            <Card className="bg-white border border-gray-200/60 rounded-xl shadow-sm overflow-hidden h-full min-h-[600px]">
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
                            const isEditor = member.role === 'editor'

                            return (
                                <div key={member.id} className="p-4 hover:bg-gray-50/50 transition-colors group">
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
                                                    variant={member.isPending ? 'outline' : (isAdmin ? 'default' : 'secondary')}
                                                    className={`text-[10px] ${member.isPending
                                                        ? 'border-blue-200 text-blue-600 bg-blue-50/30'
                                                        : (isAdmin ? 'bg-purple-100 text-purple-700' : 'bg-blue-100 text-blue-700')
                                                        }`}
                                                >
                                                    {member.isPending ? 'INVITATION SENT' : (isAdmin ? 'Admin' : 'Inventory Manager')}
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
                                            {!member.isPending && (
                                                <div className="mt-1 text-xs">
                                                    <span className="flex items-center gap-1 text-gray-500">
                                                        <Warehouse className="h-3 w-3" />
                                                        <span className="font-medium">
                                                            {(member as any).assigned_warehouse || (isAdmin ? 'All Warehouses' : 'Not Assigned')}
                                                        </span>
                                                    </span>
                                                </div>
                                            )}
                                        </div>
                                        <div className="flex items-center gap-1">
                                            {!member.isPending && (
                                                <AssignWarehouseDialog
                                                    userId={member.id}
                                                    currentWarehouse={(member as any).assigned_warehouse || null}
                                                    userName={member.full_name || member.email.split('@')[0]}
                                                    onAssign={onWarehouseAssign}
                                                />
                                            )}
                                            {isEditor && (
                                                <Button
                                                    variant="ghost"
                                                    size="icon"
                                                    onClick={() => setPendingAction({ 
                                                        type: 'role_update', 
                                                        userId: member.id,
                                                        targetRole: 'admin'
                                                    })}
                                                    title="Promote to Admin"
                                                    className="h-8 w-8 rounded-md text-gray-400 hover:text-purple-600 hover:bg-purple-50 transition-colors"
                                                >
                                                    <UserPlus className="h-3.5 w-3.5" />
                                                </Button>
                                            )}
                                            {isAdmin && (
                                                <Button
                                                    variant="ghost"
                                                    size="icon"
                                                    onClick={() => setPendingAction({ 
                                                        type: 'role_update', 
                                                        userId: member.id,
                                                        targetRole: 'editor'
                                                    })}
                                                    title="Demote to Manager"
                                                    className="h-8 w-8 rounded-md text-gray-400 hover:text-blue-600 hover:bg-blue-50 transition-colors"
                                                >
                                                    <UserMinus className="h-3.5 w-3.5" />
                                                </Button>
                                            )}
                                            <Button
                                                variant="ghost"
                                                size="icon"
                                                onClick={() => setPendingAction({ type: 'remove', userId: member.id })}
                                                title="Remove Staff"
                                                className="h-8 w-8 rounded-md text-gray-400 hover:text-red-600 hover:bg-red-50 transition-colors"
                                            >
                                                <Trash2 className="h-3.5 w-3.5" />
                                            </Button>
                                        </div>
                                    </div>
                                </div>
                            )
                        })}
                    </div>
                </CardContent>
            </Card>

            {/* ── SAFETY DIALOG INTERLOCK ── */}
            <AlertDialog open={!!pendingAction} onOpenChange={(open) => !open && setPendingAction(null)}>
                <AlertDialogContent className="rounded-xl">
                    <AlertDialogHeader>
                        <AlertDialogTitle className="flex items-center gap-2">
                            {pendingAction?.type === 'role_update' ? (
                                <>
                                    <Shield className="h-5 w-5 text-purple-600" />
                                    Confirm Role Update
                                </>
                            ) : (
                                <>
                                    <AlertTriangle className="h-5 w-5 text-red-600" />
                                    Confirm Removal
                                </>
                            )}
                        </AlertDialogTitle>
                        <AlertDialogDescription>
                            {pendingAction?.type === 'role_update' 
                                ? (pendingAction.targetRole === 'admin' 
                                    ? "Are you sure you want to grant full Admin privileges? This grants UNRESTRICTED access to personnel and system settings."
                                    : "Are you sure you want to demote this user to Inventory Manager? This restricts access to personnel management. They will remain an Inventory Manager.")
                                : "Are you sure you want to remove this staff member? Their access will be revoked immediately."
                            }
                        </AlertDialogDescription>
                    </AlertDialogHeader>
                    <AlertDialogFooter>
                        <AlertDialogCancel className="rounded-lg">Cancel</AlertDialogCancel>
                        <AlertDialogAction 
                            onClick={handleConfirm}
                            className={`rounded-lg ${pendingAction?.type === 'role_update' 
                                ? (pendingAction.targetRole === 'admin' ? 'bg-purple-600 hover:bg-purple-700' : 'bg-blue-600 hover:bg-blue-700') 
                                : 'bg-red-600 hover:bg-red-700'}`}
                        >
                            {pendingAction?.type === 'role_update' 
                                ? (pendingAction.targetRole === 'admin' ? 'Promote to Admin' : 'Demote to Manager') 
                                : 'Revoke Access'}
                        </AlertDialogAction>
                    </AlertDialogFooter>
                </AlertDialogContent>
            </AlertDialog>
        </>
    )
}
