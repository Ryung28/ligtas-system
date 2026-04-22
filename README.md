# LIGTAS Live Inventory Dashboard

A professional, real-time inventory management dashboard built with Next.js, Shadcn/UI, and Supabase.

## Features

✨ **Core Features:**
- 📊 Real-time inventory tracking with live updates
- 🔍 Dynamic search filtering by item name and category
- 🎨 Beautiful, modern UI with Shadcn/UI components
- ⚡ Performance optimized with React hooks (useMemo, useCallback)
- 🔴 Visual alerts for low stock items (< 5 units)
- 📈 Statistics dashboard with key metrics
- 🔄 Real-time Supabase subscriptions
- 🎯 Type-safe with TypeScript

## Tech Stack

- **Framework:** Next.js 14 (App Router)
- **UI Library:** Shadcn/UI + Tailwind CSS
- **Database:** Supabase (PostgreSQL)
- **Language:** TypeScript
- **Icons:** Lucide React
- **Styling:** Tailwind CSS with custom theme

## Prerequisites

- Node.js 18+ installed
- A Supabase account and project
- npm or yarn package manager

## Setup Instructions

### 1. Install Dependencies

\`\`\`bash
npm install
\`\`\`

### 2. Configure Supabase

1. Create a Supabase project at [supabase.com](https://supabase.com)
2. Create the `inventory` table with the following structure:

\`\`\`sql
CREATE TABLE inventory (
  id BIGSERIAL PRIMARY KEY,
  item_name TEXT NOT NULL,
  category TEXT NOT NULL,
  stock_available INTEGER NOT NULL DEFAULT 0,
  status TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Add some sample data
INSERT INTO inventory (item_name, category, stock_available, status) VALUES
  ('Laptop Dell XPS 13', 'Electronics', 15, 'In Stock'),
  ('Office Chair Pro', 'Furniture', 3, 'Low Stock'),
  ('Wireless Mouse', 'Electronics', 0, 'Out of Stock'),
  ('Standing Desk', 'Furniture', 8, 'In Stock'),
  ('USB-C Cable', 'Accessories', 2, 'Low Stock');
\`\`\`

3. Get your Supabase credentials:
   - Go to Project Settings → API
   - Copy the Project URL and anon/public key

### 3. Environment Variables

Update the `.env.local` file with your Supabase credentials:

\`\`\`env
NEXT_PUBLIC_SUPABASE_URL=your-supabase-project-url
NEXT_PUBLIC_SUPABASE_ANON_KEY=your-supabase-anon-key
\`\`\`

### 4. Run Development Server

\`\`\`bash
npm run dev
\`\`\`

Open [http://localhost:3000](http://localhost:3000) to view the application.

### 5. Navigate to Inventory Dashboard

Click "Go to Inventory Dashboard" or navigate to `/dashboard/inventory`

## Project Structure

\`\`\`
web/
├── app/
│   ├── dashboard/
│   │   └── inventory/
│   │       └── page.tsx          # Main inventory dashboard
│   ├── globals.css               # Global styles
│   ├── layout.tsx                # Root layout
│   └── page.tsx                  # Home page
├── components/
│   └── ui/                       # Shadcn/UI components
│       ├── badge.tsx
│       ├── button.tsx
│       ├── card.tsx
│       ├── input.tsx
│       └── table.tsx
├── lib/
│   ├── supabase.ts              # Supabase client & types
│   └── utils.ts                 # Utility functions
├── .env.local                   # Environment variables
├── package.json
├── tailwind.config.ts
└── tsconfig.json
\`\`\`

## Key Features Explained

### Real-Time Updates
The dashboard uses Supabase real-time subscriptions to automatically update when inventory changes in the database.

### Search Filtering
Uses memoized filtering for optimal performance, searching across item names and categories.

### Low Stock Highlighting
Rows with stock < 5 are highlighted in red with a border indicator.

### Statistics Cards
Displays:
- Total Items
- Total Stock
- Low Stock Items (< 5)
- Out of Stock Items (= 0)

### Senior Developer Patterns Used
- ✅ React hooks optimization (useMemo, useCallback)
- ✅ TypeScript for type safety
- ✅ Component composition
- ✅ Clean separation of concerns
- ✅ Error handling and loading states
- ✅ Real-time data synchronization
- ✅ Accessible UI components

## Build for Production

\`\`\`bash
npm run build
npm start
\`\`\`

## License

MIT

---

Built with ❤️ for LIGTAS System
