/**
 * 🛡️ SYSTEM ROUTE RESOLVER (SSOT)
 * 
 * Centralized engine for resolving deep-link URLs across the entire ResQTrack ecosystem.
 * Handles polymorphic inputs from Notifications, System Intel, and Audit Logs.
 */

export interface RouteContext {
    type: string;
    category?: string;
    metadata?: any;
    referenceId?: string | number | null;
    reference_id?: string | number | null;
    id?: string | number | null;
    title?: string;
}

export const resolveSystemRoute = (ctx: RouteContext): string | null => {
    const type = (ctx.type || '').toLowerCase();
    const category = (ctx.category || '').toUpperCase();
    const meta = ctx.metadata || {};
    const title = ctx.title || "";
    
    // 🛡️ IDENTITY CONTRACT: Standardize ID resolution across all payload variants
    const refId = meta.borrow_id || meta.log_id || meta.item_id || ctx.referenceId || ctx.reference_id || meta.id || '';

    // 1. ASSET DOMAIN (Inventory Hub)
    const inventoryTypes = ['stock_low', 'stock_out', 'low_stock', 'inventory_alert', 'restock_alert', 'inventory'];
    const isInventoryContext = 
        category === 'INVENTORY' || 
        inventoryTypes.includes(type) || 
        (String(ctx.id || '').startsWith('inv-'));

    if (isInventoryContext) {
        const itemId = meta.item_id || meta.id || refId || '';
        const itemName = meta.item_name || meta.search_query || title;
        // Ensure we don't pass a UUID as an inventory BigInt ID
        const cleanId = String(itemId).includes('-') && !String(itemId).startsWith('inv-') ? '' : itemId;
        return `/dashboard/inventory?id=${cleanId}&search=${encodeURIComponent(itemName)}&highlight=true`;
    }

    // 2. IDENTITY/LOGISTICS DOMAIN (Logs & Transactions)
    const identityTypes = [
        'borrow_request', 'item_overdue', 'item_returned', 'borrow', 'return',
        'user_pending', 'user_request', 'borrow_approved', 'borrow_rejected', 
        'overdue_alert', 'logistics_alert', 'logistics'
    ];
    
    const targetName = meta.search_query || meta.borrower_name || meta.requester_name || "";
    const isIdentityContext = 
        category === 'LOGISTICS' || 
        category === 'OVERDUE' ||
        identityTypes.includes(type) || 
        (String(ctx.id || '').startsWith('log-') || String(ctx.id || '').startsWith('bor-')) ||
        targetName.length > 0;

    if (isIdentityContext) {
        const transactionId = meta.borrow_id || meta.log_id || refId || '';
        // If ID is a UUID but we are in logistics, we should rely on search name fallback
        const cleanTxId = String(transactionId).includes('-') ? '' : transactionId;
        return `/dashboard/logs?id=${cleanTxId}&search=${encodeURIComponent(targetName)}&highlight=true`;
    }

    // 3. ACCESS DOMAIN
    if (category === 'ACCESS' || type.startsWith('user_')) {
        return '/dashboard/users?tab=requests';
    }

    return null;
};
