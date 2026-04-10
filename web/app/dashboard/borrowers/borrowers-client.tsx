'use client'

import { useState, useEffect, useCallback } from 'react'
import { useRouter, useSearchParams, usePathname } from 'next/navigation'
import { BorrowerHeader } from '@/components/users/borrower-header'
import { SummaryCard } from '@/components/dashboard/summary-card'
import { BorrowerTable } from '@/components/users/borrower-table'
import { BorrowerDetailModal } from '@/components/users/borrower-detail-modal'
import { useBorrowerRegistry } from '@/hooks/use-borrower-registry'
import { useDebounce } from '@/hooks/use-debounce'

interface BorrowersClientProps {
    initialData: {
        borrowers: any[]
        stats: any
    }
}

const ITEMS_PER_PAGE = 10

export function BorrowersClient({ initialData }: BorrowersClientProps) {
    const router = useRouter()
    const pathname = usePathname()
    const searchParams = useSearchParams()

    // 🌐 URL STATE SYNC
    const currentPage = parseInt(searchParams.get('page') || '1')
    const initialSearch = searchParams.get('search') || ''
    
    const [searchQuery, setSearchQuery] = useState(initialSearch)
    const debouncedSearch = useDebounce(searchQuery, 300)

    const {
        borrowers,
        totalCount,
        stats,
        isLoading,
        isValidating,
        lastSync,
        refresh
    } = useBorrowerRegistry({
        search: debouncedSearch,
        page: currentPage,
        limit: ITEMS_PER_PAGE
    })

    const [selectedBorrower, setSelectedBorrower] = useState<any>(null)
    const [detailOpen, setDetailOpen] = useState(false)

    // Update URL when search or page changes
    const createQueryString = useCallback(
        (name: string, value: string) => {
            const params = new URLSearchParams(searchParams.toString())
            params.set(name, value)
            if (name === 'search') params.set('page', '1') // Reset to page 1 on new search
            return params.toString()
        },
        [searchParams]
    )

    useEffect(() => {
        router.push(pathname + '?' + createQueryString('search', debouncedSearch))
    }, [debouncedSearch, router, pathname, createQueryString])

    const handlePageChange = (page: number) => {
        router.push(pathname + '?' + createQueryString('page', page.toString()))
    }

    const handleSelectBorrower = (borrower: any) => {
        setSelectedBorrower(borrower)
        setDetailOpen(true)
    }

    // Deep-Link & Highlight Logic
    useEffect(() => {
        const id = searchParams.get('id')
        const highlight = searchParams.get('highlight')
        const search = searchParams.get('search')

        if (search && highlight === 'true' && borrowers.length > 0) {
            let target = borrowers.find(b => 
                (id && b.borrower_user_id === id) || 
                (b.borrower_name.toLowerCase() === search.toLowerCase())
            )

            if (!target && !isLoading) {
                target = {
                    borrower_user_id: id || '',
                    borrower_name: search,
                    borrower_email: '',
                    total_borrows: 0,
                    active_borrows: 0,
                    returned_count: 0,
                    total_items_handled: 0,
                    total_consumables_issued: 0,
                    active_items: 0,
                    return_rate_percent: 100,
                    overdue_count: 0,
                    is_verified_user: false,
                    user_role: 'responder',
                    user_status: 'active',
                }
            }

            if (target) handleSelectBorrower(target)
        }
    }, [searchParams, borrowers, isLoading])

    return (
        <div className="space-y-4 animate-in fade-in duration-500">
            <BorrowerHeader
                lastSync={lastSync}
                isValidating={isValidating}
                searchQuery={searchQuery}
                onSearchChange={setSearchQuery}
            />

            <div className="grid gap-4 grid-cols-2 md:grid-cols-4">
                <SummaryCard title="Total Borrowers" value={stats.totalBorrowers} label="People" color="blue" />
                <SummaryCard title="Active Borrowers" value={stats.activeBorrowersCount} label="Active" color="orange" />
                <SummaryCard title="Verified Users" value={stats.verifiedCount} label="Verified" color="indigo" />
                <SummaryCard title="Total Items Out" value={stats.totalInField} label="Units" color="emerald" />
            </div>

            <BorrowerTable
                borrowers={borrowers}
                totalCount={totalCount}
                currentPage={currentPage}
                itemsPerPage={ITEMS_PER_PAGE}
                onPageChange={handlePageChange}
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
