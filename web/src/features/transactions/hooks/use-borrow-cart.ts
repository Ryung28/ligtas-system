'use client';

import { useState } from 'react';
import { AvailableItem } from './use-available-catalog';
import { toast } from 'sonner';

export interface CartItem {
    item: AvailableItem;
    quantity: number;
    selectedVariantId?: number | null;
    selectedVariantName?: string | null;
}

/**
 * useBorrowCart Hook
 * Managed the temporary session "Cart" for batch dispatching.
 */
export function useBorrowCart() {
    const [cart, setCart] = useState<CartItem[]>([]);

    const addToCart = (item: AvailableItem, quantity: number, variantId?: number | null, variantName?: string | null) => {
        // Validation: Stock Check (Blueprint or Variant)
        const availableCount = variantId 
            ? item.variants?.find(v => v.id === variantId)?.stock_available || 0
            : item.primary_stock_available;

        if (quantity > availableCount) {
            toast.error(`Stock Error: Only ${availableCount} units available at this location.`);
            return;
        }

        // Validation: Duplicate Check (Now by ID + Variant)
        if (cart.find(c => c.item.id === item.id && c.selectedVariantId === variantId)) {
            toast.error('This specific variant is already in your dispatch queue.');
            return;
        }

        setCart(prev => [...prev, { item, quantity, selectedVariantId: variantId, selectedVariantName: variantName }]);
        toast.success(`${item.item_name} (${variantName || 'Primary'}) added to dispatch queue.`);
    };

    const removeFromCart = (itemId: number) => {
        setCart(prev => prev.filter(c => c.item.id !== itemId));
    };

    const clearCart = () => setCart([]);

    return {
        cart,
        addToCart,
        removeFromCart,
        clearCart,
        isEmpty: cart.length === 0
    };
}
