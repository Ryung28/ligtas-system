# LIGTAS System - Pending Access Migration Guide

## 🎯 Overview
This migration implements a **"Post-Registration Approval"** workflow, solving the friction of pre-whitelisting users who don't have official email addresses (volunteers, NGO partners, etc.).

### Before (Pre-Approval Whitelist)
- ❌ Users needed to be manually whitelisted **before** they could sign in
- ❌ Non-LGU users without Gmail struggled to get access
- ❌ No visibility into who tried to access the system
- ❌ Administrative bottleneck

### After (Pending Access)
- ✅ Anyone can download the app and sign in
- ✅ New signups default to "Pending" status
- ✅ Pending users see a friendly "Awaiting Approval" screen
- ✅ Admins approve/reject users via the web dashboard
- ✅ Full audit trail of all access requests

---

## 📋 Implementation Status

### ✅ Completed - Backend (Database)
- **File**: `web/_db_scripts/pending_access_migration.sql`
- Added `status` column to `user_profiles` (pending/active/suspended)
- Updated Row Level Security (RLS) policies
- Created `access_requests` audit table
- Added helper functions: `approve_user()`, `reject_user()`

### ✅ Completed - Frontend (Web Dashboard)
- **File**: `web/hooks/use-user-management.ts`
  - Added TypeScript interfaces for UserProfile and AccessRequest
  - Implemented approve/reject/suspend/reactivate functions
  - Maintained backward compatibility with whitelist system

- **File**: `web/components/users/pending-access-table.tsx`
  - New component for Access Requests tab
  - Role selection dropdown (admin/editor/viewer)
  - Approve/Reject confirmation dialogs
  - Time-ago display for request timestamps

- **File**: `web/app/dashboard/users/page.tsx`
  - Tabbed interface: "Active Staff" and "Access Requests"
  - Updated stats cards to show pending count
  - Integrated PendingAccessTable component

### ⏳ Pending - Mobile App
You'll need to update the Flutter mobile app to handle the "pending" status:

1. **Update Auth Check**:
   ```dart
   // In your main navigation guard
   if (userProfile.status == 'pending') {
     return PendingApprovalScreen();
   } else if (userProfile.status == 'active') {
     return MainApp();
   } else {
     return AccessDeniedScreen(); // suspended
   }
   ```

2. **Create PendingApprovalScreen**:
   ```dart
   class PendingApprovalScreen extends StatelessWidget {
     @override
     Widget build(BuildContext context) {
       return Scaffold(
         body: Center(
           child: Column(
             mainAxisAlignment: MainAxisAlignment.center,
             children: [
               Icon(Icons.schedule, size: 80, color: Colors.orange),
               SizedBox(height: 20),
               Text('Access Pending',
                   style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
               SizedBox(height: 10),
               Padding(
                 padding: EdgeInsets.symmetric(horizontal: 40),
                 child: Text(
                   'Your account is awaiting approval by the LIGTAS administrator.',
                   textAlign: TextAlign.center,
                   style: TextStyle(color: Colors.grey[600]),
                 ),
               ),
             ],
           ),
         ),
       );
     }
   }
   ```

---

## 🚀 Migration Steps

### Step 1: Run the Database Migration
```sql
-- In Supabase SQL Editor, run:
-- File: web/_db_scripts/pending_access_migration.sql
```

**What this does**:
- Adds `status` column to all user profiles
- Marks all existing users as "active"
- Updates RLS policies to block pending users from sensitive data
- Creates audit infrastructure

### Step 2: Deploy Web Dashboard Updates
The following files have been updated:
- `web/hooks/use-user-management.ts`
- `web/components/users/pending-access-table.tsx`
- `web/app/dashboard/users/page.tsx`

**Deploy** these to your Next.js production environment.

### Step 3: Update Mobile App
Follow the "Pending - Mobile App" section above to update your Flutter app.

### Step 4: Test the Workflow

#### Test Scenario 1: New User Signup
1. Download the mobile app (as a test user)
2. Sign in with a new Google account
3. You should see "Access Pending" screen
4. In web dashboard, go to **Staff Management → Access Requests** tab
5. You should see the new user in the pending list
6. Click **Approve**, select role, confirm
7. Mobile app should refresh and unlock features

#### Test Scenario 2: Reject User
1. In web dashboard, click **Reject** on a pending user
2. User status changes to "suspended"
3. Mobile app shows "Access Denied" screen

---

## 🔐 Security Model

### Pending Users Can:
- ✅ View their own profile
- ❌ Read inventory data
- ❌ Read borrow logs
- ❌ Create transactions
- ❌ View other users

### Active Users Can:
- ✅ All of the above, based on their role (admin/editor/viewer)

### Suspended Users Can:
- ❌ Nothing (similar to pending, but marked as rejected)

---

## 📊 Database Schema Changes

### `user_profiles` Table
```sql
-- New columns:
status user_status DEFAULT 'pending' NOT NULL,
approved_at TIMESTAMPTZ,
approved_by UUID REFERENCES auth.users(id)
```

### `access_requests` Table (New)
```sql
CREATE TABLE access_requests (
    id BIGSERIAL PRIMARY KEY,
    user_id UUID REFERENCES auth.users NOT NULL,
    email TEXT NOT NULL,
    full_name TEXT,
    requested_at TIMESTAMPTZ DEFAULT NOW(),
    approved_at TIMESTAMPTZ,
    approved_by UUID REFERENCES auth.users,
    status TEXT DEFAULT 'pending'
);
```

---

## 🎨 UI Changes

### Staff Management Page
**Before**: Single table with active users only

**After**: Tabbed interface
- **Tab 1**: Active Staff (existing functionality)
- **Tab 2**: Access Requests (new)
  - Shows all pending users
  - Role dropdown per user
  - Approve/Reject buttons with confirmation

### Stats Cards
**Before**:
- Total Staff | Whitelist | Admins | Editors

**After**:
- Active Staff | Pending | Admins | Editors

---

## 🔧 Helper Functions (Backend)

### `approve_user(target_user_id, target_role)`
```sql
SELECT approve_user(
    'uuid-here'::uuid, 
    'editor'::text
);
```

### `reject_user(target_user_id)`
```sql
SELECT reject_user('uuid-here'::uuid);
```

These are automatically called by the web dashboard, but can also be run manually in SQL Editor for testing.

---

## 🐛 Troubleshooting

### Issue: Pending users still see inventory
**Fix**: Ensure you ran the RLS policy updates in the migration script.

### Issue: Approve button doesn't work
**Check**: 
1. Is the RPC function `approve_user` created?
2. Is the current admin user marked as `status = 'active'`?
3. Check browser console for errors

### Issue: Mobile app crashes after migration
**Fix**: The mobile app needs to handle the new `status` field. Update your auth flow as described above.

---

## 📈 Rollback Plan

If you need to rollback:

```sql
-- Remove status column (WARNING: This will lose pending user data)
ALTER TABLE user_profiles DROP COLUMN status;

-- Restore old RLS policies
-- (Run the original supabase_auth_setup.sql policies)
```

**Not recommended** unless critical issues arise. Instead, mark all pending users as active:

```sql
UPDATE user_profiles SET status = 'active' WHERE status = 'pending';
```

---

## 🎯 Next Steps (Optional Enhancements)

1. **Email Notifications**: Send an email when a user is approved
2. **Auto-Approval Rules**: Auto-approve users with `@cdrrmo.gov.ph` emails
3. **Approval Expiry**: Auto-reject requests older than 30 days
4. **Batch Approval**: Select multiple pending users and approve all at once

---

## 📚 Related Files

### Backend
- `web/_db_scripts/pending_access_migration.sql` - Database migration
- `web/hooks/use-user-management.ts` - React hook for user management

### Frontend (Web)
- `web/app/dashboard/users/page.tsx` - Staff management page
- `web/components/users/pending-access-table.tsx` - Access requests table
- `web/components/users/user-header.tsx` - Page header
- `web/components/users/user-table.tsx` - Active users table

### Frontend (Mobile)
- `mobile/lib/src/features/auth/` - Auth flow (needs update)
- `mobile/lib/src/core/` - User profile models (needs update)

---

## ✅ Done!

You now have a production-ready "Pending Access" system that solves the onboarding friction for non-government users while maintaining enterprise-grade security.

**Questions?** Review this guide or check the inline comments in the migration SQL.
