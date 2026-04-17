# LIGTAS AI RULES — Next.js + Flutter + Supabase + Riverpod

---

## BEHAVIOR

- No preamble. No "Great question!". No "Here's how we can solve this!".
- Never explain what you're about to do. Just do it.
- Keep wording simple and non-technical by default. If a technical term is unavoidable, explain it in plain words right away.
- After code, output exactly two sections:
  - **Changes** — bullet list, one line each, plain English, what changed and where
  - **Watch out** — only if there's a real risk, assumption, or something the dev must manually handle. Skip this section entirely if there's nothing worth flagging.
- If a task is unclear, ask one specific question. Not multiple. Not a paragraph.


## LANGUAGE

Explain in simple words, thats it, super simple words


---

## BEFORE WRITING ANY CODE

State in 2–3 sentences:
1. What you're building and where it lives
2. What you're deliberately NOT doing and why

If you're unsure about an existing pattern in the codebase, write:
`// ASSUMPTION: [what you're guessing]`
Never silently invent structure.

---

## FOLDER STRUCTURE

### Next.js
```
/features/{feature-name}/
  components/     # UI only, no logic
  actions/        # Server Actions, mutations only
  hooks/          # Client-side data fetching, state
  types.ts        # Types scoped to this feature
  utils.ts        # Only if 3+ consumers exist

/shared/
  ui/             # Reusable dumb components
  lib/            # Supabase client, auth helpers
  types/          # Global types
  hooks/          # Hooks used across 2+ features
```

### Flutter
```
/features/{feature-name}/
  presentation/   # Widgets only
  providers/      # Riverpod providers
  repository/     # Supabase calls
  model/          # Freezed models

/shared/
  widgets/
  providers/
  services/       # Supabase client, auth
```

**Hard rules:**
- No `utils.ts` at root level. Ever.
- No file over 200 lines. Stop and split before continuing.
- No feature importing from another feature directly. Go through `/shared/`.

---

## NEXT.JS RULES

- Server Actions for all mutations. No API routes unless streaming or webhook.
- No DB calls inside components. Components call hooks or actions only.
- No `useEffect` to sync state. If you feel the urge, stop and find the right pattern.
- `use client` only on leaf components that need interactivity. Never on a layout or page.
- Always validate with Zod before touching Supabase.
- Return typed responses from every Server Action:
  ```ts
  type ActionResult<T> = { data: T; error: null } | { data: null; error: string }
  ```
- No `any`. No `as SomeType` without a comment explaining why.

---

## FLUTTER RULES

- Every provider uses `.when(data:, error:, loading:)`. No `.value` without null check.
- All models use Freezed. No plain Dart classes for data that crosses layers.
- No business logic inside widgets. Widgets call providers, nothing else.
- Providers are `AsyncNotifierProvider` or `FutureProvider`. Plain `StateProvider` only for primitive UI state (bool, int).
- Repository layer handles all Supabase calls. Providers call repositories, not Supabase directly.
- Always handle offline: if a query can fail silently, say so in **Watch out**.

---

## SUPABASE RULES

- Every query must be scoped to the user:
  ```ts
  .eq('user_id', session.user.id)
  ```
- Never `.select('*')`. Always name the columns you need.
- Never expose raw Supabase errors to the UI. Map them to a user-facing string.
- Confirm RLS exists on the table before writing queries. If unknown, flag it in **Watch out**.
- Use DTOs. Never pass raw Supabase row types into UI or business logic layers.
- Paginate any list query over 20 items. Default: `.range(from, to)` with a page size constant.

---

## TYPE SAFETY

- No `any`. No `dynamic` in Flutter except JSON decoding, and only at the boundary.
- All function parameters and return types explicitly typed.
- API and Supabase responses typed via generated types or a manual DTO. Never inferred from raw response.

---

## ERROR HANDLING

- All external calls (Supabase, API, storage) inside try-catch.
- No empty catch blocks. At minimum: log + return structured error.
- Never throw raw errors to the UI. Always return `{ data, error }` or equivalent.

---

## WHAT MAKES CODE SENIOR HERE

These are the patterns that separate acceptable code from good code in this stack.

**Do:**
- Co-locate everything for a feature. A dev should find all logic for `invoices` inside `/features/invoices/`.
- Name things by domain, not by type. `useInvoiceList` not `useData`. `invoiceRepository` not `dataService`.
- Write one function per responsibility. If a function fetches AND transforms AND validates, split it.
- Keep providers thin. Providers orchestrate. Repositories fetch. Utils transform.

**Never:**
- Create an abstraction that has only one call site.
- Split a file just to hit a line count. Split only when concerns are genuinely different.
- Add a loading state without an error state.
- Write optimistic updates without a rollback plan.

---

## SELF-CHECK BEFORE OUTPUT

Before returning code, silently verify:
- [ ] No file over 200 lines
- [ ] No unscoped Supabase query
- [ ] Every external call has error handling
- [ ] No logic inside a widget or component
- [ ] No invented structure — flagged assumptions where unsure
- [ ] Output only the changed functions, not the whole file

If any item fails, fix it before outputting.

---

## OUTPUT FORMAT

```
[code]

**Changes**
- Added `invoiceRepository.ts` — handles all invoice Supabase queries
- Moved validation into `createInvoiceAction.ts` before DB call
- Updated `InvoiceList` widget to use `.when()` on provider

**Watch out**
- Assumes RLS is enabled on `invoices` table — verify before deploying
```

Nothing else. No summaries. No explanations above the code.