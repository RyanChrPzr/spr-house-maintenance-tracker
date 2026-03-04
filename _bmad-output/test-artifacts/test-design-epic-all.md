---
stepsCompleted: ['step-01-detect-mode', 'step-02-load-context', 'step-03-risk-and-testability', 'step-04-coverage-plan', 'step-05-generate-output']
lastStep: 'step-05-generate-output'
lastSaved: '2026-03-04'
mode: epic-level
epics: [0, 1, 2, 3, 4, 5, 6]
project: spr-house-maintenance-tracker
---

# Test Design: All Epics (0–6) — SPR House Maintenance Tracker

**Date:** 2026-03-04
**Author:** HackathonTeam2
**Status:** Draft
**Stack:** Flutter (Dart) + Supabase (PostgreSQL, RLS, Edge Functions, Realtime, Storage) + Firebase FCM

---

## Executive Summary

**Scope:** Full epic-level test design covering all 7 epics (Epic 0–6), 18 stories, and 54 test scenarios across the hackathon MVP.

**Risk Summary:**

- Total risks identified: 30 (across all epics)
- Active high-priority risks (≥6): 7 (3 SEC risks waived per team decision)
- Critical BLOCK risk: 1 (R3.1 — Booking state machine)
- Critical categories: BUS (booking lifecycle, health score, due date calc), TECH (Realtime), PERF (FCM latency), OPS (pg_cron)

**Coverage Summary:**

- P0 scenarios: 18 (~12–14 hrs)
- P1 scenarios: 35 (~25–30 hrs)
- P2 scenarios: 7 (~3–5 hrs)
- **Total: 60 tests (~40–49 hrs)**

**Test framework:** `flutter_test` (unit + widget) · `integration_test` (integration) · Deno test runner (Edge Functions, out of scope for now)

---

## Not in Scope

| Item | Reasoning | Mitigation |
|------|-----------|------------|
| RLS policy correctness (R0.3) | Security testing deferred by team | Manual review of migration `008_rls_policies.sql` before demo |
| go_router role-guard bypass (R0.1) | Security testing deferred | Manual smoke test of route guards before demo |
| Suspended vendor RLS exclusion (R3.2) | Security testing deferred | Covered by 3.4-INT-001 (functional no-show test observes vendor disappears) |
| FCM end-to-end notification delivery | Requires live FCM credentials; non-deterministic in test | Monitor via Supabase Edge Function logs; manual verification on device |
| Supabase Edge Function unit tests | Deno runtime out of current test scope | Edge functions are integration-tested via `3.4-INT-001`, `6.1-INT-001` |
| Performance / load testing | Hackathon scope; single demo environment | NFR1 (30s push latency) monitored manually via Supabase dashboard |
| GCash deep-link testing | Removed from scope (QRPH-only) | N/A |

---

## Risk Assessment

### BLOCK Risk (Score = 9) — Must resolve before any booking feature ships

| Risk ID | Category | Description | P | I | Score | Mitigation | Owner | Timeline |
|---------|----------|-------------|---|---|-------|------------|-------|----------|
| R3.1 | BUS | Booking state machine accepts invalid transitions (e.g. `completed → requested`) — corrupts booking data for both roles | 3 | 3 | **9** | Implement `BookingStatus` enum + transition guard in `booking_model.dart`; cover all 7 transitions in 3.3-UNIT-001–007 | Dev | Before Epic 3 starts |

### High-Priority Risks (Score 6–8) — MITIGATE before release

| Risk ID | Category | Description | P | I | Score | Mitigation | Owner |
|---------|----------|-------------|---|---|-------|------------|-------|
| R0.2 | BUS | Role selection creates wrong `user_type` in `profiles` — poisons all downstream RLS and routing | 2 | 3 | 6 | Covered by 0.2-INT-001; assert `profiles.user_type` after registration | Dev |
| R1.1 | BUS | Next due date calculation wrong for recurrence intervals (off-by-one, boundary dates) | 3 | 2 | 6 | 5 unit tests (1.3-UNIT-001–005) covering all 4 recurrence variants + immediate recalc on change | Dev |
| R2.1 | BUS | Health Score formula broken (divide-by-zero on 0 tasks; off-by-one on proportional calc) | 3 | 2 | 6 | 4 unit tests (2.1-UNIT-001–004) covering 0 tasks, partial overdue, all overdue, restore-to-100 | Dev |
| R3.3 | PERF | Vendor receives booking push notification >30s or not at all (FCM dispatch failure) | 3 | 2 | 6 | Verify `dispatch-notification` Edge Function triggers on `bookings` insert; manual test on device; monitor Supabase function logs | Dev/Ops |
| R3.4 | TECH | Supabase Realtime subscription drops; homeowner booking status update not received | 3 | 2 | 6 | Covered by 3.3-INT-001; assert status update visible without manual refresh | Dev |
| R3.5 | BUS | `suspend-vendor` Edge Function fails silently; vendor NOT suspended after no-show | 2 | 3 | 6 | Covered by 3.4-INT-001; assert `is_suspended = true` and vendor absent from browse results | Dev |

### Medium-Priority Risks (Score 4–5) — MONITOR

| Risk ID | Category | Description | P | I | Score |
|---------|----------|-------------|---|---|-------|
| R0.4 | BUS | Session persistence navigates to wrong role screen on relaunch | 2 | 2 | 4 |
| R1.2 | BUS | Default tasks not pre-populated on property save | 2 | 2 | 4 |
| R1.3 | SEC | RLS allows homeowner to read another homeowner's data (waived) | 2 | 2 | 4 |
| R2.2 | DATA | Photo upload succeeds but URL not saved to `maintenance_logs` | 2 | 2 | 4 |
| R2.3 | OPS | Push reminder not firing for due tasks (pg_cron misconfiguration) | 2 | 2 | 4 |
| R2.4 | BUS | Next due date not recalculated after task completion | 2 | 2 | 4 |
| R2.5 | UI | Status colour is sole indicator — WCAG AA violation (NFR11) | 2 | 2 | 4 |
| R3.6 | OPS | Auto-cancel booking fires too early or not at all (pg_cron drift) | 2 | 2 | 4 |
| R3.7 | BUS | Booking created for `is_available = false` vendor | 2 | 2 | 4 |
| R4.1 | DATA | QRPH image uploaded but `qrph_url` not saved to `vendor_extensions` | 2 | 2 | 4 |
| R4.2 | PERF | Onboarding >2 min on slow mobile network | 2 | 2 | 4 |
| R4.4 | BUS | Vendor profile not immediately visible after onboarding | 2 | 2 | 4 |
| R5.1 | BUS | Booking notification sent to `is_available = false` vendor | 2 | 2 | 4 |
| R5.2 | BUS | Homeowner contact not revealed on booking acceptance | 2 | 2 | 4 |
| R5.3 | TECH | Availability toggle optimistic UI not rolled back on error | 2 | 2 | 4 |
| R6.1 | DATA | `completed_jobs_count` not incrementing on job completion | 2 | 2 | 4 |
| R6.2 | BUS | Net earnings calculation wrong (10% fee not applied) | 2 | 2 | 4 |
| R6.3 | BUS | Final price ₱0 accepted despite validation | 2 | 2 | 4 |
| R6.4 | BUS | Payment confirmed push notification not sent to vendor | 2 | 2 | 4 |

### Low-Priority Risks (Score 1–3) — DOCUMENT

| Risk ID | Category | Description | P | I | Score |
|---------|----------|-------------|---|---|-------|
| R0.5 | SEC | Env secrets accidentally committed to source control | 1 | 3 | 3 |
| R1.4 | DATA | Task customisation saves to wrong user's row | 1 | 3 | 3 |
| R4.3 | DATA | Price range min > max accepted without validation | 2 | 1 | 2 |

---

## Entry Criteria

- [ ] Flutter project initialised (`flutter create` complete; pubspec.yaml packages resolved)
- [ ] Supabase project created; migrations 001–010 applied via `supabase db push`
- [ ] `.env` file configured with `SUPABASE_URL`, `SUPABASE_ANON_KEY`, `FCM_SENDER_ID` (not committed)
- [ ] `test/helpers/test_helpers.dart` scaffolded with mock Supabase client setup
- [ ] At least one connected device or emulator available for integration tests
- [ ] Epic under test deployed to the test environment (local Supabase via `supabase start`)

## Exit Criteria

- [ ] All 18 P0 test cases passing (100%)
- [ ] P1 pass rate ≥ 95% (≤2 failures triaged with waivers)
- [ ] R3.1 state machine: all 7 transition scenarios green
- [ ] R2.1 Health Score edge cases: all 4 scenarios green
- [ ] R1.1 due date calculations: all 5 recurrence variants green
- [ ] No open BLOCK or MITIGATE risks without a documented mitigation owner
- [ ] Integration tests pass against a clean Supabase local instance (fresh migrations)

---

## Test Coverage Plan

### P0 (Critical) — Run on every commit (unit/widget only; ~3 min)

**Criteria:** Blocks core user journey + High risk (≥6) + No workaround

| Story | Scenario | Test ID | Level | Risk Link |
|-------|----------|---------|-------|-----------|
| 0.3 Login | Homeowner login → navigates to `/homeowner/dashboard` | 0.3-INT-001 | Integration | R0.2 |
| 0.3 Login | Vendor login → navigates to `/vendor/dashboard` | 0.3-INT-002 | Integration | R0.2 |
| 1.3 Schedule | Due date calc: monthly recurrence | 1.3-UNIT-001 | Unit | R1.1 |
| 1.3 Schedule | Due date calc: quarterly recurrence | 1.3-UNIT-002 | Unit | R1.1 |
| 1.3 Schedule | Due date calc: semi-annual recurrence | 1.3-UNIT-003 | Unit | R1.1 |
| 1.3 Schedule | Due date calc: annual recurrence | 1.3-UNIT-004 | Unit | R1.1 |
| 1.3 Schedule | Changing interval immediately recalculates next due date | 1.3-UNIT-005 | Unit | R1.1 |
| 2.1 Health Score | Score = 100 when no overdue tasks | 2.1-UNIT-001 | Unit | R2.1 |
| 2.1 Health Score | Score = 100 − (overdue/total × 100) proportional formula | 2.1-UNIT-002 | Unit | R2.1 |
| 2.1 Health Score | No divide-by-zero when `total tasks = 0` | 2.1-UNIT-003 | Unit | R2.1 |
| 2.1 Health Score | Score restores to 100 when last overdue task completed | 2.1-UNIT-004 | Unit | R2.1 |
| 3.3 Booking | State machine: `requested → confirmed` valid | 3.3-UNIT-001 | Unit | R3.1 |
| 3.3 Booking | State machine: `confirmed → in_progress` valid | 3.3-UNIT-002 | Unit | R3.1 |
| 3.3 Booking | State machine: `in_progress → completed` valid | 3.3-UNIT-003 | Unit | R3.1 |
| 3.3 Booking | State machine: `completed → requested` **INVALID** — must throw | 3.3-UNIT-004 | Unit | R3.1 |
| 3.3 Booking | State machine: `requested → completed` direct skip **INVALID** | 3.3-UNIT-005 | Unit | R3.1 |
| 3.3 Booking | State machine: `requested → cancelled` valid (homeowner cancel) | 3.3-UNIT-006 | Unit | R3.1 |
| 3.3 Booking | Cancel `confirmed` booking → `AlertDialog` warning shown first | 3.3-UNIT-007 | Unit | R3.1 |

**Total P0: 18 tests (~12–14 hrs to write)**

---

### P1 (High) — Run on every PR (~5–10 min for unit/widget; integration pre-demo)

**Criteria:** Core user journeys + Medium/High risk + Common workflows

#### Epic 0 — Auth

| Story | Scenario | Test ID | Level |
|-------|----------|---------|-------|
| 0.2 Register | Inline errors on invalid email / password <6 chars | 0.2-UNIT-001 | Unit |
| 0.2 Register | Register → role selection → `profiles.user_type` correct | 0.2-INT-001 | Integration |
| 0.3 Login | Inline error "Incorrect email or password" on bad credentials | 0.3-UNIT-001 | Unit |

#### Epic 1 — Property & Schedule

| Story | Scenario | Test ID | Level |
|-------|----------|---------|-------|
| 1.1 Property | Save without property type → validation error | 1.1-UNIT-001 | Unit |
| 1.1 Property | Property save → `properties` row created → navigate to template screen | 1.1-INT-001 | Integration |
| 1.2 Templates | Select-zero templates → prompt shown | 1.2-UNIT-001 | Unit |
| 1.2 Templates | Template selection → `maintenance_tasks` with correct default recurrence | 1.2-INT-001 | Integration |
| 1.3 Schedule | Task name + notes edit saved and reflected immediately | 1.3-INT-001 | Integration |

#### Epic 2 — Maintenance & Health Score

| Story | Scenario | Test ID | Level |
|-------|----------|---------|-------|
| 2.1 Health Score | `HealthScoreWidget` Semantics: "Home Health Score: {n} out of 100" | 2.1-WIDGET-001 | Widget |
| 2.2 Task List | Overdue tasks sorted to top of list | 2.2-UNIT-001 | Unit |
| 2.2 Task List | Task status categorization logic (overdue / upcoming / on-track) | 2.2-UNIT-002 | Unit |
| 2.2 Task List | `TaskCardWidget` overdue → red border + "Overdue" chip | 2.2-WIDGET-001 | Widget |
| 2.2 Task List | `TaskCardWidget` upcoming → amber border + "Soon" chip | 2.2-WIDGET-002 | Widget |
| 2.3 Logging | Complete task with photo → `maintenance_logs` row + next due date updated | 2.3-INT-001 | Integration |
| 2.3 Logging | Complete task without photo → `maintenance_logs` row (no photo URL) | 2.3-INT-002 | Integration |

#### Epic 3 — Vendor Discovery & Booking

| Story | Scenario | Test ID | Level |
|-------|----------|---------|-------|
| 3.1 Browse | Filter by service type → only matching vendors | 3.1-UNIT-001 | Unit |
| 3.1 Browse | Keyword search → vendors with matching `service_types` | 3.1-UNIT-002 | Unit |
| 3.1 Browse | `VendorCardWidget` renders all required fields | 3.1-WIDGET-001 | Widget |
| 3.1 Browse | `VendorCardWidget` Book button disabled when `is_available = false` | 3.1-WIDGET-002 | Widget |
| 3.2 Booking | Confirm booking → `bookings` row with `status = 'requested'` | 3.2-INT-001 | Integration |
| 3.3 Status | `BookingStatusStepperWidget` highlights correct active step | 3.3-WIDGET-001 | Widget |
| 3.3 Status | Homeowner taps "Vendor is here" → `status = 'in_progress'` | 3.3-INT-001 | Integration |
| 3.4 No-Show | No-show report → `is_suspended = true`; vendor absent from browse | 3.4-INT-001 | Integration |

#### Epic 4 — Vendor Onboarding

| Story | Scenario | Test ID | Level |
|-------|----------|---------|-------|
| 4.1 Onboarding | Inline errors on missing required fields | 4.1-UNIT-001 | Unit |
| 4.1 Onboarding | Complete onboarding → `vendor_extensions` row; profile visible to homeowners | 4.1-INT-001 | Integration |
| 4.2 Pricing | Price range displayed correctly (₱min–₱max per visit) | 4.2-UNIT-001 | Unit |
| 4.2 QRPH | QRPH upload → `qrph_url` saved to `vendor_extensions` | 4.2-INT-001 | Integration |

#### Epic 5 — Vendor Booking Management

| Story | Scenario | Test ID | Level |
|-------|----------|---------|-------|
| 5.1 Accept/Decline | Accept → `status = 'confirmed'`; homeowner contact revealed | 5.1-INT-001 | Integration |
| 5.1 Accept/Decline | Decline → reason saved; homeowner notified | 5.1-INT-002 | Integration |
| 5.2 Availability | Toggle off → `is_available = false`; vendor not bookable | 5.2-INT-001 | Integration |
| 5.2 Availability | Toggle failure → optimistic UI rolled back | 5.2-UNIT-001 | Unit |

#### Epic 6 — Job Completion & Earnings

| Story | Scenario | Test ID | Level |
|-------|----------|---------|-------|
| 6.1 Final Price | Final price ₱0 → validation error | 6.1-UNIT-001 | Unit |
| 6.1 Final Price | Final price confirmed → `status = 'completed'`; homeowner notified | 6.1-INT-001 | Integration |
| 6.3 Earnings | Net earnings = gross − 10% admin fee (formula correct) | 6.3-UNIT-001 | Unit |
| 6.3 Earnings | Earnings totals update immediately after booking completion (no refresh) | 6.3-UNIT-002 | Unit |

**Total P1: 35 tests (~25–30 hrs to write)**

---

### P2 (Medium) — Run pre-demo / nightly

**Criteria:** Secondary flows + Low risk + UX polish

| Story | Scenario | Test ID | Level |
|-------|----------|---------|-------|
| 1.4 Property Edit | Edit property type → `properties` row updated | 1.4-INT-001 | Integration |
| 4.3 Public Profile | Vendor profile screen renders all required fields | 4.3-WIDGET-001 | Widget |
| 5.2 Availability | `AvailabilityToggleWidget` Semantics: "Availability toggle, currently {on/off}" | 5.2-WIDGET-001 | Widget |
| 6.2 Payment | Payment screen: QRPH image + final amount displayed | 6.2-WIDGET-001 | Widget |
| 6.2 Payment | Payment screen: cash fallback when no QRPH uploaded | 6.2-WIDGET-002 | Widget |
| 6.2 Payment | "I've Paid" tap → vendor payment notification dispatched | 6.2-INT-001 | Integration |
| 6.3 Earnings | `EarningsSummaryWidget` Semantics: "Net earned this month: ₱{n}" | 6.3-WIDGET-001 | Widget |

**Total P2: 7 tests (~3–5 hrs to write)**

---

## Execution Order

### On every PR — Unit + Widget only (~3–5 min, no device needed)

```
flutter test test/features/
```

- [ ] All 1.3-UNIT-001–005 (due date calculations)
- [ ] All 2.1-UNIT-001–004 (health score formula)
- [ ] All 3.3-UNIT-001–007 (state machine)
- [ ] All other P0/P1 unit + widget tests

### Pre-demo / nightly — Integration suite (~15–30 min, requires device + Supabase)

```
flutter test integration_test/ --dart-define=SUPABASE_URL=... --dart-define=SUPABASE_ANON_KEY=...
```

- [ ] All P0 integration tests (0.3-INT-001, 0.3-INT-002)
- [ ] All P1 integration tests (full feature flows)
- [ ] P2 integration tests

---

## Resource Estimates

| Priority | Count | Hrs/Test (avg) | Total Hours |
|----------|-------|----------------|-------------|
| P0 | 18 | ~0.7 | ~12–14 hrs |
| P1 | 35 | ~0.8 | ~25–30 hrs |
| P2 | 7 | ~0.5 | ~3–5 hrs |
| **Total** | **60** | — | **~40–49 hrs** |

**Hackathon realistic target:** P0 + P1 unit/widget tests during feature development (~30–35 hrs). Integration tests wired up as each epic completes.

### Prerequisites

**Test Helpers:**
- `test/helpers/test_helpers.dart` — mock `SupabaseClient` using `mocktail` or `mockito`
- Seed data factories for: `profiles`, `vendor_extensions`, `properties`, `maintenance_tasks`, `bookings`

**Tooling:**
- `flutter_test` — unit + widget tests (included in Flutter SDK)
- `integration_test` — integration tests (Flutter package)
- `mocktail` or `mockito` — mocking Supabase repository calls in unit tests

**Environment:**
- Local Supabase instance via `supabase start` for integration tests
- Clean database state per test (use `supabase db reset` or per-test teardown)
- Connected iOS simulator or Android emulator for integration tests

---

## Quality Gate Criteria

| Criterion | Threshold |
|-----------|-----------|
| P0 pass rate | **100%** — no exceptions |
| P1 pass rate | ≥ 95% |
| P2 pass rate | Best effort (informational) |
| R3.1 state machine (7 transitions) | All green before Epic 3 dev starts |
| R2.1 Health Score (4 edge cases) | All green before Epic 2 dev starts |
| R1.1 due date (5 variants) | All green before Epic 1 dev starts |
| BLOCK risk (R3.1) | Resolved before any booking story is marked done |
| MITIGATE risks (R0.2, R1.1, R2.1, R3.3, R3.4, R3.5) | Mitigation owner assigned; verification test passing |
| Security tests (SEC category) | Deferred — manual review only |

---

## Mitigation Plans

### R3.1: Booking State Machine Invalid Transitions (Score: 9 — BLOCK)

**Mitigation Strategy:** Define `BookingStatus` as a Dart enum in `booking_model.dart`. Implement a `canTransitionTo(BookingStatus next)` guard method. All `booking_repository.dart` status updates must call this guard and throw `AppException` on invalid transition. Test with 3.3-UNIT-001–007.
**Owner:** Dev (Epic 3 story 3.3)
**Timeline:** Before Story 3.3 implementation begins
**Status:** Planned
**Verification:** 3.3-UNIT-001–007 all green

### R0.2: Role Selection Creates Wrong user_type (Score: 6)

**Mitigation Strategy:** After role selection, assert `profiles.user_type` value in `auth_repository.dart` before navigating. Test with 0.2-INT-001.
**Owner:** Dev (Epic 0 story 0.2)
**Timeline:** Story 0.2 implementation
**Status:** Planned
**Verification:** 0.2-INT-001 green; manual check of `profiles` table row after registration

### R1.1: Due Date Calculation Incorrect (Score: 6)

**Mitigation Strategy:** Implement `calculateNextDueDate(DateTime base, RecurrenceInterval interval)` as a pure function in `maintenance_task_model.dart`. Cover all 4 intervals + immediate recalc with 1.3-UNIT-001–005.
**Owner:** Dev (Epic 1 story 1.3)
**Timeline:** Story 1.3 implementation
**Status:** Planned
**Verification:** 1.3-UNIT-001–005 all green

### R2.1: Health Score Calculation Errors (Score: 6)

**Mitigation Strategy:** Implement `calculateHealthScore(int total, int overdue)` as a pure function in `maintenance_notifier.dart`. Guard against `total == 0` (return 100). Cover with 2.1-UNIT-001–004.
**Owner:** Dev (Epic 2 story 2.1)
**Timeline:** Story 2.1 implementation
**Status:** Planned
**Verification:** 2.1-UNIT-001–004 all green

### R3.3: FCM Notification >30s or Not Delivered (Score: 6)

**Mitigation Strategy:** Verify `dispatch-notification` Edge Function is wired to `bookings` DB webhook in Supabase dashboard. Manual smoke test: submit booking → check vendor device notification within 30s. Monitor via Supabase Edge Function logs.
**Owner:** Dev/Ops (Epic 3 story 3.2 + 5.1)
**Timeline:** Before hackathon demo
**Status:** Planned
**Verification:** Manual test on physical devices before demo

### R3.4: Supabase Realtime Subscription Drops (Score: 6)

**Mitigation Strategy:** Ensure `BookingNotifier.build()` subscribes via `.stream(primaryKey: ['id'])` pattern. Covered by 3.3-INT-001 — assert status update visible without manual refresh after vendor action.
**Owner:** Dev (Epic 3 story 3.3)
**Timeline:** Story 3.3 implementation
**Status:** Planned
**Verification:** 3.3-INT-001 green

### R3.5: suspend-vendor Edge Function Silent Failure (Score: 6)

**Mitigation Strategy:** Verify `suspend-vendor` Edge Function is wired to `no_show_reports` insert webhook. Covered by 3.4-INT-001 — assert `vendor_extensions.is_suspended = true` and vendor absent from browse after no-show.
**Owner:** Dev (Epic 3 story 3.4)
**Timeline:** Story 3.4 implementation
**Status:** Planned
**Verification:** 3.4-INT-001 green

---

## Assumptions and Dependencies

### Assumptions

1. `flutter_test` and `integration_test` packages are standard — no additional test framework setup beyond `pubspec.yaml` dev dependencies
2. `mocktail` is acceptable for mocking `SupabaseClient` in unit tests (no real Supabase calls in unit/widget tests)
3. Integration tests run against a local Supabase instance (`supabase start`) with a clean schema per test run
4. FCM notification delivery is verified manually on physical devices — not automated
5. pg_cron jobs (`auto-cancel-booking`, `schedule-reminders`) are tested manually or via Supabase Studio — not in automated suite

### Dependencies

1. `supabase_flutter ^2.12.0` — required for integration test Supabase client
2. `integration_test` Flutter package — required for integration tests (add to `pubspec.yaml` dev_dependencies)
3. `mocktail` or `mockito` — required for repository mocking in unit tests
4. Supabase CLI + `supabase start` — required for integration test environment
5. Migrations 001–010 applied before running integration tests

### Risks to Plan

- **Risk**: Hackathon time pressure may reduce P1 integration test coverage
  - **Impact**: No automated regression on booking flows
  - **Contingency**: Prioritise P0 unit tests (state machine, health score, due dates) — these run in seconds and catch the highest-value bugs

- **Risk**: Physical device availability for integration tests
  - **Impact**: Integration tests skipped if no connected device
  - **Contingency**: Use iOS Simulator or Android Emulator; flag if unavailable

---

## Interworking & Regression

| Component | Affected By | Regression Scope |
|-----------|-------------|-----------------|
| `booking_repository.dart` | All booking epics (3, 5, 6) | Re-run 3.2-INT-001, 3.3-INT-001, 5.1-INT-001–002, 6.1-INT-001 on any booking schema change |
| `maintenance_notifier.dart` | Health Score widget (Epic 2) | Re-run 2.1-UNIT-001–004 on any maintenance task state change |
| `BookingStatus` enum / guard | State machine (Epic 3) | Re-run 3.3-UNIT-001–007 on any booking status change |
| `schedule-reminders` Edge Function | Push reminders (Epic 2) | Manual verification if pg_cron config changes |
| `dispatch-notification` Edge Function | FCM across all epics | Manual smoke test on all 6 notification event types before demo |
| `suspend-vendor` Edge Function | No-show flow (Epic 3) | Re-run 3.4-INT-001 on any change to `no_show_reports` or `vendor_extensions` |
| RLS policies (`008_rls_policies.sql`) | All data access | Manual review of migration if any table schema changes |

---

## Follow-on Workflows

- Run `/bmad-tea-testarch-atdd` to generate failing P0 acceptance tests before Story 3.3 (state machine) development.
- Run `/bmad-tea-testarch-automate` for broader widget/integration test scaffolding once Epic 0 infrastructure is complete.
- Run `/bmad-tea-testarch-ci` to scaffold the CI quality pipeline (PR gate for unit/widget, nightly for integration).

---

## Appendix

### Knowledge Base References

- `risk-governance.md` — Risk classification and gate decision framework
- `probability-impact.md` — P×I scoring methodology (1–9 scale)
- `test-levels-framework.md` — Unit / Widget / Integration selection rules
- `test-priorities-matrix.md` — P0–P3 prioritization criteria

### Related Documents

- PRD: `docs/PRD/index.md`
- Epics & Stories: `_bmad-output/planning-artifacts/epics.md`
- Architecture: `_bmad-output/planning-artifacts/architecture.md`
- Sprint Status: `_bmad-output/implementation-artifacts/sprint-status.yaml`

---

**Generated by:** BMad TEA Agent — Murat, Master Test Architect
**Workflow:** `_bmad/tea/testarch/test-design`
**Version:** 5.0 (BMad v6.0.4)
