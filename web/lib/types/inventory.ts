export type TransactionStatus = 'borrowed' | 'returned' | 'overdue' | 'pending' | 'rejected' | 'cancelled' | 'mixed' | 'all' | 'staged' | 'reserved';
export type TransactionType = 'borrow' | 'return';

export interface BorrowLog {
    id: number;
    inventory_id: number;
    item_name: string;
    quantity: number;
    borrower_name: string;
    borrower_contact: string;
    borrower_organization: string;
    transaction_type: TransactionType;
    borrow_date: string;
    expected_return_date: string | null;
    actual_return_date: string | null;
    status: TransactionStatus;
    notes?: string;
    purpose?: string;
    approved_by_name?: string | null;
    released_by_name?: string | null;
    released_by_user_id?: string | null;
    received_by_name?: string | null;
    received_by_user_id?: string | null;
    return_condition?: string | null;
    return_notes?: string | null;
    pickup_scheduled_at?: string | null;
    platform_origin?: 'Web' | 'Mobile';
    created_origin?: 'Web' | 'Mobile' | null;
    last_updated_origin?: 'Web' | 'Mobile' | null;
    created_at: string;
}

export interface BorrowSession {
    key: string; // borrower_name + timestamp_minute
    borrower_name: string;
    borrower_organization: string;
    borrower_contact: string;
    items: BorrowLog[];
    total_quantity: number;
    status: TransactionStatus;
    approved_by_name?: string | null;
    released_by_name?: string | null;
    pickup_scheduled_at?: string | null;
    platform_origin?: 'Web' | 'Mobile';
    created_origin?: 'Web' | 'Mobile' | null;
    last_updated_origin?: 'Web' | 'Mobile' | null;
    created_at: string;
}

export interface LogStats {
    total: number;
    borrowed: number;
    returned: number;
    overdue: number;
    pending: number;
    staged: number;
    reserved: number;
}
