# Active Context - LIGTAS Mobile

## Current Focus
Polishing the User Experience and finalizing the Dashboard/Loan management flow.

## 🛠️ Recent Fixes & Additions
1. **Sync Feedback**: Added a premium glassmorphic notification when pull-to-refreshing the Dashboard.
2. **Scanner Stability**: Fixed "Red Screen" RangeError by hardening ID substring logic.
3. **Time Accuracy**: Fixed Active Tab timestamps showing "now" / "a moment ago" instead of correct time.
   - **Root Cause**: loan_model.dart fell back to `DateTime.now()` (phone time) when `borrow_date` was NULL
   - **Fix**: Removed phone time fallback, use database timestamps only
4. **Dock Restoration**: Ensured the navigation dock properly reappears after closing a QR Scan modal.
5. **Color Semantics**: Implemented consistent color-coding for tab badges (Active/Overdue/Pending).

## 📂 Key Files Involved
- `lib/src/features/dashboard/screens/dashboard_screen.dart` - Added Sync feedback
- `lib/src/features/scanner/widgets/scan_result_sheet.dart` - Substring safety fix
- `lib/src/features/dashboard/widgets/mission_control_widgets.dart` - Time formatting fix
- `lib/src/features/loans/models/loan_model.dart` - borrow_date fallback fix
- `lib/src/features/navigation/screens/main_screen.dart` - Dock visibility fix

## 🚀 Next Steps
- Verify the "Scan-to-Return" logic handles partial returns correctly in all scenarios.
- Review and refine the "Success" state of the borrow request flow.
