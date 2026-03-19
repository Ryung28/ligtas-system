-- d:\LIGTAS_SYSTEM\web\_db_scripts\get_active_chat_inbox_v2.sql

-- PHASE 1: Create the optimized DB view/RPC for the chat inbox
-- This function replaces the N+1 query loop in getChatRooms with a single, lightning-fast PGSQL execution plan.

CREATE OR REPLACE FUNCTION get_active_chat_inbox_v2(staff_uuid UUID)
RETURNS TABLE (
    chat_room_id UUID, 
    chat_borrower_user_id UUID,
    chat_borrow_request_id BIGINT,
    chat_borrower_id UUID,
    chat_borrower_full_name TEXT,
    chat_borrower_role TEXT,
    chat_borrower_last_seen TIMESTAMPTZ,
    chat_last_message_content TEXT,
    chat_last_message_created_at TIMESTAMPTZ,
    chat_last_message_sender_id UUID
) AS $$
BEGIN
    RETURN QUERY
    WITH existing_rooms AS (
        SELECT 
            cr.id AS room_id,
            cr.borrower_user_id,
            cr.borrow_request_id
        FROM chat_rooms cr
    ),
    last_msgs AS (
        SELECT DISTINCT ON (room_id)
            room_id,
            content AS last_message_content,
            created_at AS last_message_created_at,
            sender_id AS last_message_sender_id
        FROM chat_messages
        ORDER BY room_id, created_at DESC
    ),
    staff_profile AS (
        SELECT role FROM user_profiles WHERE user_profiles.id = staff_uuid LIMIT 1
    ),
    all_viewers AS (
        SELECT up.id, up.full_name, up.role, up.last_seen
        FROM user_profiles up
        CROSS JOIN staff_profile sp
        WHERE up.id != staff_uuid 
          AND (sp.role IN ('admin', 'editor') AND up.role = 'viewer')
    )
    SELECT 
        COALESCE(er.room_id, v.id) AS id, -- Fallback to user_id as deterministic room_id
        COALESCE(er.borrower_user_id, v.id) AS borrower_user_id,
        er.borrow_request_id,
        v.id AS borrower_id,
        v.full_name AS borrower_full_name,
        v.role AS borrower_role,
        v.last_seen AS borrower_last_seen,
        lm.last_message_content,
        lm.last_message_created_at,
        lm.last_message_sender_id
    FROM all_viewers v
    LEFT JOIN existing_rooms er ON er.borrower_user_id = v.id
    LEFT JOIN last_msgs lm ON lm.room_id = er.room_id

    UNION

    -- Cover active rooms for ghosts, or for the borrower calling this endpoint (they only see their room)
    SELECT 
        er.room_id AS id,
        er.borrower_user_id,
        er.borrow_request_id,
        er.borrower_user_id AS borrower_id,
        COALESCE(
            (SELECT full_name FROM user_profiles up WHERE up.id = er.borrower_user_id),
            (SELECT full_name FROM access_requests ar WHERE ar.user_id = er.borrower_user_id LIMIT 1),
            (SELECT borrower_name FROM borrow_logs bl WHERE bl.id = er.borrow_request_id LIMIT 1),
            (SELECT borrower_name FROM borrow_logs bl WHERE bl.borrower_user_id = er.borrower_user_id LIMIT 1),
            'Mobile User ' || SUBSTRING(er.borrower_user_id::text, 1, 4)
        ) AS borrower_full_name,
        COALESCE((SELECT role FROM user_profiles up WHERE up.id = er.borrower_user_id), 'viewer') AS borrower_role,
        (SELECT last_seen FROM user_profiles up WHERE up.id = er.borrower_user_id) AS borrower_last_seen,
        lm.last_message_content,
        lm.last_message_created_at,
        lm.last_message_sender_id
    FROM existing_rooms er
    LEFT JOIN last_msgs lm ON lm.room_id = er.room_id
    WHERE er.borrower_user_id NOT IN (SELECT id FROM all_viewers)
      -- Restrict via inline RLS logic: staff sees all ghosts, borrower only sees themselves.
      AND (
          (SELECT role FROM staff_profile) IN ('admin', 'editor')
          OR 
          er.borrower_user_id = staff_uuid
      )
    
    ORDER BY last_message_created_at DESC NULLS LAST;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
