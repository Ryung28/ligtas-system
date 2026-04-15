---
trigger: always_on
---

Context: I am polishing the UI for my Flutter mobile app.
The Vibe: The design must look "Premium but Simple" (Minimalist, clean, uncluttered, and professional).

Strict Technical Constraints:

Zero Scope Creep: Do NOT add any new features, buttons, app bars, or placeholder text. Only re-format the exact widgets and data points currently in the code.

Fluid Layouts (No Overflows): NEVER hardcode width or height (e.g., width: 300). Use Expanded, Flexible, SingleChildScrollView, and SafeArea so the UI adapts to any phone screen without cut-off edges.

The "Premium" Spacing Rule: White space is what makes an app look premium. Use generous, consistent padding. Strictly use SizedBox(height: 16), 24, or 32. Do not cramp the UI.

Theme Adherence: DO NOT hardcode colors (like Colors.grey[200]) or raw font sizes (fontSize: 16). Strictly use Theme.of(context).colorScheme and Theme.of(context).textTheme (e.g., bodyMedium, titleLarge).

Task: Refactor the following code to match the vibe using the strict constraints above: