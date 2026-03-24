'use client'

import { useState, useMemo, useEffect } from 'react'
import { UserBorrowTracker } from '@/components/users/user-borrow-tracker'
import { BorrowerHeader } from '@/components/users/borrower-header'
import { SummaryCard } from '@/components/dashboard/summary-card'
import { BorrowerTable } from '@/components/users/borrower-table'
import { useBorrowerRegistry } from '@/hooks/use-borrower-registry'

interface BorrowersClientProps {
    initialData: {
        allBorrowers: any[]
        stats: any
    }
}

export function BorrowersClient({ initialData }: BorrowersClientProps) {
    const {
        allBorrowers,
        stats,
        isLoading,
        isValidating,
        lastSync,
        refresh
    } = useBorrowerRegistry()

    // Use server data initially, then switch to live data
    const displayBorrowers = allBorrowers.length > 0 ? allBorrowers : initialData.allBorrowers
    const displayStats = allBorrowers.length > 0 ? stats : initialData.stats

    const [searchQuery, setSearchQuery] = useState('')
    const [selectedBorrower, setSelectedBorrower] = useState<any>(null)
    const [trackerOpen, setTrackerOpen] = useState(false)

    const filteredBorrowers = useMemo(() => {
        return displayBorrowers
            .filter(b => b.name.toLowerCase().includes(searchQuery.toLowerCase()))
            .sort((a, b) => b.count - a.count)
    }, [displayBorrowers, searchQuery])

    const handleSelectBorrower = (borrower: any) => {
        setSelectedBorrower(borrower)
        setTrackerOpen(true)
    }

    return (
        <div className="space-y-4 animate-in fade-in duration-500">
            <BorrowerHeader
                lastSync={lastSync}
                isValidating={isValidating}
                searchQuery={searchQuery}
                onSearchChange={setSearchQuery}
            />

            <div className="grid gap-4 grid-cols-2 md:grid-cols-4">
                <SummaryCard title="Total Borrowers" value={displayStats.activeBorrowersCount} label="People" color="blue" />
                <SummaryCard title="Total Items Out" value={displayStats.totalInField} label="Units" color="orange" />
                <SummaryCard title="Staff Members" value={displayStats.staffCount} label="LGU" color="indigo" />
                <SummaryCard title="Other People" value={displayStats.guestCount} label="Guest" color="emerald" />
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
