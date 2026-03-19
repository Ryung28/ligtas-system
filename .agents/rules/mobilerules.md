---
trigger: always_on
---

MASTER FLUTTER ARCHITECT PROTOCOL (ANTI-GRAVITY)
1. Architectural Integrity & "The Steel Cage"
Feature-First Structure: Organize by feature (e.g., features/borrowing, features/inventory), never by file type.

Layered Isolation: Each feature MUST have three distinct folders:

Presentation: UI Widgets and @riverpod Notifiers (Logic).

Domain: Entities and Use Cases (Pure Dart only).

Data: Repositories, Data Sources (Supabase/FCM), and DTO Models.

The "No-Logic" Widget Rule: Widgets must be ConsumerWidget or StatelessWidget. Business logic stays in the Notifier; UI logic stays in the Widget.

2. State Management (Riverpod + Freezed)
Riverpod Generator: Always use @riverpod annotations. No manual StateNotifierProvider.

Immutability: Use Freezed for all States and Entities. Use @Default for every field to ensure Zero Null Pointer Exceptions.

AsyncValue Pattern: Use AsyncValue for all data fetching. The UI must explicitly handle .when(data, error, loading) with LIGTAS-branded skeletons.

Reactive Invalidation: When an FCM notification arrives (e.g., "Approved"), the AI must include ref.invalidate(provider) to refresh the list in the background.

3. Data & Communication (Supabase/FCM)
Repository Pattern: Widgets NEVER talk to Supabase directly. They call an Abstract Repository.

Domain Mapping: Data Sources return Models (JSON-aware); Repositories convert them into Entities (UI-aware) before they reach the Provider.

Deep Linking (GoRouter): Every notification-based navigation must use path-based routing (e.g., /borrow/details/:id) to land the user on the specific item.

4. UI & Performance Standards
Atomic Design: Break UI into atoms (Buttons), molecules (Search Bar), and organisms (Borrow Card).

Constraints: Use const constructors everywhere. Use the Gap widget for spacing; never hardcode pixel margins.

Theme Extensions: Style via Theme.of(context).extension<LigtasColors>() to maintain the dark-obsidian enterprise look.

5. The Audit Handshake (Output Requirement)
For every code snippet, the AI must provide:

The Spark: Why this specific logic was chosen (e.g., "To prevent race conditions during FCM boot").

The Path: Trace data from Supabase -> Repository -> Provider -> Widget.

The Safety Net: Point out the specific line handling "Offline Mode" or "Unauthorized" states.

Pattern Receipt: List patterns used (e.g., "Singleton Service", "Observer Pattern").