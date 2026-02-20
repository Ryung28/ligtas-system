# Flutter Mobile App - Pending Access Implementation

## ✅ Changes Made

### 1. **Updated User Model** (`auth/models/user_model.dart`)
- Added `role` field (admin/editor/viewer)
- Added `status` field (pending/active/suspended)
- Added convenience getters:
  - `isActive` - Check if user has active access
  - `isPending` - Check if awaiting approval
  - `isSuspended` - Check if access denied
  - `isAdmin` - Check if user has admin privileges
  - `canEdit` - Check if user can edit (admin or editor)
- Updated `fromSupabase()` to map from `user_profiles` table

### 2. **Created Pending Access Screen** (`auth/screens/pending_access_screen.dart`)
- Premium UI with animated icons
- Shows user email and status
- Displays helpful information cards
- **Pull-to-refresh** functionality to check approval status
- Sign out button

### 3. **Created Access Denied Screen** (`auth/screens/access_denied_screen.dart`)
- Shown to suspended users
- Clear messaging about access denial
- Helpful next steps
- Sign out button

### 4. **Updated Auth Provider** (`auth/providers/auth_provider.dart`)
- Now fetches `user_profiles` from database (not just auth user)
- Gets role and status from database
- Added `refreshProfile()` method to manually check status
- Added convenience providers:
  - `hasActiveAccessProvider` - Boolean for active access
  - `userStatusProvider` - String status value

### 5. **Updated App Router** (`app.dart`)
- Added routes for `/pending` and `/denied`
- Implemented smart redirect logic:
  - Pending users → `/pending` screen
  - Suspended users → `/denied` screen
  - Active users → Main app (`/dashboard`)
- Protected routes check user status before allowing access

---

## 🔄 User Flow

### New User Signup
1. User downloads app and signs up
2. Profile created with `status: 'pending'`
3. User sees **Pending Access Screen**
4. Admin approves via web dashboard
5. User pulls down to refresh
6. Status changes to `active`
7. App automatically redirects to dashboard

### Suspended User
1. Admin rejects or suspends user
2. Status changes to `suspended`
3. User sees **Access Denied Screen**
4. Must contact admin for clarification

### Active User
1. User has `status: 'active'`
2. Full access to app features based on role
3. Router allows navigation to all protected routes

---

## 🧪 Testing

### Test Scenario 1: New Signup (Pending)
```dart
// In Supabase, manually set a user to pending:
UPDATE user_profiles 
SET status = 'pending' 
WHERE email = 'test@example.com';

// Expected behavior:
// - User opens app
// - Sees orange clock icon
// - "Access Pending" message
// - Can pull to refresh
// - Can sign out
```

### Test Scenario 2: Approval Flow
```dart
// 1. User is pending
// 2. Admin approves via web dashboard
// 3. User pulls down on pending screen
// 4. App fetches new profile
// 5. Status is now 'active'
// 6. Router automatically redirects to /dashboard
```

### Test Scenario 3: Suspended User
```dart
// In Supabase:
UPDATE user_profiles 
SET status = 'suspended' 
WHERE email = 'test@example.com';

// Expected behavior:
// - User opens app
// - Sees red block icon
// - "Access Denied" message
// - Can only sign out
```

---

## 🔐 Security Notes

### Database-Level Security (RLS)
The pending access system relies on Row Level Security policies in Supabase:

- **Pending users** can only:
  - Read their own profile
  - NOT read inventory
  - NOT read borrow logs
  
- **Active users** can:
  - Read inventory (all roles)
  - Create borrow logs (editor/admin)
  - Manage staff (admin only)

The mobile app enforces this at the UI level, but **security is enforced at the database level** via RLS policies.

---

## 📱 Pull-to-Refresh

The **Pending Access Screen** includes `RefreshIndicator`:

```dart
RefreshIndicator(
  onRefresh: () async {
    await ref.read(authProvider.notifier).refreshProfile();
  },
  // ... screen content
)
```

**How it works:**
1. User pulls down on pending screen
2. App calls `refreshProfile()`
3. Fetches latest `user_profiles` data
4. If status changed to `active`, router detects it
5. Automatic redirect to dashboard

---

## 🐛 Troubleshooting

### Issue: Pending screen doesn't redirect after approval
**Fix:** 
- Ensure pull-to-refresh is working
- Check if router redirect logic is correct
- Verify `refreshProfile()` is fetching updated data

### Issue: App crashes after login
**Fix:**
- Check if `user_profiles` table exists
- Verify RLS policies allow reading own profile
- Check if migration script was run

### Issue: Always shows pending screen even for active users
**Fix:**
- Check database: `SELECT status FROM user_profiles WHERE id = 'user-id';`
- Ensure router redirect logic checks `user.isActive`
- Clear app cache and restart

---

## 🔄 Next Steps (Optional Enhancements)

1. **Real-time Subscriptions**
   ```dart
   // Listen for status changes in real-time
   _supabase
     .from('user_profiles')
     .stream(primaryKey: ['id'])
     .eq('id', userId)
     .listen((data) {
       // Auto-update when admin approves
     });
   ```

2. **Push Notifications**
   - Send notification when user is approved
   - Use Firebase Cloud Messaging

3. **Role-Based UI**
   - Show/hide features based on `user.role`
   - Example: Only admins see "Manage Users" button

---

## ✅ Checklist

- [x] Updated `UserModel` with role and status
- [x] Created `PendingAccessScreen`
- [x] Created `AccessDeniedScreen`
- [x] Updated `AuthNotifier` to fetch user_profiles
- [x] Added `refreshProfile()` method
- [x] Updated router with status-based redirects
- [x] Added pull-to-refresh on pending screen
- [ ] Run database migration (see web guide)
- [ ] Test new user signup flow
- [ ] Test approval flow
- [ ] Test suspended user flow

---

## 📚 Related Files

### Modified
- `lib/src/features/auth/models/user_model.dart`
- `lib/src/features/auth/providers/auth_provider.dart`
- `lib/src/app.dart`

### Created
- `lib/src/features/auth/screens/pending_access_screen.dart`
- `lib/src/features/auth/screens/access_denied_screen.dart`

### Backend (Web)
- `web/_db_scripts/pending_access_migration.sql` - Run this first!

---

**Status**: ✅ Mobile App Updated | ⏳ Database Migration Pending

Once you run the database migration script, the entire pending access system will be operational end-to-end!
