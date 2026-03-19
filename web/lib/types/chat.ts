export interface ChatMessage {
    id: string;
    room_id: string;
    sender_id: string;
    content: string;
    created_at: string;
    is_read: boolean;
    status?: 'sending' | 'sent' | 'error';
}

export interface ChatRoom {
    id: string;
    borrow_request_id: number;
    created_at: string;
}
