'use client'

import { useState, useMemo, useEffect } from 'react'
import { Shield, Users, Smartphone } from 'lucide-react'
import { UserHeader } from '@/components/users/user-header'
import { SummaryCard } from '@/components/dashboard/summary-card'
import { useUserManagement } from '@/hooks/use-user-management'
import { StaffManagementCard } from '@/components/users/staff-management-card'
import { BorrowerManagementCard } from '@/components/users/borrower-management-card'
import { getCurrentUser } from '@/lib/auth'

export default function AccessControlPage() {
    const [currentUser, setCurrentUser] = useState<any>(null)
    const {
        users,
        stats,
        isLoading,
        isValidating,
        refresh,
        approveUser,
        rejectUser,
        suspendUser,
        reactivateUser,
        authorizeUser,
        unauthorizeUser
    } = useUserManagement()

    useEffect(() => {
        getCurrentUser().then(u => {
            setCurrentUser(u)
        })
    }, [])

    // Filter staff members (admins and editors only)
    const staffMembers = useMemo(() => {
        return users.filter(user =>
            user.status === 'active' &&
            (user.role === 'admin' || user.role === 'editor')
        )
    }, [users])

    // Filter pending borrowers (requests)
    const pendingBorrowers = useMemo(() => {
        return users.filter(user => user.status === 'pending')
    }, [users])

    // Filter active borrowers (mobile app users)
    const activeBorrowers = useMemo(() => {
        return users.filter(user => user.status === 'active' && user.role === 'viewer')
    }, [users])

    // Calculate enhanced stats
    const enhancedStats = useMemo(() => {
        return {
            ...stats,
            totalStaff: staffMembers.length,
            totalBorrowers: activeBorrowers.length,
            pendingBorrowers: pendingBorrowers.length
        }
    }, [stats, staffMembers, activeBorrowers, pendingBorrowers])

    // Handle borrower approval (locked to 'viewer' role)
    const handleApproveBorrower = async (userId: string) => {
        return await approveUser(userId, 'viewer')
    }

    if (!isLoading && currentUser && currentUser.role !== 'admin') {
        return (
            <div className="flex flex-col items-center justify-center h-[70vh] space-y-4">
                <div className="h-20 w-20 rounded-full bg-red-50 flex items-center justify-center border border-red-100">
                    <Shield className="h-10 w-10 text-red-600" />
                </div>
                <h1 className="text-2xl font-bold text-slate-900">Access Denied</h1>
                <p className="text-slate-500 max-w-md text-center">
                    You do not have the required permissions to access this page. Only administrators can manage system users and approvals.
                </p>
            </div>
        )
    }

    return (
        <div className="space-y-4 animate-in fade-in duration-500">
            <UserHeader
                isLoading={isLoading}
                isValidating={isValidating}
                onInvite={authorizeUser}
            />

            <div className="grid gap-4 grid-cols-2 md:grid-cols-4">
                <SummaryCard title="Staff Members" value={enhancedStats.totalStaff} label="Active" color="blue" />
                <SummaryCard title="Active Borrowers" value={enhancedStats.totalBorrowers} label="Mobile Users" color="emerald" />
                <SummaryCard title="Pending Approvals" value={enhancedStats.pendingBorrowers} label="Requests" color="orange" />
                <SummaryCard title="Admins" value={stats.adminsCount} label="Staff" color="purple" />
            </div>

            {/* Two-Column Layout */}
            <div className="grid grid-cols-1 lg:grid-cols-2 gap-4">
                {/* Left Column: Staff Management */}
                <StaffManagementCard
                    staff={staffMembers}
                    isLoading={isLoading}
                    onRemove={suspendUser}
                    onInvite={authorizeUser}
                />

                {/* Right Column: Borrower Management (Tabs: Pending & Active) */}
                <BorrowerManagementCard
                    pendingBorrowers={pendingBorrowers}
                    activeBorrowers={activeBorrowers}
                    isLoading={isLoading}
                    onApprove={handleApproveBorrower}
                    onReject={rejectUser}
                    onRemove={suspendUser}
                />
            </div>

            {/* Protocol Footer */}
            <div className="bg-gradient-to-br from-slate-900/5 to-blue-900/5 border border-slate-100 rounded-[1.5rem] p-5 flex items-start gap-4">
                <div className="h-10 w-10 rounded-xl bg-slate-900 flex items-center justify-center shrink-0">
                    <Shield className="h-5 w-5 text-white" />
                </div>
                <div className="flex-1">
                    <h3 className="text-[11px] font-bold text-slate-900 uppercase tracking-[0.15em] mb-2">Access Control Policy</h3>
                    <div className="grid grid-cols-1 md:grid-cols-2 gap-4 text-xs text-slate-600 leading-relaxed">
                        <div className="space-y-1">
                            <div className="flex items-center gap-2">
                                <Users className="h-3.5 w-3.5 text-blue-600" />
                                <strong className="text-slate-900">Staff Management (Left)</strong>
                            </div>
                            <p className="pl-5 text-slate-500">
                                Use <strong className="text-blue-600">INVITE STAFF</strong> to add Admins and Inventory Managers. Internal personnel only.
                            </p>
                        </div>
                        <div className="space-y-1">
                            <div className="flex items-center gap-2">
                                <Smartphone className="h-3.5 w-3.5 text-orange-600" />
                                <strong className="text-slate-900">Borrower Management (Right)</strong>
                            </div>
                            <p className="pl-5 text-slate-500">
                                Start in <strong>Pending Requests</strong> to approve app signups. Accepted users move to <strong>Active Directory</strong> where you can manage them.
                            </p>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    )
}
