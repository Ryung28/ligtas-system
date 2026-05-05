# 🚀 Quick Start: Expiry Alert Notifications

## What This Does

Automatically sends notifications to the notification bell when inventory items are approaching their expiry date.

## ⚡ 3-Step Setup

### 1️⃣ Apply Database Migrations

**Option A: Supabase CLI**
```bash
supabase db push
```

**Option B: Supabase Dashboard**
1. Go to **SQL Editor**
2. Copy and run: `supabase/migrations/20260505000000_expiry_alert_notifications.sql`

### 2️⃣ Enable pg_cron

1. **Supabase Dashboard** → **Database** → **Extensions**
2. Search: `pg_cron`
3. Click **Enable**

### 3️⃣ Schedule the Job

Run in **SQL Editor**:

```sql
SELECT cron.schedule(
    'daily-expiry-alert-check',
    '0 6 * * *',
    $$SELECT public.check_expiry_alerts();$$
);
```

## ✅ Verify It's Working

```sql
-- Check job is scheduled
SELECT * FROM cron.job WHERE jobname = 'daily-expiry-alert-check';

-- Manually trigger (for testing)
SELECT public.check_expiry_alerts();

-- View notifications
SELECT * FROM system_notifications 
WHERE type IN ('expiry', 'expiry_critical', 'expiry_warning')
ORDER BY created_at DESC;
```

## 🎯 How It Works

- **Runs daily** at 6:00 AM UTC
- **Checks all items** with expiry dates
- **Creates notifications** for:
  - ❌ **EXPIRED** items (past expiry date)
  - 🔴 **CRITICAL** items (≤ 7 days remaining)
  - 🟡 **WARNING** items (within alert threshold)
- **Prevents duplicates** (24-hour window)
- **Auto-cleans** old notifications (> 7 days)

## 🔔 User Experience

**Web Dashboard:**
- Notification bell shows unread count
- Click bell to view alerts
- "VIEW ITEM" button links to inventory
- Critical items play alarm sound

**Mobile App:**
- Push notifications to all managers
- Critical alarm sound
- Tap to view item details

## 📝 Setting Alert Thresholds

When adding/editing inventory items:

1. Set **Expiry Date** (e.g., 2026-12-31)
2. Set **Notify when expiry is within (days)** (default: 15)
3. System will alert when item is within that threshold

## 🧪 Quick Test

```sql
-- Create test item expiring in 5 days
INSERT INTO inventory_items (
    item_name, category, item_type,
    expiry_date, expiry_alert_days,
    stock_available, stock_total
) VALUES (
    'Test Item', 'Medical', 'consumable',
    CURRENT_DATE + INTERVAL '5 days', 15,
    10, 10
);

-- Trigger check
SELECT public.check_expiry_alerts();

-- View notification
SELECT type, title, message 
FROM system_notifications 
WHERE type = 'expiry_critical' 
ORDER BY created_at DESC LIMIT 1;

-- Clean up
DELETE FROM inventory_items WHERE item_name = 'Test Item';
```

## 📚 Full Documentation

- **Complete Guide**: `docs/system/EXPIRY_NOTIFICATIONS.md`
- **Implementation Details**: `EXPIRY_ALERTS_IMPLEMENTATION.md`
- **Management Scripts**: `supabase/scripts/expiry_alerts_management.sql`

## 🆘 Troubleshooting

**Notifications not appearing?**

1. Check pg_cron is enabled:
   ```sql
   SELECT * FROM pg_extension WHERE extname = 'pg_cron';
   ```

2. Manually trigger:
   ```sql
   SELECT public.check_expiry_alerts();
   ```

3. Check for items that should alert:
   ```sql
   SELECT item_name, expiry_date, 
          (expiry_date::date - CURRENT_DATE) as days_remaining
   FROM inventory_items
   WHERE expiry_date IS NOT NULL
     AND stock_available > 0
     AND (expiry_date::date - CURRENT_DATE) <= 15;
   ```

---

**That's it!** The system is now monitoring expiry dates and will notify managers automatically. 🎉
