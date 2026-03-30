'use client'

import { useState, useMemo } from 'react'
import { BorrowerHeader } from '@/components/users/borrower-header'
import { SummaryCard } from '@/components/dashboard/summary-card'
import { BorrowerTable } from '@/components/users/borrower-table'
import { BorrowerDetailModal } from '@/components/users/borrower-detail-modal'
import { useBorrowerRegistry } from '@/hooks/use-borrower-registry'

interface BorrowersClientProps {
    initialData: {
        borrowers: any[]
        stats: any
    }
}

export function BorrowersClient({ initialData }: BorrowersClientProps) {
    const {
        borrowers,
        stats,
        isLoading,
        isValidating,
        lastSync,
        refresh
    } = useBorrowerRegistry()

    // Use server data initially, then switch to live data
    const displayBorrowers = borrowers.length > 0 ? borrowers : initialData.borrowers
    const displayStats = borrowers.length > 0 ? stats : initialData.stats

    const [searchQuery, setSearchQuery] = useState('')
    const [selectedBorrower, setSelectedBorrower] = useState<any>(null)
    const [detailOpen, setDetailOpen] = useState(false)

    const filteredBorrowers = useMemo(() => {
        return displayBorrowers
            .filter(b => b.borrower_name.toLowerCase().includes(searchQuery.toLowerCase()))
            .sort((a, b) => b.total_borrows - a.total_borrows)
    }, [displayBorrowers, searchQuery])

    const handleSelectBorrower = (borrower: any) => {
        setSelectedBorrower(borrower)
        setDetailOpen(true)
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
                <SummaryCard title="Total Borrowers" value={displayStats.totalBorrowers} label="People" color="blue" />
                <SummaryCard title="Active Borrowers" value={displayStats.activeBorrowersCount} label="Active" color="orange" />
                <SummaryCard title="Verified Users" value={displayStats.verifiedCount} label="Verified" color="indigo" />
                <SummaryCard title="Total Items Out" value={displayStats.totalInField} label="Units" color="emerald" />
            </div>

            <BorrowerTable
                borrowers={filteredBorrowers}
                isLoading={isLoading}
                onSelectBorrower={handleSelectBorrower}
            />

            {selectedBorrower && (
                <BorrowerDetailModal
                    open={detailOpen}
                    onOpenChange={setDetailOpen}
                    borrower={selectedBorrower}
                    onRefresh={refresh}
                />
            )}
        </div>
    )
}
