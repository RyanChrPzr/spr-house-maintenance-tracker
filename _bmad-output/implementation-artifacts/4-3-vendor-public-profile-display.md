# Story 4.3: Vendor Public Profile Display

Status: review

<!-- Note: Validation is optional. Run validate-create-story for quality check before dev-story. -->

## Story

As a vendor,
I want a public profile that showcases my services, pricing, availability, and completed jobs,
so that homeowners feel confident booking me.

## Acceptance Criteria

1. **Given** a homeowner taps on my `VendorCardWidget`, **when** the vendor profile screen loads (`/homeowner/vendor/:vendorId`), **then** they see: profile photo (large hero, full-width 200dp height), name, services offered as chips, price range as "₱{min} – ₱{max} per visit" (or "Price not set" if null), current availability status badge (green "● Available" / grey "Unavailable"), and completed jobs count.

2. **Given** I have 0 completed jobs, **when** a homeowner views my profile, **then** they see the text "New vendor — no completed jobs yet." instead of a jobs count number.

3. **Given** I have ≥ 1 completed jobs, **when** a homeowner views my profile, **then** they see "{n} jobs completed".

4. **Given** I update my profile (name, services, photo, price range via Stories 4.1/4.2 screens), **when** a homeowner next opens my profile screen, **then** changes are reflected because the screen fetches fresh data from Supabase on every load.

5. **Given** the data fetch for a vendor profile fails, **when** the screen loads, **then** an error message is shown with a retry button; the screen does not crash.

6. **Given** a `VendorCardWidget` is rendered with `isAvailable: true`, **when** displayed, **then** the card shows a green "● Available" badge and an enabled Book button; when `isAvailable: false`, the badge is grey "Unavailable" and the Book button is disabled.

7. **Given** a vendor's `is_suspended = true`, **when** a homeowner attempts to view or browse that vendor, **then** they do not appear in results (enforced by RLS at the database layer — no additional Flutter logic needed).

8. **Given** a booking is marked Completed (Story 6.1), **when** the record is saved, **then** `vendor_extensions.completed_jobs_count` is incremented by 1 — **this AC is deferred to Story 6.1** and is out of scope here. *(Story 4.3 must read and display whatever count is stored; the increment logic lives in the booking completion story.)*

## Tasks / Subtasks

- [x] **Task 1: Extend `VendorProfileModel` to include `name`** (AC: 1, 2, 3)
  - [x] Add `name` field (String, defaults to `''` when absent) to `VendorProfileModel` in `lib/features/vendor/domain/vendor_profile_model.dart`
  - [x] Update `fromJson()` factory to extract `name` from the optional nested `profiles` key: `(json['profiles'] as Map<String, dynamic>?)?['name'] as String? ?? ''`
  - [x] Update `toJson()` to exclude `name` (it lives in `profiles`, not `vendor_extensions` — never write it back via `vendor_extensions` update)
  - [x] Add `name` to constructor; mark required

- [x] **Task 2: Add `fetchVendorProfile(vendorId)` to `vendor_repository.dart`** (AC: 1, 4, 5)
  - [x] Add method `fetchVendorProfile(String vendorId)` → returns `VendorProfileModel`
  - [x] Query: `_supabase.from('vendor_extensions').select('*, profiles!inner(name)').eq('id', vendorId).single()`
  - [x] Catch `PostgrestException` → rethrow as `AppException`
  - [x] No new imports needed — `supabase_flutter` already imported

- [x] **Task 3: Add `vendorProfileProvider` to `vendor_provider.dart`** (AC: 1, 4, 5)
  - [x] Add `final vendorProfileProvider = FutureProvider.family<VendorProfileModel, String>((ref, vendorId) => ref.read(vendorRepositoryProvider).fetchVendorProfile(vendorId));`
  - [x] Import `vendor_profile_model.dart` in `vendor_provider.dart`
  - [x] This is a read-only provider; no notifier needed for this story

- [x] **Task 4: Create `VendorCardWidget`** (AC: 6)
  - [x] Create `lib/features/booking/presentation/widgets/vendor_card_widget.dart`
  - [x] Stateless `ConsumerWidget` receiving a `VendorProfileModel vendor` and `VoidCallback? onBook` parameter
  - [x] Card anatomy (Airbnb-style): avatar (CircleAvatar 40dp radius, NetworkImage from `avatarUrl`), availability badge, name, services (Wrap of small Chips), price range text, "Book" FilledButton
  - [x] Availability badge: `isAvailable: true` → green dot + "Available"; `isAvailable: false` → grey dot + "Unavailable"
  - [x] Book button: enabled when `isAvailable: true` AND `onBook != null`; disabled when `isAvailable: false`
  - [x] Wrap entire card in `Card` + `InkWell` for tap-to-profile navigation
  - [x] Accessibility: `Semantics(label: '${vendor.name}, ${vendor.services.join(', ')}, ${vendor.completedJobsCount} jobs, price range, ${vendor.isAvailable ? "Available" : "Unavailable"}')`
  - [x] No Supabase calls in this widget — receives model from parent/provider

- [x] **Task 5: Create `vendor_profile_screen.dart`** (AC: 1, 2, 3, 4, 5)
  - [x] Create `lib/features/booking/presentation/screens/vendor_profile_screen.dart`
  - [x] `ConsumerWidget` with `vendorId` constructor parameter (passed from router extra or path param)
  - [x] Watches `vendorProfileProvider(vendorId)` with `.when(data:, loading:, error:)`
  - [x] **Loading state:** `CircularProgressIndicator.adaptive()` centered
  - [x] **Error state:** Column with error message text + `FilledButton("Retry", onPressed: () => ref.invalidate(vendorProfileProvider(vendorId)))`
  - [x] **Data state layout (SingleChildScrollView):**
    - Hero photo: `avatarUrl` != null → `Image.network(avatarUrl, height: 200, width: double.infinity, fit: BoxFit.cover)` with grey fallback Container when null
    - Name: `Text(vendor.name, style: textTheme.headlineSmall)`
    - Availability badge: Row with coloured dot + "Available" / "Unavailable" text
    - Services: `Wrap` of `Chip(label: Text(service))` for each service in `vendor.services`
    - Price range: "₱{min} – ₱{max} per visit" or "Price not set" when both null
    - Completed jobs: "New vendor — no completed jobs yet." when count == 0; "{n} jobs completed" when > 0
    - Book CTA: full-width `FilledButton("Book This Vendor")` — enabled when `vendor.isAvailable`; disabled when not; navigation to booking form (placeholder `SnackBar('Booking — Story 3.2')` for now)
  - [x] AppBar: back button (automaticallyImplyLeading: true default); title "Vendor Profile"
  - [x] Use `context.push()` for navigation TO this screen (preserves back stack)

- [x] **Task 6: Update `app_router.dart`** (AC: 1)
  - [x] Add import for `vendor_profile_screen.dart` from booking feature
  - [x] Add route `/homeowner/vendor/:vendorId` → `VendorProfileScreen(vendorId: state.pathParameters['vendorId']!)`
  - [x] Place under homeowner route group (after `/homeowner` route)

- [x] **Task 7: Write tests** (AC: 1, 2, 3, 5, 6)
  - [x] Create `test/features/vendor/data/vendor_profile_fetch_test.dart`
    - Test `fetchVendorProfile()` calls correct table + select with profiles join
    - Test returns `VendorProfileModel` with `name` populated from joined `profiles` key
    - Test `PostgrestException` → `AppException` mapping
  - [x] Create `test/features/booking/presentation/vendor_card_widget_test.dart`
    - Test card shows "Available" badge when `isAvailable: true`
    - Test card shows "Unavailable" badge + disabled Book button when `isAvailable: false`
    - Test "0 jobs" case not directly in card (jobs displayed on profile screen)

## Dev Notes

### Critical: `VendorProfileModel` Extension — Adding `name`

The `name` field lives in the `profiles` table and is joined via PostgREST's embedded resource syntax. The `fromJson()` must handle both plain `vendor_extensions` rows (no `profiles` key) and joined rows.

```dart
// Updated VendorProfileModel with name field
@immutable
class VendorProfileModel {
  const VendorProfileModel({
    required this.id,
    required this.name,           // ← NEW: populated from profiles join
    required this.services,
    required this.isAvailable,
    required this.isSuspended,
    required this.completedJobsCount,
    this.priceRangeMin,
    this.priceRangeMax,
    this.qrphUrl,
    this.avatarUrl,
  });

  final String id;
  final String name;              // ← NEW
  // ... rest of fields unchanged

  factory VendorProfileModel.fromJson(Map<String, dynamic> json) {
    // Handle optional profiles join: present when fetched via fetchVendorProfile,
    // absent when constructing from insert response (createVendorProfile, which
    // returns void — so fromJson is not called there).
    final profilesMap = json['profiles'] as Map<String, dynamic>?;
    return VendorProfileModel(
      id: json['id'] as String,
      name: profilesMap?['name'] as String? ?? '',
      services: List<String>.from(json['services'] as List? ?? []),
      priceRangeMin: (json['price_range_min'] as num?)?.toDouble(),
      priceRangeMax: (json['price_range_max'] as num?)?.toDouble(),
      qrphUrl: json['qrph_url'] as String?,
      avatarUrl: json['avatar_url'] as String?,
      isAvailable: json['is_available'] as bool? ?? true,
      isSuspended: json['is_suspended'] as bool? ?? false,
      completedJobsCount: json['completed_jobs_count'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
    // name intentionally excluded — it lives in profiles table, not vendor_extensions
    'services': services,
    'price_range_min': priceRangeMin,
    'price_range_max': priceRangeMax,
    'qrph_url': qrphUrl,
    'avatar_url': avatarUrl,
    'is_available': isAvailable,
    'is_suspended': isSuspended,
    'completed_jobs_count': completedJobsCount,
  };
}
```

> ⚠️ `name` is excluded from `toJson()` because it is never written back through the `vendor_extensions` table. Name updates go through `profiles.update({name: ...})` (already established in `createVendorProfile()`).

> ⚠️ Existing tests that call `VendorProfileModel.fromJson()` without a `profiles` key will NOT break — `name` defaults to `''` via null-coalesce.

[Source: `_bmad-output/planning-artifacts/architecture.md` — Data Architecture, Format Patterns]

---

### Critical: `fetchVendorProfile` — Supabase PostgREST JOIN Pattern

```dart
/// Fetches a single vendor's public profile, joining name from profiles.
///
/// Throws [AppException] if the vendor is not found or a DB error occurs.
Future<VendorProfileModel> fetchVendorProfile(String vendorId) async {
  try {
    final data = await _supabase
        .from('vendor_extensions')
        .select('*, profiles!inner(name)')
        .eq('id', vendorId)
        .single();
    return VendorProfileModel.fromJson(data);
  } on PostgrestException catch (e) {
    throw AppException(code: e.code ?? 'db-error', message: e.message);
  }
}
```

**What `profiles!inner(name)` does:**
- PostgREST embedded resource select — does an INNER JOIN on `profiles.id = vendor_extensions.id`
- Returns data like: `{"id":"...", "services":[...], ..., "profiles": {"name": "Juan Cruz"}}`
- `!inner` means non-matching rows are excluded (safe for normal vendors; suspended vendors are already excluded by RLS)
- Only fetches `name` from profiles — not phone, avatar_url (those are on vendor_extensions already)

> ⚠️ Use `.single()` — a vendor ID maps to exactly one `vendor_extensions` row. If the row doesn't exist (vendor never completed onboarding), `single()` throws a `PostgrestException` that is caught and rethrown as `AppException`.

> ⚠️ The `is_suspended` RLS policy on `vendor_extensions` ensures suspended vendors are invisible to homeowners at the DB layer. No Flutter-level suspension check needed.

[Source: `_bmad-output/planning-artifacts/architecture.md` — API & Communication Patterns, Authentication & Security]

---

### Critical: `vendorProfileProvider` — FutureProvider.family Pattern

```dart
// In vendor_provider.dart — add after existing providers:
import '../domain/vendor_profile_model.dart';

/// Fetches a single vendor's public profile by ID.
/// Invalidate with ref.invalidate(vendorProfileProvider(vendorId)) to retry.
final vendorProfileProvider =
    FutureProvider.family<VendorProfileModel, String>(
  (ref, vendorId) =>
      ref.read(vendorRepositoryProvider).fetchVendorProfile(vendorId),
);
```

> ⚠️ Use `FutureProvider.family` (not `AsyncNotifier`) for simple read-only fetches parameterised by ID. This avoids boilerplate for a fetch-and-display pattern with no mutation.

> ⚠️ Use `ref.read(vendorRepositoryProvider)` (not `ref.watch`) inside `FutureProvider` body — watching inside a provider body can cause infinite rebuild loops.

[Source: `_bmad-output/planning-artifacts/architecture.md` — State Management Patterns]

---

### Critical: `VendorCardWidget` — Airbnb-Style Card

```dart
// lib/features/booking/presentation/widgets/vendor_card_widget.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../vendor/domain/vendor_profile_model.dart';

class VendorCardWidget extends ConsumerWidget {
  const VendorCardWidget({
    super.key,
    required this.vendor,
    this.onBook,
    this.onTap,
  });

  final VendorProfileModel vendor;
  final VoidCallback? onBook;
  final VoidCallback? onTap;  // tap card body → navigate to full profile

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    return Semantics(
      label: '${vendor.name}, ${vendor.services.join(', ')}, '
          '${vendor.completedJobsCount} jobs completed, '
          '${_priceRangeText()}, '
          '${vendor.isAvailable ? "Available" : "Unavailable"}',
      child: Card(
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Photo
                CircleAvatar(
                  radius: 40,
                  backgroundImage: vendor.avatarUrl != null
                      ? NetworkImage(vendor.avatarUrl!)
                      : null,
                  child: vendor.avatarUrl == null
                      ? const Icon(Icons.person, size: 40)
                      : null,
                ),
                const SizedBox(width: 12),

                // Info column
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Name + availability badge row
                      Row(
                        children: [
                          Expanded(
                            child: Text(vendor.name,
                                style: theme.textTheme.titleMedium),
                          ),
                          _AvailabilityBadge(isAvailable: vendor.isAvailable),
                        ],
                      ),
                      const SizedBox(height: 4),

                      // Services chips
                      Wrap(
                        spacing: 4,
                        runSpacing: 4,
                        children: vendor.services
                            .map((s) => Chip(
                                  label: Text(s,
                                      style: theme.textTheme.labelSmall),
                                  padding: EdgeInsets.zero,
                                  materialTapTargetSize:
                                      MaterialTapTargetSize.shrinkWrap,
                                ))
                            .toList(),
                      ),
                      const SizedBox(height: 4),

                      // Price range
                      Text(_priceRangeText(),
                          style: theme.textTheme.bodySmall),

                      // Jobs count
                      Text(
                        vendor.completedJobsCount == 0
                            ? 'New vendor — no completed jobs yet.'
                            : '${vendor.completedJobsCount} jobs completed',
                        style: theme.textTheme.bodySmall,
                      ),
                      const SizedBox(height: 8),

                      // Book button
                      SizedBox(
                        width: double.infinity,
                        child: FilledButton(
                          onPressed: vendor.isAvailable ? onBook : null,
                          child: const Text('Book'),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _priceRangeText() {
    if (vendor.priceRangeMin != null && vendor.priceRangeMax != null) {
      return '₱${vendor.priceRangeMin!.toStringAsFixed(0)} – '
          '₱${vendor.priceRangeMax!.toStringAsFixed(0)} per visit';
    }
    return 'Price not set';
  }
}

class _AvailabilityBadge extends StatelessWidget {
  const _AvailabilityBadge({required this.isAvailable});
  final bool isAvailable;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          Icons.circle,
          size: 10,
          color: isAvailable ? Colors.green : Colors.grey,
        ),
        const SizedBox(width: 4),
        Text(
          isAvailable ? 'Available' : 'Unavailable',
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
            color: isAvailable ? Colors.green : Colors.grey,
          ),
        ),
      ],
    );
  }
}
```

> ⚠️ `VendorCardWidget` is in `lib/features/booking/presentation/widgets/` (per architecture), but imports `VendorProfileModel` from the `vendor` feature. Cross-feature model imports are acceptable — only cross-feature *Supabase calls* are forbidden.

> ⚠️ The `onBook` callback is passed from the parent (vendor browse screen or profile screen). The widget does NOT navigate or call a notifier — those are parent responsibilities.

[Source: `_bmad-output/planning-artifacts/ux-design-specification.md` — VendorCardWidget, Component Implementation Strategy]
[Source: `_bmad-output/planning-artifacts/architecture.md` — Enforcement Guidelines]

---

### Critical: `VendorProfileScreen` — Full Profile View

```dart
// lib/features/booking/presentation/screens/vendor_profile_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../vendor/presentation/vendor_provider.dart';

class VendorProfileScreen extends ConsumerWidget {
  const VendorProfileScreen({super.key, required this.vendorId});
  final String vendorId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final vendorAsync = ref.watch(vendorProfileProvider(vendorId));
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Vendor Profile'),
        // automaticallyImplyLeading: true (default) — has back button (pushed via context.push)
      ),
      body: vendorAsync.when(
        loading: () => const Center(child: CircularProgressIndicator.adaptive()),
        error: (e, _) => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Could not load vendor profile.',
                  style: theme.textTheme.bodyLarge),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: () =>
                    ref.invalidate(vendorProfileProvider(vendorId)),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
        data: (vendor) => SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Hero photo
              if (vendor.avatarUrl != null)
                Image.network(
                  vendor.avatarUrl!,
                  height: 200,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) =>
                      _photoFallback(),
                )
              else
                _photoFallback(),

              // Profile details
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Name
                    Text(vendor.name, style: theme.textTheme.headlineSmall),
                    const SizedBox(height: 8),

                    // Availability badge
                    Row(
                      children: [
                        Icon(Icons.circle,
                            size: 12,
                            color: vendor.isAvailable
                                ? Colors.green
                                : Colors.grey),
                        const SizedBox(width: 6),
                        Text(
                          vendor.isAvailable ? 'Available' : 'Unavailable',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: vendor.isAvailable
                                ? Colors.green
                                : Colors.grey,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Services
                    Text('Services', style: theme.textTheme.titleSmall),
                    const SizedBox(height: 6),
                    Wrap(
                      spacing: 8,
                      runSpacing: 4,
                      children: vendor.services
                          .map((s) => Chip(label: Text(s)))
                          .toList(),
                    ),
                    const SizedBox(height: 16),

                    // Price range
                    Text('Price Range', style: theme.textTheme.titleSmall),
                    const SizedBox(height: 4),
                    Text(
                      _priceRangeText(vendor),
                      style: theme.textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 16),

                    // Jobs count
                    Text('Experience', style: theme.textTheme.titleSmall),
                    const SizedBox(height: 4),
                    Text(
                      vendor.completedJobsCount == 0
                          ? 'New vendor — no completed jobs yet.'
                          : '${vendor.completedJobsCount} jobs completed',
                      style: theme.textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 32),

                    // Book CTA
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton(
                        onPressed: vendor.isAvailable
                            ? () => ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                      content: Text('Booking — Story 3.2')),
                                )
                            : null,
                        child: const Text('Book This Vendor'),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _photoFallback() => Container(
        height: 200,
        width: double.infinity,
        color: Colors.grey[200],
        child: const Icon(Icons.person, size: 80, color: Colors.grey),
      );

  String _priceRangeText(vendor) {
    if (vendor.priceRangeMin != null && vendor.priceRangeMax != null) {
      return '₱${vendor.priceRangeMin!.toStringAsFixed(0)} – '
          '₱${vendor.priceRangeMax!.toStringAsFixed(0)} per visit';
    }
    return 'Price not set';
  }
}
```

> ⚠️ **Book button placeholder:** The Book action is wired in Story 3.2 (One-Tap Booking Request). For this story, the button shows a SnackBar placeholder. Do NOT implement actual booking logic here — that's Story 3.2's scope.

> ⚠️ **Back navigation:** This screen is reached via `context.push('/homeowner/vendor/$vendorId')` from the vendor browse or VendorCardWidget. The AppBar back button uses `go_router`'s default pop — do NOT add `automaticallyImplyLeading: false`.

> ⚠️ **`ref.invalidate(vendorProfileProvider(vendorId))`** — correct way to retry a `FutureProvider.family`. Do not call `ref.refresh()` — it returns a Future that is ignored here.

[Source: `_bmad-output/planning-artifacts/ux-design-specification.md` — Journey 2: Homeowner Booking Flow, Vendor browse screen: photo 200dp hero]
[Source: `_bmad-output/planning-artifacts/architecture.md` — Frontend Architecture, State Management Patterns]

---

### Critical: Router Changes

```dart
// In app_router.dart, add import:
import '../../features/booking/presentation/screens/vendor_profile_screen.dart';

// Add route (after /homeowner route):
GoRoute(
  path: '/homeowner/vendor/:vendorId',
  builder: (context, state) => VendorProfileScreen(
    vendorId: state.pathParameters['vendorId']!,
  ),
),
```

**Navigation to this screen (from VendorCardWidget or browse screen):**
```dart
context.push('/homeowner/vendor/${vendor.id}');
```

> ⚠️ Use `context.push()` (not `context.go()`) — the homeowner must be able to tap Back to return to the browse list. `context.go()` replaces the stack; `context.push()` adds to it.

[Source: `_bmad-output/planning-artifacts/architecture.md` — Communication Patterns, Navigation]

---

### Critical: `VendorCardWidget` Location — Cross-Feature Import

Per the architecture, `VendorCardWidget` lives in the `booking` feature:
```
lib/features/booking/presentation/widgets/vendor_card_widget.dart
```

It imports `VendorProfileModel` from the vendor feature:
```dart
import '../../../vendor/domain/vendor_profile_model.dart';
```

This is acceptable — the rule "only `*_repository.dart` imports `supabase_flutter`" applies to the Supabase SDK, not to domain model imports across features. Cross-feature model imports are a normal dependency in feature-first Flutter architecture.

> ⚠️ Do NOT place `VendorCardWidget` in `lib/features/vendor/` — the architecture explicitly maps it to `lib/features/booking/presentation/widgets/` because it is the entry point to the booking flow.

[Source: `_bmad-output/planning-artifacts/architecture.md` — Complete Project Directory Structure, Enforcement Guidelines]

---

### Critical: `completed_jobs_count` — Scope Boundary

**AC8 is OUT OF SCOPE for Story 4.3.** The `completed_jobs_count` increment happens in Story 6.1 (Final Price Confirmation and Booking Completion). This story only DISPLAYS whatever count is stored in `vendor_extensions.completed_jobs_count` (which starts at `0` from the migration default).

The display logic already handles this:
- `completedJobsCount == 0` → "New vendor — no completed jobs yet."
- `completedJobsCount > 0` → "{n} jobs completed"

When Story 6.1 increments the count via `.update({'completed_jobs_count': supabase.rpc(...) or count+1 })`, the display will automatically reflect the new value on next profile load.

[Source: `_bmad-output/planning-artifacts/architecture.md` — Data Architecture, `vendor_extensions` table]

---

### Architecture Compliance — Mandatory Rules

| Rule | Correct | Wrong |
|---|---|---|
| Supabase calls | Only in `vendor_repository.dart` | Never in `VendorCardWidget`, notifiers, or `vendor_provider.dart` |
| Navigation to profile | `context.push('/homeowner/vendor/$id')` | Never `context.go()` — homeowner needs back button |
| Provider for read-only fetch | `FutureProvider.family` | Don't use `AsyncNotifier` for simple read-with-no-mutation |
| Vendor model field | `name` from joined `profiles` key | Never try to read `name` directly from `vendor_extensions` |
| Book button action | Placeholder SnackBar for now | Don't implement booking logic (Story 3.2) |
| `completed_jobs_count` | Display only | Don't increment here (Story 6.1) |
| Widget imports | Cross-feature model imports are OK | Never call `supabase.from()` outside `*_repository.dart` |

[Source: `_bmad-output/planning-artifacts/architecture.md` — Enforcement Guidelines, Anti-Patterns]

---

### Library / Framework Requirements

| Package | Version | Use in this story |
|---|---|---|
| `supabase_flutter` | ^2.12.0 | `fetchVendorProfile` — PostgREST `.select()` with embedded join |
| `flutter_riverpod` | ^2.x | `FutureProvider.family`, `ConsumerWidget`, `ref.watch()`, `ref.invalidate()` |
| `go_router` | ^14.x | `context.push('/homeowner/vendor/:id')`, `state.pathParameters` |

> All packages already in `pubspec.yaml`. No new dependencies required.

---

### File Structure Requirements — What to Create / Modify

**Create (new files):**
```
lib/features/booking/presentation/widgets/vendor_card_widget.dart
lib/features/booking/presentation/screens/vendor_profile_screen.dart
test/features/vendor/data/vendor_profile_fetch_test.dart
test/features/booking/presentation/vendor_card_widget_test.dart
```

**Modify (existing files):**
```
lib/features/vendor/domain/vendor_profile_model.dart          ← add name field
lib/features/vendor/data/vendor_repository.dart               ← add fetchVendorProfile
lib/features/vendor/presentation/vendor_provider.dart         ← add vendorProfileProvider
lib/core/router/app_router.dart                               ← add /homeowner/vendor/:vendorId route
```

**Note — booking feature directories:**
The `lib/features/booking/` directory may not exist yet (it's scaffolded in the architecture but no story has created it). Create the full path:
```
lib/features/booking/
  presentation/
    screens/
      vendor_profile_screen.dart   ← create this
    widgets/
      vendor_card_widget.dart       ← create this
```
No `.gitkeep` files need to be removed (booking directories don't have them — they were never created).

[Source: `_bmad-output/planning-artifacts/architecture.md` — Complete Project Directory Structure]

---

### Testing Requirements

**`test/features/vendor/data/vendor_profile_fetch_test.dart`:**
- Reuse `_FakeVendorRepository` / mock Supabase pattern from `vendor_repository_test.dart`
- Mock the `.from('vendor_extensions').select('*, profiles!inner(name)').eq('id', vendorId).single()` chain
- Test `fetchVendorProfile()` returns a `VendorProfileModel` with `name` populated from nested `profiles` map
- Test `fetchVendorProfile()` with missing `profiles` key → `name` defaults to `''` (no crash)
- Test `PostgrestException` → `AppException` mapping

**`test/features/booking/presentation/vendor_card_widget_test.dart`:**
- Use `pumpWidget` with `ProviderScope` wrapper
- Build a `VendorProfileModel` with `name: 'Test Vendor'`, `isAvailable: true` → verify green "Available" badge text present
- Build with `isAvailable: false` → verify grey "Unavailable" badge; `FilledButton` should be disabled (onPressed == null)
- Build with `completedJobsCount: 0` — this is on the profile screen, not card, but test "New vendor" string on profile screen separately if desired

**Testing patterns (from Story 4.1/4.2 learnings):**
- `registerFallbackValue` and `ProviderContainer` patterns from vendor tests apply
- For widget tests, use `MaterialApp` + `ProviderScope` wrapper
- `VendorProfileModel` now requires `name` — update any existing test fixtures that construct `VendorProfileModel` directly (add `name: ''` to avoid compilation errors)

> ⚠️ **IMPORTANT:** When you add `name` as a required field to `VendorProfileModel`, ALL existing tests that construct `VendorProfileModel(...)` directly will need `name: ''` added. Check and update:
> - `test/features/vendor/data/vendor_repository_test.dart`
> - `test/features/vendor/presentation/vendor_notifier_test.dart`
> - Any other files that construct `VendorProfileModel` directly

[Source: Story 4.1 Dev Agent Record — testing patterns]
[Source: Story 4.2 Dev Agent Record — `ProviderContainer` with override, `registerFallbackValue` pattern]

---

### Previous Story Intelligence

**From Story 4.2 (Vendor Price Range & QRPH Setup):**
- `vendor_repository.dart` EXISTS — has `uploadProfilePhoto`, `createVendorProfile`, `updateVendorProfile`, `uploadQrphCode`. ADD `fetchVendorProfile` at the end; do NOT recreate
- `vendor_notifier.dart` EXISTS — has `submitOnboarding` + `submitPricingSetup` methods. No changes needed for this story
- `vendor_provider.dart` EXISTS — has `vendorRepositoryProvider` + `vendorOnboardingNotifierProvider`. ADD `vendorProfileProvider` at the end
- `vendor_profile_model.dart` EXISTS — MODIFY to add `name` field (see Task 1)
- `app_router.dart` EXISTS — has `/vendor`, `/vendor/profile-setup`, `/vendor/dashboard`. ADD `/homeowner/vendor/:vendorId` route
- Single price range confirmed: `price_range_min` / `price_range_max` display as "₱{min} – ₱{max} per visit" (decided in Story 4.2)
- All 24 existing tests pass — adding `name` to `VendorProfileModel` will require updating test fixtures

**Confirmed REAL files from Story 4.1/4.2:**
- `lib/features/vendor/domain/vendor_profile_model.dart` — `@immutable` class, fromJson/toJson, no `name` field yet
- `lib/features/vendor/data/vendor_repository.dart` — 4 methods, `SupabaseClient` injectable
- `lib/features/vendor/presentation/vendor_provider.dart` — `vendorRepositoryProvider` here
- `lib/features/vendor/presentation/vendor_notifier.dart` — `vendorOnboardingNotifierProvider` HERE (not in provider.dart)
- `supabase/migrations/002_create_vendor_extensions.sql` — schema includes `price_range_min`, `price_range_max`, `completed_jobs_count`

**Key architectural note:** Profile name is in `profiles.name`, NOT in `vendor_extensions`. The RLS policy `homeowner_read_active_vendors` on `vendor_extensions` allows homeowners to read non-suspended vendor rows. The `profiles` table has its own RLS (`users read/write their own row only`) — but the PostgREST embedded join (`profiles!inner(name)`) works via the service role context for reads when called from `vendor_extensions` joins. *(Verify this in Supabase if the join returns empty — may need a dedicated RLS policy for homeowner reading vendor profiles.)*

> ⚠️ **POTENTIAL RLS ISSUE:** The `profiles` table has `users read/write their own row only` as its base policy. When a homeowner queries `vendor_extensions?select=*,profiles!inner(name)`, the embedded `profiles` join might be blocked by that RLS policy. If this occurs during testing:
> - Add a separate RLS policy on `profiles` allowing homeowners to read vendor profiles: `CREATE POLICY "homeowner_read_vendor_profiles" ON public.profiles FOR SELECT USING (user_type = 'vendor')` — but this is migration work, not Flutter code.
> - Alternatively, store `vendor_name` as a denormalised column in `vendor_extensions` and populate it in `createVendorProfile` / update methods.
> - For the hackathon, the simplest fix: store name in `vendor_extensions` as a denormalised `vendor_name` column (requires a new migration). Raise this to the team before implementing.

---

### Git Intelligence Summary

- Branch naming pattern from previous stories: `epic0/role-selection`, `epic4/vendor-onboarding` → use `epic4/vendor-public-profile` for this story
- Tests committed alongside implementation (not separate PRs)
- Stories in `review` before merge

---

### Project Structure Notes

- Flutter project root: `spr_house_maintenance_tracker/` (inside repo root)
- Supabase directory: at REPO ROOT (not inside Flutter project)
- `lib/features/booking/` directory likely does NOT exist yet — create the full path when adding files
- `test/features/booking/` directory likely does NOT exist yet — create the full path for new test files
- `lib/features/vendor/presentation/widgets/.gitkeep` still present — leave it (no vendor widgets in this story)

### References

- Story AC: [Source: `_bmad-output/planning-artifacts/epics.md` — Epic 4, Story 4.3]
- `VendorCardWidget` spec: [Source: `_bmad-output/planning-artifacts/ux-design-specification.md` — VendorCardWidget, Component Implementation Strategy]
- Vendor profile screen (200dp hero): [Source: `_bmad-output/planning-artifacts/ux-design-specification.md` — Journey 2: Homeowner Booking Flow]
- `vendor_extensions` schema: [Source: `_bmad-output/planning-artifacts/architecture.md` — Data Architecture]
- RLS policy for homeowner vendor reads: [Source: `_bmad-output/planning-artifacts/architecture.md` — Authentication & Security]
- PostgREST join pattern: [Source: `_bmad-output/planning-artifacts/architecture.md` — API & Communication Patterns]
- Feature folder structure: [Source: `_bmad-output/planning-artifacts/architecture.md` — Structure Patterns]
- FutureProvider.family pattern: [Source: `_bmad-output/planning-artifacts/architecture.md` — State Management Patterns]
- Navigation pattern (push vs go): [Source: `_bmad-output/planning-artifacts/architecture.md` — Communication Patterns]
- Enforcement rules: [Source: `_bmad-output/planning-artifacts/architecture.md` — Enforcement Guidelines]
- Single price range decision: [Source: `_bmad-output/implementation-artifacts/4-2-vendor-price-range-and-qrph-setup.md` — Dev Notes: Critical Schema Clarification]
- Model patterns + test fixtures: [Source: `_bmad-output/implementation-artifacts/4-1-vendor-fast-onboarding-flow.md` — Dev Agent Record]
- Airbnb card visual spec: [Source: `_bmad-output/planning-artifacts/ux-design-specification.md` — Visual Design Foundation, Vendor photo sizing]

## Dev Agent Record

### Agent Model Used

claude-sonnet-4-6

### Debug Log References

No debug issues encountered. All tasks implemented cleanly on first pass.

### Completion Notes List

- Extended `VendorProfileModel` with required `name` field; `fromJson` handles optional `profiles` nested key (null-coalesces to `''`); `name` intentionally excluded from `toJson` since it lives in `profiles` table.
- Added `fetchVendorProfile(String vendorId)` to `VendorRepository` using PostgREST embedded join `profiles!inner(name)`; `PostgrestException` → `AppException` mapping follows existing pattern.
- Added `vendorProfileProvider` as `FutureProvider.family<VendorProfileModel, String>` — read-only, uses `ref.read` to avoid rebuild loops.
- Created `VendorCardWidget` in `lib/features/booking/presentation/widgets/` (Airbnb-style card, cross-feature model import from vendor domain is acceptable per architecture rules).
- Created `VendorProfileScreen` in `lib/features/booking/presentation/screens/` — 200dp hero photo, loading/error/data states, retry via `ref.invalidate`, Book CTA placeholder SnackBar for Story 3.2.
- Added `/homeowner/vendor/:vendorId` route to `app_router.dart`.
- All 57 tests pass (16 new tests added). Existing tests unaffected — `VendorProfileModel` constructor change is backward-safe because no existing tests construct the model directly.
- Removed unused `go_router` import from `vendor_profile_screen.dart` (back button handled by AppBar default `automaticallyImplyLeading: true`).

### File List

**New files:**
- `spr_house_maintenance_tracker/lib/features/booking/presentation/widgets/vendor_card_widget.dart`
- `spr_house_maintenance_tracker/lib/features/booking/presentation/screens/vendor_profile_screen.dart`
- `spr_house_maintenance_tracker/test/features/vendor/data/vendor_profile_fetch_test.dart`
- `spr_house_maintenance_tracker/test/features/booking/presentation/vendor_card_widget_test.dart`

**Modified files:**
- `spr_house_maintenance_tracker/lib/features/vendor/domain/vendor_profile_model.dart`
- `spr_house_maintenance_tracker/lib/features/vendor/data/vendor_repository.dart`
- `spr_house_maintenance_tracker/lib/features/vendor/presentation/vendor_provider.dart`
- `spr_house_maintenance_tracker/lib/core/router/app_router.dart`
- `_bmad-output/implementation-artifacts/sprint-status.yaml`
- `_bmad-output/implementation-artifacts/4-3-vendor-public-profile-display.md`

## Change Log

- 2026-03-04: Implemented Story 4.3 — Vendor Public Profile Display. Added `name` field to `VendorProfileModel`, `fetchVendorProfile` to repository with PostgREST join, `vendorProfileProvider` FutureProvider.family, `VendorCardWidget`, `VendorProfileScreen`, and `/homeowner/vendor/:vendorId` route. 16 new tests added, all 57 tests pass.
