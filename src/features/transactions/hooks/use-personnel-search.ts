'use client'

import { useState, useEffect } from 'react'
import { searchPersonnel, BorrowerPersonnel } from '@/src/features/transactions/queries/transaction.queries'

export function usePersonnelSearch(query: string) {
    const [results, setResults] = useState<BorrowerPersonnel[]>([])
    const [isLoading, setIsLoading] = useState(false)

    useEffect(() => {
        const handler = setTimeout(async () => {
            if (!query || query.length < 1) {
                setResults([])
                return
            }

            setIsLoading(true)
            try {
                const res = await searchPersonnel(query)
                if (res.success && res.data) {
                    setResults(res.data)
                }
            } catch (err) {
                console.error('Search hook error:', err)
            } finally {
                setIsLoading(false)
            }
        }, 300)

        return () => clearTimeout(handler)
    }, [query])

    return { results, isLoading }
}
