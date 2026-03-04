---
stepsCompleted: ['step-01-preflight-and-context', 'step-02-generation-mode', 'step-03-test-strategy', 'step-04-generate-tests', 'step-04c-aggregate', 'step-05-validate-and-complete']
lastStep: 'step-05-validate-and-complete'
lastSaved: '2026-03-04'
workflowType: 'testarch-atdd'
story_id: '0.2'
inputDocuments:
  - _bmad-output/planning-artifacts/epics.md
  - _bmad-output/planning-artifacts/architecture.md
  - _bmad-output/test-artifacts/test-design-epic-all.md
---

# ATDD Checklist — Epic 0, Story 0.2: User Registration & Role Selection

**Date:** 2026-03-04  |  **Author:** HackathonTeam2  |  **Level:** Unit + Integration

---

## Story Summary

As a new user, I want to register with email + password and choose homeowner or vendor role,
so I can access role-appropriate features. Registration creates a Supabase Auth account; role
selection creates a `profiles` row with `user_type`.

---

## Acceptance Criteria

1. **AC1** — Unauthenticated user cannot access homeowner/vendor screens
2. **AC2** — Valid registration → Supabase account created → role selection screen
3. **AC3** — "I am a Homeowner" → `profiles.user_type = 'homeowner'` → `/homeowner/dashboard`
4. **AC4** — "I am a Vendor" → `profiles.user_type = 'vendor'` → `/vendor/onboarding`
5. **AC5** — Duplicate email → inline error "An account with this email already exists."
6. **AC6** — Invalid email format or password < 6 chars → inline field validation errors

---

## Failing Tests Created (RED Phase)

### Unit Tests — 3 tests
**File:** `test/features/auth/presentation/registration_notifier_test.dart`
- ✅ `[P0] 0.2-UNIT-001` — Successful register emits AsyncData | RED — RegistrationNotifier not implemented
- ✅ `[P1] 0.2-UNIT-002` — Duplicate email emits AsyncError with expected message | RED
- ✅ `[P1] 0.2-UNIT-003` — Client validation prevents repo call for invalid inputs | RED

### Integration Tests — 3 tests
**File:** `integration_test/registration_test.dart`
- ✅ `[P0] 0.2-INT-001` — Register → select homeowner → `/homeowner/dashboard` | RED
- ✅ `[P0] 0.2-INT-002` — Register → select vendor → `/vendor/onboarding` | RED
- ✅ `[P0] 0.2-INT-003` — Duplicate email shows inline error | RED

---

## Required Widget Keys
| Key | Widget | Screen |
|---|---|---|
| `Key('email_field')` | TextField | RegisterScreen |
| `Key('password_field')` | TextField | RegisterScreen |
| `Key('register_button')` | FilledButton | RegisterScreen |
| `Key('register_error_text')` | Text | RegisterScreen |
| `Key('role_homeowner_button')` | FilledButton | RoleSelectionScreen |
| `Key('role_vendor_button')` | OutlinedButton | RoleSelectionScreen |
| `Key('homeowner_dashboard')` | Scaffold | HomeownerDashboardScreen |
| `Key('vendor_onboarding')` | Scaffold | VendorOnboardingScreen |

---

## Mock Requirements
- `MockAuthRepository extends Mock implements AuthRepository`
- `AuthRepository.register({email, password})` → `Future<void>`; throws `AppException` on duplicate
- Stub classes in `registration_notifier_test.dart` — delete once production code exists

## Supabase Seed Data
- `existing@test.spr.ph` — pre-existing account for duplicate-email test (0.2-INT-003)

---

## Implementation Checklist

### 0.2-UNIT-001 / 002 / 003
- [ ] Create `lib/features/auth/data/auth_repository.dart` — add `register({email, password})` method
- [ ] Create `lib/features/auth/presentation/registration_notifier.dart` — `AsyncNotifier` calling `authRepository.register()`; catches `AuthException` → rethrows as `AppException`
- [ ] Add client-side validation in notifier: email regex + password min-length 6
- [ ] Export `registrationNotifierProvider` from `auth_providers.dart`
- [ ] Remove stubs from `registration_notifier_test.dart`; uncomment production imports; rewrite act section with `ProviderContainer`
- [ ] Remove `skip:` from all 3 unit tests → run: `flutter test test/features/auth/presentation/registration_notifier_test.dart`

### 0.2-INT-001 / 002
- [ ] Create `lib/features/auth/presentation/register_screen.dart` with Keys listed above
- [ ] Create `lib/features/auth/presentation/role_selection_screen.dart` with `Key('role_homeowner_button')`, `Key('role_vendor_button')`
- [ ] `RoleSelectionNotifier.selectRole(homeowner)` → upsert `profiles` row → `context.go('/homeowner/dashboard')`
- [ ] `RoleSelectionNotifier.selectRole(vendor)` → upsert `profiles` row → `context.go('/vendor/onboarding')`
- [ ] Add `/auth/register` and `/auth/role-selection` routes in `app_router.dart`
- [ ] Uncomment test body in `registration_test.dart`; remove `skip:` from INT-001 and INT-002

### 0.2-INT-003
- [ ] `RegistrationNotifier` must surface `AppException` message to UI via `state = AsyncError(e, st)`
- [ ] `RegisterScreen` reads error from `ref.watch(registrationNotifierProvider)` and shows `Key('register_error_text')` when `AsyncError`
- [ ] Seed `existing@test.spr.ph` in test Supabase
- [ ] Remove `skip:` from INT-003

---

## Running Tests
```bash
flutter test test/features/auth/presentation/registration_notifier_test.dart
flutter test integration_test/registration_test.dart --dart-define=SUPABASE_URL=<url> --dart-define=SUPABASE_ANON_KEY=<key> -d <device>
```

---

**Generated by BMad TEA Agent (Murat)** — 2026-03-04
