export type TransactionStatus = 'borrowed' | 'returned' | 'overdue' | 'pending' | 'rejected' | 'cancelled' | 'mixed' | 'all';
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
    created_at: string;
}

export interface LogStats {
    total: number;
    borrowed: number;
    returned: number;
    overdue: number;
    pending: number;
    cancelled: number;
}
