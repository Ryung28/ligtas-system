'use client'

import { useState, useEffect, useCallback } from 'react'
import { useRouter, useSearchParams, usePathname } from 'next/navigation'
import { BorrowerHeader } from '@/components/users/borrower-header'
import { SummaryCard } from '@/components/dashboard/summary-card'
import { BorrowerTable } from '@/components/users/borrower-table'
import { BorrowerDossier } from '@/components/users/borrower-dossier'
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

    // 🛡️ COMMAND DECK: Selected borrower drives the right panel (NO MODAL)
    const [selectedBorrower, setSelectedBorrower] = useState<any>(null)

    // Update URL when search changes, but ONLY if the search query actually changed
    // Prevents the "Pagination Reset" bug where changing pages triggers this effect
    const createQueryString = useCallback(
        (name: string, value: string) => {
            const params = new URLSearchParams(searchParams.toString())
            params.set(name, value)
            if (name === 'search') params.set('page', '1')
            return params.toString()
        },
        [searchParams]
    )

    useEffect(() => {
        const currentSearch = searchParams.get('search') || ''
        if (debouncedSearch !== currentSearch) {
            router.push(pathname + '?' + createQueryString('search', debouncedSearch))
        }
    }, [debouncedSearch, router, pathname, createQueryString, searchParams])

    const handlePageChange = (page: number) => {
        router.push(pathname + '?' + createQueryString('page', page.toString()))
    }

    const handleSelectBorrower = (borrower: any) => {
        setSelectedBorrower(prev =>
            // Toggle off if clicking the same row
            prev && (
                borrower.borrower_user_id
                    ? prev.borrower_user_id === borrower.borrower_user_id
                    : prev.borrower_name === borrower.borrower_name
            ) ? null : borrower
        )
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

            if (target) setSelectedBorrower(target)
        }
    }, [searchParams, borrowers, isLoading])

    return (
        // 🛡️ STEEL CAGE: Viewport clamp — nothing pushes below the fold
        <div className="flex flex-col h-full gap-4 animate-in fade-in duration-200">

            {/* ── TOP CONTROLS ────────────────────────────────────────── */}
            <BorrowerHeader
                lastSync={lastSync}
                isValidating={isValidating}
                searchQuery={searchQuery}
                onSearchChange={setSearchQuery}
            />

            {/* ── SUMMARY STATS ────────────────────────────────────────── */}
            <div className="grid gap-3 grid-cols-2 md:grid-cols-4 shrink-0">
                <SummaryCard title="Total Borrowers" value={stats.totalBorrowers} label="People" color="blue" />
                <SummaryCard title="Active Borrowers" value={stats.activeBorrowersCount} label="Active" color="orange" />
                <SummaryCard title="Verified Users" value={stats.verifiedCount} label="Verified" color="indigo" />
                <SummaryCard title="Total Items Out" value={stats.totalInField} label="Units" color="emerald" />
            </div>

            {/* ── COMMAND DECK: Split View ──────────────────────────────── */}
            <div className="flex flex-1 min-h-0 gap-4">

                {/* LEFT PANEL: Registry Table — independently scrollable */}
                <div className="flex-1 min-w-0 overflow-y-auto rounded-xl">
                    <BorrowerTable
                        borrowers={borrowers}
                        totalCount={totalCount}
                        currentPage={currentPage}
                        itemsPerPage={ITEMS_PER_PAGE}
                        onPageChange={handlePageChange}
                        isLoading={isLoading}
                        onSelectBorrower={handleSelectBorrower}
                        selectedBorrower={selectedBorrower}
                    />
                </div>

                {/* RIGHT PANEL: Identity Dossier — persistent, zero modals */}
                <div className="hidden lg:flex w-[360px] xl:w-[400px] shrink-0 flex-col overflow-hidden rounded-xl border border-gray-200/80 bg-white shadow-sm">
                    <div className="flex items-center justify-between px-4 py-2.5 border-b border-gray-100 shrink-0 bg-gray-50/80">
                        <p className="text-[10px] font-black text-gray-400 uppercase tracking-widest">
                            Person Details
                        </p>
                        {selectedBorrower && (
                            <button
                                onClick={() => setSelectedBorrower(null)}
                                className="text-[10px] text-gray-400 hover:text-gray-600 font-medium transition-colors"
                            >
                                Clear
                            </button>
                        )}
                    </div>
                    <div className="flex-1 min-h-0 overflow-y-auto">
                        <BorrowerDossier
                            borrower={selectedBorrower}
                            onRefresh={refresh}
                        />
                    </div>
                </div>
            </div>
        </div>
    )
}
