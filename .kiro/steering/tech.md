# LIGTAS Tech Stack

## Mobile App (Flutter)

### Core Framework
- **Flutter SDK**: ^3.7.0
- **Dart SDK**: ^3.7.0
- **State Management**: Riverpod 2.5.1 + Riverpod Generator
- **Navigation**: GoRouter 14.2.7

### Backend & Networking
- **Supabase**: ^2.5.6 (Primary backend)
- **Firebase**: ^3.10.1 (Analytics, Messaging)
- **Dio**: ^5.7.0 (HTTP client)
- **Google Sign-In**: ^6.2.1

### Local Storage
- **Isar**: ^3.1.0+1 (Local database for offline-first)
- **SharedPreferences**: ^2.3.3

### QR & Scanning
- **Mobile Scanner**: ^5.1.1
- **QR Flutter**: ^4.1.0

### UI & Animations
- **Flutter Animate**: ^4.5.0 (Micro-animations)
- **Shimmer**: ^3.0.0 (Loading skeletons)
- **Animated Notch Bottom Bar**: ^1.0.4
- **Cached Network Image**: ^3.4.1
- **Google Fonts**: ^6.2.1 (Roboto typography)
- **Flutter Staggered Animations**: ^1.1.1
- **Gap**: ^3.0.1 (Spacing widgets)
- **Timeago**: ^3.7.0

### Code Generation
- **Freezed**: ^2.5.2 (Immutable models)
- **Json Serializable**: ^6.8.0
- **Build Runner**: ^2.4.12

### Build & Test Commands
```bash
# Install dependencies
flutter pub get

# Run code generation
flutter pub run build_runner build --delete-conflicting-outputs

# Run tests
flutter test

# Run with hot reload
flutter run

# Build Android APK
flutter build apk

# Build iOS
flutter build ios
```

## Web Dashboard (Next.js 15)

### Core Framework
- **Next.js**: 15 (App Router)
- **React**: 19
- **TypeScript**: Strict mode

### Styling
- **Tailwind CSS**: v3.x
- **Shadcn/UI**: Component library
- **Classname**: Utility-first class name manager

### Backend Integration
- **Supabase**: JavaScript client
- **Server Actions**: For all mutations
- **Zod**: Input validation

### State Management
- **URL State**: Primary (searchParams)
- **Zustand**: Global client state only

### Build & Dev Commands
```bash
# Install dependencies
npm install

# Run dev server (with turbo for faster rebuilds)
npm run dev -- --turbo

# Build for production
npm run build

# Start production server
npm start

# Run linting
npm run lint
```

## Shared Infrastructure

### Database
- **PostgreSQL**: Via Supabase
- **Row Level Security (RLS)**: Enabled on all tables
- **Triggers**: Auto-update inventory stock, timestamps

### Authentication
- **Supabase Auth**: JWT tokens
- **Google Sign-In**: Optional provider

### Deployment
- **Mobile**: Android APK (iOS in progress)
- **Web**: Vercel (Next.js default)

## Project Structure Conventions

### Mobile
```
lib/src/
├── core/              # Shared utilities, design system
├── features/          # Feature-based organization
├── features_v2/       # Next-gen feature implementations
└── generated/         # Code-generated files (DO NOT EDIT)
```

### Web
```
app/
├── actions/           # Server Actions (all mutations)
├── dashboard/         # Protected dashboard routes
├── login/             # Auth pages
└── layout.tsx         # Root layout

components/
├── ui/                # Shadcn components
├── layout/            # Sidebar, header
└── [feature]/         # Feature-specific components

lib/
├── supabase.ts        # Database client
├── auth.ts            # Auth helpers
└── utils.ts           # Shared utilities
```
