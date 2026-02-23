# LIGTAS Mobile Polishment Plan

## 🛠️ Refactoring & Optimization
- [x] **Centralize Notifications:** Move `_showTopNotification` from individual screens to a reusable `AppToast` utility.
- [x] **Globalize Dashboard Providers:** Move `_freshLoansProvider` from `DashboardScreen` state to `dashboard_provider.dart`.
- [x] **Centralize Inventory Categories:** Move hardcoded category lists from `InventoryScreen` to a centralized configuration/provider.
- [x] **Refine Error Handling:** Create a premium `LigtasErrorState` component to replace simple text error messages.

## 🚀 Functional Improvements
- [x] **Active Loans Actions:** Implement "Cancel Request" and "Initiate Return" logic in `ActiveLoansScreen`.
- [x] **Offline Awareness:** Implement a global "Offline" status indicator.
- [x] **Bento Performance:** Optimize Bento tile animations for smoother scroll performance.
