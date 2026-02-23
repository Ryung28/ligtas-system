# Quick Setup Guide - Live Inventory Dashboard

## 🚀 Quick Start (5 minutes)

### Step 1: Install Dependencies
```bash
cd d:\LIGTAS_SYSTEM\web
npm install
```

### Step 2: Setup Supabase

1. **Create Supabase Project**
   - Go to https://supabase.com
   - Click "New Project"
   - Fill in project details

2. **Create Database Table**
   
   Run this SQL in Supabase SQL Editor:
   
   ```sql
   CREATE TABLE inventory (
     id BIGSERIAL PRIMARY KEY,
     item_name TEXT NOT NULL,
     category TEXT NOT NULL,
     stock_available INTEGER NOT NULL DEFAULT 0,
     status TEXT,
     created_at TIMESTAMPTZ DEFAULT NOW(),
     updated_at TIMESTAMPTZ DEFAULT NOW()
   );

   -- Sample data for testing
   INSERT INTO inventory (item_name, category, stock_available, status) VALUES
     ('Laptop Dell XPS 13', 'Electronics', 15, 'In Stock'),
     ('Office Chair Pro', 'Furniture', 3, 'Low Stock'),
     ('Wireless Mouse', 'Electronics', 0, 'Out of Stock'),
     ('Standing Desk', 'Furniture', 8, 'In Stock'),
     ('USB-C Cable', 'Accessories', 2, 'Low Stock'),
     ('Monitor 27"', 'Electronics', 25, 'In Stock'),
     ('Keyboard Mechanical', 'Electronics', 1, 'Low Stock'),
     ('Desk Lamp LED', 'Accessories', 12, 'In Stock'),
     ('Ergonomic Mat', 'Accessories', 0, 'Out of Stock'),
     ('Whiteboard', 'Office Supplies', 6, 'In Stock');
   ```

3. **Get Your Credentials**
   - Go to Project Settings → API
   - Copy **Project URL** and **anon/public key**

### Step 3: Configure Environment Variables

Edit `.env.local` file:

```env
NEXT_PUBLIC_SUPABASE_URL=https://your-project.supabase.co
NEXT_PUBLIC_SUPABASE_ANON_KEY=your-anon-key-here
```

### Step 4: Run the Application

```bash
npm run dev
```

Open http://localhost:3000

### Step 5: Navigate to Dashboard

Click "Go to Inventory Dashboard" or visit:
```
http://localhost:3000/dashboard/inventory
```

## ✅ Features Checklist

Once running, verify these features:

- [ ] Real-time inventory display
- [ ] Search by item name or category
- [ ] Low stock items (< 5) highlighted in red
- [ ] Statistics cards showing totals
- [ ] Status badges (In Stock, Low Stock, Out of Stock)
- [ ] Refresh button working
- [ ] Responsive design on mobile

## 🔧 Troubleshooting

### Error: "Failed to fetch inventory"
- Check your `.env.local` credentials
- Verify the `inventory` table exists in Supabase
- Check Supabase RLS (Row Level Security) policies

### Blank Page or No Data
- Open browser console (F12) to check for errors
- Ensure Supabase URL and key are correct
- Try adding RLS policy:
  ```sql
  ALTER TABLE inventory ENABLE ROW LEVEL SECURITY;
  
  CREATE POLICY "Enable read access for all users" ON inventory
    FOR SELECT USING (true);
  ```

### Low Stock Not Highlighting
- Ensure some items have `stock_available < 5`
- Check browser console for styling errors

## 📱 Testing Real-Time Updates

1. Open the dashboard in your browser
2. Open Supabase Table Editor
3. Update a stock value in the database
4. Watch it update automatically in the dashboard!

## 🎨 Customization

### Change Low Stock Threshold
Edit `page.tsx` line 83:
```typescript
const lowStockItems = inventory.filter(item => item.stock_available < 10).length
```

### Modify Color Scheme
Edit `tailwind.config.ts` or component classNames

### Add More Columns
1. Update Supabase table
2. Update `InventoryItem` type in `lib/supabase.ts`
3. Add column to table in `page.tsx`

---

Built with Next.js 14, Shadcn/UI, and Supabase 💙
