-- Function to allow Admins to change user roles
CREATE OR REPLACE FUNCTION public.update_user_role(target_user_id UUID, new_role TEXT)
RETURNS BOOLEAN AS $$
DECLARE
    is_super_admin BOOLEAN;
BEGIN
    -- Security Check: Executor must be an Active Admin
    SELECT (role = 'admin' AND status = 'active') INTO is_super_admin
    FROM user_profiles WHERE id = auth.uid();

    IF NOT is_super_admin THEN
        RAISE EXCEPTION 'Unauthorized: Only active admins can manage roles';
    END IF;

    -- Update Role
    UPDATE user_profiles 
    SET role = new_role 
    WHERE id = target_user_id;

    RETURN TRUE;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
