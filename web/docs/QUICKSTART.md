# 🚀 QUICKSTART CHECKLIST - Live Inventory Dashboard

## ✅ Step-by-Step Launch Guide

### Phase 1: Install Dependencies (5 minutes)
```bash
# Navigate to project
cd d:\LIGTAS_SYSTEM\web

# Install all packages
npm install

# Verify installation
npm list --depth=0
```

**Expected packages:**
- next@14.1.0
- react@18.2.0
- @supabase/supabase-js@2.39.3
- Shadcn/UI components
- Tailwind CSS

---

### Phase 2: Setup Supabase Database (10 minutes)

#### 2.1 Create Supabase Account
- [ ] Go to https://supabase.com
- [ ] Sign up / Log in
- [ ] Click "New Project"
- [ ] Name: `ligtas-inventory` (or your choice)
- [ ] Database Password: (save this!)
- [ ] Region: Choose closest to you
- [ ] Click "Create new project"
- [ ] Wait for project to initialize (~2 minutes)

#### 2.2 Run SQL Setup
- [ ] In Supabase Dashboard, click "SQL Editor"
- [ ] Click "New query"
- [ ] Open file: `d:\LIGTAS_SYSTEM\web\supabase_setup.sql`
- [ ] Copy ALL contents
- [ ] Paste into SQL Editor
- [ ] Click "Run" (or press Ctrl+Enter)
- [ ] Verify: Should see "Success. No rows returned"

#### 2.3 Verify Database
Run this query in SQL Editor:
```sql
SELECT COUNT(*) as total_items FROM inventory;
```
✅ Should return: `total_items: 30`

#### 2.4 Get API Credentials
- [ ] Click "Settings" → "API"
- [ ] Copy **Project URL** (starts with https://...supabase.co)
- [ ] Copy **anon/public key** (starts with eyJ...)

---

### Phase 3: Configure Environment Variables (2 minutes)

#### 3.1 Edit .env.local
- [ ] Open: `d:\LIGTAS_SYSTEM\web\.env.local`
- [ ] Replace with your actual values:

```env
NEXT_PUBLIC_SUPABASE_URL=https://xxxxxxxxxxxxx.supabase.co
NEXT_PUBLIC_SUPABASE_ANON_KEY=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.ey...
```

- [ ] Save file
- [ ] ⚠️ IMPORTANT: Make sure there are NO spaces around the `=` sign
- [ ] ⚠️ Do not use quotes around the values

---

### Phase 4: Run Development Server (1 minute)

```bash
# Start the development server
npm run dev
```

**Expected output:**
```
  ▲ Next.js 14.1.0
  - Local:        http://localhost:3000
  - Network:      http://192.168.x.x:3000

 ✓ Ready in 3.2s
```

- [ ] See "Ready" message
- [ ] No error messages

---

### Phase 5: Access Dashboard (1 minute)

#### 5.1 Open Browser
- [ ] Open Chrome/Edge/Firefox
- [ ] Go to: http://localhost:3000

#### 5.2 Navigate to Dashboard
- [ ] Click "Go to Inventory Dashboard" button
- [ ] OR go directly to: http://localhost:3000/dashboard/inventory

---

### Phase 6: Verify Features ✨

#### Check These Features Work:
- [ ] **Statistics Cards** - Shows 4 metrics at top
  - Total Items: 30
  - Total Stock: (number)
  - Low Stock Items: (items with stock < 5)
  - Out of Stock: (items with stock = 0)

- [ ] **Inventory Table** - Displays all items
  - See 30 rows of data
  - Columns: Item Name, Category, Available Stock, Status

- [ ] **Search Filter** - Type "laptop" in search box
  - Table filters to show only laptops
  - Item count updates dynamically

- [ ] **Low Stock Highlighting**
  - Items with stock < 5 have RED background
  - Alert icon (⚠️) appears next to item name

- [ ] **Status Badges**
  - Green badge: "In Stock" (stock >= 5)
  - Yellow badge: "Low Stock" (stock 1-4)
  - Red badge: "Out of Stock" (stock = 0)

- [ ] **Refresh Button**
  - Click refresh icon (top right)
  - Spinner animation shows
  - Data reloads

- [ ] **Last Updated Time**
  - Shows current time near title
  - Updates when you refresh

---

### Phase 7: Test Real-Time Updates 🔄

#### 7.1 Open Supabase Table Editor
- [ ] In Supabase Dashboard → "Table Editor"
- [ ] Select `inventory` table
- [ ] Keep dashboard open in browser

#### 7.2 Make a Change
- [ ] Click on any row in Supabase
- [ ] Change `stock_available` value
  - Example: Change "Wireless Mouse" from 0 to 10
- [ ] Click "Save"

#### 7.3 Watch Magic Happen ✨
- [ ] Switch back to your browser with dashboard
- [ ] **Data should update automatically!**
- [ ] No refresh needed
- [ ] Status badge should change color
- [ ] Statistics cards should update

---

## 🎯 Success Criteria

You're fully set up if:
- ✅ Dashboard loads without errors
- ✅ All 30 inventory items display
- ✅ Search filtering works
- ✅ Low stock items highlighted in red
- ✅ Statistics cards show correct numbers
- ✅ Real-time updates work when you edit in Supabase

---

## 🐛 Troubleshooting

### Error: "Failed to fetch inventory"
**Cause:** Environment variables not configured
**Fix:**
1. Check `.env.local` has correct URL and key
2. Restart dev server: Stop (Ctrl+C) and run `npm run dev` again
3. Clear browser cache (Ctrl+F5)

### No Data Shows / Empty Table
**Cause:** Database not set up or RLS blocking access
**Fix:**
1. Go to Supabase → Table Editor → Check `inventory` table has 30 rows
2. Run this SQL in Supabase:
```sql
ALTER TABLE inventory ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Enable read access for all users" ON inventory FOR SELECT USING (true);
```

### "Module not found" Errors
**Cause:** Dependencies not installed
**Fix:**
```bash
rm -rf node_modules package-lock.json
npm install
```

### Port 3000 Already in Use
**Cause:** Another app using port 3000
**Fix:**
```bash
# Use different port
npm run dev -- -p 3001
```
Then visit: http://localhost:3001

### Real-Time Not Working
**Cause:** Supabase realtime not enabled
**Fix:**
1. Supabase Dashboard → Database → Replication
2. Enable replication for `inventory` table

---

## 📱 Next Steps After Setup

### A. Add More Data
```sql
INSERT INTO inventory (item_name, category, stock_available, status) 
VALUES ('Your Item', 'Your Category', 10, 'In Stock');
```

### B. Customize Low Stock Threshold
Edit `page.tsx` line 83:
```typescript
const lowStockItems = inventory.filter(item => item.stock_available < 10).length
```

### C. Add More Columns to Table
1. Add field to Supabase table
2. Update `InventoryItem` interface in `lib/supabase.ts`
3. Add `<TableHead>` and `<TableCell>` in `page.tsx`

### D. Deploy to Production
```bash
# Build for production
npm run build

# Deploy to Vercel
npx vercel deploy
```

---

## 📞 Need Help?

- Check `IMPLEMENTATION_SUMMARY.md` for features overview
- Check `ARCHITECTURE.md` for system design
- Check `README.md` for full documentation
- Review the code in `app/dashboard/inventory/page.tsx`

---

**Current Status:** ✅ Project fully built and ready to launch!

**Next Action:** Run `npm install` then `npm run dev`

🎉 Happy Coding! 🎉
