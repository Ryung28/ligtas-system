'use client'

import { useState, useMemo } from 'react'
import { UserBorrowTracker } from '@/components/users/user-borrow-tracker'
import { BorrowerHeader } from '@/components/users/borrower-header'
import { SummaryCard } from '@/components/dashboard/summary-card'
import { BorrowerTable } from '@/components/users/borrower-table'
import { useBorrowerRegistry } from '@/hooks/use-borrower-registry'

export default function BorrowerRegistryPage() {
    const {
        allBorrowers,
        stats,
        isLoading,
        isValidating,
        lastSync,
        syncProgress,
        refresh
    } = useBorrowerRegistry()

    const [searchQuery, setSearchQuery] = useState('')
    const [selectedBorrower, setSelectedBorrower] = useState<any>(null)
    const [trackerOpen, setTrackerOpen] = useState(false)

    const filteredBorrowers = useMemo(() => {
        return allBorrowers
            .filter(b => b.name.toLowerCase().includes(searchQuery.toLowerCase()))
            .sort((a, b) => b.count - a.count)
    }, [allBorrowers, searchQuery])

    const handleSelectBorrower = (borrower: any) => {
        setSelectedBorrower(borrower)
        setTrackerOpen(true)
    }

    return (
        <div className="space-y-4 animate-in fade-in duration-500 relative">
            <BorrowerHeader
                lastSync={lastSync}
                isValidating={isValidating}
                syncProgress={syncProgress}
                searchQuery={searchQuery}
                onSearchChange={setSearchQuery}
            />

            <div className="grid gap-4 grid-cols-2 md:grid-cols-4">
                <SummaryCard title="Total Borrowers" value={stats.activeBorrowersCount} label="People" color="blue" />
                <SummaryCard title="Total Items Out" value={stats.totalInField} label="Units" color="orange" />
                <SummaryCard title="Staff Members" value={stats.staffCount} label="LGU" color="indigo" />
                <SummaryCard title="Other People" value={stats.guestCount} label="Guest" color="emerald" />
            </div>

            <BorrowerTable
                borrowers={filteredBorrowers}
                isLoading={isLoading}
                onSelectBorrower={handleSelectBorrower}
            />

            {selectedBorrower && (
                <UserBorrowTracker
                    open={trackerOpen}
                    onOpenChange={setTrackerOpen}
                    userName={selectedBorrower.name}
                    activeBorrows={selectedBorrower.items}
                    onRefresh={refresh}
                />
            )}
        </div>
    )
}
