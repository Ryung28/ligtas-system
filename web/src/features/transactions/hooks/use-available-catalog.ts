'use client';

import { useState, useEffect, useCallback } from 'react';
import { getAvailableItems } from '../../catalog/queries/catalog.queries';
import { toast } from 'sonner';

export interface AvailableItem {
    id: number;
    item_name: string;
    category: string;
    item_type?: 'equipment' | 'consumable';
    image_url: string | null;
    storage_location: string;
    primary_stock_available: number;
    aggregate_available: number;
    variants: Array<{
        id: number;
        storage_location: string;
        stock_available: number;
        stock_total: number;
    }>;
    status: string;
    packaging_json?: any;
}

/**
 * useAvailableCatalog
 * A domain-specific hook for the ResQTrack inventory dispatch engine.
 * 
 * The Manager's Strategy: "Logistical Buffering"
 * Loads the entire available catalog once and provides high-speed local filtering.
 */
// 🏛️ PERSISTENT LOGISTICS CACHE: Lives inside the hook to survive re-mounts
// REMOVED GLOBAL BUFFER to prevent "stale stock" ghosting reported by users.
let LAST_SYNC_TIME = 0;
const CACHE_TTL = 2000; // 2 seconds fresh buffer for high-speed dispatching

export function useAvailableCatalog(autoLoad = true) {
    const [items, setItems] = useState<AvailableItem[]>([]);
    const [isLoading, setIsLoading] = useState(false);
    const [error, setError] = useState<string | null>(null);

    const fetchCatalog = useCallback(async (force = false) => {
        // Return current state if still extremely fresh
        if (!force && items.length > 0 && (Date.now() - LAST_SYNC_TIME < CACHE_TTL)) {
            return;
        }

        setIsLoading(true);
        setError(null);
        try {
            const result = await getAvailableItems();
            if (result.success && result.data) {
                const rawItems = result.data as any[];

                // SMART NAME-GROUPING ENGINE
                // Group everything by name to collapse duplicates into a single card
                const groupedByName: Record<string, any[]> = {};

                rawItems.forEach(item => {
                    const nameKey = item.item_name.toLowerCase().trim();
                    if (!groupedByName[nameKey]) {
                        groupedByName[nameKey] = [];
                    }
                    groupedByName[nameKey].push(item);
                });

                const normalized = Object.values(groupedByName).map(group => {
                    // Sort so the one without a parent id (or just the first one) is the "Primary"
                    const sortedGroup = group.sort((a, b) => {
                        if (a.parent_id === null && b.parent_id !== null) return -1;
                        if (a.parent_id !== null && b.parent_id === null) return 1;
                        return 0;
                    });

                    const primary = sortedGroup[0];
                    const otherEntries = sortedGroup.slice(1);

                    // Map all other entries as variants
                    const variants = otherEntries.map(v => ({
                        id: v.id,
                        storage_location: v.storage_location || 'Satellite',
                        stock_available: v.stock_available || 0,
                        stock_total: v.stock_total || 0
                    }));

                    const variantStock = variants.reduce((acc, v) => acc + v.stock_available, 0);

                    return {
                        ...primary,
                        primary_stock_available: primary.stock_available || 0,
                        aggregate_available: (primary.stock_available || 0) + variantStock,
                        variants: variants,
                        packaging_json: group.find(item => item.packaging_json?.enabled)?.packaging_json || primary.packaging_json
                    };
                });

                LAST_SYNC_TIME = Date.now();
                setItems(normalized as AvailableItem[]);
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
