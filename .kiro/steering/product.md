# LIGTAS Product Overview

**LIGTAS** (Lightning Inventory and Tracking System) is a disaster management and equipment tracking system for CDRRMO (City/Municipal Disaster Risk Reduction and Management Office).

## Core Purpose

Track and manage inventory items (equipment, supplies) with full lifecycle tracking from borrowing to return, including QR code scanning for quick item identification.

## Key Stakeholders

- **CDRRMO Staff** - Administer inventory and view reports
- **Borrowers** - Request and return equipment
- **System** - Automated tracking via QR codes and mobile scanning

## Platform Architecture

### Mobile App (Flutter)
- **Target**: Field staff and borrowers
- **Key Features**: QR scanning, active loans, inventory browsing, profile management
- **Offline-First**: Uses Isar for local persistence with background sync
- **Navigation**: GoRouter with deep linking support

### Web Dashboard (Next.js 15)
- **Target**: LGU staff and administrators
- **Key Features**: Inventory management, borrow/return logs, reporting, analytics
- **Architecture**: App Router with Server Components by default
- **Design**: "Steel Cage" layout optimized for 14" laptop screens

## Data Model

### Core Entities
- **Inventory Items** - Equipment and supplies with stock tracking
- **Borrow Logs** - Transaction records with status (borrowed/returned/overdue/cancelled)
- **Users** - Authenticated users with roles and status (active/pending/suspended)

### Key Workflows
1. **Borrowing**: Scan item → Select quantity → Specify return date → Log transaction
2. **Returning**: Scan item → Log return → Update inventory stock
3. **Overdue Detection**: Automatic status update when expected return date passes

## Technical Constraints

- **Multi-Tenant Isolation**: Every query must be scoped to authenticated user
- **Offline-First**: Mobile app must work without internet with sync on reconnect
- **Real-Time**: Web dashboard shows live inventory updates
- **Type Safety**: No `dynamic` (Dart) or `any` (TypeScript) allowed
