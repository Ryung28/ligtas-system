'use client'

import { useState, useMemo } from 'react'
import {
    Search,
    X,
    UsersRound,
    ShieldCheck,
    Package,
    Activity,
    ChevronLeft,
    ChevronRight,
} from 'lucide-react'
import { MobileHeader } from '@/components/mobile/mobile-header'
import { EmptyState, ErrorState } from '@/components/mobile/primitives'
import { useBorrowerRegistry, type BorrowerStats } from '@/hooks/use-borrower-registry'
import { useDebounce } from '@/hooks/use-debounce'
import { cn } from '@/lib/utils'
import { mFocus } from '@/lib/mobile/tokens'
import { BorrowerCard } from './borrower-card'
import { BorrowerDetailSheet } from './borrower-detail-sheet'

const PAGE_SIZE = 20

export function BorrowersClient() {
    const [searchQuery, setSearchQuery] = useState('')
    const [page, setPage] = useState(1)
    const [selected, setSelected] = useState<BorrowerStats | null>(null)

    const debounced = useDebounce(searchQuery, 300)

    const {
        borrowers,
        totalCount,
        stats,
        isLoading,
        isValidating,
        refresh,
        error,
    } = useBorrowerRegistry({ search: debounced, page, limit: PAGE_SIZE })

    const totalPages = Math.max(1, Math.ceil(totalCount / PAGE_SIZE))

    const miniStats = useMemo(
        () => [
            {
                label: 'Total',
                value: stats.totalBorrowers,
                tone: 'bg-gray-900 text-white',
                icon: UsersRound,
            },
            {
                label: 'Active',
                value: stats.activeBorrowersCount,
                tone: 'bg-amber-50 text-amber-900 border border-amber-100',
                icon: Activity,
            },
            {
                label: 'Verified',
                value: stats.verifiedCount,
                tone: 'bg-blue-50 text-blue-900 border border-blue-100',
                icon: ShieldCheck,
            },
            {
                label: 'In field',
                value: stats.totalInField,
                tone: 'bg-emerald-50 text-emerald-900 border border-emerald-100',
                icon: Package,
            },
        ],
        [stats],
    )

    const handleSearchChange = (value: string) => {
        setSearchQuery(value)
        if (page !== 1) setPage(1)
    }

    return (
        <div className="space-y-5 pb-8">
            <MobileHeader
                title="Borrowers"
                onRefresh={refresh}
                isLoading={isValidating}
            />

            {/* Stats grid */}
            <section
                className="grid grid-cols-2 gap-3"
                aria-label="Borrower summary"
            >
                {miniStats.map((stat) => (
                    <div
                        key={stat.label}
                        className={cn(
                            'rounded-2xl p-3.5 flex items-center gap-3 shadow-sm',
                            stat.tone,
                        )}
                    >
                        <div className="w-9 h-9 rounded-xl bg-white/15 flex items-center justify-center shrink-0">
                            <stat.icon className="w-4 h-4" aria-hidden />
                        </div>
                        <div className="min-w-0">
                            <p className="text-[10px] font-bold uppercase tracking-widest opacity-70">
                                {stat.label}
                            </p>
                            <p className="text-xl font-black tabular-nums leading-tight">
                                {stat.value}
                            </p>
                        </div>
                    </div>
                ))}
            </section>

            {/* Search */}
            <div className="sticky top-[56px] z-40 -mx-4 px-4 pt-1 pb-3 bg-gray-50/95 backdrop-blur-md border-b border-gray-100">
                <label htmlFor="borrower-search" className="sr-only">
                    Search borrowers
                </label>
                <div className="relative group">
                    <div className="absolute inset-y-0 left-4 flex items-center pointer-events-none">
                        <Search className="w-5 h-5 text-gray-400 group-focus-within:text-red-500 motion-safe:transition-colors" />
                    </div>
                    <input
                        id="borrower-search"
                        type="search"
                        value={searchQuery}
                        onChange={(e) => handleSearchChange(e.target.value)}
                        placeholder="Search by name…"
                        autoComplete="off"
                        className={cn(
                            'w-full h-12 bg-white border border-gray-200 rounded-2xl pl-12 pr-10 text-sm',
                            'focus:outline-none focus:ring-2 focus:ring-red-500/20 focus:border-red-500',
                            'motion-safe:transition-all shadow-sm',
                        )}
                    />
                    {searchQuery && (
                        <button
                            type="button"
                            onClick={() => handleSearchChange('')}
                            className={cn(
                                'absolute inset-y-0 right-2 my-auto w-8 h-8 flex items-center justify-center rounded-full',
                                'text-gray-400 hover:text-gray-700 hover:bg-gray-100',
                                mFocus,
                            )}
                            aria-label="Clear search"
                        >
                            <X className="w-4 h-4" />
                        </button>
                    )}
                </div>
            </div>

            {/* List */}
            {error ? (
                <ErrorState
                    title="Couldn't load borrowers"
                    description="Check your connection and try again."
                    onRetry={refresh}
                    isRetrying={isValidating}
                />
            ) : isLoading && borrowers.length === 0 ? (
                <div className="space-y-3">
                    {[1, 2, 3, 4, 5].map((i) => (
                        <div
                            key={i}
                            className="h-24 rounded-2xl bg-white border border-gray-100 animate-pulse"
                        />
                    ))}
                </div>
            ) : borrowers.length === 0 ? (
                <EmptyState
                    icon={UsersRound}
                    title={debounced ? 'No matches' : 'No borrowers yet'}
                    description={
                        debounced
                            ? `No borrower matches "${debounced}".`
                            : 'Borrowers appear here after their first approved request.'
                    }
                    action={
                        debounced ? { label: 'Clear search', onClick: () => handleSearchChange('') } : undefined
                    }
                />
            ) : (
                <>
                    <ul className="space-y-3" aria-label="Borrower list">
                        {borrowers.map((b) => (
                            <li
                                key={
                                    b.borrower_user_id
                                        ? `u:${b.borrower_user_id}`
                                        : `n:${b.borrower_name}`
                                }
                            >
                                <BorrowerCard borrower={b} onSelect={setSelected} />
                            </li>
                        ))}
                    </ul>

                    {totalPages > 1 && (
                        <div
                            className="flex items-center justify-between bg-white rounded-2xl border border-gray-100 p-2 mt-4 shadow-sm"
                            role="navigation"
                            aria-label="Pagination"
                        >
                            <button
                                type="button"
                                onClick={() => setPage((p) => Math.max(1, p - 1))}
                                disabled={page === 1 || isValidating}
                                className={cn(
                                    'h-10 px-3 rounded-xl text-xs font-bold uppercase tracking-wider',
                                    'text-gray-700 hover:bg-gray-50 disabled:opacity-40 disabled:pointer-events-none',
                                    'inline-flex items-center gap-1 motion-safe:transition-colors',
                                    mFocus,
                                )}
                            >
                                <ChevronLeft className="w-4 h-4" aria-hidden />
                                Prev
                            </button>
                            <span className="text-xs font-semibold text-gray-600 tabular-nums">
                                Page {page} of {totalPages}
                            </span>
                            <button
                                type="button"
                                onClick={() => setPage((p) => Math.min(totalPages, p + 1))}
                                disabled={page >= totalPages || isValidating}
                                className={cn(
                                    'h-10 px-3 rounded-xl text-xs font-bold uppercase tracking-wider',
                                    'text-gray-700 hover:bg-gray-50 disabled:opacity-40 disabled:pointer-events-none',
                                    'inline-flex items-center gap-1 motion-safe:transition-colors',
                                    mFocus,
                                )}
                            >
                                Next
                                <ChevronRight className="w-4 h-4" aria-hidden />
                            </button>
                        </div>
                    )}
                </>
            )}

            <BorrowerDetailSheet
                borrower={selected}
                onOpenChange={(o) => !o && setSelected(null)}
            />
        </div>
    )
}
