# Manager Batch Hand Over + Reserve Blueprint

This blueprint defines a manager-friendly multi-item flow for `HAND OVER` and `RESERVE` without changing behavior yet.

## Goal

Allow one manager to process many items for one recipient in one session, with fewer taps and fewer dispatch mistakes.

## Current State (What we already have)

- User flow already supports cart behavior in mobile (`mission_cart_provider`) and request flow (`borrow_request_provider`).
- Manager sheet modes (`IDENTITY`, `RESTOCK`, `HAND OVER`, `RESERVE`) are currently single-item only.
- `HAND OVER` and `RESERVE` submit one `borrowItem(...)` call per opened item sheet.

## Proposed UX Model

Use a manager version of cart flow:

1. Manager enters `HAND OVER` or `RESERVE` mode.
2. Manager selects multiple items (cart/session list).
3. Manager fills recipient fields once.
4. Manager reviews all lines with warnings.
5. Manager confirms one batch action.

## Why not copy user FAB exactly

- A floating bubble is easy to miss in manager workflows.
- Managers need stronger affordance for “commit operation”.
- Better pattern: sticky bottom action bar in manager mode, plus optional FAB badge if needed.

## Recommended UI Layout (Mobile)

### 1) Selection State

- Keep item cards tappable for add/remove.
- Show inline quantity controls on selected cards.
- Show sticky bottom bar:
  - `Selected: N items`
  - Primary: `REVIEW HAND OVER` or `REVIEW RESERVE`
  - Secondary: `CLEAR`

### 2) Review Sheet

- Header:
  - Mode (`HAND OVER` or `RESERVE`)
  - Count summary (`3 items · 7 units`)
- Recipient block (shared fields):
  - Recipient name
  - Office
  - Contact
  - Approved by
  - Released by
- Schedule block:
  - Handover: optional return date toggle
  - Reserve: required pickup date + optional return date
- Item lines:
  - Item name + location + qty stepper
  - Per-line warning chips (`LOW STOCK`, `CONFLICT`, `RESERVED`)
- Footer:
  - `BACK`
  - `CONFIRM HAND OVER` / `CONFIRM RESERVE`

### 3) Result State

- Success: “Batch complete” with count and simple receipt summary.
- Failure: show per-line failures and allow retry only failed lines.

## Interaction Rules (Ease of Use)

- Prefill `releasedBy` from current user.
- Prefill last used recipient fields per manager (local cached draft).
- Keep tap count low:
  - Single item quick path remains available.
  - Batch path activates only when 2+ items selected or user chooses batch.
- Fast quantity controls:
  - `-` and `+`
  - Long-press acceleration
  - Hard stock clamp

## Safety Rules

- Always show review step before final submit.
- Validate shared fields before submit.
- Validate each line stock at review and at commit.
- If backend is not atomic yet, clearly label result as partial-success capable.

## Data + State Blueprint

Add manager batch state parallel to current manager action state:

- `mode`: handover | reserve
- `items`: selected line items with quantity and optional line-level dates
- `recipient`: shared profile block
- `approval`: approvedBy + releasedBy
- `schedule`: pickup + return settings
- `ui`: isReviewOpen, isSubmitting, submitError

Keep this independent from existing user request cart to avoid role coupling.

## Implementation Phases

### Phase 1 — UI + State (no backend schema change)

- Create `manager_dispatch_cart_provider` (selection + quantities).
- Add manager sticky bottom action bar in inventory manager mode.
- Add review sheet widget for batch handover/reserve.
- Keep existing single-item sheet for quick single actions.

### Phase 2 — Submit Strategy

Option A (fastest): loop single `borrowItem` calls with result summary.

Option B (preferred): add `batchBorrowItems` style repository method for manager flow.

Use Option A first only if we need speed and can tolerate partial success.

### Phase 3 — Reliability + Polish

- Save/restore in-progress draft for accidental close.
- Add receipt summary view.
- Add telemetry for:
  - open review
  - submit success
  - submit partial failure

## API and Repository Direction

- Keep widgets dumb: widgets call provider only.
- Provider orchestrates; repository does Supabase calls.
- Do not call Supabase directly from presentation.

## Edge Cases to Test

- Same item selected multiple times across locations.
- Quantity exceeds available stock mid-session.
- One line fails while others succeed.
- Reserve with missing pickup schedule.
- Offline or session expired during submit.

## Rollout Plan

1. Ship behind manager-only path first.
2. Keep single-item flow active as fallback.
3. Watch failure rates and completion time.
4. Promote batch as default once stable.
