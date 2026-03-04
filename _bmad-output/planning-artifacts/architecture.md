---
stepsCompleted: [1, 2, 3, 4, 5, 6, 7, 8]
lastStep: 8
status: 'complete'
completedAt: '2026-03-04'
inputDocuments:
  - docs/PRD/index.md
  - docs/PRD/1-problem-statement.md
  - docs/PRD/2-target-users.md
  - docs/PRD/3-market-context.md
  - docs/PRD/4-tech-stack.md
  - docs/PRD/5-core-value-proposition.md
  - docs/PRD/6-revenue-model.md
  - docs/PRD/7-design-principles.md
  - docs/PRD/8-mvp-scope-hackathon.md
  - docs/PRD/9-core-demo-loop.md
  - docs/PRD/10-out-of-scope-hackathon-mvp.md
  - docs/PRD/11-success-metrics-post-hackathon.md
  - docs/PRD/12-epics-user-stories-acceptance-criteria.md
  - docs/PRD/13-open-questions.md
  - _bmad-output/brainstorming/brainstorming-session-2026-03-03-0001.md
workflowType: 'architecture'
project_name: 'spr-house-maintenance-tracker'
user_name: 'HackathonTeam2'
date: '2026-03-04'
---

# Architecture Decision Document

_This document builds collaboratively through step-by-step discovery. Sections are appended as we work through each architectural decision together._

## Project Context Analysis

### Requirements Overview

**Functional Requirements:**
7 epics, 18 user stories split across two user roles. Core flows: property setup
and maintenance scheduling (homeowner), vendor onboarding and profile management
(vendor), and the shared booking lifecycle connecting both sides. The booking
state machine (Requested → Confirmed → In Progress → Completed) with auto-cancel
and no-show suspension is the most complex functional component.

**Non-Functional Requirements:**
- Push notifications must fire within 30 seconds of trigger events (V2 AC)
- Vendor onboarding must complete in under 2 minutes (V1 AC)
- Vendor suspension must be immediate and cascade to booking visibility (H9 AC)
- Mobile-first: iOS + Android via Flutter
- Image uploads required for 3 contexts: profile photos, maintenance log photos, QRPH QR code images

**Scale & Complexity:**
- Primary domain: Mobile-first full-stack (Flutter + Supabase BaaS)
- Complexity level: Medium
- Estimated architectural components: 6 (Auth, User Profiles, Property/Maintenance, Booking, Notifications, File Storage)

### Technical Stack (Resolved)

- **Mobile client:** Flutter (iOS + Android) via `supabase_flutter` SDK
- **Backend / API:** Supabase (PostgREST auto-generated REST + Realtime)
- **Auth:** Supabase Auth — email + password, JWT-based
- **Database:** PostgreSQL (managed by Supabase)
- **Storage:** Supabase Storage buckets (profile photos, maintenance log photos, QRPH codes)
- **Real-time:** Supabase Realtime (Postgres row-change subscriptions over WebSocket — used for booking status updates)
- **Custom logic:** Supabase Edge Functions (Deno/TypeScript) — FCM dispatch, auto-cancel, vendor suspension enforcement
- **Scheduled jobs:** pg_cron or scheduled Edge Functions — maintenance reminders (H3), 24-hour booking auto-cancel (H8/V3)
- **Push notifications:** Firebase Cloud Messaging via Edge Functions
- **Role-based access:** PostgreSQL Row Level Security (RLS) policies

### Technical Constraints & Dependencies

- GCash deep link scheme (`gcash://`) must be validated on both platforms before demo
- No payment processing integration in scope
- No geographic/location services in scope
- Edge Functions runtime is Deno (TypeScript) — not Node.js

### Cross-Cutting Concerns Identified

1. **RLS Policies** — homeowner vs vendor row-level security gates all data access at the database layer
2. **FCM Push Notification Routing** — Edge Function triggered by DB webhooks; covers at least 6 event types across both user roles
3. **Supabase Storage** — 3 upload contexts with bucket-level access policies
4. **Scheduled Jobs** — pg_cron or scheduled Edge Functions for reminders and auto-cancel
5. **Booking State Machine + Suspension** — 4-state lifecycle plus vendor suspension managed via DB constraints and Edge Functions

## Starter Template Evaluation

### Primary Technology Domain

Flutter mobile app (iOS + Android) with Supabase BaaS — no custom backend server.

### Starter Options Considered

- **Very Good CLI + Supabase:** Production-grade, BLoC, test-focused — too heavyweight for hackathon timeline
- **ApparenceKit:** Includes FCM + Riverpod — commercial license; non-transparent setup risky under hackathon pressure
- **Sandro Maglione's template:** Modular, functional patterns — complex DI configuration (`get_it`/`injectable`) adds friction
- **`flutter create` (plain):** Selected — full control, no hidden constraints, nothing to fight

### Selected Starter: `flutter create` with feature-first architecture

**Rationale:** Hackathon speed and intermediate team skill level favour a plain Flutter project
with deliberate structure over a third-party template. 7 well-scoped epics map cleanly to
feature folders. Avoids debugging framework opinions under time pressure.

**Initialization Command:**

```bash
flutter create spr_house_maintenance_tracker --org com.spr --platforms ios,android
```

**Key Packages:**

```yaml
dependencies:
  supabase_flutter: ^2.12.0    # Backend, auth, storage, realtime
  firebase_messaging: ^16.1.2  # FCM push notifications
  flutter_riverpod: ^2.x       # State management
  go_router: ^14.x             # Declarative navigation with route guards
  image_picker: ^1.x           # Photo uploads (logs, profiles, QRPH)
```

**Architectural Decisions Established:**

**Language & Runtime:** Dart (Flutter SDK latest stable)

**Project Structure:** Feature-first — `lib/features/{auth,property,maintenance,booking,vendor,notifications,payment}/` — maps directly to the 7 PRD epics

**State Management:** Riverpod — provider-per-feature, async state via `AsyncNotifier`; less boilerplate than BLoC, more structure than `setState`, excellent Supabase integration

**Navigation:** `go_router` with role-based guards separating homeowner and vendor route trees

**Data Layer:** Repository pattern — each feature exposes a `*_repository.dart` that wraps Supabase SDK calls; UI never touches Supabase directly

**Build Tooling:** Flutter CLI (`flutter build ios` / `flutter build apk`)

**Development Experience:** Flutter DevTools, hot reload, Supabase local development via Supabase CLI

**Note:** Project initialization using this command should be the first implementation story.

## Core Architectural Decisions

### Decision Priority Analysis

**Critical Decisions (Block Implementation):**
- User role modeling: profiles + vendor_extensions pattern
- Edge Functions scope: 4 functions defined
- Environment configuration: --dart-define pattern

**Important Decisions (Shape Architecture):**
- UI framework: Material Design 3
- Offline strategy: none for MVP

**Deferred Decisions (Post-MVP):**
- Offline/local caching (Supabase local cache layer)
- Custom design system beyond Material 3
- CI/CD pipeline

### Data Architecture

**User Role Modeling:** Option C — `profiles` + `vendor_extensions`

- `profiles (id, user_type: homeowner|vendor, name, phone, avatar_url)` — one row per user regardless of role; RLS uses `user_type` for routing
- `vendor_extensions (id → profiles.id, services[], price_range_min, price_range_max, gcash_number, qrph_url, is_available, completed_jobs_count)` — exists only for vendor users; RLS restricts reads/writes to owner

Rationale: shared identity in one place, vendor-specific business data separate. Avoids nullable columns on homeowner rows.

**Migration approach:** Supabase CLI migrations (`supabase migration new`) tracked in source control under `supabase/migrations/`.

**Caching strategy:** None beyond Riverpod's in-memory AsyncNotifier state. No separate cache layer for MVP.

### Authentication & Security

**Auth:** Supabase Auth — email + password, JWT. Role embedded in `profiles.user_type`, readable via RLS context (`auth.uid()`).

**RLS Policy Strategy:**
- All tables enable RLS
- `profiles`: users read/write their own row only
- `vendor_extensions`: vendors read/write their own row; homeowners read all rows for vendor browse (H6)
- `properties` + `maintenance_tasks`: homeowner-owner only
- `bookings`: homeowner reads own bookings; vendor reads bookings where `vendor_id = auth.uid()`
- Vendor suspension: `is_suspended` flag on `vendor_extensions`; RLS excludes suspended vendors from homeowner-facing reads

**Storage bucket policies:**
- `avatars/` — authenticated read (public profiles), owner write
- `maintenance-logs/` — owner read/write only
- `qrph-codes/` — owner write; homeowner read when booking is confirmed

### API & Communication Patterns

**Primary data access:** Supabase PostgREST via `supabase_flutter` SDK — all standard CRUD operations

**Real-time:** Supabase Realtime channel subscriptions on `bookings` table — Flutter client subscribes to own booking rows; status changes push automatically (resolves H8 without polling)

**Edge Functions (4 total):**

| Function | Trigger | Purpose |
|---|---|---|
| `dispatch-notification` | DB webhook on booking/reminder events | FCM push to target user |
| `auto-cancel-booking` | pg_cron every 15 min | Cancel bookings pending >24hr |
| `suspend-vendor` | DB webhook on no-show report insert | Set is_suspended=true, cascade |
| `schedule-reminders` | pg_cron daily | Push FCM for due/overdue tasks |

**Error handling:** Repository layer catches Supabase exceptions and maps to typed app errors; Riverpod AsyncNotifier surfaces to UI as error states.

### Frontend Architecture

**State management:** Riverpod — one `AsyncNotifier` per feature domain; no global app state object

**Navigation:** `go_router` with two route trees gated by `user_type`:
- `/homeowner/...` — property, maintenance, booking, vendor browse screens
- `/vendor/...` — dashboard, bookings, profile, earnings screens
- `/auth/...` — login, register, role selection

**UI framework:** Flutter Material Design 3 (`useMaterial3: true` in ThemeData). No custom design system for MVP.

**Offline strategy:** None. All operations require connectivity. AsyncNotifier error states handle connectivity failures gracefully.

**Image handling:** `image_picker` for capture/selection; upload directly to Supabase Storage via `supabase_flutter` storage API; store public URL in DB row after upload.

### Infrastructure & Deployment

**Supabase project:** Free tier sufficient for hackathon demo.

**Environment configuration:**
```bash
flutter run \
  --dart-define=SUPABASE_URL=https://xxx.supabase.co \
  --dart-define=SUPABASE_ANON_KEY=xxx \
  --dart-define=FCM_SENDER_ID=xxx
```
Accessed via `const String.fromEnvironment(...)`. Secrets stored in local `.env` file (already in `.gitignore`), never committed.

**Supabase local dev:** `supabase start` for local Postgres + Edge Functions during development. Migrations via `supabase db push`.

**Monitoring:** Supabase dashboard (logs, DB inspector) sufficient for hackathon. No external monitoring for MVP.

**Demo distribution:** Direct APK sideload (Android) + TestFlight or direct device run (iOS) for hackathon presentation.

### Decision Impact Analysis

**Implementation Sequence:**
1. Supabase project setup + schema migrations (profiles, vendor_extensions, properties, maintenance_tasks, bookings)
2. Flutter project init + package setup + environment config
3. Auth screens (login, register, role selection) + go_router guards
4. RLS policies on all tables
5. Feature implementation following epic order (H1→H9, V1→V9)
6. Edge Functions (dispatch-notification first; others after core flows work)

**Cross-Component Dependencies:**
- `profiles.user_type` drives every RLS policy and both route trees — must be correct before any other feature works
- `dispatch-notification` Edge Function is shared by all push events — implement once, reuse across all 6 notification triggers
- Supabase Realtime subscription on `bookings` is the foundation for H8 and V2/V3 — set up early

## Implementation Patterns & Consistency Rules

### Pattern Categories Defined

**Critical Conflict Points Identified:** 7 areas where AI agents could make different choices without explicit rules.

### Naming Patterns

**Database Naming Conventions (always `snake_case`):**
- Tables: `profiles`, `vendor_extensions`, `maintenance_tasks`, `bookings`
- Columns: `user_type`, `created_at`, `vendor_id`, `is_available`
- Foreign keys: `{table_singular}_id` format — `vendor_id`, `homeowner_id`, `booking_id`
- Boolean columns: `is_*` prefix — `is_available`, `is_suspended`, `is_completed`

**Dart Code Naming Conventions:**
- Classes/widgets: `PascalCase` — `BookingRepository`, `HomeScreen`, `VendorCard`
- Files: `snake_case.dart` — `booking_repository.dart`, `home_screen.dart`
- Variables/methods: `camelCase` — `userId`, `fetchBookings()`, `isAvailable`
- Constants: `camelCase` (Dart style, not `SCREAMING_SNAKE_CASE`)

**Feature Naming — consistent across all layers:**
- Canonical names: `auth`, `property`, `maintenance`, `booking`, `vendor`, `notifications`, `payment`
- Same name used for: folder path, route prefix, and provider prefix

### Structure Patterns

**Every feature follows this exact layout — no deviation:**
```
lib/features/{feature}/
  data/
    {feature}_repository.dart     ← ONLY file that imports supabase_flutter
  domain/
    {feature}_model.dart          ← immutable data class
  presentation/
    {feature}_notifier.dart       ← AsyncNotifier (Riverpod)
    {feature}_provider.dart       ← provider declarations
    screens/
      {screen_name}_screen.dart
    widgets/
      {widget_name}_widget.dart
```

**Tests mirror `lib/` under `test/`:**
```
test/features/{feature}/
  data/{feature}_repository_test.dart
  presentation/{feature}_notifier_test.dart
```

**Shared code location:**
- `lib/core/exceptions/app_exception.dart` — typed exception classes
- `lib/core/router/app_router.dart` — all go_router route definitions
- `lib/core/theme/app_theme.dart` — ThemeData configuration
- `lib/core/constants/` — app-wide constants

### Format Patterns

**Supabase JSON → Dart Models:**
- Supabase returns `snake_case` JSON; `fromJson()`/`toJson()` maps to `camelCase` Dart fields
- All model fields `final`; constructors `const` where possible
- Dates: ISO 8601 strings in Postgres, parsed to `DateTime` in Dart models

**API Response Handling — no manual wrapper:**
- Supabase PostgREST returns direct data or throws `PostgrestException`
- Repository catches `PostgrestException`, rethrows as typed `AppException`
- Do NOT create manual `{data: ..., error: ...}` wrappers — use Riverpod `AsyncValue`

### State Management Patterns

**Always `AsyncNotifier` — never `StateNotifier` for async state:**
```dart
// ✅ Correct
class BookingNotifier extends AsyncNotifier<List<Booking>> {
  @override
  Future<List<Booking>> build() => ref.read(bookingRepositoryProvider).fetchAll();
}

// ❌ Wrong
class BookingNotifier extends StateNotifier<AsyncValue<List<Booking>>> { ... }
```

**Provider naming — always `{feature}NotifierProvider`:**
```dart
final bookingNotifierProvider =
    AsyncNotifierProvider<BookingNotifier, List<Booking>>(BookingNotifier.new);
```

**UI consumption — always `.when()`:**
```dart
ref.watch(bookingNotifierProvider).when(
  data: (bookings) => BookingList(bookings),
  loading: () => const CircularProgressIndicator.adaptive(),
  error: (e, _) => ErrorWidget(e.toString()),
);
```

### Communication Patterns

**Navigation — `go_router` exclusively:**
- `context.go('/path')` — replace stack (post-login, post-action)
- `context.push('/path')` — add to stack (detail screens)
- `Navigator.push()` is forbidden — always use `go_router`

**Supabase Realtime — subscribe in notifier `build()`:**
```dart
@override
Future<List<Booking>> build() async {
  supabase.from('bookings')
    .stream(primaryKey: ['id'])
    .listen((data) => state = AsyncData(data.map(Booking.fromJson).toList()));
  return fetchInitial();
}
```

### Process Patterns

**Error Handling — typed exceptions only:**
```dart
// ✅ In repository
try {
  return await supabase.from('bookings').select();
} on PostgrestException catch (e) {
  throw AppException(code: e.code, message: e.message);
}

// ❌ Never
throw Exception('Something went wrong');
```

**Loading States — local, never global:**
- Each feature manages its own loading via `AsyncNotifier`
- No global loading overlay or global `isLoading` flag
- Use `CircularProgressIndicator.adaptive()` (respects iOS/Android platform)

**Image Upload — always storage-first, then DB:**
```dart
// 1. Upload to Supabase Storage → get public URL
// 2. Save public URL string to DB column
// Never store binary data in Postgres
```

### Enforcement Guidelines

**All AI Agents MUST:**
1. Place ALL `supabase.from(...)` calls exclusively in `*_repository.dart` files
2. Use `AsyncNotifier` for all async Riverpod state — never `StateNotifier`
3. Name providers exactly `{feature}NotifierProvider`
4. Use `snake_case` for all DB identifiers; `camelCase`/`PascalCase` for Dart
5. Use `context.go()` / `context.push()` exclusively — never `Navigator.push()`
6. Catch `PostgrestException` in repositories and rethrow as `AppException`
7. Follow the feature folder structure exactly — no additional nesting

**Anti-Patterns (never do these):**
- Calling `supabase.from(...)` inside a widget or notifier
- Using `Navigator.push()` instead of `go_router`
- Storing binary image data in Postgres instead of Storage URLs
- Using `StateNotifier` for async operations
- Creating global loading state or a global app state object

## Project Structure & Boundaries

### Complete Project Directory Structure

```
spr_house_maintenance_tracker/         ← Flutter app root
├── pubspec.yaml
├── analysis_options.yaml
├── .gitignore
├── android/
├── ios/
├── lib/
│   ├── main.dart                      ← Supabase.initialize() + FCM setup
│   ├── core/
│   │   ├── constants/
│   │   │   └── app_constants.dart     ← service types, recurrence intervals
│   │   ├── exceptions/
│   │   │   └── app_exception.dart     ← typed AppException class
│   │   ├── router/
│   │   │   └── app_router.dart        ← all go_router routes + role guards
│   │   └── theme/
│   │       └── app_theme.dart         ← Material 3 ThemeData
│   └── features/
│       ├── auth/                      ← Login, register, role selection
│       │   ├── data/auth_repository.dart
│       │   ├── domain/user_model.dart
│       │   └── presentation/
│       │       ├── auth_notifier.dart
│       │       ├── auth_provider.dart
│       │       └── screens/
│       │           ├── login_screen.dart
│       │           ├── register_screen.dart
│       │           └── role_selection_screen.dart
│       ├── property/                  ← H1: property setup
│       │   ├── data/property_repository.dart
│       │   ├── domain/property_model.dart
│       │   └── presentation/
│       │       ├── property_notifier.dart
│       │       ├── property_provider.dart
│       │       └── screens/
│       │           ├── property_setup_screen.dart
│       │           └── property_detail_screen.dart
│       ├── maintenance/               ← H2, H3, H4, H5
│       │   ├── data/maintenance_repository.dart
│       │   ├── domain/
│       │   │   ├── maintenance_task_model.dart
│       │   │   └── maintenance_log_model.dart
│       │   └── presentation/
│       │       ├── maintenance_notifier.dart
│       │       ├── maintenance_provider.dart
│       │       ├── screens/
│       │       │   ├── maintenance_dashboard_screen.dart
│       │       │   ├── task_detail_screen.dart
│       │       │   └── log_completion_screen.dart
│       │       └── widgets/
│       │           ├── health_score_widget.dart
│       │           └── task_card_widget.dart
│       ├── booking/                   ← H6, H7, H8, H9, V2, V3, V9
│       │   ├── data/booking_repository.dart
│       │   ├── domain/booking_model.dart
│       │   └── presentation/
│       │       ├── booking_notifier.dart  ← Realtime subscription lives here
│       │       ├── booking_provider.dart
│       │       ├── screens/
│       │       │   ├── vendor_browse_screen.dart
│       │       │   ├── vendor_profile_screen.dart
│       │       │   ├── booking_request_screen.dart
│       │       │   ├── booking_status_screen.dart
│       │       │   └── payment_screen.dart
│       │       └── widgets/
│       │           ├── booking_status_stepper_widget.dart
│       │           ├── vendor_card_widget.dart
│       │           └── no_show_report_widget.dart
│       ├── vendor/                    ← V1, V4, V5, V6, V7, V8
│       │   ├── data/vendor_repository.dart
│       │   ├── domain/vendor_profile_model.dart
│       │   └── presentation/
│       │       ├── vendor_notifier.dart
│       │       ├── vendor_provider.dart
│       │       ├── screens/
│       │       │   ├── vendor_onboarding_screen.dart
│       │       │   ├── vendor_dashboard_screen.dart
│       │       │   ├── vendor_bookings_screen.dart
│       │       │   └── earnings_screen.dart
│       │       └── widgets/
│       │           ├── availability_toggle_widget.dart
│       │           └── earnings_summary_widget.dart
│       ├── notifications/             ← FCM token registration + foreground handling
│       │   ├── data/notification_repository.dart
│       │   ├── domain/fcm_token_model.dart
│       │   └── presentation/
│       │       ├── notification_notifier.dart
│       │       └── notification_provider.dart
│       └── payment/                   ← V7, V9 payment screen
│           ├── data/payment_repository.dart
│           ├── domain/payment_model.dart
│           └── presentation/
│               ├── payment_notifier.dart
│               ├── payment_provider.dart
│               └── screens/
│                   └── payment_confirmation_screen.dart
├── test/
│   ├── features/
│   │   ├── auth/
│   │   ├── property/
│   │   ├── maintenance/
│   │   ├── booking/
│   │   ├── vendor/
│   │   └── notifications/
│   └── helpers/
│       └── test_helpers.dart          ← mock Supabase client setup

supabase/                              ← Supabase backend root
├── config.toml
├── migrations/
│   ├── 001_create_profiles.sql
│   ├── 002_create_vendor_extensions.sql
│   ├── 003_create_properties.sql
│   ├── 004_create_maintenance_tasks.sql
│   ├── 005_create_maintenance_logs.sql
│   ├── 006_create_bookings.sql
│   ├── 007_create_no_show_reports.sql
│   ├── 008_rls_policies.sql
│   └── 009_pg_cron_jobs.sql
└── functions/
    ├── dispatch-notification/
    │   └── index.ts                   ← FCM dispatch for all 6 event types
    ├── auto-cancel-booking/
    │   └── index.ts                   ← pg_cron every 15 min
    ├── suspend-vendor/
    │   └── index.ts                   ← triggered by no_show_reports insert
    └── schedule-reminders/
        └── index.ts                   ← pg_cron daily for H3
```

### Architectural Boundaries

**Flutter → Supabase PostgREST:**
All CRUD via `supabase_flutter` SDK in `*_repository.dart` files only. No direct SDK calls in notifiers or widgets.

**Flutter → Supabase Realtime:**
Booking status subscription lives in `booking_notifier.dart` `build()` method. Streams `bookings` table rows matching `auth.uid()`.

**Flutter → Supabase Storage:**
Image upload/download via `*_repository.dart` only. URLs stored as strings in DB after upload completes.

**DB → Edge Functions (server-side only):**
- `bookings` insert/update → webhook → `dispatch-notification`
- `no_show_reports` insert → webhook → `suspend-vendor`
- pg_cron schedule → `auto-cancel-booking` (every 15 min)
- pg_cron schedule → `schedule-reminders` (daily)

### Data Flow

```
User action (widget)
  → notifier method call
    → repository method call
      → supabase SDK call
        → PostgreSQL / Storage / Edge Function
      ← response / PostgrestException
    ← typed model / AppException
  ← AsyncValue state update
← widget rebuild via ref.watch()
```

### Requirements to Structure Mapping

**Epic → Directory:**
- Epic 1 (H1, H2, H3): `features/property/` + `features/maintenance/`
- Epic 2 (H4, H5): `features/maintenance/`
- Epic 3 (H6, H7, H8, H9): `features/booking/`
- Epic 4 (V1, V8): `features/vendor/` + `features/auth/`
- Epic 5 (V2, V3, V5): `features/booking/` + `features/vendor/`
- Epic 6 (V4, V6, V7): `features/vendor/`
- Epic 7 (V9): `features/booking/` + `features/payment/`

**Cross-Cutting Concerns:**
- Auth + role guard: `core/router/app_router.dart`
- FCM token registration: `features/notifications/` — called once after login
- Typed exceptions: `core/exceptions/app_exception.dart` — used by all repositories

### Integration Points

**External Services:**
- Supabase (PostgREST + Realtime + Storage + Auth): via `supabase_flutter`
- Firebase Cloud Messaging: via `firebase_messaging` + `google-services.json` (Android) / `GoogleService-Info.plist` (iOS)
- GCash deep link: `payment_screen.dart` — `url_launcher` package, `gcash://` scheme validated before demo

## Architecture Validation Results

### Coherence Validation ✅

All technology decisions are mutually compatible. `supabase_flutter` 2.12.0 + `firebase_messaging` 16.1.2 have no known conflicts. Riverpod `AsyncNotifier` integrates cleanly with Supabase Realtime streams. `go_router` redirect logic supports `user_type`-based role routing natively. Patterns align with stack choices. Project structure supports all architectural boundaries.

### Requirements Coverage Validation ✅

All 18 user stories (H1–H9, V1–V9) have explicit architectural support. All 3 NFRs (push latency ≤30s, onboarding <2min, immediate suspension) are addressed by specific architectural components.

| Story | Covered By |
|---|---|
| H1 Property Setup | `features/property/` + `profiles` table |
| H2 Templates | `features/maintenance/` + `maintenance_tasks` |
| H3 Recurring + Reminders | `features/maintenance/` + `schedule-reminders` pg_cron |
| H4 Log + Photo | `features/maintenance/` + `maintenance-logs/` Storage bucket |
| H5 Health Score | `health_score_widget.dart` + computed in notifier |
| H6 Vendor Browse | `vendor_browse_screen.dart` + PostgREST on `vendor_extensions` |
| H7 One-Tap Booking | `booking_request_screen.dart` + `bookings` insert |
| H8 Status Tracker | Realtime subscription + `auto-cancel-booking` pg_cron |
| H9 No-Show | `no_show_report_widget.dart` + `suspend-vendor` Edge Function |
| V1 Fast Onboarding | `vendor_onboarding_screen.dart` + `vendor_extensions` insert |
| V2 Instant Notification | `dispatch-notification` on `bookings` insert webhook |
| V3 Accept/Decline | `features/booking/` + `bookings` status update |
| V4 Price Range | `vendor_extensions.price_range_min/max` |
| V5 Availability Toggle | `availability_toggle_widget.dart` + `is_available` flag |
| V6 Earnings Dashboard | `earnings_screen.dart` + aggregated from `bookings` |
| V7 QRPH + GCash | `qrph-codes/` bucket + `url_launcher` deep link |
| V8 Vendor Profile | `vendor_extensions` + PostgREST read |
| V9 Final Price | `payment_screen.dart` + `bookings` final price update |

### Gap Analysis & Resolutions

**Gap 1 (Important): FCM token storage — RESOLVED**
Added migration `010_create_fcm_tokens.sql`:
`fcm_tokens (id, user_id → profiles.id, token, platform, updated_at)`
`notification_repository.dart` upserts token on app launch after login.
`dispatch-notification` Edge Function queries this table to find target device.

**Gap 2 (Minor): Missing `url_launcher` package — RESOLVED**
Added to pubspec.yaml: `url_launcher: ^6.x` — used in `payment_screen.dart` for GCash `gcash://` deep link (V7). Validate scheme on both platforms before demo.

**Gap 3 (Minor): Booking cancellation state — NOTED**
`bookings.status` valid values: `requested | confirmed | in_progress | completed | cancelled`.
Homeowner may cancel when status = `requested` only (H8 AC). No additional table required — handled by status update in `booking_repository.dart`.

### Architecture Completeness Checklist

**✅ Requirements Analysis**
- [x] Project context thoroughly analyzed
- [x] Scale and complexity assessed (Medium)
- [x] Technical constraints identified
- [x] Cross-cutting concerns mapped (5 identified)

**✅ Architectural Decisions**
- [x] Full stack specified with verified package versions
- [x] Data model approach defined (profiles + vendor_extensions)
- [x] All 4 Edge Functions scoped and triggered
- [x] RLS policy strategy defined per table
- [x] Storage bucket policies defined

**✅ Implementation Patterns**
- [x] Naming conventions: DB snake_case, Dart camelCase/PascalCase
- [x] Feature folder structure: data/domain/presentation
- [x] State management: AsyncNotifier only
- [x] Navigation: go_router exclusively
- [x] Error handling: typed AppException
- [x] 7 enforcement rules + anti-patterns documented

**✅ Project Structure**
- [x] Complete Flutter directory tree with all files named
- [x] Complete Supabase directory tree (10 migrations + FCM tokens, 4 Edge Functions)
- [x] All 18 stories mapped to specific files/directories
- [x] Data flow documented end-to-end

### Architecture Readiness Assessment

**Overall Status: READY FOR IMPLEMENTATION**

**Confidence Level: High**

**Key Strengths:**
- Supabase resolves all TBD items (backend, storage, auth, real-time) in one platform
- Repository pattern enforces clean separation — AI agents cannot accidentally couple UI to data layer
- 7 enforcement rules prevent the most common agent consistency failures
- All 18 stories explicitly mapped to implementation locations

**Areas for Future Enhancement (Post-Hackathon):**
- Offline support via Supabase local cache
- Geographic vendor filtering
- Ratings and reviews system
- Vendor appeal process for suspensions
- CI/CD pipeline

### Implementation Handoff

**AI Agent Guidelines:**
- Follow all architectural decisions exactly as documented
- Use implementation patterns consistently across all features
- Respect project structure — no deviation from defined folder layout
- Refer to this document for all architectural questions

**First Implementation Story:**
```bash
flutter create spr_house_maintenance_tracker --org com.spr --platforms ios,android
```
Then: Supabase project creation + run migrations 001–010 in sequence.
