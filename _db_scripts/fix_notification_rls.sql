-- web/_db_scripts/fix_notification_rls.sql
-- Resolve the RLS violation on the system_notifications table

-- 1. Create Supabase RLS Policy to explicitly allow authenticated inserts
CREATE POLICY "Allow authenticated insert notifications" 
ON system_notifications 
FOR INSERT 
WITH CHECK (auth.role() = 'authenticated');

-- 2. PostgreSQL Function with SECURITY DEFINER to automate notification insertion 
--    and bypass client-side RLS restrictions completely.
CREATE OR REPLACE FUNCTION handle_new_borrow_request() 
RETURNS TRIGGER AS $$
BEGIN
  INSERT INTO system_notifications (
    title, 
    message, 
    type, 
    created_at
  ) VALUES (
    'New Pre-Borrow Request',
    'A mobile user has initiated a pre-borrow request.',
    'borrow_request',
    NOW()
  );
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- 3. Attach standard AFTER INSERT trigger to automate the call 
--    whenever a mobile user inserts a new pre-borrow request log.
DROP TRIGGER IF EXISTS trigger_new_borrow_request ON borrow_logs;

CREATE TRIGGER trigger_new_borrow_request
AFTER INSERT ON borrow_logs
FOR EACH ROW
EXECUTE FUNCTION handle_new_borrow_request();
