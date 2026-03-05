# Story 4.2: Vendor Price Range & QRPH Setup

Status: done

<!-- Note: Validation is optional. Run validate-create-story for quality check before dev-story. -->

## Story

As a vendor,
I want to set my price range and upload my QRPH code,
so that homeowners know what to expect before booking and I can receive digital payments after jobs.

## Acceptance Criteria

1. **Given** I have just completed vendor onboarding (Story 4.1), **when** my profile is saved, **then** I am navigated to `/vendor/profile-setup` (the price + QRPH setup screen) instead of `/vendor/dashboard`. *(Requires one-line change to `vendor_onboarding_screen.dart`: `context.go('/vendor/profile-setup')`).*

2. **Given** I am on the vendor profile setup screen, **when** it loads, **then** I see a form with: Min Price (numeric, required if Max provided), Max Price (numeric, required if Min provided), and QRPH Code Photo (image picker, optional).

3. **Given** I enter a valid min price (e.g., ₱500) and max price (e.g., ₱1500) and tap "Save & Continue", **when** the form is submitted, **then** `vendor_extensions.price_range_min` and `vendor_extensions.price_range_max` are updated in Supabase and I am navigated to `/vendor/dashboard`.

4. **Given** I upload a QRPH code image (JPG or PNG), **when** the upload completes, **then** the image is stored in the `qrph-codes/` Supabase Storage bucket at path `vendor-{userId}.{extension}` and the public URL is saved to `vendor_extensions.qrph_url`.

5. **Given** I enter a min price greater than the max price (e.g., min=₱2000, max=₱500), **when** validation runs, **then** an inline error appears ("Min price must be less than max price") and the form is NOT submitted.

6. **Given** I enter only one price field (min without max or vice versa), **when** validation runs, **then** an inline error appears ("Both min and max prices are required together") and the form is NOT submitted.

7. **Given** I tap "Skip for now", **when** the action runs, **then** I am navigated directly to `/vendor/dashboard` without saving any data (price and QRPH remain null).

## Tasks / Subtasks

- [x] **Task 1: Create `qrph-codes/` Supabase Storage bucket** (AC: 4) *(Manual step — document SQL)*
  - [x] Document SQL to create bucket: `insert into storage.buckets (id, name, public) values ('qrph-codes', 'qrph-codes', false)`
  - [x] Document RLS policy: owner write (`auth.uid()::text = split_part(name, '-', 2)`); homeowner read when booking confirmed (deferred to booking story — set public=false for now)
  - [x] Note: bucket must be created in Supabase Studio before end-to-end testing

- [x] **Task 2: Extend `vendor_repository.dart`** (AC: 3, 4)
  - [x] Add method `updateVendorPricing({required String userId, required double? priceMin, required double? priceMax})` → updates `vendor_extensions` row via `.update().eq('id', userId)`
  - [x] Add method `uploadQrphCode(String userId, Uint8List imageBytes, String extension)` → uploads to `qrph-codes/vendor-{userId}.{extension}` with `upsert: true` → returns public URL string
  - [x] Catch `PostgrestException` → rethrow as `AppException`; catch `StorageException` → rethrow as `AppException`
  - [x] No new imports needed — `supabase_flutter` already imported in this file

- [x] **Task 3: Extend `vendor_notifier.dart` and `vendor_provider.dart`** (AC: 3, 4)
  - [x] Add method `submitPricingSetup({required String userId, required double? priceMin, required double? priceMax, XFile? qrphPhoto})` to `VendorOnboardingNotifier` — uploads QRPH (if provided) then calls `updateVendorPricing`; propagates `AppException`
  - [x] QRPH upload is optional — only call `uploadQrphCode` if `qrphPhoto != null`; pass `null` to `updateVendorPricing` for `qrphUrl` if not uploading (repo handles null qrph URL separately — do NOT include `qrph_url` in the pricing update payload unless a new URL was produced)
  - [x] Do NOT navigate inside the notifier — navigation via `ref.listen` in screen

- [x] **Task 4: Create `vendor_profile_setup_screen.dart`** (AC: 2, 3, 4, 5, 6, 7)
  - [x] Create `lib/features/vendor/presentation/screens/vendor_profile_setup_screen.dart`
  - [x] Use `ConsumerStatefulWidget`
  - [x] AppBar: `automaticallyImplyLeading: false`; title "Set Your Pricing"; no back button (arrived via `context.go()`)
  - [x] Min Price field: `TextField`, label `'Min Price (₱) *'`, `TextInputType.numberWithOptions(decimal: true)`, inline `errorText`
  - [x] Max Price field: `TextField`, label `'Max Price (₱) *'`, `TextInputType.numberWithOptions(decimal: true)`, inline `errorText`
  - [x] QRPH Upload: `OutlinedButton.icon` "Upload QRPH Code (optional)" → `ImagePicker().pickImage(source: ImageSource.gallery, imageQuality: 90)`; show filename text below button on selection (no CircleAvatar — QR codes are rectangles)
  - [x] Validation on submit: both prices provided OR both null; if both provided: min > 0, max > min
  - [x] Primary CTA: full-width `FilledButton` "Save & Continue" — disable + spinner while in-flight
  - [x] Secondary CTA: full-width `TextButton` "Skip for now" → `context.go('/vendor/dashboard')` immediately (no Supabase call)
  - [x] `ref.listen` on `vendorOnboardingNotifierProvider`: success → `context.go('/vendor/dashboard')`; error → error SnackBar
  - [x] Screen gets `userId` from `Supabase.instance.client.auth.currentUser!.id` before dispatching (same pattern as `vendor_onboarding_screen.dart`)
  - [x] Dispose `TextEditingController`s in `dispose()`

- [x] **Task 5: Update `app_router.dart` and `vendor_onboarding_screen.dart`** (AC: 1, 3, 7)
  - [x] In `app_router.dart`: change `/vendor/dashboard` placeholder to keep as-is; add new route `/vendor/profile-setup` → `const VendorProfileSetupScreen()`
  - [x] In `app_router.dart`: add import for `vendor_profile_setup_screen.dart`
  - [x] In `vendor_onboarding_screen.dart`: change `context.go('/vendor/dashboard')` to `context.go('/vendor/profile-setup')` in `ref.listen` success branch

- [x] **Task 6: Write tests** (AC: 3, 4, 5, 6)
  - [x] Create `test/features/vendor/data/vendor_pricing_repository_test.dart` — test `updateVendorPricing` updates correct fields; test `uploadQrphCode` calls storage with correct bucket/path; test `PostgrestException` → `AppException`; test null price fields are handled
  - [x] Create `test/features/vendor/presentation/vendor_pricing_notifier_test.dart` — test `submitPricingSetup()` transitions loading → data; test optional QRPH (no photo provided → no storage call); test error propagation

## Dev Notes

### Critical: Schema Clarification — Single Price Range (NOT per-service)

The `vendor_extensions` table has **one** `price_range_min` and **one** `price_range_max` column — not per-service-type. AC2 in the epics mentions "different price range per service type independently" but this contradicts the architecture-defined schema.

**Resolution for MVP/hackathon:** Implement as a **single overall price range** (e.g., "₱500 – ₱1500 per visit") applied across all services. Per-service pricing is a post-hackathon enhancement requiring schema changes. The UI label should say "Price Range per Visit" to avoid confusion.

This single range will display on the `VendorCardWidget` (Story 4.3) as `₱{min} – ₱{max} per visit`.

[Source: `_bmad-output/planning-artifacts/architecture.md` — Data Architecture, `vendor_extensions` table]

---

### Critical: Supabase Storage — `qrph-codes/` Bucket Setup (Manual)

Before testing end-to-end, create the bucket manually in Supabase Studio:

```sql
-- Create bucket (private — homeowner access controlled via bookings in a later story)
insert into storage.buckets (id, name, public)
values ('qrph-codes', 'qrph-codes', false);

-- Vendor can write their own QRPH code
create policy "qrph_owner_write"
  on storage.objects for insert
  with check (
    bucket_id = 'qrph-codes'
    and auth.uid()::text = split_part(name, '-', 2)
  );

-- Vendor can update/replace their QRPH code (upsert)
create policy "qrph_owner_update"
  on storage.objects for update
  using (
    bucket_id = 'qrph-codes'
    and auth.uid()::text = split_part(name, '-', 2)
  );

-- Anyone authenticated can read (homeowners need it at payment time)
-- Scoped to booking confirmation is deferred to booking story
create policy "qrph_authenticated_read"
  on storage.objects for select
  using (bucket_id = 'qrph-codes' and auth.role() = 'authenticated');
```

> ⚠️ `getPublicUrl()` requires the bucket to have `public = true` OR use `createSignedUrl()` for private buckets. For hackathon simplicity, set the bucket to **public** (`public = true`) so `getPublicUrl()` works without signed URL complexity. Adjust policies post-hackathon.

> ⚠️ File naming: `vendor-{userId}.{extension}` — same prefix pattern as `avatars/` bucket. For QR codes, common formats are PNG or JPG.

[Source: `_bmad-output/planning-artifacts/architecture.md` — Storage bucket policies]

---

### Critical: Extending `vendor_repository.dart` — Update & Upload Patterns

```dart
/// Updates price range on vendor_extensions.
/// Pass null to explicitly clear a price field.
/// Do NOT include qrph_url in this payload — managed separately.
Future<void> updateVendorPricing({
  required String userId,
  required double? priceMin,
  required double? priceMax,
}) async {
  try {
    await _supabase.from('vendor_extensions').update({
      'price_range_min': priceMin,
      'price_range_max': priceMax,
    }).eq('id', userId);
  } on PostgrestException catch (e) {
    throw AppException(code: e.code ?? 'db-error', message: e.message);
  }
}

/// Uploads QRPH code image to `qrph-codes/` bucket.
/// Returns public URL string.
Future<String> uploadQrphCode(
  String userId,
  Uint8List imageBytes,
  String extension,
) async {
  final path = 'vendor-$userId.$extension';
  try {
    await _supabase.storage.from('qrph-codes').uploadBinary(
      path,
      imageBytes,
      fileOptions: FileOptions(
        contentType: 'image/$extension',
        upsert: true,
      ),
    );
    return _supabase.storage.from('qrph-codes').getPublicUrl(path);
  } on StorageException catch (e) {
    throw AppException(code: 'storage-error', message: e.message);
  }
}
```

> ⚠️ The `updateVendorPricing` method uses `.update().eq()` — NOT `.insert()`. The `vendor_extensions` row already exists from Story 4.1 onboarding. Using `.insert()` will throw a duplicate key violation.

> ⚠️ Do NOT include `qrph_url` in the pricing update payload. Save it separately only when a new QRPH image was uploaded. Otherwise you'd overwrite an existing QRPH URL with null on every pricing save.

[Source: `_bmad-output/planning-artifacts/architecture.md` — Process Patterns, Error Handling]

---

### Critical: `VendorOnboardingNotifier.submitPricingSetup` Pattern

Extends the existing `VendorOnboardingNotifier` (same notifier provider reused — no new provider needed):

```dart
Future<void> submitPricingSetup({
  required String userId,
  required double? priceMin,
  required double? priceMax,
  XFile? qrphPhoto,
}) async {
  state = const AsyncLoading();
  state = await AsyncValue.guard(() async {
    // 1. Upload QRPH code if provided
    if (qrphPhoto != null) {
      final bytes = await qrphPhoto.readAsBytes();
      final extension = qrphPhoto.name.split('.').last.toLowerCase();
      final qrphUrl = await ref
          .read(vendorRepositoryProvider)
          .uploadQrphCode(userId, bytes, extension);

      // Save qrph_url separately
      await _supabase_NOT_VALID — use repository only!
      // ✅ Correct: add updateQrphUrl method to repo, or include in updateVendorPricing when URL available
    }

    // 2. Update price range (always — even if null to clear)
    await ref.read(vendorRepositoryProvider).updateVendorPricing(
      userId: userId,
      priceMin: priceMin,
      priceMax: priceMax,
    );
  });
}
```

> ⚠️ **QRPH URL persistence:** When a QRPH photo is uploaded, the resulting URL needs to be saved to `vendor_extensions.qrph_url`. The simplest approach: add `qrphUrl` as an optional parameter to `updateVendorPricing` and include it in the update payload only when non-null.

**Revised repository method signature:**

```dart
Future<void> updateVendorProfile({
  required String userId,
  double? priceMin,
  double? priceMax,
  String? qrphUrl,        // only included in payload when non-null
}) async {
  final payload = <String, dynamic>{
    'price_range_min': priceMin,
    'price_range_max': priceMax,
  };
  if (qrphUrl != null) payload['qrph_url'] = qrphUrl;

  try {
    await _supabase.from('vendor_extensions').update(payload).eq('id', userId);
  } on PostgrestException catch (e) {
    throw AppException(code: e.code ?? 'db-error', message: e.message);
  }
}
```

**Revised notifier:**

```dart
Future<void> submitPricingSetup({
  required String userId,
  required double? priceMin,
  required double? priceMax,
  XFile? qrphPhoto,
}) async {
  state = const AsyncLoading();
  state = await AsyncValue.guard(() async {
    String? qrphUrl;
    if (qrphPhoto != null) {
      final bytes = await qrphPhoto.readAsBytes();
      final extension = qrphPhoto.name.split('.').last.toLowerCase();
      qrphUrl = await ref
          .read(vendorRepositoryProvider)
          .uploadQrphCode(userId, bytes, extension);
    }

    await ref.read(vendorRepositoryProvider).updateVendorProfile(
      userId: userId,
      priceMin: priceMin,
      priceMax: priceMax,
      qrphUrl: qrphUrl, // null = don't overwrite existing URL
    );
  });
}
```

> ⚠️ **Naming:** Call the combined update method `updateVendorProfile` (not `updateVendorPricing`) since it now handles both price and QRPH URL. This is more consistent and avoids a second DB round-trip.

[Source: `_bmad-output/planning-artifacts/architecture.md` — State Management Patterns, Process Patterns]

---

### Critical: `VendorProfileSetupScreen` — Key Implementation Points

```dart
class VendorProfileSetupScreen extends ConsumerStatefulWidget {
  const VendorProfileSetupScreen({super.key});
  // ...
}

class _VendorProfileSetupScreenState
    extends ConsumerState<VendorProfileSetupScreen> {
  final _minPriceController = TextEditingController();
  final _maxPriceController = TextEditingController();
  XFile? _qrphPhoto;
  String? _minPriceError;
  String? _maxPriceError;

  @override
  void dispose() {
    _minPriceController.dispose();
    _maxPriceController.dispose();
    super.dispose();
  }

  bool _validate() {
    final minText = _minPriceController.text.trim();
    final maxText = _maxPriceController.text.trim();
    final minEmpty = minText.isEmpty;
    final maxEmpty = maxText.isEmpty;

    // Both empty is OK (skip pricing)
    if (minEmpty && maxEmpty) {
      setState(() {
        _minPriceError = null;
        _maxPriceError = null;
      });
      return true;
    }

    // One filled, one empty
    if (minEmpty != maxEmpty) {
      setState(() {
        _minPriceError = minEmpty ? 'Both min and max prices are required together' : null;
        _maxPriceError = maxEmpty ? 'Both min and max prices are required together' : null;
      });
      return false;
    }

    // Both filled — validate values
    final min = double.tryParse(minText);
    final max = double.tryParse(maxText);

    setState(() {
      _minPriceError = min == null || min <= 0 ? 'Enter a valid price' : null;
      _maxPriceError = max == null || max <= 0 ? 'Enter a valid price' : null;
    });

    if (_minPriceError != null || _maxPriceError != null) return false;

    if (min! >= max!) {
      setState(() => _minPriceError = 'Min price must be less than max price');
      return false;
    }

    return true;
  }

  Future<void> _pickQrphPhoto() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 90,  // QR codes need higher quality to scan
    );
    if (picked != null) setState(() => _qrphPhoto = picked);
  }
}
```

> ⚠️ **imageQuality: 90** for QRPH codes (not 80 like profile photos) — QR codes must be scannable; higher quality preserves pattern fidelity.

> ⚠️ No `CircleAvatar` for QRPH preview — QR codes are square/rectangular. Show filename text instead: `Text(_qrphPhoto!.name, style: textTheme.bodySmall)`.

> ⚠️ **Skip button:** Use `TextButton` (not `OutlinedButton`) to visually de-emphasize skip vs save. `FilledButton` = primary action; `TextButton` = low-priority action.

[Source: `_bmad-output/planning-artifacts/ux-design-specification.md` — Form Patterns, Button Hierarchy]

---

### Critical: Router Changes

```dart
// In app_router.dart, add:
import '../../features/vendor/presentation/screens/vendor_profile_setup_screen.dart';

GoRoute(
  path: '/vendor/profile-setup',
  builder: (context, state) => const VendorProfileSetupScreen(),
),

// In vendor_onboarding_screen.dart, change ref.listen success branch:
// BEFORE (Story 4.1):
if (next.hasValue && !next.isLoading) {
  context.go('/vendor/dashboard');  // ← change this
}
// AFTER (Story 4.2):
if (next.hasValue && !next.isLoading) {
  context.go('/vendor/profile-setup');  // ← updated
}
```

> ⚠️ This modifies `vendor_onboarding_screen.dart` (a Story 4.1 file currently in `review` status). This is intentional — Story 4.2 extends the onboarding flow. The change is minimal (one string).

[Source: `_bmad-output/planning-artifacts/architecture.md` — Frontend Architecture, Navigation]

---

### Critical: Numeric Input Pattern

```dart
TextField(
  controller: _minPriceController,
  keyboardType: const TextInputType.numberWithOptions(decimal: true),
  decoration: InputDecoration(
    labelText: 'Min Price (₱) *',
    prefixText: '₱ ',
    errorText: _minPriceError,
  ),
),
```

Use `double.tryParse(text.trim())` to convert to number — returns `null` on invalid input. Never use `int.parse()` for currency (decimals needed).

---

### Architecture Compliance — Mandatory Rules

| Rule | Correct | Wrong |
|---|---|---|
| Supabase calls | Only in `vendor_repository.dart` | Never in notifier or screens |
| QRPH vs avatar upload | `qrph-codes/` bucket | Never mix with `avatars/` bucket |
| Update pattern | `.update({...}).eq('id', userId)` | Never `.insert()` — row already exists |
| Optional payload | Include `qrph_url` in update payload only when non-null | Never overwrite existing URL with null |
| Numeric parsing | `double.tryParse()` | Never `int.parse()` for currency |
| Navigation | `context.go()` in `ref.listen` | Never inside notifier |
| Provider reuse | Reuse `vendorOnboardingNotifierProvider` | Don't create a separate provider for this screen |

[Source: `_bmad-output/planning-artifacts/architecture.md` — Enforcement Guidelines]

---

### Library / Framework Requirements

| Package | Version | Use in this story |
|---|---|---|
| `supabase_flutter` | ^2.12.0 | PostgREST update, Storage uploadBinary, `PostgrestException`, `StorageException` |
| `flutter_riverpod` | ^2.x | `AsyncNotifier`, `ConsumerStatefulWidget`, `ref.listen` |
| `go_router` | ^14.x | `context.go('/vendor/dashboard')`, `context.go('/vendor/profile-setup')` |
| `image_picker` | ^1.x | `ImagePicker().pickImage()`, `XFile`, `readAsBytes()` |

> All packages already in `pubspec.yaml`. No new dependencies required.

---

### File Structure Requirements — What to Create / Modify

**Create (new files):**
```
lib/features/vendor/presentation/screens/vendor_profile_setup_screen.dart
test/features/vendor/data/vendor_pricing_repository_test.dart
test/features/vendor/presentation/vendor_pricing_notifier_test.dart
```

**Modify (existing files):**
```
lib/features/vendor/data/vendor_repository.dart        ← add updateVendorProfile, uploadQrphCode
lib/features/vendor/presentation/vendor_notifier.dart  ← add submitPricingSetup method
lib/core/router/app_router.dart                        ← add /vendor/profile-setup route
lib/features/vendor/presentation/screens/vendor_onboarding_screen.dart  ← change nav to /vendor/profile-setup
```

[Source: `_bmad-output/planning-artifacts/architecture.md` — Complete Project Directory Structure]

---

### Testing Requirements

**`test/features/vendor/data/vendor_pricing_repository_test.dart`:**
- Reuse `_CapturingUpdateBuilder` / `_CompletedFilterBuilder` fakes from `vendor_repository_test.dart` (copy into this file or refactor to shared helpers)
- Test `updateVendorProfile()`: verify correct fields sent (price_range_min, price_range_max)
- Test `updateVendorProfile()` with qrphUrl: verify `qrph_url` included in payload
- Test `updateVendorProfile()` without qrphUrl: verify `qrph_url` NOT in payload
- Test `uploadQrphCode()`: verify `qrph-codes` bucket used (not `avatars`)
- Test `PostgrestException` → `AppException` mapping

**`test/features/vendor/presentation/vendor_pricing_notifier_test.dart`:**
- Use `ProviderContainer` with `vendorRepositoryProvider` override (same pattern as `vendor_notifier_test.dart`)
- Use `_FakeVendorRepository` extended with `updateVendorProfile` and `uploadQrphCode` overrides
- Test `submitPricingSetup()` with photo: `AsyncLoading` → `AsyncData`
- Test `submitPricingSetup()` without photo: `AsyncLoading` → `AsyncData`; verify `uploadQrphCode` not called
- Test error propagation from `updateVendorProfile`

**Testing patterns (from Story 4.1 learnings):**
- `registerFallbackValue(Uint8List(0))` + `registerFallbackValue(const FileOptions())` in `setUpAll`
- `_FakeXFile` for mock photo
- `await container.read(vendorOnboardingNotifierProvider.future)` before listening
- Screen gets `userId` directly; notifier receives it as parameter (no `Supabase.instance` in notifier)

[Source: Story 4.1 Dev Agent Record — Debug Log (Uint8List fallback, userId pattern)]

---

### Previous Story Intelligence

**From Story 4.1 (Vendor Fast Onboarding):**
- `vendor_repository.dart` EXISTS at `lib/features/vendor/data/vendor_repository.dart` — EXTEND it, do NOT recreate
- `vendor_notifier.dart` EXISTS — add `submitPricingSetup` method to `VendorOnboardingNotifier`; keep `submitOnboarding` intact
- `vendor_provider.dart` EXISTS — no changes needed; reuse `vendorOnboardingNotifierProvider`
- `vendorRepositoryProvider` in `vendor_provider.dart`; `vendorOnboardingNotifierProvider` in `vendor_notifier.dart`
- `VendorProfileModel` at `lib/features/vendor/domain/vendor_profile_model.dart` — no changes needed
- `vendor_onboarding_screen.dart` — modify only the nav target in `ref.listen` (`/vendor/dashboard` → `/vendor/profile-setup`)
- `registerFallbackValue(Uint8List(0))` pattern required for Mocktail — copy to new test file
- Supabase storage mock: `MockSupabaseStorageClient` + `MockStorageFileApi` — copy from vendor_repository_test.dart
- `.update().eq()` chain requires `_CompletedFilterBuilder.eq()` returning `this` — already established pattern
- `_CapturingUpdateBuilder` fake established in vendor_repository_test — reuse pattern

**Confirmed REAL files from Story 4.1:**
- `lib/features/vendor/data/vendor_repository.dart` — has `uploadProfilePhoto` + `createVendorProfile`
- `lib/features/vendor/presentation/vendor_notifier.dart` — has `submitOnboarding(userId, name, services, phone, photo)`
- `lib/features/vendor/presentation/vendor_provider.dart` — has `vendorRepositoryProvider` + `vendorOnboardingNotifierProvider`
- `lib/core/router/app_router.dart` — has `/vendor` → `VendorOnboardingScreen`, `/vendor/dashboard` → placeholder
- `supabase/migrations/002_create_vendor_extensions.sql` — `price_range_min`, `price_range_max`, `qrph_url` columns ALREADY EXIST

**Key deviation from story spec to maintain:** `submitOnboarding()` takes `userId` as parameter (not read from `Supabase.instance` in notifier) — carry forward this same pattern for `submitPricingSetup()`.

---

### Git Intelligence Summary

- Branch naming pattern: `epic0/role-selection`, `test-architecture` → use `epic4/vendor-pricing-qrph` for this story
- Tests committed alongside implementation (not separate PRs)
- Stories reviewed before merge

---

### Project Structure Notes

- Flutter project root: `spr_house_maintenance_tracker/` (inside repo root)
- Supabase directory: at REPO ROOT (not inside Flutter project)
- `qrph-codes/` bucket must be created manually in Supabase Studio before end-to-end testing
- No new directories needed — all vendor subdirectories exist from Story 4.1
- `lib/features/vendor/presentation/widgets/.gitkeep` still present — leave in place (widgets folder used in future stories)

### References

- Story AC: [Source: `_bmad-output/planning-artifacts/epics.md` — Epic 4, Story 4.2]
- vendor_extensions schema: [Source: `_bmad-output/planning-artifacts/architecture.md` — Data Architecture]
- Storage bucket policies: [Source: `_bmad-output/planning-artifacts/architecture.md` — Authentication & Security]
- Single price range decision: [Source: `_bmad-output/planning-artifacts/architecture.md` — Data Architecture, `vendor_extensions` table]
- Feature folder structure: [Source: `_bmad-output/planning-artifacts/architecture.md` — Structure Patterns]
- AsyncNotifier pattern: [Source: `_bmad-output/planning-artifacts/architecture.md` — State Management Patterns]
- Image upload pattern: [Source: `_bmad-output/planning-artifacts/architecture.md` — Process Patterns]
- Navigation pattern: [Source: `_bmad-output/planning-artifacts/architecture.md` — Communication Patterns]
- Enforcement rules: [Source: `_bmad-output/planning-artifacts/architecture.md` — Enforcement Guidelines]
- Button hierarchy + form patterns: [Source: `_bmad-output/planning-artifacts/ux-design-specification.md` — Form Patterns, Button Hierarchy]
- QR code image quality consideration: [Source: `_bmad-output/planning-artifacts/ux-design-specification.md` — Camera access for QRPH codes]
- Previous story patterns: [Source: `_bmad-output/implementation-artifacts/4-1-vendor-fast-onboarding-flow.md` — Dev Agent Record]

## Dev Agent Record

### Agent Model Used

claude-sonnet-4-6

### Debug Log References

No blockers encountered. All implementation followed Dev Notes patterns exactly.

### Completion Notes List

- Implemented `updateVendorProfile` (renamed from `updateVendorPricing` per Dev Notes guidance) with conditional `qrph_url` inclusion — prevents overwriting existing URL on plain pricing saves.
- Implemented `uploadQrphCode` targeting `qrph-codes/` bucket with upsert, imageQuality 90 for QR code fidelity.
- Added `submitPricingSetup` to existing `VendorOnboardingNotifier` — reuses provider, no new provider created.
- Created `VendorProfileSetupScreen` with full validation (both-or-neither pricing, min < max), filename display for QRPH selection, FilledButton primary CTA + TextButton skip.
- Updated `vendor_onboarding_screen.dart` nav target: `/vendor/dashboard` → `/vendor/profile-setup` (one-line change as specified in AC1).
- Added `/vendor/profile-setup` route to `app_router.dart`.
- All 24 tests pass (8 repo + 5 notifier + 11 regression from Story 4.1).

### File List

**Created:**
- `spr_house_maintenance_tracker/lib/features/vendor/presentation/screens/vendor_profile_setup_screen.dart`
- `spr_house_maintenance_tracker/test/features/vendor/data/vendor_pricing_repository_test.dart`
- `spr_house_maintenance_tracker/test/features/vendor/presentation/vendor_pricing_notifier_test.dart`

**Modified:**
- `spr_house_maintenance_tracker/lib/features/vendor/data/vendor_repository.dart`
- `spr_house_maintenance_tracker/lib/features/vendor/presentation/vendor_notifier.dart`
- `spr_house_maintenance_tracker/lib/core/router/app_router.dart`
- `spr_house_maintenance_tracker/lib/features/vendor/presentation/screens/vendor_onboarding_screen.dart`
- `_bmad-output/implementation-artifacts/4-2-vendor-price-range-and-qrph-setup.md`
- `_bmad-output/implementation-artifacts/sprint-status.yaml`

**Change Log:**
- 2026-03-04: Implemented Story 4.2 — vendor price range setup screen, QRPH code upload, repository and notifier extensions, router updates, 13 new tests.
