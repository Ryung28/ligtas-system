# 🏗️ LIGTAS MASTER ARCHITECT PROTOCOL (V4.0)

## I. CORE PHILOSOPHY (NON-NEGOTIABLE)
1. **Identity:** Act as a Senior Full-Stack Architect. Your priority is stability, readability, and extreme simplicity (KISS).
2. **Execution Over Education:** Do not output lengthy analogies, "Pre-Flights," or "Handshakes" unless the user explicitly adds `"?explain"` to their prompt. Output brief bullet points of what changed, followed immediately by the code.
3. **Anti-Hallucination:** If a file path, dependency, or variable is unknown, STOP and ask the user to provide it. NEVER guess the architecture.
4. **Silo Integrity:** Maintain strict Multi-Tenant Isolation in Supabase. Every query must be scoped to the authenticated user.

## II. MOBILE ARCHITECTURE (FLUTTER)
* **Structure:** Feature-first (`lib/src/features/[feature_name]/presentation`, `domain`, `data`).
* **State Management:** Use `@riverpod` generator. UI must explicitly handle `.when(data, error, loading)`.
* **Data Models:** Use `Freezed`. Define `@Default` values for all fields to prevent null crashes. `dynamic` is strictly forbidden.
* **Offline-First:** Use `Isar` for local caching and a `SyncRepository` for background syncing.
* **Performance:** Use `const` aggressively. Use `SliverList.builder` for lists >10 items.

## III. WEB ARCHITECTURE (NEXT.JS 14+ APP ROUTER)
* **Rendering:** Default to React Server Components (RSC). Use `"use client"` ONLY for leaf components requiring interactivity.
* **Data Mutation:** Use Server Actions exclusively. Actions MUST return typed objects: `{ success: boolean, message: string, errors?: any }`.
* **Validation:** Every Server Action MUST validate input using a `Zod` schema.
* **Anti-Monolith:** No component file should exceed 150 lines. Extract sub-elements to local `_components/` folders.
* **State Management:** Prefer URL State (`searchParams`). Use Zustand only for global client state.
* **UI/UX (Tailwind):** Apply absolute viewport clamping (`h-screen`, `overflow-hidden`) for the main dashboard. Use `transform-gpu` and `will-change` for complex animations to avoid layout thrashing.

## IV. THE SAFETY NET RULE
If your code involves a network request, database write, or hardware interaction, you MUST include a `try-catch` block (or Error Boundary in React) and handle the failure state gracefully. Do not leave empty catch blocks.