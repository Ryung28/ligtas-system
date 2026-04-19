# Report System Fix Blueprint

This document outlines the steps to fix critical issues in the report generator and dashboard stats.

## 1. Fix Server Memory Crash (Dashboard Stats)
**Problem:** `getReportStatsAction` downloads all inventory and logs to count them in memory.
**Fix:** 
- Stop downloading rows. Use Supabase's `{ count: 'exact', head: true }` feature.
- Make separate, fast queries for each stat (total items, low stock, borrowed, overdue) using database-level filters (e.g., `.lt('expected_return_date', now)`).

## 2. Fix Silent Data Loss (Report Generator Limit)
**Problem:** A hidden `.limit(500)` drops records without telling the user.
**Fix:** 
- Remove the hard limit for Excel exports. Use pagination (`.range()`) in a loop if we expect thousands of rows, stitching them together before export.
- For print, if the count is massive, warn the user first, or just allow the full fetch since it is an explicit report request.

## 3. Fix Missing User Scoping (Data Leak Risk)
**Problem:** Queries in `fetchReportData` do not filter by the current user's organization or ID.
**Fix:** 
- Get the user session at the start of `fetchReportData`.
- Add `.eq('user_id', session.user.id)` or the appropriate organization/warehouse ID filter to every query.

## 4. Fix Security Vulnerability (XSS in Print)
**Problem:** User inputs (like names and notes) are injected straight into HTML.
**Fix:** 
- Create a simple HTML escape utility function in `web/lib/utils.ts` (or equivalent shared location).
- Wrap every dynamic string in `generateReportHTML` with this escape function before putting it in the HTML string.

## 5. Fix Timezone Mismatches
**Problem:** Hardcoding `T23:59:59` causes wrong data because the database uses UTC time.
**Fix:** 
- Take the user's selected date and convert it to a proper UTC timestamp range for the start and end of that specific day in their local timezone.
- Pass these precise UTC strings to Supabase.

## 6. Fix Forever Loading Screen (Print Catalog)
**Problem:** If the inventory is empty, the print handshake waits forever.
**Fix:** 
- Check if the fetched `freshItems` is empty. If it is, close the print window immediately, stop syncing, and show a "No items found" toast message.

## 7. Fix Popup Blockers and Crashes
**Problem:** Blocked popups fail silently. Closed windows cause crashes.
**Fix:** 
- Immediately after calling `window.open()`, check if the result is null. If yes, show an error toast about popup blockers and stop.
- Before writing to `printWindow.document`, check if `printWindow.closed` is true. If the user closed it early, just stop and clean up state.
