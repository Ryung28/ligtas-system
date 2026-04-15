"use client"

import React, { createContext, useContext, useEffect, useMemo } from "react"
import useSWR, { mutate as globalMutate } from "swr"
import { createClient } from "@/lib/supabase-browser"
import { InventoryItem } from "@/lib/supabase"
import { fetchInventory } from "@/lib/queries/inventory"
import { INVENTORY_CACHE_KEY } from "@/hooks/use-inventory"

interface InventoryContextType {
    inventory: InventoryItem[]
    isLoading: boolean
    lastUpdated: Date
    refresh: () => Promise<void>
}

const InventoryContext = createContext<InventoryContextType | undefined>(undefined)

/**
 * 📦 LIGTAS GLOBAL INVENTORY PROVIDER
 * 🛡️ SUPER SENIOR PROTOCOL: Background Lifecycle Management
 * This provider establishes the Realtime connection ONCE for the entire session.
 * It prevents the "Connect/Disconnect" lag when navigating between pages.
 */
export function InventoryProvider({ children }: { children: React.ReactNode }) {
    const supabase = createClient()
    const [lastUpdated, setLastUpdated] = React.useState(new Date())

    // ── 1. The Global Master Data Fetch ──
    const { data: inventory = [], isLoading, mutate: refresh, isValidating } = useSWR(
        INVENTORY_CACHE_KEY, 
        fetchInventory, 
        {
            revalidateOnFocus: false,
            dedupingInterval: 30000, // 30s master dedupe
            persistSize: true,
        }
    )

    // ── 2. The Singleton Realtime Engine ──
    useEffect(() => {
        // We establish the channel once and keep it alive
        const channel = supabase
            .channel('global-inventory-sync')
            .on('postgres_changes', { event: '*', schema: 'public', table: 'inventory' }, () => {
                // Background revalidate when changes occur
                refresh()
                setLastUpdated(new Date())
            })
            .on('postgres_changes', { event: '*', schema: 'public', table: 'borrow_logs' }, () => {
                // Also Refresh when logs change to keep availability numbers accurate
                refresh()
                globalMutate('borrow_logs')
            })
            .subscribe()

        return () => {
            supabase.removeChannel(channel)
        }
    }, [refresh, supabase])

    const value = useMemo(() => ({
        inventory: Array.isArray(inventory) ? inventory : [],
        isLoading: isLoading || isValidating,
        lastUpdated,
        refresh: async () => { await refresh() }
    }), [inventory, isLoading, isValidating, lastUpdated, refresh])

    return (
        <InventoryContext.Provider value={value}>
            {children}
        </InventoryContext.Provider>
    )
}

export function useGlobalInventory() {
    const context = useContext(InventoryContext)
    if (context === undefined) {
        throw new Error("useGlobalInventory must be used within an InventoryProvider")
    }
    return context
}
