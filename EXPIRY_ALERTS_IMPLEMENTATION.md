# ✅ Expiry Alert Notification System - Implementation Complete

## What Was Implemented

The system now automatically creates notifications in the notification bell when inventory items are approaching their expiry date based on the `expiry_alert_days` threshold set for each item.

## 🎯 Features

### 1. **Automatic Expiry Monitoring**
- Daily scan of all inventory items with expiry dates
- Compares current date against item's `expiry_date` and `expiry_alert_days` threshold
- Creates notifications for items within alert window

### 2. **Three Alert Levels**

| Level | Condition | Color | Sound |
|-------|-----------|-------|-------|
| **EXPIRED** | Past expiry date | 🔴 Red | ✅ Critical Alarm |
| **CRITICAL** | ≤ 7 days remaining | 🔴 Red | ✅ Critical Alarm |
| **WARNING** | Within alert threshold (e.g., 15 days) | 🟡 Amber | ❌ No sound |

### 3. **Smart Notification Management**
- **Deduplication**: Only one notification per item per 24 hours
- **Auto-cleanup**: Notifications older than 7 days are automatically deleted
- **Broadcast**: Notifications sent to all managers/admins
- **Real-time**: Instant updates via Supabase Realtime

### 4. **Rich Notification Cards**
- Shows item name, days remaining, and urgency level
- "VIEW ITEM" button links directly to inventory page
- Color-coded by severity
- Includes metadata for filtering and routing

## 📁 Files Created/Modified

### New Files:
1. **`supabase/migrations/20260505000000_expiry_alert_notifications.sql`**
   - Database function `check_expiry_alerts()`
   - Notification creation logic
   - Cleanup logic

2. **`supabase/migrations/20260505000001_enable_expiry_cron.sql`**
   - Schedules the daily cron job
   - Verifies pg_cron is enabled

3. **`supabase/scripts/expiry_alerts_management.sql`**
   - Helpful queries for testing and management
   - Manual trigger commands
   - Statistics and debugging queries

4. **`docs/system/EXPIRY_NOTIFICATIONS.md`**
   - Complete documentation
   - Setup instructions
   - Troubleshooting guide

### Modified Files:
1. **`web/lib/repositories/notification-repository.ts`**
   - Added action mappings for expiry notifications
   - "VIEW ITEM" button links to inventory with highlight

2. **`web/components/notifications/constants/notification.config.tsx`**
   - Added `expiry`, `expiry_critical`, `expiry_warning` types
   - Configured colors and icons
   - Added to ALERTS filter

3. **`web/hooks/use-notifications.ts`**
   - Updated sound trigger to include `expiry_critical`
   - Critical alarm plays for expired and critical items

## 🚀 Setup Instructions

### Step 1: Apply Migrations

```bash
# If using Supabase CLI
supabase db push

# Or apply manually in Supabase Dashboard > SQL Editor
```

### Step 2: Enable pg_cron Extension

1. Go to **Supabase Dashboard**
2. Navigate to **Database** → **Extensions**
3. Search for `pg_cron`
4. Click **Enable**

### Step 3: Schedule the Cron Job

Run this in SQL Editor:

```sql
SELECT cron.schedule(
    'daily-expiry-alert-check',
    '0 6 * * *',  -- Every day at 6:00 AM UTC
    $$SELECT public.check_expiry_alerts();$$
);
```

### Step 4: Verify Setup

```sql
-- Check if job is scheduled
SELECT * FROM cron.job WHERE jobname = 'daily-expiry-alert-check';

-- Manually trigger for testing
SELECT public.check_expiry_alerts();

-- View created notifications
SELECT * FROM system_notifications 
WHERE type IN ('expiry', 'expiry_critical', 'expiry_warning')
ORDER BY created_at DESC;
```

## 🧪 Testing

### Quick Test with Sample Data

```sql
-- Create a test item expiring in 5 days
INSERT INTO inventory_items (
    item_name,
    category,
    item_type,
    expiry_date,
    expiry_alert_days,
    stock_available,
    stock_total
)
VALUES (
    'Test Medicine - Expiring Soon',
    'Medical',
    'consumable',
    CURRENT_DATE + INTERVAL '5 days',
    15,
    10,
    10
);

-- Run the check
SELECT public.check_expiry_alerts();

-- Verify notification was created
SELECT 
    type,
    title,
    message,
    metadata->>'item_name' as item_name,
    metadata->>'days_remaining' as days_remaining
FROM system_notifications 
WHERE type = 'expiry_critical' 
ORDER BY created_at DESC 
LIMIT 1;
```

### Clean Up Test Data

```sql
DELETE FROM inventory_items WHERE item_name LIKE 'Test Medicine%';
DELETE FROM system_notifications WHERE metadata->>'item_name' LIKE 'Test Medicine%';
```

## 📊 How It Works

### Daily Workflow

1. **6:00 AM UTC** - Cron job triggers `check_expiry_alerts()`
2. **Function scans** all items with `expiry_date` and `stock_available > 0`
3. **Calculates** days remaining: `expiry_date - CURRENT_DATE`
4. **Determines alert level**:
   - Expired: < 0 days
   - Critical: 0-7 days
   - Warning: 8 days to alert threshold
5. **Checks for duplicates** (within last 24 hours)
6. **Creates notification** if needed
7. **Cleans up** old notifications (> 7 days)

### User Experience

**Web Dashboard:**
1. Notification bell shows unread count badge
2. Bell turns black when unread notifications exist
3. Click bell to open notification panel
4. Expiry notifications appear in "ALERTS" filter
5. Critical/expired items play alarm sound
6. Click "VIEW ITEM" to go to inventory page

**Mobile App:**
- Push notifications sent to all manager devices
- Critical alarm sound plays
- Tapping opens inventory item detail

## 🔧 Customization

### Change Schedule Frequency

```sql
-- Unschedule existing
SELECT cron.unschedule('daily-expiry-alert-check');

-- Reschedule (e.g., every 6 hours)
SELECT cron.schedule(
    'daily-expiry-alert-check',
    '0 */6 * * *',
    $$SELECT public.check_expiry_alerts();$$
);
```

### Adjust Deduplication Window

Edit the function to change from 24 hours to 12 hours:

```sql
-- Find this line in the function:
AND created_at > NOW() - INTERVAL '24 hours'

-- Change to:
AND created_at > NOW() - INTERVAL '12 hours'
```

## 🐛 Troubleshooting

### Notifications Not Appearing

1. **Check pg_cron is enabled:**
   ```sql
   SELECT * FROM pg_extension WHERE extname = 'pg_cron';
   ```

2. **Verify job is scheduled:**
   ```sql
   SELECT * FROM cron.job WHERE jobname = 'daily-expiry-alert-check';
   ```

3. **Check cron logs:**
   ```sql
   SELECT * FROM cron.job_run_details 
   WHERE jobid = (SELECT jobid FROM cron.job WHERE jobname = 'daily-expiry-alert-check')
   ORDER BY start_time DESC;
   ```

4. **Manually run:**
   ```sql
   SELECT public.check_expiry_alerts();
   ```

### No Items Triggering Alerts

Verify items meet criteria:

```sql
SELECT 
    id,
    item_name,
    expiry_date,
    expiry_alert_days,
    stock_available,
    (expiry_date::date - CURRENT_DATE) as days_remaining
FROM inventory_items
WHERE expiry_date IS NOT NULL
  AND stock_available > 0
  AND (expiry_date::date - CURRENT_DATE) <= COALESCE(expiry_alert_days, 15);
```

## 📈 Monitoring

### View Statistics

```sql
SELECT 
    COUNT(DISTINCT ii.id) as total_items_with_expiry,
    COUNT(DISTINCT CASE WHEN (ii.expiry_date::date - CURRENT_DATE) < 0 THEN ii.id END) as expired_items,
    COUNT(DISTINCT CASE WHEN (ii.expiry_date::date - CURRENT_DATE) BETWEEN 0 AND 7 THEN ii.id END) as critical_items,
    COUNT(DISTINCT CASE WHEN (ii.expiry_date::date - CURRENT_DATE) BETWEEN 8 AND COALESCE(ii.expiry_alert_days, 15) THEN ii.id END) as warning_items,
    COUNT(DISTINCT sn.id) as total_notifications
FROM inventory_items ii
LEFT JOIN system_notifications sn ON sn.reference_id = ii.id::TEXT 
    AND sn.type IN ('expiry', 'expiry_critical', 'expiry_warning')
    AND sn.created_at > NOW() - INTERVAL '7 days'
WHERE ii.expiry_date IS NOT NULL
  AND ii.stock_available > 0;
```

## 🎉 What's Next

The system is now fully functional! Here are some potential enhancements:

1. **Per-user subscriptions** - Let users subscribe to specific item alerts
2. **Email notifications** - Send daily/weekly email summaries
3. **Batch notifications** - Group multiple expiring items into one notification
4. **Configurable defaults** - System-wide default alert thresholds
5. **Snooze functionality** - Temporarily dismiss alerts
6. **Expiry reports** - Generate weekly/monthly reports

## 📚 Related Documentation

- **Full Documentation**: `docs/system/EXPIRY_NOTIFICATIONS.md`
- **Management Scripts**: `supabase/scripts/expiry_alerts_management.sql`
- **Expiry Utils**: `web/lib/expiry-utils.ts`
- **Notification Hook**: `web/hooks/use-notifications.ts`

---

**Implementation Date**: May 5, 2026  
**Status**: ✅ Complete and Ready for Production
