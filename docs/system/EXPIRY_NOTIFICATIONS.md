# Expiry Alert Notification System

## Overview

The expiry alert notification system automatically monitors inventory items and creates notifications in the notification bell when items are approaching their expiry date.

## How It Works

### Alert Thresholds

Each inventory item has an `expiry_alert_days` field (default: 15 days) that determines when to start alerting.

**Alert Levels:**

| Status | Condition | Color | Notification Type |
|--------|-----------|-------|-------------------|
| **EXPIRED** | Past expiry date (≤ 0 days) | 🔴 Red | `expiry` |
| **CRITICAL** | 7 days or less remaining | 🔴 Red | `expiry_critical` |
| **WARNING** | Within alert threshold | 🟡 Amber | `expiry_warning` |
| **GOOD** | Beyond alert threshold | 🟢 Green | No notification |

### Notification Behavior

- **Broadcast**: Notifications are sent to all managers/admins (not individual users)
- **Deduplication**: Only one notification per item per 24 hours
- **Auto-cleanup**: Notifications older than 7 days are automatically deleted
- **Sound Alert**: Critical and expired items trigger the critical alarm sound
- **Real-time**: Notifications appear instantly via Supabase Realtime

## Database Components

### Function: `check_expiry_alerts()`

Scans all inventory items with expiry dates and creates appropriate notifications.

**Logic:**
1. Queries all items with `expiry_date` and `stock_available > 0`
2. Calculates days remaining until expiry
3. Compares against the item's `expiry_alert_days` threshold
4. Creates notification if within threshold and no recent notification exists
5. Cleans up old notifications (>7 days)

### Scheduled Job (pg_cron)

The function runs automatically every day at **6:00 AM UTC** via pg_cron.

## Setup Instructions

### 1. Apply the Migration

```bash
# The migration file is already created
supabase/migrations/20260505000000_expiry_alert_notifications.sql
```

If using Supabase CLI:
```bash
supabase db push
```

Or apply manually in Supabase Dashboard > SQL Editor.

### 2. Enable pg_cron Extension

**In Supabase Dashboard:**
1. Go to **Database** → **Extensions**
2. Search for `pg_cron`
3. Click **Enable**

### 3. Schedule the Cron Job

After enabling pg_cron, run this SQL in the SQL Editor:

```sql
SELECT cron.schedule(
    'daily-expiry-alert-check',
    '0 6 * * *',  -- Every day at 6:00 AM UTC
    $$SELECT public.check_expiry_alerts();$$
);
```

### 4. Verify Setup

Check if the job is scheduled:

```sql
SELECT * FROM cron.job;
```

You should see an entry for `daily-expiry-alert-check`.

## Manual Testing

### Trigger the Check Manually

```sql
SELECT public.check_expiry_alerts();
```

### View Created Notifications

```sql
SELECT 
    id,
    type,
    title,
    message,
    reference_id,
    created_at,
    metadata
FROM system_notifications
WHERE type IN ('expiry', 'expiry_critical', 'expiry_warning')
ORDER BY created_at DESC;
```

### Test with Sample Data

Create a test item expiring soon:

```sql
-- Insert test item expiring in 5 days
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
    'Test Medicine',
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
SELECT * FROM system_notifications 
WHERE type = 'expiry_critical' 
ORDER BY created_at DESC 
LIMIT 1;
```

## Notification Metadata

Each notification includes rich metadata for UI routing and filtering:

```json
{
  "item_id": 123,
  "item_name": "First Aid Kit",
  "expiry_date": "2026-05-10",
  "days_remaining": 5,
  "alert_threshold": 15,
  "stock_available": 10,
  "audience_role": "manager",
  "search_query": "First Aid Kit"
}
```

## User Experience

### Web Dashboard

1. **Notification Bell** (top right): Shows unread count badge
2. **Click bell**: Opens notification panel
3. **Notification card**: Shows item name, days remaining, and urgency
4. **Action button**: "VIEW ITEM" links to inventory page with item highlighted
5. **Sound**: Critical/expired items play alarm sound on notification arrival

### Mobile App

- Push notifications sent to all manager/admin devices
- Tapping notification opens inventory item detail
- Critical alarm sound plays for urgent alerts

## Customization

### Change Schedule Frequency

To run more frequently (e.g., every 6 hours):

```sql
-- Unschedule existing job
SELECT cron.unschedule('daily-expiry-alert-check');

-- Reschedule with new frequency
SELECT cron.schedule(
    'daily-expiry-alert-check',
    '0 */6 * * *',  -- Every 6 hours
    $$SELECT public.check_expiry_alerts();$$
);
```

### Adjust Deduplication Window

Edit the function to change the 24-hour window:

```sql
-- Change this line in the function:
AND created_at > NOW() - INTERVAL '24 hours'

-- To (for example, 12 hours):
AND created_at > NOW() - INTERVAL '12 hours'
```

### Modify Cleanup Period

Change the 7-day cleanup period:

```sql
-- Change this line:
AND created_at < NOW() - INTERVAL '7 days'

-- To (for example, 30 days):
AND created_at < NOW() - INTERVAL '30 days'
```

## Troubleshooting

### Notifications Not Appearing

1. **Check if pg_cron is enabled:**
   ```sql
   SELECT * FROM pg_extension WHERE extname = 'pg_cron';
   ```

2. **Verify job is scheduled:**
   ```sql
   SELECT * FROM cron.job WHERE jobname = 'daily-expiry-alert-check';
   ```

3. **Check for errors in cron logs:**
   ```sql
   SELECT * FROM cron.job_run_details 
   WHERE jobid = (SELECT jobid FROM cron.job WHERE jobname = 'daily-expiry-alert-check')
   ORDER BY start_time DESC;
   ```

4. **Manually run the function:**
   ```sql
   SELECT public.check_expiry_alerts();
   ```

### Duplicate Notifications

The system prevents duplicates within 24 hours. If you're seeing duplicates:

1. Check if multiple cron jobs are scheduled:
   ```sql
   SELECT * FROM cron.job WHERE command LIKE '%check_expiry_alerts%';
   ```

2. Remove duplicate jobs:
   ```sql
   SELECT cron.unschedule('job-name-here');
   ```

### No Items Triggering Alerts

Verify items have:
- `expiry_date` set
- `stock_available > 0`
- Expiry date within the alert threshold

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

## Performance Considerations

- The function scans all items with expiry dates (typically a small subset)
- Uses indexes on `expiry_date` and `stock_available` for efficiency
- Cleanup query removes old notifications to prevent table bloat
- Runs during low-traffic hours (6 AM UTC) to minimize impact

## Future Enhancements

Potential improvements:

1. **Per-user notifications**: Allow users to subscribe to specific item alerts
2. **Email notifications**: Send email summaries of expiring items
3. **Batch notifications**: Group multiple expiring items into one notification
4. **Configurable thresholds**: Allow system-wide default alert thresholds
5. **Snooze functionality**: Let users dismiss alerts temporarily
6. **Expiry reports**: Generate weekly/monthly expiry reports

## Related Files

- **Migration**: `supabase/migrations/20260505000000_expiry_alert_notifications.sql`
- **Notification Hook**: `web/hooks/use-notifications.ts`
- **Notification Bell**: `web/components/layout/notification-bell-v2.tsx`
- **Expiry Utils**: `web/lib/expiry-utils.ts`
- **Consumable Fields**: `web/src/features/catalog/components/catalog-item-dialog/_components/v2-consumable-fields.tsx`
