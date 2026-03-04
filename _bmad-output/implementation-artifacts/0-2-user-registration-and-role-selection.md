# Story 0.2: User Registration & Role Selection

Status: review

## Story

As a new user,
I want to register with my email and password and choose whether I am a homeowner or a vendor,
so that I can access the features relevant to my role.

## Acceptance Criteria

1. **Given** I am a new user and not logged in, **when** I open the app, **then** I am shown the registration screen at `/auth/register` (the initial route) and cannot access any homeowner or vendor screens.

2. **Given** I am on the registration screen, **when** I enter a valid email and password and tap "Register", **then** a Supabase Auth account is created and I am navigated to `/auth/role-selection`.

3. **Given** I am on the role selection screen, **when** I tap "I am a Homeowner", **then** a `profiles` row is created with `user_type = 'homeowner'` and I am navigated to `/homeowner` via `context.go('/homeowner')`.

4. **Given** I am on the role selection screen, **when** I tap "I am a Vendor", **then** a `profiles` row is created with `user_type = 'vendor'` and I am navigated to `/vendor` via `context.go('/vendor')`.

5. **Given** I enter an already-registered email, **when** I tap "Register", **then** an inline error is shown: "An account with this email already exists."

6. **Given** I enter an invalid email format or a password under 6 characters, **when** I tap "Register", **then** inline validation errors appear below the respective fields before the network call is made.

## Tasks / Subtasks

- [x] **Task 1: Add colour constants to app_constants.dart and fix app_theme.dart** (AC: 2, 5, 6)
  - [x] Add all colour constants from UX spec to `AppConstants` class (see Dev Notes below for exact values)
  - [x] Fix `app_theme.dart`: change `colorSchemeSeed` to `colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF1B3A6B))` (Deep Navy per UX spec — current file uses wrong green value `0xFF1B6B3A` and wrong parameter name `colorSchemeSeed`)

- [x] **Task 2: Create `user_model.dart`** (AC: 2, 3, 4)
  - [x] Create `lib/features/auth/domain/user_model.dart`
  - [x] Fields: `id` (String), `email` (String), `userType` (String — `'homeowner'` or `'vendor'`)
  - [x] `fromJson()` factory reading Supabase `profiles` row (`snake_case` columns → `camelCase` fields)
  - [x] All fields `final`, constructor `const`

- [x] **Task 3: Create `auth_repository.dart`** (AC: 2, 3, 4, 5)
  - [x] Create `lib/features/auth/data/auth_repository.dart`
  - [x] Method `signUp(String email, String password)` → calls `supabase.auth.signUp()` → returns `AuthResponse`
  - [x] Method `createProfile(String userId, String userType)` → inserts into `profiles` table
  - [x] Method `getCurrentUser()` → returns `supabase.auth.currentUser` (nullable)
  - [x] Catch `AuthException` → rethrow as `AppException`; catch `PostgrestException` → rethrow as `AppException`
  - [x] ONLY this file imports `supabase_flutter` in the auth feature

- [x] **Task 4: Create `auth_notifier.dart` and `auth_provider.dart`** (AC: 2, 3, 4)
  - [x] Create `lib/features/auth/presentation/auth_notifier.dart`
  - [x] `AuthNotifier extends AsyncNotifier<void>` — action-oriented; `build()` returns `Future.value()`
  - [x] Method `register(String email, String password)` — calls repository `signUp()`; propagates `AppException`
  - [x] Method `createProfile(String userType)` — calls repository with current user ID + userType
  - [x] Do NOT navigate inside the notifier — navigation happens in screen's `ref.listen` callback
  - [x] Create `lib/features/auth/presentation/auth_provider.dart`
  - [x] `final authRepositoryProvider = Provider<AuthRepository>((ref) => AuthRepository());`
  - [x] `final authNotifierProvider = AsyncNotifierProvider<AuthNotifier, void>(AuthNotifier.new);`

- [x] **Task 5: Create `register_screen.dart`** (AC: 1, 2, 5, 6)
  - [x] Create `lib/features/auth/presentation/screens/register_screen.dart`
  - [x] Use `ConsumerStatefulWidget` (needs controllers + error state)
  - [x] Email `TextField` with `TextInputType.emailAddress`, label `'Email *'`
  - [x] Password `TextField` with `obscureText: true`, label `'Password *'`
  - [x] Client-side validation on submit only: non-empty + `@` check for email; ≥ 6 chars for password; display via `errorText` inline
  - [x] Full-width `FilledButton` at bottom: "Register" — disabled with `CircularProgressIndicator.adaptive()` while loading
  - [x] `ref.listen` on `authNotifierProvider`: on success → `context.go('/auth/role-selection')`; on error → set `_emailError` for duplicate email
  - [x] `TextButton` below: "Already have an account? Log in" → `context.go('/auth/login')` (placeholder, Story 0.3)
  - [x] Dispose `TextEditingController`s in `dispose()`

- [x] **Task 6: Create `role_selection_screen.dart`** (AC: 3, 4)
  - [x] Create `lib/features/auth/presentation/screens/role_selection_screen.dart`
  - [x] Use `ConsumerStatefulWidget` (needs loading state per button)
  - [x] AppBar title: "Choose Your Role"
  - [x] Heading: "Who are you?" — `headlineSmall`, `AppConstants.primaryNavy`
  - [x] Subheading: "Choose your role to get started" — `bodyMedium`, `AppConstants.textSecondary`
  - [x] Full-width `FilledButton`: "I am a Homeowner" → `createProfile('homeowner')` then `context.go('/homeowner')`
  - [x] Full-width `OutlinedButton`: "I am a Vendor" → `createProfile('vendor')` then `context.go('/vendor')`
  - [x] Both buttons disabled + `CircularProgressIndicator.adaptive()` while in-flight
  - [x] On `AppException`: show `SnackBar` with error message (background `AppConstants.statusError`)
  - [x] No back navigation — reached via `context.go()`, not `context.push()`

- [x] **Task 7: Wire real screens in `app_router.dart`** (AC: 1, 2, 3, 4)
  - [x] Replace `/auth/register` placeholder builder with `const RegisterScreen()`
  - [x] Replace `/auth/role-selection` placeholder builder with `const RoleSelectionScreen()`
  - [x] Change `initialLocation` from `'/auth/login'` to `'/auth/register'` (Story 0.3 adds session redirect)
  - [x] Add imports for the two new screen files

- [x] **Task 8: Write tests** (AC: 2, 3, 4, 5)
  - [x] Create `test/features/auth/data/auth_repository_test.dart` — mock Supabase client; test `signUp` happy path; test `createProfile` inserts correct row; test duplicate email surfaces as `AppException`
  - [x] Create `test/features/auth/presentation/auth_notifier_test.dart` — test `register()` transitions loading → data; test error propagation

## Dev Notes

### Critical: supabase_flutter 2.x Auth API

```dart
// Registration — user is immediately active (email confirm disabled for hackathon)
final AuthResponse res = await Supabase.instance.client.auth.signUp(
  email: email,
  password: password,
);

// Duplicate email handling — TWO behaviours possible:
// 1. Supabase returns user with empty identities list (silent duplicate)
if (res.user != null && (res.user!.identities?.isEmpty ?? false)) {
  throw AppException(code: 'user-already-exists', message: 'An account with this email already exists.');
}
// 2. OR throws AuthException with message containing "already registered"/"already exists"
// Handle both in catch block

// Access current user after signUp (session stored automatically)
final User? currentUser = Supabase.instance.client.auth.currentUser;

// Profile insertion
await Supabase.instance.client.from('profiles').insert({
  'id': currentUser!.id,
  'user_type': userType, // 'homeowner' or 'vendor'
});
```

### Critical: auth_repository.dart Full Pattern

```dart
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/exceptions/app_exception.dart';

class AuthRepository {
  final _supabase = Supabase.instance.client;

  Future<AuthResponse> signUp(String email, String password) async {
    try {
      final res = await _supabase.auth.signUp(email: email, password: password);
      if (res.user != null && (res.user!.identities?.isEmpty ?? false)) {
        throw AppException(
          code: 'user-already-exists',
          message: 'An account with this email already exists.',
        );
      }
      return res;
    } on AuthException catch (e) {
      final isDuplicate = e.message.toLowerCase().contains('already registered') ||
                          e.message.toLowerCase().contains('already exists');
      throw AppException(
        code: isDuplicate ? 'user-already-exists' : (e.statusCode?.toString() ?? 'auth-error'),
        message: isDuplicate ? 'An account with this email already exists.' : e.message,
      );
    }
  }

  Future<void> createProfile(String userId, String userType) async {
    try {
      await _supabase.from('profiles').insert({
        'id': userId,
        'user_type': userType,
      });
    } on PostgrestException catch (e) {
      throw AppException(code: e.code ?? 'db-error', message: e.message);
    }
  }

  User? getCurrentUser() => _supabase.auth.currentUser;
}
```

### Critical: AuthNotifier Pattern (AsyncNotifier<void>)

```dart
class AuthNotifier extends AsyncNotifier<void> {
  @override
  Future<void> build() async {}

  Future<void> register(String email, String password) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref.read(authRepositoryProvider).signUp(email, password),
    );
  }

  Future<void> createProfile(String userType) async {
    state = const AsyncLoading();
    final user = ref.read(authRepositoryProvider).getCurrentUser();
    state = await AsyncValue.guard(
      () => ref.read(authRepositoryProvider).createProfile(user!.id, userType),
    );
  }
}
```

### Critical: Navigation via ref.listen (NOT inside notifier)

```dart
// In RegisterScreen — use ref.listen for navigation
ref.listen<AsyncValue<void>>(authNotifierProvider, (previous, next) {
  if (next.hasError) {
    final err = next.error;
    if (err is AppException && err.code == 'user-already-exists') {
      setState(() => _emailError = err.message);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(err.toString()), backgroundColor: AppConstants.statusError),
      );
    }
  }
  if (next.hasValue && previous?.isLoading == true) {
    context.go('/auth/role-selection');
  }
});
```

### Critical: Colour Constants — Add to app_constants.dart

Add inside `AppConstants` class after the existing constants:

```dart
import 'package:flutter/material.dart'; // add to top of file if not present

// Primary
static const Color primaryNavy     = Color(0xFF1B3A6B);
static const Color primaryBlue     = Color(0xFF2E6BC6);
static const Color primaryBlueSoft = Color(0xFFD6E4F7);

// Neutrals
static const Color backgroundApp   = Color(0xFFF8F9FB);
static const Color surfaceCard     = Color(0xFFFFFFFF);
static const Color divider         = Color(0xFFEEF0F4);
static const Color textSecondary   = Color(0xFF9BA3B2);
static const Color textPrimary     = Color(0xFF1C2230);

// Semantic
static const Color statusSuccess   = Color(0xFF4CAF82);
static const Color statusWarning   = Color(0xFFF4A732);
static const Color statusError     = Color(0xFFE05252);
```

[Source: `_bmad-output/planning-artifacts/ux-design-specification.md` — Visual Design Foundation, Color System]

### Critical: app_theme.dart Bug Fix

Current file has TWO bugs — wrong parameter name AND wrong colour. Fix to:

```dart
import 'package:flutter/material.dart';

class AppTheme {
  static ThemeData light() => ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: const Color(0xFF1B3A6B), // Deep Navy (UX spec)
      brightness: Brightness.light,
    ),
  );
}
```

> `colorSchemeSeed` does NOT exist as a `ThemeData` parameter — use `colorScheme: ColorScheme.fromSeed(...)`. Current code will fail `flutter analyze`.

### Critical: profiles Table Schema (Migration 001)

```sql
profiles (
  id          uuid        PK references auth.users ON DELETE CASCADE,
  user_type   text        NOT NULL CHECK (user_type IN ('homeowner', 'vendor')),
  name        text,       -- nullable, set in later stories
  phone       text,       -- nullable
  avatar_url  text,       -- nullable
  created_at  timestamptz NOT NULL DEFAULT now()
)
-- RLS: auth.uid() = id (all operations)
```

Insert only `id` and `user_type` in this story. Name/phone/avatar_url are set later.

### Critical: app_router.dart Changes

```dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../features/auth/presentation/screens/register_screen.dart';
import '../../features/auth/presentation/screens/role_selection_screen.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: '/auth/register', // Changed — Story 0.3 adds session redirect
  routes: [
    GoRoute(
      path: '/auth/login',
      builder: (context, state) => const Scaffold(
        body: Center(child: Text('Login — Story 0.3')),
      ),
    ),
    GoRoute(
      path: '/auth/register',
      builder: (context, state) => const RegisterScreen(),
    ),
    GoRoute(
      path: '/auth/role-selection',
      builder: (context, state) => const RoleSelectionScreen(),
    ),
    GoRoute(
      path: '/homeowner',
      builder: (context, state) => const Scaffold(
        body: Center(child: Text('Homeowner Dashboard — Epic 1')),
      ),
    ),
    GoRoute(
      path: '/vendor',
      builder: (context, state) => const Scaffold(
        body: Center(child: Text('Vendor Dashboard — Epic 4')),
      ),
    ),
  ],
);
```

### UX Notes — Register Screen

- AppBar title: "Create Account"
- Screen background: `AppConstants.backgroundApp` (`#F8F9FB`), horizontal padding 16dp
- Email field label: `'Email *'`, `TextInputType.emailAddress`
- Password field label: `'Password *'`, `obscureText: true`
- Validate on submit only — never on keystroke
- Primary button: `FilledButton` full-width, anchored at bottom with 16dp padding
- While in-flight: disable button, show `CircularProgressIndicator.adaptive()` inside button
- Error display: `TextField` `errorText` inline (never `AlertDialog` or `SnackBar` for form errors)
- Below button: `TextButton` "Already have an account? Log in" → `context.go('/auth/login')`

[Source: `_bmad-output/planning-artifacts/ux-design-specification.md` — UX Consistency Patterns, Form Patterns + Button Hierarchy]

### UX Notes — Role Selection Screen

- AppBar title: "Choose Your Role"
- Column centred vertically, 16dp horizontal padding
- Heading: "Who are you?" — `Theme.of(context).textTheme.headlineSmall`, colour `AppConstants.primaryNavy`
- Subheading: "Choose your role to get started" — `bodyMedium`, colour `AppConstants.textSecondary`
- `SizedBox(height: 32)` between heading block and buttons
- Homeowner: `FilledButton` full-width — "I am a Homeowner"
- `SizedBox(height: 12)` between buttons
- Vendor: `OutlinedButton` full-width — "I am a Vendor"
- All buttons: min height 48dp, 16dp horizontal padding inside
- No back arrow — navigated via `context.go()`, stack replaced

[Source: `_bmad-output/planning-artifacts/ux-design-specification.md` — User Journey Flows, Journey 1 + Journey 3]

### Architecture Compliance — Mandatory Rules (ALL Stories)

| Rule | Correct | Wrong |
|---|---|---|
| Supabase calls | Only in `auth_repository.dart` | Never in notifier or widgets |
| Async state | `AsyncNotifier<void>` | Never `StateNotifier<AsyncValue<...>>` |
| Navigation | `context.go()` / `context.push()` | Never `Navigator.push()` |
| Errors | Catch typed exceptions → rethrow as `AppException` | Never `throw Exception('...')` |
| Provider names | `authRepositoryProvider`, `authNotifierProvider` | Any other suffix |
| DB columns | `snake_case`: `user_type`, `created_at` | Never `camelCase` in SQL/JSON |

[Source: `_bmad-output/planning-artifacts/architecture.md` — Enforcement Guidelines]

### Previous Story Intelligence (Story 0.1)

- `app_exception.dart` — **EXISTS** at `lib/core/exceptions/app_exception.dart`; do NOT recreate
- `app_router.dart` — **EXISTS** at `lib/core/router/app_router.dart`; MODIFY in-place, do NOT recreate
- `app_constants.dart` — **EXISTS**; ADD colour constants to existing class
- `app_theme.dart` — **EXISTS**; FIX the two parameter bugs (use Edit, not Write)
- All `lib/features/auth/` subdirectories — **EXIST** with `.gitkeep` files; add `.dart` files, remove `.gitkeep` as folders get populated
- `main.dart` — already uses `DefaultFirebaseOptions.currentPlatform` (fixed during dev session); do NOT revert
- `supabase/migrations/001_create_profiles.sql` — already created; profiles table is ready
- `supabase_flutter 2.x` named params confirmed: `Supabase.initialize(url: ..., anonKey: ...)` ✅
- `firebase_core: ^4.5.0` already in pubspec.yaml
- Manual steps still pending: `flutter pub get`, `flutter analyze`, `supabase db push` — do not depend on local CLI

> Story 0.1 file is at: `_bmad-output/implementation-artifacts/1-1-flutter-project-scaffolding-and-supabase-initialisation.md` (old naming — still valid reference)

### Project Structure Notes

- New files all under `lib/features/auth/` per feature-first layout
- `auth_provider.dart` and `auth_notifier.dart` go directly in `lib/features/auth/presentation/` (not in a subdirectory)
- Remove `.gitkeep` from `auth/data/`, `auth/domain/`, `auth/presentation/screens/` as real files are added
- Tests go in `test/features/auth/data/` and `test/features/auth/presentation/` (directories exist from Story 0.1)

### References

- Story AC: [Source: `_bmad-output/planning-artifacts/epics.md` — Epic 0, Story 0.2]
- Feature folder structure: [Source: `_bmad-output/planning-artifacts/architecture.md` — Structure Patterns]
- AuthNotifier/AsyncNotifier pattern: [Source: `_bmad-output/planning-artifacts/architecture.md` — State Management Patterns]
- Colour constants: [Source: `_bmad-output/planning-artifacts/ux-design-specification.md` — Visual Design Foundation, Color System]
- Form patterns: [Source: `_bmad-output/planning-artifacts/ux-design-specification.md` — UX Consistency Patterns, Form Patterns]
- Button hierarchy: [Source: `_bmad-output/planning-artifacts/ux-design-specification.md` — UX Consistency Patterns, Button Hierarchy]
- profiles schema: [Source: `_bmad-output/planning-artifacts/architecture.md` — Data Architecture]
- Enforcement rules: [Source: `_bmad-output/planning-artifacts/architecture.md` — Enforcement Guidelines]

## Dev Agent Record

### Agent Model Used

claude-sonnet-4-6

### Debug Log References

- Circular import issue: `auth_notifier.dart` importing `auth_provider.dart` which imported back. Resolved by splitting providers: `auth_provider.dart` holds only `authRepositoryProvider`; `auth_notifier.dart` holds `AuthNotifier` class + `authNotifierProvider`.
- `SupabaseQueryBuilder` implements `Future`, so mocktail's `thenReturn` was rejected for `client.from()`. Resolved using `thenAnswer((_) => queryBuilder)` and custom `Fake`-based `_CapturingQueryBuilder`.
- Notifier test missed `AsyncLoading` because `build()` hadn't completed before listener registration. Resolved by awaiting `container.read(authNotifierProvider.future)` before setting up the listener.
- `mocktail: ^1.0.4` added to dev_dependencies (required by story task "mock Supabase client"; anticipated by pre-existing `test_helpers.dart` comment).

### Completion Notes List

- All 8 tasks and all subtasks implemented and verified.
- `AuthRepository` given optional `supabaseClient` constructor param for testability; production default is `Supabase.instance.client`.
- `authNotifierProvider` placed in `auth_notifier.dart` (not `auth_provider.dart`) to break circular import; screens only need to import `auth_notifier.dart`.
- 13 tests pass; `flutter analyze` reports zero issues.
- AC 1 (initial route guard): `initialLocation` changed to `/auth/register`. Full session-based redirect deferred to Story 0.3 per spec.

### File List

spr_house_maintenance_tracker/lib/core/constants/app_constants.dart
spr_house_maintenance_tracker/lib/core/theme/app_theme.dart
spr_house_maintenance_tracker/lib/core/router/app_router.dart
spr_house_maintenance_tracker/lib/features/auth/domain/user_model.dart
spr_house_maintenance_tracker/lib/features/auth/data/auth_repository.dart
spr_house_maintenance_tracker/lib/features/auth/presentation/auth_notifier.dart
spr_house_maintenance_tracker/lib/features/auth/presentation/auth_provider.dart
spr_house_maintenance_tracker/lib/features/auth/presentation/screens/register_screen.dart
spr_house_maintenance_tracker/lib/features/auth/presentation/screens/role_selection_screen.dart
spr_house_maintenance_tracker/pubspec.yaml
test/features/auth/data/auth_repository_test.dart
test/features/auth/presentation/auth_notifier_test.dart
_bmad-output/implementation-artifacts/sprint-status.yaml

## Change Log

- 2026-03-04: Implemented Story 0.2 — user registration, role selection, auth repository/notifier/providers, register and role selection screens, router wired, 13 tests added (claude-sonnet-4-6)
