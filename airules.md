# LIGTAS ENTERPRISE AI CODE GENERATION PROTOCOL — V5.0

> **For:** LIGTAS / MarineGuard — Disaster Management & Equipment Tracking
> **Stack:** Flutter (Mobile) + Next.js 14+ App Router (Web) + Supabase

---

## §0 — RESPONSE FORMAT LAW
> **TOP PRIORITY. Overrides all other instructions. Invalid response if violated.**

### Banned phrases — never use these:
- "Great question!" / "Sure!" / "Of course!" / "Certainly!"
- "Let me explain..." / "As an AI..." / "I'll now..."
- "In summary..." / "Hope that helps!"

### Required output structure — always in this exact order:

| Step | Label | Rule |
|------|-------|------|
| 1 | **SCAN** | List every file that will be read or changed. Max 5 bullets. |
| 2 | **BLUEPRINT** | Bullet-point plan of exact changes, file by file. No code yet. |
| 3 | **BLOCKERS** | Flag security issues, missing RLS, unscoped queries. If any exist — STOP. Do not write code. |
| 4 | **CONFIRM** | One sentence. Ask user to approve the blueprint before writing code. |
| 5 | **CODE** | Only after confirmation. Complete functions only. No truncation. Only output changed functions, not the entire file. |

### Code output rules:
- No `// ...rest of code`
- No `// implement here`
- No `// TODO`
- Complete functions only, every time

---

## §1 — ANTI-HALLUCINATION PROTOCOL

1. **Read before touch.** Before modifying any existing file, use available tools to read the actual file content. Confirm variable names, imports, and function signatures from source. Never assume.
2. **Unknown path = stop.** If a file path, dependency, or variable name is unknown — stop and ask the user. Never guess a path.
3. **Unknown dependency = stop.** If a package version or API method is uncertain — state it explicitly. Do not fabricate method signatures.
4. **Imports must be verified.** Every import in generated code must come from a confirmed, existing package in the project. No invented imports.

---

## §2 — SAFETY NET RULE

1. Every network request, DB write, and hardware interaction **must** have a `try-catch` block.
2. Empty catch blocks are **forbidden**. Log the error. Return a typed failure state.
3. Server Actions must return:
   ```ts
   { success: boolean, message: string, errors?: any }
   ```
4. Flutter async functions must handle all three states — every time:
   ```dart
   .when(data: ..., loading: ..., error: ...)
   ```

---

## §3 — SECURITY & MULTI-TENANCY
> **BLOCKER: Missing RLS on any Supabase query = refuse to write the query until the policy is confirmed.**

1. Every Supabase query must be scoped to the authenticated user. No unscoped `.select()` calls.
2. LGU tenant isolation is mandatory. Cross-tenant data leaks are a critical vulnerability — flag immediately.
3. All Server Action inputs must be validated via a `Zod` schema before any DB operation.
4. Never expose raw Supabase errors to the client. Sanitize error messages before returning.

---

## §4 — FLUTTER ARCHITECTURE

1. **Structure:** Feature-first directory layout:
   ```
   lib/src/features/[feature_name]/
   ├── presentation/
   ├── domain/
   └── data/
   ```
2. **State:** `@riverpod` generator only. Every provider must handle `.when(data, loading, error)` in the UI.
3. **Models:** `Freezed` with `@Default` on all fields. `dynamic` is strictly forbidden.
4. **Offline:** `Isar` for local cache. `SyncRepository` for background sync.
5. **Performance:** `const` constructors everywhere possible. `SliverList.builder` for all lists with more than 10 items.

---

## §5 — NEXT.JS ARCHITECTURE (App Router 14+)

1. **Rendering:** Default to React Server Components. `"use client"` only on leaf components requiring hooks or browser APIs.
2. **Mutations:** Server Actions exclusively. Must return typed `{ success, message, errors? }`.
3. **Validation:** Every Server Action validates with a `Zod` schema before touching the DB.
4. **State:** URL state (`searchParams`) first. Zustand only for global client state.
5. **Styling:** Tailwind only. No hardcoded `px` values. Use `rem` or `%`. Responsive from 14" laptop down to mobile.

---

## §6 — LANGUAGE & OUTPUT STANDARDS

1. Plain English with correct technical terms. Short sentences. Max 2 sentences per explanation point.
2. No analogies or metaphors unless user appends `?explain` to the prompt.
3. No truncation. No `// ...rest of code`. No `// implement here`. Complete functions only.
4. When modifying existing code — output only the changed functions, not the entire file.
5. **Zero sycophancy.** If a proposed design is insecure, over-engineered, or wrong — say so bluntly before writing anything.
6. If a simpler native solution exists for a complex abstraction request — reject the complex version and provide the simple one.

---

## Quick Reference — Blocker Checklist

Before writing any code, verify:

- [ ] File read and confirmed before modifying?
- [ ] RLS policy confirmed for every Supabase query?
- [ ] Every query scoped to authenticated user?
- [ ] `try-catch` on every network/DB/hardware call?
- [ ] Zod schema on every Server Action input?
- [ ] No `dynamic` types in Flutter models?
- [ ] All three Riverpod states handled in UI?
- [ ] Blueprint confirmed by user before code output?