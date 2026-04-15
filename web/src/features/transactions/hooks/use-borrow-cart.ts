'use client';

import { useState } from 'react';
import { AvailableItem } from './use-available-catalog';
import { toast } from 'sonner';

export interface CartItem {
    item: AvailableItem;
    quantity: number;
}

/**
 * useBorrowCart Hook
 * Managed the temporary session "Cart" for batch dispatching.
 */
export function useBorrowCart() {
    const [cart, setCart] = useState<CartItem[]>([]);

    const addToCart = (item: AvailableItem, quantity: number) => {
        // Validation: Stock Check
        if (quantity > item.primary_stock_available) {
            toast.error(`Stock Error: Only ${item.primary_stock_available} units at this site.`);
            return;
        }

        // Validation: Duplicate Check
        if (cart.find(c => c.item.id === item.id)) {
            toast.error('Item is already in your dispatch queue.');
            return;
        }

        setCart(prev => [...prev, { item, quantity }]);
        toast.success(`${item.item_name} added to dispatch queue.`);
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
