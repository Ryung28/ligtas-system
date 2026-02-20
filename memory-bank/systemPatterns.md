# LIGTAS Architecture

## Stack
- **Mobile**: Flutter + Riverpod + GoRouter
- **Web**: Next.js 14 + TypeScript + Tailwind
- **Backend**: Supabase (PostgreSQL + Auth)

## Key Patterns

### Riverpod State
```dart
final provider = StateNotifierProvider<Notifier, State>((ref) => Notifier(ref));
```

### Modal Sheet Dock Fix
```dart
// Force show dock when suppression ends
ref.listen(isDockSuppressedProvider, (prev, next) {
  if (prev == true && next == false) {
    setState(() => _isDockVisible = true);
  }
});
```

## Files
- `mobile/lib/src/features/navigation/` - Nav & dock
- `mobile/lib/src/features/loans/` - Borrow flow
- `mobile/lib/src/features/scanner/` - QR scanning
