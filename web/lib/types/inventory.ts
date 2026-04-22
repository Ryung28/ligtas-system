
export type TransactionStatus = 'all' | 'borrowed' | 'returned' | 'pending' | 'overdue' | 'lost' | 'damaged' | 'maintenance' | 'reserved' | 'staged' | 'denied' | 'dispensed';

export interface BorrowLog {
    id: number;
    inventory_id: number | null;
    item_name: string;
    borrower_name: string;
    borrower_email: string | null;
    borrower_organization: string | null;
    borrower_contact: string | null;
    borrower_user_id: string | null;
    quantity: number;
    status: TransactionStatus;
    borrow_date: string;
    expected_return_date: string | null;
    actual_return_date: string | null;
    return_condition: string | null;
    return_notes: string | null;
    received_by_name: string | null;
    returned_by_name: string | null;
    approved_by_name: string | null;
    released_by_name: string | null;
    platform_origin: string | null;
    pickup_scheduled_at: string | null;
    return_scheduled_at: string | null;
    purpose: string | null;
    created_at: string;
    updated_at: string | null;
    inventory?: {
        item_name?: string;
        image_url?: string | null;
        item_type?: string;
        category?: string;
        serial_number?: string;
        model_number?: string;
        brand?: string;
        expiry_date?: string;
        storage_location?: string;
    };
    image_url?: string | null;
}

export interface BorrowSession {
    key: string;
    borrower_name: string;
    borrower_organization: string | null;
    created_at: string;
    items: BorrowLog[];
    total_items: number;
    total_quantity: number;
    status: 'mixed' | TransactionStatus;
}

export interface LogStats {
    total: number;
    active: number;
    pending: number;
    staged: number;
    borrowed: number;
    returned: number;
    reserved: number;
    overdue: number;
    returned_today: number;
}
