# Admin Profile Fix - Borrow Logs Not Displaying

## The Problem

You're logged into the web dashboard as an admin, but you see **"No transactions found"** on the Borrow/Return Logs page, even though logs exist in the database.

## Root Cause: The "Ghost Admin" Issue

In Supabase, there are two separate identity systems:

1. **Auth System** (`auth.users`) - Manages login credentials (email/password)
2. **Public System** (`public.user_profiles`) - Manages roles and permissions

**The Issue**: Your account exists in `auth.users` but has NO corresponding row in `user_profiles`.

### Why This Breaks Everything

All RLS (Row Level Security) policies check `user_profiles` to determine your role:

```sql
-- This is what every policy does:
SELECT role FROM user_profiles WHERE id = auth.uid()
```

If there's no row, the query returns `NULL`, and the system treats you as a **guest with zero permissions**.

### Analogy

You have the key to the building (`auth.users`), but once inside, the security guard asks for your ID badge (`user_profiles`). Since you don't have one, they won't let you access any files.

## The Solution

Run the quick fix script to create your admin profile:

### Option 1: Quick Fix (Recommended)

1. Open Supabase Dashboard → SQL Editor
2. Copy and paste `QUICK_FIX_admin_profile.sql`
3. Click "Run"
4. Hard refresh your web dashboard (Ctrl+Shift+R or Cmd+Shift+R)

### Option 2: Manual Fix

If you know your admin email, run this:

```sql
INSERT INTO public.user_profiles (id, full_name, email, role, status, assigned_warehouse)
SELECT 
    id,
    COALESCE(raw_user_meta_data->>'full_name', email),
    email,
    'admin',
    'active',
    NULL
FROM auth.users
WHERE email = 'your-admin@email.com'
ON CONFLICT (id) DO UPDATE
SET role = 'admin', status = 'active', assigned_warehouse = NULL;
```

## Prevention: Auto-Create Profiles

To prevent this from happening again, run `auto_create_user_profile_trigger.sql`. This creates a database trigger that automatically creates a `user_profiles` row whenever a new user signs up.

## Verification

After running the fix, verify it worked:

```sql
-- Check your profile exists
SELECT id, email, role, status FROM user_profiles WHERE id = auth.uid();

-- Check you can see logs
SELECT COUNT(*) FROM borrow_logs;
```

You should see:
- Your profile with `role = 'admin'`
- A count of all borrow logs (e.g., 10)

## Technical Details

### Why RLS Policies Failed

The `borrow_logs` SELECT policy uses this logic:

```sql
USING (
    public.is_admin()  -- This checks user_profiles
    OR ...
)
```

The `is_admin()` function does:

```sql
SELECT EXISTS (
    SELECT 1 FROM user_profiles 
    WHERE id = auth.uid() AND role = 'admin'
)
```

If there's no row in `user_profiles`, this returns `FALSE`, and you see nothing.

### Why Warehouse Assignment Matters

For admin users:
- `assigned_warehouse = NULL` means **full access to all warehouses**
- `assigned_warehouse = '2nd_floor_warehouse'` means **restricted to that warehouse only**

The fix script sets `assigned_warehouse = NULL` to give you full admin access.

## Files Created

1. `QUICK_FIX_admin_profile.sql` - Immediate fix (run this first)
2. `fix_missing_admin_profile.sql` - Detailed fix with verification
3. `auto_create_user_profile_trigger.sql` - Prevention (run after fix)
4. `diagnose_current_user.sql` - Diagnostic tool (already exists)

## Next Steps

1. Run `QUICK_FIX_admin_profile.sql` in Supabase SQL Editor
2. Hard refresh web dashboard
3. Check Borrow/Return Logs page - you should see all logs
4. Run `auto_create_user_profile_trigger.sql` to prevent future issues
