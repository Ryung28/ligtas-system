'use client'

import { useState, useMemo } from 'react'
import { Shield } from 'lucide-react'
import { UserHeader } from '@/components/users/user-header'
import { SummaryCard } from '@/components/dashboard/summary-card'
import { UserTable } from '@/components/users/user-table'
import { useUserManagement } from '@/hooks/use-user-management'

export default function AccessControlPage() {
    const {
        users,
        stats,
        isLoading,
        isValidating,
        refresh
    } = useUserManagement()

    const [searchQuery, setSearchQuery] = useState('')

    const filteredUsers = useMemo(() => {
        return users.filter(user =>
            user.email?.toLowerCase().includes(searchQuery.toLowerCase()) ||
            user.full_name?.toLowerCase().includes(searchQuery.toLowerCase()) ||
            user.department?.toLowerCase().includes(searchQuery.toLowerCase())
        )
    }, [users, searchQuery])

    return (
        <div className="space-y-4 animate-in fade-in duration-500">
            <UserHeader
                isLoading={isLoading}
                isValidating={isValidating}
                onRefresh={refresh}
            />

            <div className="grid gap-4 grid-cols-2 md:grid-cols-3">
                <SummaryCard title="Total Staff" value={stats.totalStaff} label="People" color="slate" />
                <SummaryCard title="Main Admins" value={stats.adminsCount} label="Admins" color="purple" />
                <SummaryCard title="Staff Editors" value={stats.editorsCount} label="Editors" color="blue" />
            </div>

            <UserTable
                users={filteredUsers}
                isLoading={isLoading}
                searchQuery={searchQuery}
                onSearchChange={setSearchQuery}
            />

            {/* Protocol Footer */}
            <div className="bg-slate-900/5 border border-slate-100 rounded-[1.5rem] p-5 flex items-start gap-4">
                <div className="h-10 w-10 rounded-xl bg-slate-900 flex items-center justify-center shrink-0">
                    <Shield className="h-5 w-5 text-white" />
                </div>
                <div>
                    <h3 className="text-[11px] font-bold text-slate-900 uppercase tracking-[0.15em] mb-1">Access Control Protocols</h3>
                    <p className="text-xs text-slate-500 leading-relaxed font-medium">
                        Administrator clearance is required for personnel modifications.
                        <strong className="text-slate-900 mx-1">Admins</strong> manage core infrastructure while
                        <strong className="text-slate-900 mx-1">Editors</strong> handle operational workflows.
                    </p>
                </div>
            </div>
        </div>
    )
}
