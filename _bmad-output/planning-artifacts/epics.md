---
stepsCompleted: [1, 2, 3, 4]
lastStep: 4
workflowStatus: complete
recommendedImplementationOrder: "Epic 0 → Epic 1 → Epic 2 → Epic 4 → Epic 3 → Epic 5 → Epic 6"
inputDocuments:
  - docs/PRD/index.md
  - docs/PRD/1-problem-statement.md
  - docs/PRD/4-tech-stack.md
  - docs/PRD/7-design-principles.md
  - docs/PRD/8-mvp-scope-hackathon.md
  - docs/PRD/9-core-demo-loop.md
  - docs/PRD/12-epics-user-stories-acceptance-criteria.md
  - _bmad-output/planning-artifacts/architecture.md
  - _bmad-output/planning-artifacts/ux-design-specification.md
---

# spr-house-maintenance-tracker - Epic Breakdown

## Overview

This document provides the complete epic and story breakdown for spr-house-maintenance-tracker, decomposing the requirements from the PRD, UX Design, and Architecture into implementable stories.

**Recommended Implementation Order:** Epic 0 → Epic 1 → Epic 2 → Epic 4 → Epic 3 → Epic 5 → Epic 6

> Note: Epic 4 (Vendor Onboarding) is recommended before Epic 3 (Vendor Discovery) because Story 3.1 (Vendor Browse) requires vendor data to exist in the system for meaningful end-to-end testing.

## Requirements Inventory

### Functional Requirements

FR1: System guides new homeowners through a property setup flow (property type: house/condo/lot, optional property age) before reaching the home screen
FR2: On property setup completion, the app generates a default maintenance schedule based on property type
FR3: Homeowner can edit property details at any time from settings
FR4: App displays pre-loaded Filipino maintenance task templates: aircon cleaning, pest control, plumbing check, septic tank pump-out, rooftop inspection, electrical check
FR5: Homeowner can select tasks from templates; each added task is assigned a default recurrence interval
FR6: Homeowner can customise task name, recurrence interval, and notes on any task
FR7: Maintenance tasks support recurring schedules with options: monthly, quarterly, semi-annual, annual
FR8: App sends push notification when a task is due or overdue
FR9: Overdue tasks are highlighted in red and sorted to the top of the task list
FR10: Tasks due within 7 days are highlighted in amber as "upcoming"
FR11: Tapping a push notification navigates directly to the relevant task detail screen
FR12: On task completion and logging, the next due date is automatically calculated and set
FR13: Homeowner can log a completed maintenance task with an optional photo
FR14: Maintenance history shows: task name, completion date, vendor name (if booked through app), and attached photo (if any)
FR15: A Home Health Score (0–100) is displayed prominently on the homeowner dashboard
FR16: Health Score starts at 100; decreases proportionally with number of overdue tasks out of total tasks; restores to 100 when all overdue tasks are completed
FR17: Homeowner can browse all vendors filtered by service type (no geographic filter in MVP)
FR18: Homeowner can search vendors by keyword (matches vendor service names)
FR19: Vendor cards display: name, profile photo, services offered, price range, availability status, and completed jobs count
FR20: Homeowner sends a booking request from a vendor profile: service type (pre-filled from task context) + preferred date
FR21: Vendor receives a push notification within 30 seconds of a booking request being submitted
FR22: Booking status is tracked in real-time: Requested → Confirmed → In Progress → Completed
FR23: Homeowner triggers "In Progress" status when the vendor arrives at the property
FR24: Homeowner can cancel a booking when status is "Requested"; cancellation after "Confirmed" shows a warning dialog
FR25: Booking requests not responded to within 24 hours are automatically cancelled; homeowner is notified
FR26: Homeowner can report a no-show vendor; vendor account is immediately suspended and removed from the public vendor list
FR27: After a no-show report, homeowner is shown a recovery screen with alternative vendor suggestions and "Browse All Vendors" CTA
FR28: Vendor completes onboarding in under 2 minutes; required fields: full name, service type(s), contact number, profile photo
FR29: Vendor profile is immediately active and visible to homeowners after onboarding
FR30: Vendor receives instant push notification for booking requests matching their service type(s); suppressed when availability is toggled off
FR31: Vendor accepts or declines a booking request with a single tap
FR32: On booking acceptance, homeowner's contact details are revealed to the vendor
FR33: Vendor decline prompts for a reason: unavailable on that date / outside service type / other
FR34: Vendor toggles availability on/off from the main vendor dashboard AppBar (not buried in settings)
FR35: When availability is off, vendor does not appear bookable and does not receive booking notifications
FR36: Vendor sets minimum and maximum price range per service type; displayed on their public profile
FR37: Vendor earnings dashboard shows: total completed jobs (all time), total gross earned, total net earned (gross minus 10% admin fee), and jobs this month
FR38: Vendor uploads a QRPH code image (JPG or PNG) as their payment method
FR39: ~~REMOVED~~ GCash mobile number input removed; QRPH-only payment
FR40: After job completion and final price confirmation, homeowner sees payment screen with: final amount and scannable QRPH image only
FR41: Homeowner taps "I've Paid" to confirm payment; vendor receives "Payment confirmed" push notification
FR42: Vendor inputs final job price (>0) when marking a job as complete; price range shown as reference
FR43: On final price confirmation, booking status changes to "Completed" and homeowner receives payment notification
FR44: Vendor public profile displays: name, photo, services offered, price range per service, availability status, and completed jobs count
FR45: Authentication via email + password for both homeowner and vendor roles
FR46: Role selection (homeowner vs vendor) is required after registration before accessing any feature

### NonFunctional Requirements

NFR1: Push notifications must fire within 30 seconds of all trigger events (booking request, status changes, reminders, payment confirmation)
NFR2: Vendor onboarding end-to-end must complete in under 2 minutes
NFR3: Vendor suspension after a no-show report must be immediate — vendor disappears from all public vendor lists synchronously
NFR4: App must run on both iOS and Android via Flutter (iOS + Android platforms only)
NFR5: All app operations require network connectivity; no offline support for MVP
NFR6: Image uploads required for 3 contexts: profile photos, maintenance log photos, and QRPH QR codes (JPG/PNG)
NFR7: All database tables must have Row Level Security (RLS) policies enforced at the Supabase/PostgreSQL layer
NFR8: Environment secrets (Supabase URL, anon key, FCM Sender ID) must never be committed to source control; accessed via `--dart-define`
NFR9: Booking auto-cancellation must execute within 24 hours of timeout; pg_cron runs every 15 minutes
NFR10: Maintenance reminder push scheduling runs daily via pg_cron
NFR11: All UI must achieve WCAG AA contrast compliance; status colours (red/amber/green) always paired with text label — colour is never the sole state indicator
NFR12: Minimum touch target for all interactive elements: 48×48dp
NFR13: Target device range: 360dp–430dp phone width; single-column scrollable layouts; no hardcoded pixel widths

### Additional Requirements

**From Architecture:**

- **First Story — Project Initialisation:** Run `flutter create spr_house_maintenance_tracker --org com.spr --platforms ios,android` then create Supabase project and run migrations 001–010 in sequence
- Feature-first folder structure: `lib/features/{auth, property, maintenance, booking, vendor, notifications, payment}/` — each with `data/`, `domain/`, `presentation/` subdirectories; no deviation
- Supabase CLI migrations tracked under `supabase/migrations/`; 10 migration files (001–010) covering profiles, vendor_extensions, properties, maintenance_tasks, maintenance_logs, bookings, no_show_reports, RLS policies, pg_cron jobs, FCM tokens
- ALL `supabase.from()` calls must be in `*_repository.dart` files only — never in notifiers or widgets
- State management: `AsyncNotifier` exclusively for all async Riverpod state — `StateNotifier` is forbidden
- Providers named exactly `{feature}NotifierProvider`
- Navigation: `go_router` exclusively (`context.go()` / `context.push()`) — `Navigator.push()` is forbidden
- Error handling: repositories catch `PostgrestException` and rethrow as typed `AppException` from `lib/core/exceptions/app_exception.dart`
- 4 Edge Functions: `dispatch-notification` (DB webhook), `auto-cancel-booking` (pg_cron every 15 min), `suspend-vendor` (DB webhook on no_show_reports insert), `schedule-reminders` (pg_cron daily)
- Supabase Realtime channel subscription on `bookings` table initialised in `BookingNotifier.build()` for real-time status updates (H8)
- Image upload pattern: upload to Supabase Storage bucket → receive public URL → save URL string to DB column; never store binary data in Postgres
- FCM token upserted in `notification_repository.dart` on each app launch after login
- GCash removed from scope — payment is QRPH-only; `url_launcher` package is not required
- Environment config via `--dart-define=SUPABASE_URL=... --dart-define=SUPABASE_ANON_KEY=... --dart-define=FCM_SENDER_ID=...`; stored in local `.env`, never committed

**From UX Design:**

- 7 custom Flutter widgets required: `HealthScoreWidget`, `TaskCardWidget`, `VendorCardWidget`, `BookingStatusStepperWidget`, `AvailabilityToggleWidget`, `EarningsSummaryWidget`, `NoShowReportWidget`
- `HealthScoreWidget` animates number changes via `TweenAnimationBuilder`; includes `Semantics(label: 'Home Health Score: {score} out of 100')`
- `TaskCardWidget` uses colour-coded left border (3dp): red = overdue, amber = upcoming (≤7 days), green = on track
- `VendorCardWidget` follows Airbnb-style card layout; shows availability badge; disables Book button when vendor is unavailable
- `BookingStatusStepperWidget` is a vertical 4-step stepper with real-time Supabase Realtime updates
- `AvailabilityToggleWidget` placed in vendor dashboard AppBar trailing slot — never in settings
- `EarningsSummaryWidget` leads with "NET EARNED THIS MONTH" as the earnings hero metric
- `NoShowReportWidget` recovery screen immediately shows alternative vendor suggestions after report submission
- Every screen with async data must handle all 3 states: data, loading, error (with Retry button)
- `ErrorStateWidget` shared widget in `lib/core/` — used on all error states
- Empty states: every empty screen must show icon + title + body text + CTA button
- Full-width `FilledButton` (Calm Blue `#2E6BC6`) anchored at screen bottom (16dp padding) for all primary actions
- Homeowner bottom nav: 4 tabs (Home, Tasks, Vendors, Bookings); Vendor bottom nav: 3 tabs (Dashboard, Bookings, Profile)
- Push notification deep-link: `context.go('/specific/route')` — bypasses tab navigation entirely
- Service type filter: `FilterChip` horizontal row with "All" chip that deselects all others
- Form validation on submit only — never on each keystroke
- `Semantics` labels required on all 7 custom widgets as specified in UX design spec

### FR Coverage Map

FR1: Epic 1 — Property setup flow (type, age)
FR2: Epic 1 — Auto-generate maintenance schedule from property type
FR3: Epic 1 — Edit property details from settings
FR4: Epic 1 — Pre-loaded Filipino maintenance task templates
FR5: Epic 1 — Select tasks from templates; assign default recurrence
FR6: Epic 1 — Customise task name, recurrence, notes
FR7: Epic 1 — Recurring schedule options (monthly/quarterly/semi-annual/annual)
FR8: Epic 2 — Push notification when task is due or overdue
FR9: Epic 2 — Overdue tasks highlighted red, sorted to top
FR10: Epic 2 — Upcoming tasks (≤7 days) highlighted amber
FR11: Epic 2 — Push notification tap → task detail screen
FR12: Epic 2 — Auto-calculate next due date on task completion
FR13: Epic 2 — Log completed task with optional photo
FR14: Epic 2 — Maintenance history (task name, date, vendor, photo)
FR15: Epic 2 — Home Health Score (0–100) displayed on homeowner dashboard
FR16: Epic 2 — Health Score logic (starts 100, decreases on overdue, restores on completion)
FR17: Epic 3 — Browse all vendors filtered by service type
FR18: Epic 3 — Search vendors by keyword
FR19: Epic 3 — Vendor cards with trust signals (name, photo, services, price range, availability, jobs count)
FR20: Epic 3 — One-tap booking request (service type + preferred date)
FR21: Epic 3 — Push notification to vendor within 30 seconds of booking request
FR22: Epic 3 — Real-time booking status tracker (Requested → Confirmed → In Progress → Completed)
FR23: Epic 3 — Homeowner triggers "In Progress" when vendor arrives
FR24: Epic 3 — Booking cancellation (free when Requested; warning after Confirmed)
FR25: Epic 3 — Auto-cancel booking after 24h no vendor response
FR26: Epic 3 — No-show report → immediate vendor suspension
FR27: Epic 3 — No-show recovery screen with alternative vendor suggestions
FR28: Epic 4 — Vendor onboarding under 2 minutes (name, service types, contact, photo)
FR29: Epic 4 — Vendor profile immediately active and visible after onboarding
FR30: Epic 5 — Instant push notification to vendor for matching booking requests
FR31: Epic 5 — One-tap Accept / Decline booking request
FR32: Epic 5 — Homeowner contact details revealed to vendor on Accept
FR33: Epic 5 — Decline reason prompt (unavailable / outside service type / other)
FR34: Epic 5 — Availability toggle in vendor dashboard AppBar
FR35: Epic 5 — Availability off suppresses notifications and bookability
FR36: Epic 4 — Set min/max price range per service type
FR37: Epic 6 — Earnings dashboard (total jobs, gross earned, net earned, jobs this month)
FR38: Epic 4 — Upload QRPH code image (JPG/PNG)
FR39: ~~REMOVED~~ — GCash mobile number removed; QRPH-only payment
FR40: Epic 6 — Payment screen (final amount, QRPH image only)
FR41: Epic 6 — Homeowner "I've Paid" confirmation → vendor payment notification
FR42: Epic 6 — Vendor inputs final job price (>0) on job completion
FR43: Epic 6 — Booking → Completed status + homeowner payment notification on price confirmation
FR44: Epic 4 — Vendor public profile (name, photo, services, price range, availability, jobs count)
FR45: Epic 0 — Email + password authentication
FR46: Epic 0 — Role selection (homeowner vs vendor) after registration

## Epic List

### Epic 0: Project Foundations & Authentication
Users can register with email + password, select their role (homeowner or vendor), log in, and reach their role-specific home screen. All infrastructure (Flutter project, Supabase project + 10 migrations, go_router role guards, shared core modules, FCM token registration) is in place and ready for feature epics.
**FRs covered:** FR45, FR46
**Architecture items:** flutter create project init, Supabase project + migrations 001–010, go_router role guards, app_theme.dart, app_constants.dart, app_exception.dart, ErrorStateWidget, FCM token registration

### Epic 1: Property Setup & Maintenance Schedule
Homeowners set up their property profile (type and age) and get a personalised maintenance schedule pre-loaded with common Filipino home tasks they can select, customise, and assign recurrence intervals.
**FRs covered:** FR1, FR2, FR3, FR4, FR5, FR6, FR7

### Epic 2: Maintenance Tracking & Home Health Score
Homeowners track task due dates with colour-coded urgency (red/amber/green), receive push reminders for due and overdue tasks, log completed maintenance with optional photos, and see their Home Health Score update in real-time.
**FRs covered:** FR8, FR9, FR10, FR11, FR12, FR13, FR14, FR15, FR16

### Epic 3: Vendor Discovery & One-Tap Booking
Homeowners browse Airbnb-style vendor cards, search by service type or keyword, send one-tap booking requests, track the real-time booking lifecycle (Requested → Confirmed → In Progress → Completed), cancel bookings, and report no-shows — which trigger immediate vendor suspension and surface alternative vendors instantly.
**FRs covered:** FR17, FR18, FR19, FR20, FR21, FR22, FR23, FR24, FR25, FR26, FR27

### Epic 4: Vendor Onboarding & Public Profile
Vendors sign up in under 2 minutes by providing name, service types, contact number, and profile photo. They set their price ranges per service type and upload their QRPH code — resulting in an immediately-active public profile visible to all homeowners. For the hackathon demo, a set of mock vendor profiles is seeded into the database.
**FRs covered:** FR28, FR29, FR36, FR38, FR44

### Epic 5: Vendor Booking Management & Availability
Vendors receive instant push notifications for matching booking requests, accept or decline with a single tap, have homeowner contact details revealed on acceptance, and control their bookability via an availability toggle always accessible from the vendor dashboard AppBar.
**FRs covered:** FR30, FR31, FR32, FR33, FR34, FR35

### Epic 6: Job Completion, Earnings & Payment
Vendors confirm the final job price when marking a job complete; homeowners are presented a payment screen with a QRPH scan code; vendors see all their earnings and job history on a clear earnings dashboard.
**FRs covered:** FR37, FR40, FR41, FR42, FR43

---

## Epic 0: Project Foundations & Authentication

Users can register with email + password, select their role (homeowner or vendor), log in, and reach their role-specific home screen. All infrastructure is in place and ready for feature epics.

### Story 0.1: Flutter Project Initialisation & Backend Infrastructure

As a development team,
I want the Flutter project initialised with all required dependencies and the Supabase backend provisioned with the complete database schema,
So that all feature development can begin without infrastructure blockers.

**Acceptance Criteria:**

**Given** the development environment is set up,
**When** `flutter create spr_house_maintenance_tracker --org com.spr --platforms ios,android` is run,
**Then** the project compiles and launches on both iOS and Android with a blank Material 3 scaffold.
**And** pubspec.yaml includes: supabase_flutter ^2.12.0, firebase_messaging ^16.1.2, flutter_riverpod ^2.x, go_router ^14.x, image_picker ^1.x.

**Given** the Flutter project exists,
**When** environment config is set up via `--dart-define`,
**Then** SUPABASE_URL, SUPABASE_ANON_KEY, and FCM_SENDER_ID are accessible via `String.fromEnvironment()` and the `.env` file is excluded from source control via `.gitignore`.

**Given** the Supabase project is created,
**When** migrations 001–010 are run in sequence via `supabase db push`,
**Then** all tables exist (profiles, vendor_extensions, properties, maintenance_tasks, maintenance_logs, bookings, no_show_reports, fcm_tokens) with correct schema, RLS enabled on all tables, and pg_cron jobs registered.

**Given** the project structure is set up,
**When** `lib/core/` is created,
**Then** the following files exist: `app_exception.dart`, `app_constants.dart` (with Calm & Trustworthy colour constants), `app_theme.dart` (Material 3 with `ColorScheme.fromSeed(seedColor: Color(0xFF1B3A6B))`), `app_router.dart` (go_router skeleton with `/auth`, `/homeowner`, `/vendor` route trees and role guards), and `ErrorStateWidget` in `lib/core/widgets/`.

**Given** the feature folder structure is required,
**When** the project scaffolding is complete,
**Then** `lib/features/{auth,property,maintenance,booking,vendor,notifications,payment}/` each exist with `data/`, `domain/`, and `presentation/` subdirectories.

---

### Story 0.2: User Registration & Role Selection

As a new user,
I want to register with my email and password and choose whether I am a homeowner or a vendor,
So that I can access the features relevant to my role.

**Acceptance Criteria:**

**Given** I am a new user and not logged in,
**When** I open the app,
**Then** I am shown the login/registration screen and cannot access any homeowner or vendor screens.

**Given** I am on the registration screen,
**When** I enter a valid email and password and tap "Register",
**Then** a Supabase Auth account is created and I am navigated to the role selection screen.

**Given** I am on the role selection screen,
**When** I tap "I am a Homeowner",
**Then** a `profiles` row is created with `user_type = 'homeowner'` and I am navigated to `/homeowner/dashboard`.

**Given** I am on the role selection screen,
**When** I tap "I am a Vendor",
**Then** a `profiles` row is created with `user_type = 'vendor'` and I am navigated to the vendor onboarding screen (`/vendor/onboarding`).

**Given** I enter an already-registered email,
**When** I tap "Register",
**Then** an inline error is shown: "An account with this email already exists."

**Given** I enter an invalid email format or a password under 6 characters,
**When** I tap "Register",
**Then** inline validation errors appear below the respective fields.

---

### Story 0.3: User Login & Role-Based Navigation

As a returning user,
I want to log in with my email and password and be taken directly to my role-specific home screen,
So that I can access my dashboard without extra navigation steps.

**Acceptance Criteria:**

**Given** I am a registered user and not logged in,
**When** I enter my email and password and tap "Log In",
**Then** I am authenticated and navigated to `/homeowner/dashboard` (if homeowner) or `/vendor/dashboard` (if vendor) based on `profiles.user_type`.

**Given** the app is relaunched while I have an active session,
**When** the app loads,
**Then** I am navigated directly to my role-specific home screen without seeing the login screen.

**Given** I enter incorrect credentials,
**When** I tap "Log In",
**Then** an inline error is shown: "Incorrect email or password."

**Given** I am logged in,
**When** I tap "Log Out",
**Then** my session is cleared and I am navigated to `/auth/login` via `context.go()`.

**Given** go_router route guards are configured,
**When** an unauthenticated user navigates to any `/homeowner/...` or `/vendor/...` route,
**Then** they are redirected to `/auth/login`.

**Given** go_router route guards are configured,
**When** a homeowner navigates to any `/vendor/...` route (or vice versa),
**Then** they are redirected to their own role's home screen.

---

## Epic 1: Property Setup & Maintenance Schedule

Homeowners set up their property profile and get a personalised maintenance schedule with pre-loaded Filipino home tasks they can customise.

### Story 1.1: Property Setup Onboarding Flow

As a homeowner,
I want to set up my property by providing the type (house/condo/lot) and optional age,
So that the app can generate a relevant maintenance schedule for my home.

**Acceptance Criteria:**

**Given** I have registered as a homeowner and have no property set up,
**When** I reach `/homeowner/dashboard` for the first time,
**Then** I am directed to the property setup screen before seeing the dashboard.

**Given** I am on the property setup screen,
**When** I select a property type (house / condo / lot) and optionally enter a property age, then tap "Save",
**Then** a `properties` row is created in the database and I am navigated to the task template selection screen.

**Given** property type is required,
**When** I tap "Save" without selecting a property type,
**Then** a validation error is shown: "Please select a property type."

**Given** I complete property setup,
**When** the data is saved,
**Then** the `maintenance_tasks` table is pre-populated with default tasks appropriate to my property type.

---

### Story 1.2: Pre-loaded Maintenance Task Template Selection

As a homeowner,
I want to pick from pre-loaded Filipino home maintenance tasks,
So that I don't have to build my schedule from scratch.

**Acceptance Criteria:**

**Given** I have completed property setup,
**When** I view the task template selection screen,
**Then** I see at minimum: Aircon Cleaning, Pest Control, Plumbing Check, Septic Tank Pump-out, Rooftop Inspection, Electrical Check.

**Given** I am viewing task templates,
**When** I tap a task,
**Then** it is selected (checked) and added to my pending selection.

**Given** I tap "Confirm Selection",
**When** the selection is saved,
**Then** each selected task is created in `maintenance_tasks` with its default recurrence interval (e.g., Aircon = quarterly, Pest Control = semi-annual).
**And** I am navigated to `/homeowner/tasks`.

**Given** I select no tasks and tap "Confirm Selection",
**When** validation runs,
**Then** a prompt appears: "Select at least one task to activate your schedule."

---

### Story 1.3: Recurring Schedule Configuration & Task Customisation

As a homeowner,
I want to set recurrence intervals and customise individual tasks,
So that my maintenance schedule matches my home's actual needs.

**Acceptance Criteria:**

**Given** I am viewing a task in my schedule,
**When** I tap on the task card,
**Then** a task detail/edit screen opens showing: task name, recurrence interval (dropdown: monthly/quarterly/semi-annual/annual), notes field, and next due date.

**Given** I am editing a task,
**When** I change the recurrence interval and save,
**Then** the task's interval is updated and the next due date is recalculated immediately.

**Given** I am editing a task,
**When** I update the task name or add notes and tap "Save",
**Then** changes are saved and reflected in the task list immediately.

**Given** I am viewing the task list,
**When** I tap "Add Task",
**Then** a blank task creation form opens where I can enter a name, recurrence, and notes.

---

### Story 1.4: Property Settings Edit

As a homeowner,
I want to edit my property details from settings,
So that my schedule stays accurate as my home's needs change.

**Acceptance Criteria:**

**Given** I am on any homeowner screen,
**When** I navigate to settings,
**Then** I can access a "My Property" section showing my current property type and age.

**Given** I am editing my property details,
**When** I update the property type or age and tap "Save",
**Then** the `properties` row is updated and the changes are reflected in the app immediately.

---

## Epic 2: Maintenance Tracking & Home Health Score

Homeowners track task due dates with colour-coded urgency, receive push reminders, log completed maintenance with optional photos, and see their Home Health Score update in real-time.

### Story 2.1: Home Health Score Dashboard Widget

As a homeowner,
I want to see my Home Health Score prominently on my dashboard,
So that I can understand at a glance how well I am maintaining my property.

**Acceptance Criteria:**

**Given** I have at least one maintenance task set up,
**When** I open `/homeowner/dashboard`,
**Then** the `HealthScoreWidget` is displayed prominently showing my score (0–100).

**Given** no tasks are overdue,
**When** I view my score,
**Then** it displays 100 with a green gradient and subtitle "All tasks on track ✓".

**Given** one or more tasks are overdue,
**When** I view my score,
**Then** the score is below 100; it decreases proportionally (overdue count / total count subtracted from 100); the widget shows an amber or red progress bar with the overdue count displayed.

**Given** I complete and log all overdue tasks,
**When** the last log entry is saved,
**Then** my score updates to 100 and the `HealthScoreWidget` animates the number change via `TweenAnimationBuilder`.

**Given** I am a new user with no tasks,
**When** I view `/homeowner/dashboard`,
**Then** I see a prompt: "Add your first task to activate your Health Score" with an "Add Task" CTA button.

**Given** the `HealthScoreWidget` renders,
**When** a screen reader is active,
**Then** it announces: "Home Health Score: {score} out of 100."

---

### Story 2.2: Colour-Coded Task List with Push Reminders

As a homeowner,
I want to see my tasks colour-coded by urgency and receive push reminders when tasks are due,
So that I never miss a maintenance window.

**Acceptance Criteria:**

**Given** I have tasks in my schedule,
**When** I view `/homeowner/tasks`,
**Then** overdue tasks show a red left border and "Overdue" chip; tasks due ≤7 days show an amber border and "Soon" chip; on-track tasks show a green border and "OK" chip.

**Given** one or more tasks are overdue,
**When** the task list loads,
**Then** overdue tasks are sorted to the top of the list above all upcoming and on-track tasks.

**Given** a task's due date has arrived,
**When** the `schedule-reminders` Edge Function (pg_cron daily) fires,
**Then** a push notification is sent via FCM containing the task name and a "Book a Vendor" shortcut.

**Given** I receive a push notification for a task,
**When** I tap it,
**Then** the app opens and navigates directly to that task's detail screen via `context.go('/homeowner/tasks/{taskId}')`.

**Given** the `TaskCardWidget` renders,
**When** a screen reader is active,
**Then** it announces: "{task name}, {status}, due {date}."

---

### Story 2.3: Log Completed Maintenance Task with Photo

As a homeowner,
I want to mark a task as complete and optionally attach a photo,
So that I have an auditable record of all work done on my property.

**Acceptance Criteria:**

**Given** a task is due or overdue,
**When** I tap "Mark as Complete" on the task detail screen,
**Then** I am prompted to confirm completion and optionally attach a photo.

**Given** I attach a photo,
**When** I confirm completion,
**Then** the photo is uploaded to the `maintenance-logs/` Supabase Storage bucket; the public URL is saved to the `maintenance_logs` row; the task is marked completed; the next due date is calculated and updated.

**Given** I do not attach a photo,
**When** I confirm completion,
**Then** the task is still recorded as completed in `maintenance_logs` without a photo URL.

**Given** I want to review a past log entry,
**When** I tap on it in the maintenance history view,
**Then** I see full details: task name, completion date, vendor name (if booked through the app), and the attached photo in full size (if any).

**Given** a booking is marked Completed,
**When** both homeowner and vendor view the job record,
**Then** both can upload photos to the `maintenance_logs` row linked to that booking.

---

## Epic 3: Vendor Discovery & One-Tap Booking

Homeowners browse Airbnb-style vendor cards, send one-tap booking requests, track the real-time booking lifecycle, report no-shows, and are guided immediately to alternative vendors.

### Story 3.1: Vendor Browse & Search

As a homeowner,
I want to browse all vendors filtered by service type and search by keyword,
So that I can find the right professional for my maintenance task.

**Acceptance Criteria:**

**Given** I tap "Find a Vendor" from a task card or the Vendors tab,
**When** the vendor list loads,
**Then** all vendors with `is_available = true` and `is_suspended = false` are shown as `VendorCardWidget` items.

**Given** I select a service type filter chip (e.g., "Aircon Cleaning"),
**When** the list updates,
**Then** only vendors offering that service type are shown.

**Given** I tap the "All" filter chip,
**When** the list updates,
**Then** all available vendors are shown and all other service chips are deselected.

**Given** I type a keyword in the search field (e.g., "pest"),
**When** results load,
**Then** only vendors whose `service_types` match the keyword are returned.

**Given** a vendor has `is_available = false`,
**When** I browse the vendor list,
**Then** they appear with an "Unavailable" badge and the Book button is disabled.

**Given** a `VendorCardWidget` renders,
**When** it loads,
**Then** I see: name, profile photo (gradient fallback if none), services, price range (₱min–₱max), availability badge, and completed jobs count.
**And** when a screen reader is active it announces: "{name}, {services}, {jobs} jobs, {price range}, {availability}."

---

### Story 3.2: One-Tap Booking Request

As a homeowner,
I want to send a booking request to a vendor in one tap from their profile,
So that I can quickly schedule my maintenance service.

**Acceptance Criteria:**

**Given** I am on a vendor's profile screen,
**When** I tap "Book",
**Then** a booking form appears with: service type (pre-selected from task context or vendor's primary service) and a date picker (`showDatePicker()`) for preferred date.

**Given** I confirm the booking,
**When** I tap "Confirm Booking",
**Then** a `bookings` row is created with `status = 'requested'`; the booking appears in my bookings list as "Requested."

**Given** a booking request is submitted,
**When** the `dispatch-notification` Edge Function is triggered via DB webhook,
**Then** the vendor receives a push notification within 30 seconds displaying service type and preferred date.

**Given** a vendor declines my booking request,
**When** I am notified,
**Then** I see a prompt: "They couldn't take this job — let's find you another vendor" with a link back to vendor browse.

**Given** I tap "Confirm Booking" while offline,
**When** the Supabase call fails,
**Then** an error `SnackBar` is shown and the booking form remains open for retry.

---

### Story 3.3: Real-Time Booking Status Tracker

As a homeowner,
I want to see the real-time status of my bookings update automatically,
So that I always know what is happening with my scheduled service.

**Acceptance Criteria:**

**Given** I have an active booking,
**When** I view `/homeowner/bookings` or the booking detail screen,
**Then** the `BookingStatusStepperWidget` shows the current status step: Requested → Confirmed → In Progress → Completed.

**Given** a vendor accepts my booking,
**When** the status update is saved to the database,
**Then** my `BookingStatusStepperWidget` updates to "Confirmed" in real-time via Supabase Realtime (no manual refresh required) and I receive a push notification.

**Given** the vendor has arrived at my property,
**When** I tap "Vendor is here" on the booking detail screen,
**Then** the booking `status` changes to `'in_progress'` and the stepper updates immediately.

**Given** my booking request has received no response for 24 hours,
**When** the `auto-cancel-booking` Edge Function fires,
**Then** the booking `status` changes to `'cancelled'` and I receive a push notification prompting me to try another vendor.

**Given** I want to cancel a booking with `status = 'requested'`,
**When** I tap "Cancel Booking" and confirm the dialog,
**Then** the booking `status` changes to `'cancelled'` and I am returned to the vendor browse screen.

**Given** I want to cancel a booking with `status = 'confirmed'` or later,
**When** I tap "Cancel Booking",
**Then** a warning `AlertDialog` is shown before proceeding.

---

### Story 3.4: No-Show Reporting & Vendor Suspension

As a homeowner,
I want to report a vendor who did not show up,
So that the platform stays trustworthy and I can quickly book an alternative.

**Acceptance Criteria:**

**Given** my booking is in `'confirmed'` status and the vendor has not arrived,
**When** I tap "Vendor didn't show up",
**Then** I am shown a confirmation `AlertDialog` to confirm the no-show report.

**Given** I confirm the no-show,
**When** the `no_show_reports` row is inserted,
**Then** the `suspend-vendor` Edge Function fires; `vendor_extensions.is_suspended` is set to `true`; the vendor is immediately removed from all public vendor browse results.

**Given** the vendor is suspended,
**When** I view the screen after the report,
**Then** the `NoShowReportWidget` is displayed: "Sorry about that — let's find you another vendor" with an alternative vendor card (if available) and a "Browse All Vendors" CTA button.

**Given** I browse vendors after a no-show,
**When** the vendor list loads,
**Then** the suspended vendor does not appear (excluded by RLS `is_suspended = true` filter).

---

## Epic 4: Vendor Onboarding & Public Profile

Vendors sign up in under 2 minutes and are immediately visible with a fully-populated public profile including services, pricing, and payment details.

### Story 4.1: Vendor Fast Onboarding Flow

As a service vendor,
I want to sign up in under 2 minutes with my name, service types, contact number, and profile photo,
So that I can start receiving job notifications immediately without a lengthy registration process.

**Acceptance Criteria:**

**Given** I have selected "I am a Vendor" during registration,
**When** the vendor onboarding screen opens,
**Then** I see a form with: Full Name (required), Service Types (FilterChip multi-select, ≥1 required), Contact Number (required), Profile Photo (required).

**Given** I complete all required fields and tap "Start Receiving Jobs",
**When** my profile is submitted,
**Then** a `vendor_extensions` row is created; my profile photo is uploaded to the `avatars/` bucket and the public URL saved; my profile is immediately visible to homeowners (`is_suspended = false`, `is_available = true` by default).
**And** the full onboarding process completes in under 2 minutes.

**Given** I select multiple service types,
**When** I tap each `FilterChip`,
**Then** each chip toggles independently and all selected types are saved to `vendor_extensions.services[]`.

**Given** I skip required fields and tap "Start Receiving Jobs",
**When** validation runs,
**Then** inline error messages appear below each missing field; the form is not submitted.

---

### Story 4.2: Vendor Price Range & QRPH Setup

As a vendor,
I want to set my price range per service type and upload my QRPH code,
So that homeowners know what to expect and I can receive digital payments after jobs.

**Acceptance Criteria:**

**Given** I am on my vendor profile edit screen,
**When** I set a minimum and maximum price for a service type and save,
**Then** `vendor_extensions.price_range_min` and `price_range_max` are updated and the price range is displayed on my public profile as "₱min – ₱max per visit."

**Given** I offer multiple service types,
**When** I configure pricing,
**Then** I can set a different price range for each service type independently.

**Given** I upload a QRPH code image (JPG or PNG),
**When** the upload completes,
**Then** the image is stored in the `qrph-codes/` bucket and the URL is saved to `vendor_extensions.qrph_url`.

---

### Story 4.3: Vendor Public Profile Display

As a vendor,
I want a public profile that showcases my services, pricing, availability, and completed jobs,
So that homeowners feel confident booking me.

**Acceptance Criteria:**

**Given** a homeowner taps on my `VendorCardWidget`,
**When** my profile screen loads,
**Then** they see: profile photo (large hero), name, services offered, price range per service, current availability status, and completed jobs count.

**Given** I have 0 completed jobs,
**When** a homeowner views my profile,
**Then** they see: "New vendor — no completed jobs yet."

**Given** I update my profile (name, services, photo, price range),
**When** I save,
**Then** changes are reflected immediately on my public profile.

**Given** a booking is marked Completed,
**When** the record is saved,
**Then** my `vendor_extensions.completed_jobs_count` increments by 1.

---

## Epic 5: Vendor Booking Management & Availability

Vendors receive instant booking notifications, respond with one tap, and control their availability from the dashboard.

### Story 5.1: Instant Booking Notification & One-Tap Accept/Decline

As a vendor,
I want to receive an instant push notification when a homeowner requests my service type and accept or decline with one tap,
So that I can secure jobs quickly and manage my schedule efficiently.

**Acceptance Criteria:**

**Given** a homeowner submits a booking request for a service type I offer and I have `is_available = true`,
**When** the `bookings` row is inserted,
**Then** I receive a push notification via `dispatch-notification` Edge Function within 30 seconds displaying: service type and homeowner's preferred date.

**Given** I tap the notification,
**When** the app opens,
**Then** I am navigated directly to the booking request detail screen.

**Given** I am viewing a booking request and tap "Accept",
**When** the update is saved,
**Then** the booking `status` changes to `'confirmed'`; the homeowner is notified; the homeowner's contact details (name, contact number) are revealed to me on the booking detail screen.

**Given** I tap "Decline",
**When** a reason prompt appears,
**Then** I select from: "Unavailable on that date" / "Outside my service type" / "Other"; the reason is saved silently (not shown to homeowner); the homeowner is notified to find another vendor.

**Given** a booking request has been pending for 24 hours with no response,
**When** the `auto-cancel-booking` Edge Function fires,
**Then** the booking is automatically cancelled and the homeowner is notified.

---

### Story 5.2: Vendor Availability Toggle

As a vendor,
I want to toggle my availability on and off directly from my dashboard AppBar,
So that I only receive bookings when I am actually able to work.

**Acceptance Criteria:**

**Given** I am on `/vendor/dashboard`,
**When** I view the AppBar,
**Then** the `AvailabilityToggleWidget` is visible in the AppBar trailing slot showing a coloured dot and "Open" / "Unavailable" label with a Flutter `Switch`.

**Given** I toggle availability to "Off",
**When** `vendor_extensions.is_available` is set to `false`,
**Then** my profile shows "Currently Unavailable" to homeowners; the Book button on my profile is disabled; I stop receiving booking push notifications.

**Given** I toggle availability back to "On",
**When** `vendor_extensions.is_available` is set to `true`,
**Then** I am immediately visible and bookable; booking notifications resume.

**Given** a homeowner views my profile while I am unavailable,
**When** the profile screen loads,
**Then** the Book button label reads "Not available for bookings" and is disabled.

**Given** the `AvailabilityToggleWidget` renders,
**When** a screen reader is active,
**Then** it announces: "Availability toggle, currently {on/off}."

---

## Epic 6: Job Completion, Earnings & Payment

Vendors confirm final job pricing, homeowners pay digitally, and vendors see clear earnings on their dashboard.

### Story 6.1: Final Price Confirmation & Booking Completion

As a vendor,
I want to confirm the final job price when marking a job as complete,
So that the homeowner knows exactly what to pay and my earnings are recorded accurately.

**Acceptance Criteria:**

**Given** a booking is in `'in_progress'` status,
**When** I tap "Mark as Complete" on the booking detail screen,
**Then** I am prompted to input the final job price; my configured price range is shown as a reference (e.g., "Your range: ₱500–₱800").

**Given** I enter a valid final price (>0) and confirm,
**When** the booking is updated,
**Then** the booking `status` changes to `'completed'`; the homeowner receives a "Your job is complete — time to pay!" push notification via `dispatch-notification`; earnings totals are updated in `vendor_extensions`.

**Given** I submit a final price of ₱0,
**When** I tap "Confirm",
**Then** a validation error is shown: "Final price must be greater than ₱0."

---

### Story 6.2: Homeowner Payment Screen (QRPH)

As a homeowner,
I want to see a payment screen with the vendor's QRPH code after job completion,
So that I can pay my vendor quickly and digitally without cash handling.

**Acceptance Criteria:**

**Given** a booking has been marked Completed and final price confirmed,
**When** I view the booking detail screen,
**Then** the payment screen shows: the final amount (₱xxx) and the vendor's QRPH code as a scannable image.

**Given** I tap "I've Paid",
**When** the confirmation is saved,
**Then** the vendor receives a "Payment confirmed" push notification and the job record is closed.

**Given** the vendor has not uploaded a QRPH code,
**When** the payment screen loads,
**Then** it shows: "Cash payment — coordinate with your vendor directly" instead of digital payment options.

---

### Story 6.3: Vendor Earnings Dashboard

As a vendor,
I want to see a clear summary of my earnings and job history,
So that I can track my income and stay motivated to use the platform.

**Acceptance Criteria:**

**Given** I open `/vendor/dashboard`,
**When** the earnings section loads,
**Then** the `EarningsSummaryWidget` displays: total completed jobs (all time), total gross earned, total net earned (gross minus 10% admin fee), and jobs completed this month.

**Given** a booking is marked Completed and final price confirmed,
**When** the record is saved,
**Then** my earnings totals update immediately without requiring a screen refresh (via Riverpod `AsyncNotifier` state update).

**Given** I have no completed jobs,
**When** I view the earnings dashboard,
**Then** I see zero values with the message: "Complete your first job to start earning!"

**Given** the `EarningsSummaryWidget` renders,
**When** a screen reader is active,
**Then** it announces: "Net earned this month: ₱{amount}. Total jobs: {n}."
