# LIGTAS SYSTEM — PROJECT MAP
> Last updated: April 2026. Reference this before touching any file.

---

## OVERVIEW

| Property | Value |
|---|---|
| System Name | LIGTAS / MarineGuard |
| Domain | Disaster Management & Equipment Tracking |
| Platforms | Flutter Mobile + Next.js 15 Web |
| Backend | Supabase (Postgres + Auth + Realtime + Storage) |
| Mobile State | Riverpod 2 + Riverpod Generator |
| Mobile Local DB | Isar 3.1.0+1 |
| Web Framework | Next.js 15 App Router (React 19) |
| Web Styling | Tailwind CSS + shadcn/ui (Radix) |
| Web Mutations | Server Actions only |
| Web Validation | Zod |

---

## REPO STRUCTURE

```
LIGTAS_SYSTEM/
├── mobile/          Flutter app (Android/iOS)
├── web/             Next.js 15 web dashboard
└── PROJECT_MAP.md   This file
```

---

## USER ROLES

| Role | Mobile Landing | Web Access |
|---|---|---|
| `responder` | `/dashboard` | Read-only borrower |
| `manager` / `admin` | `/manager` (AnalystTerminalScreen) | Full dashboard |
| `pending` | `/pending` screen | Blocked |
| `suspended` | `/denied` screen | Blocked |

`user.canEdit` = true for manager/admin — gates all write operations.

---

## ═══ MOBILE (Flutter) ═══

### Entry Points
| File | Purpose |
|---|---|
| `lib/main.dart` | App bootstrap, Isar init, Firebase init |
| `lib/src/app.dart` | `LigtasApp` widget + GoRouter config + role-based redirect logic |

### Core Layer — `lib/src/core/`

| Path | Purpose |
|---|---|
| `config/app_config.dart` | App-wide constants |
| `config/env.dart` | Supabase URL/anon key |
| `design_system/app_theme.dart` | Material theme + `AppTheme.lightTheme` |
| `design_system/widgets/` | Shared widgets: `AppToast`, `ShimmerSkeleton`, `PrimaryButton`, `TacticalForensicCard`, `OfflineIndicator` |
| `di/app_providers.dart` | Root Riverpod providers |
| `errors/app_exceptions.dart` | Typed exceptions |
| `extensions/supabase_client_extension.dart` | Supabase helper extensions |
| `local_storage/isar_service.dart` | **Isar singleton** — all schema registration + static collection accessors |
| `local_storage/isar_service_provider.dart` | Riverpod provider wrapping IsarService |
| `navigation/navigator_key.dart` | `rootNavigatorKey` for imperative navigation |
| `networking/connectivity_provider.dart` | Online/offline state |
| `networking/supabase_client.dart` | Supabase client singleton |
| `repositories/sync_repository.dart` | Background sync orchestrator |
| `utils/result.dart` | `Result<T>` success/failure wrapper |

### Isar Schemas (registered in `IsarService.init()`)
| Schema | Model File | Collection Accessor |
|---|---|---|
| `InventoryCollectionSchema` | `features/inventory/models/inventory_model.dart` | `_isar.collection<InventoryCollection>()` |
| `LoanCollectionSchema` | `features/loans/models/loan_model.dart` | `_isar.collection<LoanCollection>()` |
| `TransactionCollectionSchema` | `features/transactions/models/transaction_model.dart` | `_isar.collection<TransactionCollection>()` |
| `ChatMessageIsarSchema` | `features_v2/chat/data/models/chat_isar_model.dart` | via generated getter |
| `PresenceCollectionSchema` | `features/presence/data/models/presence_model.dart` | via generated getter |
| `WeatherIsarSchema` | `features/weather/data/models/weather_isar_model.dart` | via generated getter |
| `NotificationConfigSchema` | `features/notifications/data/models/notification_config_model.dart` | via generated getter |
| `NotificationCollectionSchema` | `features/notifications/data/models/notification_model.dart` | `IsarService.notificationItems` static accessor |

> **ISAR RULE:** Always `import 'package:isar/isar.dart'` in any file using `.where()`, `.filter()`, `.findAll()`, `.findFirst()`. These are extension methods — they are invisible without the direct import.

### GoRouter Routes
| Path | Screen | Role Guard |
|---|---|---|
| `/splash` | `SplashScreenPage` | public |
| `/intro` | `ModernIntroCards` | public |
| `/login` | `LoginScreen` | public |
| `/register` | `RegisterScreen` | public |
| `/pending` | `PendingApprovalScreen` | pending users |
| `/denied` | `AccessDeniedScreen` | suspended users |
| `/dashboard` | `DashboardScreen` | responder + manager |
| `/manager` | `AnalystTerminalScreen` | `canEdit` only |
| `/manager/queue` | `LogisticalQueueScreen` | `canEdit` only |
| `/manager/activity` | `ActivityLedgerScreen` | `canEdit` only |
| `/inventory` | `InventoryScreen` | all active |
| `/inventory/request` | `RequestEquipmentScreen` | all active |
| `/requests` | `ActiveLoansScreen` | all active |
| `/notifications` | `NotificationsScreen` | all active |
| `/profile` | `SettingsScreen` | all active |
| `/profile/personal-info` | `PersonalInfoScreen` | all active |
| `/profile/security` | `SecurityScreen` | all active |
| `/scanner` | `ScannerView` | all active |
| `/transaction` | `TransactionScreen` | all active |
| `/chat/:roomId` | `ChatScreen` | all active |
| `/history` | `LoanHistoryScreen` | all active |

### Features — `lib/src/features/` (v1 — stable)

| Feature | Key Files |
|---|---|
| **auth** | `data/auth_repository.dart`, `presentation/controllers/auth_controller.dart`, `presentation/providers/auth_providers.dart`, `domain/models/user_model.dart` |
| **dashboard** | `controllers/dashboard_controller.dart`, `screens/dashboard_screen.dart`, `providers/dashboard_provider.dart`, `widgets/mission_control_widgets.dart` |
| **analyst_dashboard** | `data/repositories/analyst_repository_impl.dart`, `domain/repositories/i_analyst_repository.dart`, `presentation/screens/analyst_terminal_screen.dart`, `presentation/screens/logistical_queue_screen.dart`, `presentation/screens/activity_ledger_screen.dart`, `presentation/controllers/analyst_dashboard_controller.dart` |
| **manager_dashboard** | `data/repositories/manager_repository_impl.dart`, `domain/repositories/i_manager_repository.dart`, `presentation/controllers/manager_dashboard_controller.dart` |
| **notifications** | `data/models/notification_model.dart`, `data/repositories/notification_repository.dart`, `data/services/user_notification_service.dart`, `data/services/notification_isolate.dart`, `presentation/providers/notification_provider.dart`, `screens/notifications_screen.dart`, `controllers/notification_controller.dart` |
| **loans** (v1) | `models/loan_model.dart`, `repositories/loan_repository.dart`, `providers/loan_providers.dart`, `presentation/screens/loan_history_screen.dart` |
| **inventory** (v1) | `models/inventory_model.dart`, `providers/inventory_providers.dart` |
| **scanner** | `models/qr_payload.dart`, `presentation/screens/transaction_screen.dart`, `widgets/scanner_view.dart` |
| **transactions** | `models/transaction_model.dart`, `services/quick_borrow_service.dart` |
| **presence** | `data/models/presence_model.dart`, `data/repositories/presence_repository.dart`, `presentation/providers/presence_provider.dart` |
| **weather** | `data/repositories/weather_repository.dart`, `domain/entities/weather_data.dart`, `presentation/providers/weather_provider.dart`, `presentation/widgets/weather_card.dart` |
| **profile** | `data/profile_repository.dart`, `controllers/profile_controller.dart`, `screens/profile_screen.dart` |
| **settings** | `presentation/controllers/settings_controller.dart`, `presentation/screens/settings_screen.dart` |
| **navigation** | `screens/main_screen.dart` (FloatingDock shell), `widgets/comms_capsule.dart`, `widgets/comms_drawer.dart` |
| **intro/splash** | `screens/splash_screen_page.dart`, `screens/modern_intro_cards.dart` |

### Features V2 — `lib/src/features_v2/` (active development)

| Feature | Key Files |
|---|---|
| **inventory** | `data/repositories/supabase_inventory_repository.dart`, `domain/entities/inventory_item.dart`, `presentation/providers/inventory_provider.dart`, `presentation/providers/mission_cart_provider.dart`, `presentation/screens/inventory_screen.dart` |
| **loans** | `data/repositories/supabase_loan_repository.dart`, `domain/entities/loan_item.dart`, `presentation/providers/loan_provider.dart`, `presentation/providers/borrow_request_provider.dart`, `presentation/screens/active_loans_screen.dart` |
| **chat** | `data/models/chat_isar_model.dart`, `data/repositories/chat_repository.dart`, `presentation/providers/chat_providers.dart`, `presentation/providers/unread_chat_provider.dart`, `presentation/screens/chat_screen.dart`, `presentation/screens/chat_rooms_screen.dart` |
| **equipment_request** | `presentation/screens/request_equipment_screen.dart`, `presentation/components/request_form_step.dart`, `presentation/components/request_review_step.dart` |

---

## ═══ WEB (Next.js 15) ═══

### Entry Points
| File | Purpose |
|---|---|
| `app/layout.tsx` | Root layout, font, providers |
| `app/dashboard/layout.tsx` | Dashboard shell with Sidebar + Header |
| `middleware.ts` | Auth middleware — protects all `/dashboard` routes |
| `providers/auth-provider.tsx` | Client-side auth context |

### App Router Pages
| Route | Page File | Notes |
|---|---|---|
| `/` | `app/page.tsx` | Redirects to login or dashboard |
| `/login` | `app/login/page.tsx` | Auth form |
| `/dashboard` | `app/dashboard/page.tsx` + `dashboard-client.tsx` | Main stats overview |
| `/dashboard/inventory` | `app/dashboard/inventory/` | Inventory management |
| `/dashboard/logs` | `app/dashboard/logs/` | Borrow log management |
| `/dashboard/approvals` | `app/dashboard/approvals/` | Pending borrow approvals |
| `/dashboard/users` | `app/dashboard/users/` | User + borrower management |
| `/dashboard/borrowers` | `app/dashboard/borrowers/` | Borrower registry |
| `/dashboard/chat` | `app/dashboard/chat/` | Chat with chat-v3 components |
| `/dashboard/reports` | `app/dashboard/reports/` | Report generation |
| `/dashboard/profile` | `app/dashboard/profile/` | User profile |
| `/m/*` | `app/m/` | Mobile-optimized web views |

### Server Actions — `app/actions/` + `web/actions/`
| File | Handles |
|---|---|
| `app/actions/logs-actions.ts` | Borrow log CRUD, status transitions |
| `app/actions/user-management.ts` | Approve/suspend/invite users |
| `app/actions/notification-actions.ts` | Trigger notifications |
| `app/actions/logistics-actions.ts` | Logistics queue operations |
| `app/actions/chat-v3.ts` | Chat message send/read |
| `app/actions/report-actions.ts` | Report export |
| `app/actions/storage-locations.ts` | Storage location management |
| `src/features/transactions/actions/transaction.actions.ts` | Borrow/return transaction processing |
| `src/features/catalog/actions/catalog.actions.ts` | Inventory catalog CRUD |
| `src/features/approvals/actions/approval.actions.ts` | Approval workflow |
| `actions/inventory-transfer.ts` | Cross-warehouse transfers |

### Key Components
| Path | Purpose |
|---|---|
| `components/layout/sidebar.tsx` | Main nav sidebar |
| `components/layout/header.tsx` | Top bar + notification bell |
| `components/layout/notification-bell-v2.tsx` | Realtime notification badge |
| `components/inventory/inventory-table.tsx` | Main inventory data table |
| `components/inventory/inventory-dialog-v2/` | Add/edit inventory item (v2 dialog, split into sections) |
| `components/logs/log-session-table.tsx` | Borrow log table with bulk actions |
| `components/chat-v3/` | Full chat UI (sidebar, messenger window, FAB) |
| `components/notifications/` | Notification popover + cards |
| `components/users/` | User management tables + modals |
| `components/dashboard/` | Stats cards, charts, triage bar |
| `components/transactions/` | Borrow + return dialogs |
| `src/features/transactions/v2/` | v2 Borrow + Return command sheets |

### Data Layer
| File | Purpose |
|---|---|
| `lib/supabase-server.ts` | Server-side Supabase client (SSR cookies) |
| `lib/supabase-browser.ts` | Client-side Supabase client |
| `lib/database.types.ts` | Auto-generated Supabase types |
| `lib/queries/inventory.ts` | Inventory query functions |
| `lib/queries/logs.ts` | Borrow log query functions |
| `lib/queries/borrowers.ts` | Borrower query functions |
| `lib/repositories/notification-repository.ts` | Notification fetch/mark-read |
| `lib/repositories/analytics-repository.ts` | Analytics aggregations |
| `lib/types/inventory.ts` | Inventory TypeScript types |
| `lib/types/chat.ts` | Chat TypeScript types |
| `lib/inventory-utils.ts` | Inventory helper functions |

### Hooks
| Hook | Purpose |
|---|---|
| `use-dashboard-stats.ts` | Dashboard KPI numbers |
| `use-inventory.ts` | Inventory list + realtime |
| `use-borrow-logs.ts` | Borrow log list + realtime |
| `use-notifications.ts` | Notification list + unread count |
| `use-chat-v3.ts` | Chat messages + realtime |
| `use-unread-chat.ts` | Unread chat badge count |
| `use-user-management.ts` | User list management |
| `use-borrower-registry.ts` | Borrower registry |
| `use-pending-requests.ts` | Pending approval queue |
| `use-trending-inventory.ts` | Trending items chart data |
| `use-auth.ts` | Auth session + user role |

---

## ═══ SUPABASE DATABASE ═══

### Tables
| Table | Purpose |
|---|---|
| `user_profiles` | Extended user data: role, status, warehouse, FCM token |
| `inventory` | Equipment catalog with stock, status, location |
| `borrow_logs` | Borrow/return transactions (the core transaction table) |
| `chat_rooms` | Chat room registry |
| `chat_messages` | Chat messages with read receipts |
| `system_notifications` | App notifications for users |
| `notification_reads` | Junction table: which user read which notification |
| `storage_locations` | Named storage locations within warehouses |
| `access_requests` | Pending access requests from new users |
| `authorized_emails` | Whitelist for auto-approval |
| `user_fcm_tokens` | Firebase push token registry |
| `activity_log` | Audit log for all data changes |
| `cctv_logs` | CCTV/surveillance log entries |

### Views
| View | Purpose |
|---|---|
| `active_inventory` | Inventory filtered to non-deleted, available items |
| `inventory_availability` | Stock availability with reservation counts |
| `inventory_items_with_variants` | Items joined with variant data |

### Key RPC Functions
| Function | Purpose |
|---|---|
| `get_user_inbox(p_limit)` | Returns paginated notification inbox for current user |
| `get_active_chat_inbox_v2` | Returns chat rooms with unread counts |
| `get_full_item_name` | Assembles full item name from parts |
| `handle_device_token` | Register/update FCM token |
| `increment_inventory` | Atomic stock increment |
| `approve_user` | Approve a pending user with role assignment |
| `update_user_role` | Change a user's role |

### DB Scripts — `web/_db_scripts/`
Applied to Supabase in order as features were added. Key scripts:
- `COMPLETE_DATABASE_SETUP.sql` — base schema
- `SETUP_NOTIFICATION_PIPELINE.sql` — notification triggers
- `ENABLE_REALTIME_*.sql` — realtime publication setup
- `fix_rls_recursion.sql` — critical RLS fix (run if auth loops occur)
- `MASTER_STABILIZATION_RECOVERY.sql` — emergency recovery script

---

## ═══ KNOWN PATTERNS & GOTCHAS ═══

### Isar (Mobile)
- **Always import `package:isar/isar.dart` directly** in any file using query extension methods. Extension methods are not transitive.
- Use `IsarService.notificationItems` (static accessor) for `NotificationCollection` — avoids query-builder state machine issues.
- Run `dart run build_runner build --delete-conflicting-outputs` after any model change.

### Riverpod (Mobile)
- All providers use `@riverpod` generator. Generated files are `*.g.dart` — never edit manually.
- Every provider must handle `.when(data, loading, error)` in the UI — no exceptions.

### Server Actions (Web)
- All mutations go through Server Actions — no direct Supabase calls from client components.
- Every action validates with Zod before touching the DB.
- Return shape: `{ success: boolean, message: string, errors?: any }`.

### Auth / RLS
- Every Supabase query must be scoped to the authenticated user.
- `user_profiles` RLS had a recursion bug — `fix_rls_recursion.sql` resolves it.
- Role check: `user.canEdit` = manager or admin role.

### Dual Feature Versions (Mobile)
- `features/` = v1 (stable, some deprecated)
- `features_v2/` = active development (inventory, loans, chat)
- When touching inventory or loans, prefer `features_v2/` files.

### Chat
- Web uses `chat-v3` components and `app/actions/chat-v3.ts`.
- Mobile uses `features_v2/chat/`.
- Both hit `chat_rooms` and `chat_messages` tables via Supabase Realtime.

### Notifications
- Web: `components/notifications/` + `lib/repositories/notification-repository.ts` + `get_user_inbox` RPC.
- Mobile: `features/notifications/data/repositories/notification_repository.dart` — same RPC.
- Read receipts stored in `notification_reads` junction table (not a column on `system_notifications`).
