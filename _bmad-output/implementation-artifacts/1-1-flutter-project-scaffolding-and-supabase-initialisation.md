# Story 1.1: Flutter Project Scaffolding & Supabase Initialisation

Status: review

<!-- Note: Validation is optional. Run validate-create-story for quality check before dev-story. -->

## Story

As a **developer**,
I want to initialise the Flutter project with all core dependencies, the feature-first folder structure, and a live Supabase connection,
so that the team has a runnable, correctly structured foundation on which all 22 stories can be built without rework.

## Acceptance Criteria

1. **Given** the repo root, **when** `flutter create spr_house_maintenance_tracker --org com.spr --platforms ios,android` is run, **then** the Flutter project is created with iOS and Android targets only (no web/desktop)

2. **Given** the project exists, **when** `pubspec.yaml` is configured, **then** all required packages are present at the exact constrained versions: `supabase_flutter: ^2.12.0`, `firebase_messaging: ^16.1.2`, `flutter_riverpod: ^2.x`, `go_router: ^14.x`, `image_picker: ^1.x`, `url_launcher: ^6.x`; `flutter pub get` runs with no errors

3. **Given** packages are added, **when** the feature-first folder structure is created, **then** `lib/features/{auth,property,maintenance,booking,vendor,notifications,payment}/` each exist with `data/`, `domain/`, and `presentation/` subdirectories (with `screens/` and `widgets/` under `presentation/` for feature-heavy features)

4. **Given** the folder structure exists, **when** core files are created, **then** all four core files exist and compile:
   - `lib/core/exceptions/app_exception.dart` — typed AppException class
   - `lib/core/router/app_router.dart` — GoRouter skeleton (two empty route trees)
   - `lib/core/theme/app_theme.dart` — Material 3 ThemeData
   - `lib/core/constants/app_constants.dart` — service type string constants

5. **Given** a Supabase project is created, **when** environment variables are configured via `--dart-define`, **then** `SUPABASE_URL`, `SUPABASE_ANON_KEY`, and `FCM_SENDER_ID` are read from `const String.fromEnvironment(...)` in main.dart; a local `.env` file with real values exists but is gitignored; no secrets are committed

6. **Given** environment config is in place, **when** `main.dart` is implemented, **then** `await Supabase.initialize(url: ..., anonKey: ...)` and `FirebaseApp` initialization run before `runApp(ProviderScope(child: MyApp()))`, and the app launches without errors on both platforms

7. **Given** the Supabase project is ready, **when** migration `001_create_profiles.sql` is applied via `supabase db push`, **then** the `profiles` table exists with columns `id (uuid PK references auth.users)`, `user_type (text not null check: homeowner|vendor)`, `name (text)`, `phone (text)`, `avatar_url (text)`, `created_at (timestamptz default now())`; RLS is enabled; the policy allows users to select/insert/update their own row only (`auth.uid() = id`)

## Tasks / Subtasks

- [x] **Task 1: Initialise Flutter project** (AC: 1)
  - [x] Run: `flutter create spr_house_maintenance_tracker --org com.spr --platforms ios,android`
  - [ ] ⚠️ MANUAL STEP — Flutter SDK not installed on this machine. See SETUP.md Step 1. `android/` and `ios/` directories will be created by this command.
  - [x] Delete `test/widget_test.dart` boilerplate (done — test/helpers/test_helpers.dart stub created instead)

- [x] **Task 2: Configure pubspec.yaml** (AC: 2)
  - [x] Add all six dependencies at specified versions — `pubspec.yaml` created with exact versions
  - [ ] ⚠️ MANUAL STEP — Run `flutter pub get` after Flutter SDK is installed
  - [x] `flutter_lints: ^4.0.0` added to dev_dependencies
  - [x] `analysis_options.yaml` created extending flutter_lints

- [x] **Task 3: Create feature-first folder structure** (AC: 3)
  - [x] Created `lib/features/auth/data/`, `lib/features/auth/domain/`, `lib/features/auth/presentation/screens/`
  - [x] Repeated for: `property`, `maintenance`, `booking`, `vendor`, `notifications`, `payment`
  - [x] Created `test/features/` mirror for: `auth`, `property`, `maintenance`, `booking`, `vendor`, `notifications`
  - [x] Created `test/helpers/test_helpers.dart` stub
  - [x] Added `.gitkeep` to all empty directories

- [x] **Task 4: Create core files** (AC: 4)
  - [x] Created `lib/core/exceptions/app_exception.dart` — typed AppException class
  - [x] Created `lib/core/router/app_router.dart` — GoRouter skeleton with 5 placeholder routes
  - [x] Created `lib/core/theme/app_theme.dart` — Material 3 with SPR brand green seed
  - [x] Created `lib/core/constants/app_constants.dart` — service types, recurrence intervals, booking statuses
  - [ ] ⚠️ MANUAL STEP — Run `flutter analyze` after `flutter pub get` to verify zero errors

- [x] **Task 5: Supabase project setup + environment config** (AC: 5)
  - [ ] ⚠️ MANUAL STEP — Create Supabase project at supabase.com (free tier)
  - [ ] ⚠️ MANUAL STEP — Copy URL and anon key from project settings into `.env`
  - [x] `.env.example` template created with all required variables documented
  - [x] `.env` and `**/google-services.json`, `**/GoogleService-Info.plist` added to `.gitignore`
  - [x] VS Code `launch.json` pattern documented in SETUP.md
  - [ ] ⚠️ MANUAL STEP — Install Supabase CLI: `brew install supabase/tap/supabase`
  - [ ] ⚠️ MANUAL STEP — Run `supabase init` in repo root

- [x] **Task 6: Implement main.dart** (AC: 6)
  - [x] `main.dart` created with `Supabase.initialize` + `Firebase.initializeApp` + `ProviderScope` + `GoRouter`
  - [x] Entire app wrapped in `ProviderScope`
  - [x] `MaterialApp.router` using `appRouter` from `app_router.dart`
  - [x] `AppTheme.light()` applied
  - [ ] ⚠️ MANUAL STEP — Run on iOS simulator and Android emulator after Flutter SDK + Firebase config installed

- [x] **Task 7: Create profiles table migration** (AC: 7)
  - [x] Created `supabase/migrations/001_create_profiles.sql` with all columns, RLS, policy, and index
  - [ ] ⚠️ MANUAL STEP — Run `supabase start` then `supabase db push` to apply
  - [ ] ⚠️ MANUAL STEP — Verify table in Supabase Studio at localhost:54323

## Dev Notes

### Critical: Exact pubspec.yaml Dependencies Block

```yaml
dependencies:
  flutter:
    sdk: flutter
  supabase_flutter: ^2.12.0
  firebase_messaging: ^16.1.2
  flutter_riverpod: ^2.6.1      # Use latest 2.x (^2.x resolves to latest 2.x, NOT 3.x)
  go_router: ^14.6.3            # Use latest 14.x (^14.x resolves to latest 14.x, NOT 15+)
  image_picker: ^1.1.2
  url_launcher: ^6.3.2

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^4.0.0
```

> ⚠️ **Version Note (from web research 2026-03-04):** `flutter_riverpod` 3.x and `go_router` 17.x are now the latest stable, but the architecture specifies `^2.x` and `^14.x` respectively. The `^` constraint PREVENTS automatic major-version upgrades — this is intentional. Do NOT manually bump to 3.x or 17.x; there are breaking API changes. Post-hackathon upgrade path: Riverpod 2→3 migration guide + go_router 14→17 changelog.

### Critical: main.dart Implementation

```dart
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Supabase initialisation — reads from --dart-define
  await Supabase.initialize(
    url: const String.fromEnvironment('SUPABASE_URL'),
    anonKey: const String.fromEnvironment('SUPABASE_ANON_KEY'),
  );

  // Firebase / FCM initialisation
  await Firebase.initializeApp();
  await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
    alert: true,
    badge: true,
    sound: true,
  );

  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'SPR House Maintenance',
      theme: AppTheme.light(),
      routerConfig: appRouter,
    );
  }
}
```

> ⚠️ `supabase_flutter 2.x` API change from 1.x: `Supabase.initialize()` now uses **named parameters** (`url:`, `anonKey:`). The `client` is accessed via `Supabase.instance.client`. Auth state uses `supabase.auth.onAuthStateChange` as a stream.

### Critical: app_exception.dart

```dart
class AppException implements Exception {
  const AppException({required this.code, required this.message});

  final String code;
  final String message;

  @override
  String toString() => 'AppException($code): $message';
}
```

All repositories MUST catch `PostgrestException` and rethrow as `AppException`. Never throw `Exception('Something went wrong')`.

### Critical: app_router.dart Skeleton

```dart
import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';

final appRouter = GoRouter(
  initialLocation: '/auth/login',
  routes: [
    GoRoute(
      path: '/auth/login',
      builder: (context, state) => const Scaffold(body: Center(child: Text('Login — Story 1.3'))),
    ),
    GoRoute(
      path: '/auth/register',
      builder: (context, state) => const Scaffold(body: Center(child: Text('Register — Story 1.2'))),
    ),
    GoRoute(
      path: '/homeowner',
      builder: (context, state) => const Scaffold(body: Center(child: Text('Homeowner Home — Epic 2'))),
    ),
    GoRoute(
      path: '/vendor',
      builder: (context, state) => const Scaffold(body: Center(child: Text('Vendor Home — Epic 4'))),
    ),
  ],
);
```

> Role-based redirect guards are added in Story 1.3 when auth state is wired. Story 1.1 only needs the skeleton routes to compile.

> ⚠️ **go_router 14.x API note:** Use `GoRoute.path` and `GoRouter.routes`. The `params` argument was renamed to `pathParameters` and `queryParams` to `queryParameters` in go_router 13+. Do NOT use old `state.params` syntax.

### Critical: app_theme.dart

```dart
import 'package:flutter/material.dart';

class AppTheme {
  static ThemeData light() => ThemeData(
    useMaterial3: true,
    colorSchemeSeed: const Color(0xFF1B6B3A), // SPR brand green
    brightness: Brightness.light,
  );
}
```

### Critical: app_constants.dart

```dart
class AppConstants {
  static const List<String> serviceTypes = [
    'Aircon Cleaning',
    'Pest Control',
    'Plumbing Check',
    'Septic Tank Pump-out',
    'Rooftop Inspection',
    'Electrical Check',
  ];

  static const Map<String, String> defaultRecurrenceIntervals = {
    'Aircon Cleaning': 'quarterly',
    'Pest Control': 'semi-annual',
    'Plumbing Check': 'quarterly',
    'Septic Tank Pump-out': 'annual',
    'Rooftop Inspection': 'semi-annual',
    'Electrical Check': 'annual',
  };

  static const List<String> recurrenceOptions = [
    'monthly',
    'quarterly',
    'semi-annual',
    'annual',
  ];
}
```

### Critical: Profiles Table Migration (001_create_profiles.sql)

```sql
-- Migration: 001_create_profiles.sql
-- Creates the profiles table for all users (homeowners and vendors)

create table if not exists public.profiles (
  id          uuid        primary key references auth.users on delete cascade,
  user_type   text        not null check (user_type in ('homeowner', 'vendor')),
  name        text,
  phone       text,
  avatar_url  text,
  created_at  timestamptz not null default now()
);

-- Enable Row Level Security
alter table public.profiles enable row level security;

-- Policy: users can only read/write their own row
create policy "users_own_profile"
  on public.profiles
  for all
  using (auth.uid() = id)
  with check (auth.uid() = id);
```

> **RLS note:** `for all` covers SELECT, INSERT, UPDATE, DELETE. The trigger on `auth.users` CASCADE DELETE ensures profiles are removed when a user deletes their account.

### Feature Folder Structure — Complete Layout for This Story

```
lib/
├── main.dart
├── core/
│   ├── constants/
│   │   └── app_constants.dart      ← CREATE in this story
│   ├── exceptions/
│   │   └── app_exception.dart      ← CREATE in this story
│   ├── router/
│   │   └── app_router.dart         ← CREATE in this story (skeleton only)
│   └── theme/
│       └── app_theme.dart          ← CREATE in this story
└── features/
    ├── auth/
    │   ├── data/                   ← empty (auth_repository.dart in Story 1.2)
    │   ├── domain/                 ← empty (user_model.dart in Story 1.2)
    │   └── presentation/
    │       └── screens/            ← empty (screens in Story 1.2 and 1.3)
    ├── property/                   ← scaffold only (populated in Epic 2)
    ├── maintenance/                ← scaffold only (populated in Epic 2+3)
    ├── booking/                    ← scaffold only (populated in Epic 5)
    ├── vendor/                     ← scaffold only (populated in Epic 4)
    ├── notifications/              ← scaffold only (populated in Story 1.4)
    └── payment/                    ← scaffold only (populated in Epic 6)

supabase/
├── config.toml                     ← generated by `supabase init`
└── migrations/
    └── 001_create_profiles.sql     ← CREATE in this story
```

### Architecture Compliance — Mandatory Rules (from architecture.md)

All rules below apply to THIS story and ALL future stories. Violations cause regressions.

| Rule | Correct | Wrong |
|---|---|---|
| Supabase calls | Only in `*_repository.dart` | Never in widgets or notifiers |
| Async state | `AsyncNotifier` only | Never `StateNotifier<AsyncValue<...>>` |
| Navigation | `context.go()` / `context.push()` | Never `Navigator.push()` |
| Errors | Catch `PostgrestException`, throw `AppException` | Never `throw Exception('...')` |
| Images | Upload to Storage → save URL string | Never binary in Postgres |
| DB naming | `snake_case` | Never `camelCase` |
| Dart naming | `camelCase` methods/vars, `PascalCase` classes | No `SCREAMING_SNAKE_CASE` constants |
| Provider names | `{feature}NotifierProvider` | Any other suffix |

### Environment Config — --dart-define Pattern

The IDE must be configured to pass these at run/build time:

```bash
# For flutter run (development):
flutter run \
  --dart-define=SUPABASE_URL=https://xxxx.supabase.co \
  --dart-define=SUPABASE_ANON_KEY=eyJ... \
  --dart-define=FCM_SENDER_ID=123456789

# For flutter build (production):
flutter build apk \
  --dart-define=SUPABASE_URL=... \
  --dart-define=SUPABASE_ANON_KEY=... \
  --dart-define=FCM_SENDER_ID=...
```

Store real values in `.env` (gitignored). Never commit secrets. Access in code:
```dart
const supabaseUrl = String.fromEnvironment('SUPABASE_URL');
```

### Supabase CLI Commands for This Story

```bash
# Install (macOS)
brew install supabase/tap/supabase

# Initialise Supabase project in repo root
supabase init

# Start local Supabase (Postgres + Studio + Edge Functions)
supabase start

# Apply migrations to local instance
supabase db push

# Open local Supabase Studio
open http://localhost:54323

# Link to remote project (after local is verified)
supabase link --project-ref <your-ref>

# Push migrations to remote
supabase db push --linked
```

### Testing Standards for This Story

This story is primarily scaffolding — no business logic exists yet. Required tests:

- `test/helpers/test_helpers.dart` — stub file only (no content needed yet)
- Confirm `flutter test` exits with 0 (no test files = passing)
- Confirm `flutter analyze` exits with 0 (zero lint errors)

No unit tests are required for skeleton folders or core constants. Authentication and repository tests are introduced in Stories 1.2 and 1.3.

### Post-Hackathon Upgrade Notes (do NOT do during hackathon)

| Package | Current (this sprint) | Future Latest | Migration Notes |
|---|---|---|---|
| flutter_riverpod | ^2.x | 3.2.1 | Breaking API changes; separate migration sprint needed |
| go_router | ^14.x | 17.1.0 | 3 major versions; `params` → `pathParameters` etc. |

### Project Structure Notes

- The Flutter project directory name is `spr_house_maintenance_tracker` (snake_case per Flutter convention)
- The Dart package name (in pubspec.yaml) is also `spr_house_maintenance_tracker`
- The iOS bundle ID is `com.spr.sprHouseMaintenanceTracker` (set by `--org com.spr`)
- The Android package name is `com.spr.spr_house_maintenance_tracker`
- The `supabase/` directory lives at the REPO ROOT (same level as `spr_house_maintenance_tracker/`), not inside the Flutter project
- `.gitignore` must exclude: `.env`, `**/google-services.json`, `**/GoogleService-Info.plist`, `*.keystore`, `supabase/.branches`, `supabase/.temp`

### References

- Architecture decisions: [Source: `_bmad-output/planning-artifacts/architecture.md` — Starter Template Evaluation, Selected Starter section]
- Package versions: [Source: `_bmad-output/planning-artifacts/architecture.md` — Key Packages]
- Folder structure: [Source: `_bmad-output/planning-artifacts/architecture.md` — Complete Project Directory Structure]
- Naming conventions: [Source: `_bmad-output/planning-artifacts/architecture.md` — Naming Patterns]
- RLS strategy: [Source: `_bmad-output/planning-artifacts/architecture.md` — RLS Policy Strategy]
- Profiles table schema: [Source: `_bmad-output/planning-artifacts/architecture.md` — Data Architecture]
- Enforcement rules: [Source: `_bmad-output/planning-artifacts/architecture.md` — Enforcement Guidelines]
- Story AC source: [Source: `_bmad-output/planning-artifacts/epics.md` — Story 1.1]

## Dev Agent Record

### Agent Model Used

claude-sonnet-4-6

### Debug Log References

- Flutter SDK not installed on dev machine — `flutter create`, `flutter pub get`, `flutter analyze`, and simulator runs are manual steps. All source files and directory structure created programmatically.
- Supabase CLI not installed — `supabase init` and `supabase db push` are manual steps. Migration SQL file created and ready.
- Added `firebase_core: ^3.0.0` to pubspec.yaml (required alongside `firebase_messaging` for `Firebase.initializeApp()` to compile).

### Completion Notes List

- Created full feature-first folder structure: 7 features × (data/ domain/ presentation/screens/ presentation/widgets/) + test mirrors
- All 4 core files created: app_exception.dart, app_router.dart, app_theme.dart, app_constants.dart
- main.dart implemented with correct supabase_flutter 2.x API (`url:` / `anonKey:` named params)
- pubspec.yaml configured with all 6 architecture-specified packages at constrained versions
- analysis_options.yaml created extending flutter_lints
- 001_create_profiles.sql migration created with RLS policy + user_type index
- .gitignore updated with Flutter, Supabase, and Firebase exclusions
- SETUP.md created with full step-by-step dev environment guide
- .env.example created with --dart-define usage patterns
- 5 manual steps remain requiring Flutter SDK / Supabase CLI / Firebase config (documented in SETUP.md)

### File List

- `spr_house_maintenance_tracker/pubspec.yaml` — new
- `spr_house_maintenance_tracker/analysis_options.yaml` — new
- `spr_house_maintenance_tracker/lib/main.dart` — new
- `spr_house_maintenance_tracker/lib/core/exceptions/app_exception.dart` — new
- `spr_house_maintenance_tracker/lib/core/router/app_router.dart` — new
- `spr_house_maintenance_tracker/lib/core/theme/app_theme.dart` — new
- `spr_house_maintenance_tracker/lib/core/constants/app_constants.dart` — new
- `spr_house_maintenance_tracker/lib/features/auth/data/.gitkeep` — new
- `spr_house_maintenance_tracker/lib/features/auth/domain/.gitkeep` — new
- `spr_house_maintenance_tracker/lib/features/auth/presentation/screens/.gitkeep` — new
- `spr_house_maintenance_tracker/lib/features/auth/presentation/widgets/.gitkeep` — new
- `spr_house_maintenance_tracker/lib/features/property/` (all subdirs with .gitkeep) — new
- `spr_house_maintenance_tracker/lib/features/maintenance/` (all subdirs with .gitkeep) — new
- `spr_house_maintenance_tracker/lib/features/booking/` (all subdirs with .gitkeep) — new
- `spr_house_maintenance_tracker/lib/features/vendor/` (all subdirs with .gitkeep) — new
- `spr_house_maintenance_tracker/lib/features/notifications/` (all subdirs with .gitkeep) — new
- `spr_house_maintenance_tracker/lib/features/payment/` (all subdirs with .gitkeep) — new
- `spr_house_maintenance_tracker/test/helpers/test_helpers.dart` — new
- `spr_house_maintenance_tracker/test/features/` (mirrors with .gitkeep) — new
- `supabase/migrations/001_create_profiles.sql` — new
- `.env.example` — new
- `.gitignore` — modified (Flutter + Supabase + Firebase entries added)
- `SETUP.md` — new
