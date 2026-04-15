'use client';

import { useState, useEffect, useCallback } from 'react';
import { getAvailableItems } from '../../catalog/queries/catalog.queries';
import { toast } from 'sonner';

export interface AvailableItem {
    id: number;
    item_name: string;
    category: string;
    item_type?: 'equipment' | 'consumable';
    primary_location: string;
    primary_stock_available: number;
    aggregate_available: number;
    stock_pending: number;
    image_url?: string;
    variants: Array<{
        id: number;
        location: string;
        stock_available: number;
        stock_total: number;
    }>;
    status: string;
}

/**
 * useAvailableCatalog
 * A domain-specific hook for the LIGTAS inventory dispatch engine.
 * 
 * The Manager's Strategy: "Logistical Buffering"
 * Loads the entire available catalog once and provides high-speed local filtering.
 */
// 🏛️ PERSISTENT LOGISTICS CACHE: Lives outside the hook to survive re-mounts
let CATALOG_CACHE_BUFFER: AvailableItem[] = [];
let LAST_SYNC_TIME = 0;
const CACHE_TTL = 30000; // 30 seconds fresh buffer

export function useAvailableCatalog(autoLoad = true) {
    const [items, setItems] = useState<AvailableItem[]>(CATALOG_CACHE_BUFFER);
    const [isLoading, setIsLoading] = useState(false);
    const [error, setError] = useState<string | null>(null);

    const fetchCatalog = useCallback(async (force = false) => {
        // Return cached version if still fresh and not forced
        if (!force && CATALOG_CACHE_BUFFER.length > 0 && (Date.now() - LAST_SYNC_TIME < CACHE_TTL)) {
            setItems(CATALOG_CACHE_BUFFER);
            return;
        }

        setIsLoading(true);
        setError(null);
        try {
            const result = await getAvailableItems();
            if (result.success && result.data) {
                CATALOG_CACHE_BUFFER = result.data as AvailableItem[];
                LAST_SYNC_TIME = Date.now();
                setItems(CATALOG_CACHE_BUFFER);
            } else {
                const errMsg = result.error || 'Failed to sync with logistics engine.';
                setError(errMsg);
                toast.error(errMsg);
            }
        } catch (err) {
            console.error('Catalog Hook Sync Error:', err);
            setError('Operational Timeout');
            toast.error('Logistics server timeout.');
        } finally {
            setIsLoading(false);
        }
    }, []);

    useEffect(() => {
        if (autoLoad) {
            fetchCatalog();
        }
    }, [autoLoad, fetchCatalog]);

    /**
     * Search Helper: Instant local filtering
     */
    const filterCatalog = (search: string) => {
        if (!search) return items;
        const normalized = search.toLowerCase();
        return items.filter(i => 
            i.item_name.toLowerCase().includes(normalized) || 
            (i.category && i.category.toLowerCase().includes(normalized))
        );
    };

    return {
        items,
        isLoading,
        error,
        refresh: () => fetchCatalog(true),
        filterCatalog
    };
}
