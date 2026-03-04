# Story 0.3: User Login & Role-Based Navigation

Status: done

## Story

As a registered homeowner or vendor,
I want to log in with my email and password,
so that I reach my role-appropriate dashboard immediately and stay logged in on return visits.

## Acceptance Criteria

1. **AC1 — Role-based navigation:** A homeowner with valid credentials is navigated to `/homeowner`; a vendor with valid credentials is navigated to `/vendor`.

2. **AC2 — Session persistence:** An already-authenticated user who relaunches the app is taken directly to their dashboard without seeing the login screen (via go_router async `redirect` reading `supabase.auth.currentSession`).

3. **AC3 — Inline error:** Submitting incorrect credentials displays the message "Incorrect email or password." on the login screen without navigating away.

## Tasks / Subtasks

- [x] **Task 1: Add `signIn` and `getProfile` to `AuthRepository`**
  - [x] `signIn(String email, String password)` — calls `supabase.auth.signInWithPassword()`; catches `AuthException` → rethrows as `AppException(code: 'invalid-credentials', message: 'Incorrect email or password.')`
  - [x] `getProfile(String userId)` — queries `profiles` table, returns `UserModel`
  - [x] `getCurrentSession()` → returns `supabase.auth.currentSession`

- [x] **Task 2: Add `signIn` to `AuthNotifier`**
  - [x] `signIn(String email, String password)` — `AsyncValue.guard` wrapping `AuthRepository.signIn()`
  - [x] State is `AsyncLoading` → `AsyncData` on success, `AsyncError` on failure

- [x] **Task 3: Create `LoginScreen`**
  - [x] `Key('email_field')`, `Key('password_field')`, `Key('login_button')`, `Key('login_error_text')`
  - [x] `ref.listen` on `authNotifierProvider`: on success → calls `_navigateToRoleDashboard()` which fetches profile and routes; on `invalid-credentials` error → sets `_loginError` inline
  - [x] "Don't have an account? Register" → `context.go('/auth/register')`

- [x] **Task 4: Create `HomeownerDashboardScreen`** — placeholder with `Key('homeowner_dashboard')`

- [x] **Task 5: Create `VendorDashboardScreen`** — placeholder with `Key('vendor_dashboard')`

- [x] **Task 6: Update `app_router.dart`**
  - [x] `initialLocation` changed to `/auth/login`
  - [x] Async `redirect` callback: unauthenticated → `/auth/login`; authenticated on auth route → fetch profile → `/homeowner` or `/vendor`
  - [x] `/auth/login` wired to `LoginScreen()`
  - [x] `/homeowner` wired to `HomeownerDashboardScreen()`
  - [x] `/vendor` wired to `VendorDashboardScreen()`

- [x] **Task 7: Expose `buildApp()` in `main.dart`** — for INT-003 re-pump

- [x] **Task 8: Turn integration tests GREEN** — uncomment real assertions, remove `skip:` from 0.3-INT-001, 0.3-INT-002, 0.3-INT-003

- [x] **Task 9: Add unit tests** — 0.3-UNIT-001 (incorrect credentials → `AsyncError`) + success path

## Dev Notes

### signIn error handling — Supabase 2.x

```dart
// Invalid credentials throw AuthException with statusCode '400'
// and message "Invalid login credentials"
} on AuthException catch (e) {
  final isInvalid = e.statusCode == '400' ||
      e.message.toLowerCase().contains('invalid');
  throw AppException(
    code: isInvalid ? 'invalid-credentials' : (e.statusCode ?? 'auth-error'),
    message: isInvalid ? 'Incorrect email or password.' : e.message,
  );
}
```

### Role-based navigation pattern (screen, not notifier)

```dart
ref.listen<AsyncValue<void>>(authNotifierProvider, (previous, next) {
  if (next.hasValue && previous?.isLoading == true) {
    _navigateToRoleDashboard(); // async — fetches profile then context.go()
  }
});
```

### go_router async redirect (go_router 14.x)

```dart
redirect: (context, state) async {
  final session = Supabase.instance.client.auth.currentSession;
  if (session == null) return isOnAuth ? null : '/auth/login';
  if (isOnAuth) {
    // fetch profile from profiles table → route to /homeowner or /vendor
  }
  return null;
},
```

### Architecture Compliance

Same rules as Story 0.2 — Supabase calls only in `auth_repository.dart`, navigation only in screens.

## Dev Agent Record

### Agent Model Used

claude-sonnet-4-6

### Completion Notes

- All 9 tasks implemented.
- `_FakeAuthRepository` in test file extended with `signInError` parameter.
- 0.3-UNIT-001 and a success path unit test added (15 total unit tests).
- Integration tests (0.3-INT-001, -002, -003) moved from RED (skip) to GREEN.
- `buildApp()` exposed from `main.dart` for INT-003 widget re-pump.
- Async `redirect` in go_router handles both session persistence and unauthenticated guards.

### File List

spr_house_maintenance_tracker/lib/features/auth/data/auth_repository.dart
spr_house_maintenance_tracker/lib/features/auth/presentation/auth_notifier.dart
spr_house_maintenance_tracker/lib/features/auth/presentation/screens/login_screen.dart
spr_house_maintenance_tracker/lib/features/homeowner/presentation/homeowner_dashboard_screen.dart
spr_house_maintenance_tracker/lib/features/vendor/presentation/vendor_dashboard_screen.dart
spr_house_maintenance_tracker/lib/core/router/app_router.dart
spr_house_maintenance_tracker/lib/main.dart
spr_house_maintenance_tracker/integration_test/auth_test.dart
spr_house_maintenance_tracker/test/features/auth/presentation/auth_notifier_test.dart
_bmad-output/implementation-artifacts/sprint-status.yaml

## Change Log

- 2026-03-04: Implemented Story 0.3 — login screen, role-based navigation, session persistence redirect, integration tests GREEN (claude-sonnet-4-6)
