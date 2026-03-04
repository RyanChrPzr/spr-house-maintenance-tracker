# Story 4.1: Vendor Fast Onboarding Flow

Status: review

<!-- Note: Validation is optional. Run validate-create-story for quality check before dev-story. -->

## Story

As a service vendor,
I want to sign up in under 2 minutes with my name, service types, contact number, and profile photo,
so that I can start receiving job notifications immediately without a lengthy registration process.

## Acceptance Criteria

1. **Given** I have selected "I am a Vendor" during registration (Story 0.2 navigates to `/vendor`), **when** the vendor onboarding screen opens, **then** I see a form with four fields: Full Name (required), Service Types (FilterChip multi-select, ≥1 required), Contact Number (required), Profile Photo (required).

2. **Given** I complete all required fields and tap "Start Receiving Jobs", **when** my profile is submitted, **then** a `vendor_extensions` row is created with `is_suspended = false` and `is_available = true`; my profile photo is uploaded to the `avatars/` Supabase Storage bucket and the public URL is saved to `vendor_extensions.avatar_url`; my profile is immediately visible to homeowners.

3. **Given** the full onboarding process runs, **when** measured end-to-end, **then** it completes in under 2 minutes (4 fields + one photo picker interaction).

4. **Given** I select multiple service types, **when** I tap each `FilterChip`, **then** each chip toggles independently and all selected service types are saved to `vendor_extensions.services[]` as a PostgreSQL text array.

5. **Given** I skip required fields and tap "Start Receiving Jobs", **when** validation runs, **then** inline error messages appear below each missing/invalid field; the form is NOT submitted and no Supabase calls are made.

6. **Given** I submit the form successfully, **when** the `vendor_extensions` row is created, **then** I am navigated to `/vendor/dashboard` via `context.go('/vendor/dashboard')`.

## Tasks / Subtasks

- [x] **Task 1: Create Supabase migration `002_create_vendor_extensions.sql`** (AC: 2, 4)
  - [x] Create `supabase/migrations/002_create_vendor_extensions.sql`
  - [x] Columns: `id (uuid PK references profiles.id ON DELETE CASCADE)`, `services (text[] NOT NULL DEFAULT '{}')`, `price_range_min (numeric)`, `price_range_max (numeric)`, `qrph_url (text)`, `avatar_url (text)`, `is_available (boolean NOT NULL DEFAULT true)`, `is_suspended (boolean NOT NULL DEFAULT false)`, `completed_jobs_count (integer NOT NULL DEFAULT 0)`, `created_at (timestamptz NOT NULL DEFAULT now())`
  - [x] Enable RLS on `vendor_extensions`
  - [x] RLS policy: vendors read/write own row (`auth.uid() = id`); homeowners read all non-suspended rows (for Story 4.3 vendor browse)

- [x] **Task 2: Create `vendor_profile_model.dart`** (AC: 2, 4)
  - [x] Create `lib/features/vendor/domain/vendor_profile_model.dart`
  - [x] Fields: `id` (String), `services` (List<String>), `priceRangeMin` (double?), `priceRangeMax` (double?), `qrphUrl` (String?), `avatarUrl` (String?), `isAvailable` (bool), `isSuspended` (bool), `completedJobsCount` (int)
  - [x] `fromJson()` factory reading Supabase `vendor_extensions` row (`snake_case` → `camelCase`)
  - [x] `toJson()` for inserts/updates
  - [x] All fields `final`; constructor `const` where possible

- [x] **Task 3: Create `vendor_repository.dart`** (AC: 2, 4, 5)
  - [x] Create `lib/features/vendor/data/vendor_repository.dart`
  - [x] Method `createVendorProfile({required String userId, required List<String> services, required String avatarUrl, required String name, required String phone})` → inserts into `vendor_extensions` and updates `profiles` (name, phone, avatar_url)
  - [x] Method `uploadProfilePhoto(String userId, Uint8List imageBytes, String extension)` → uploads to `avatars/vendor-{userId}.{extension}` → returns public URL string
  - [x] Catch `PostgrestException` → rethrow as `AppException`; catch `StorageException` → rethrow as `AppException`
  - [x] Optional `supabaseClient` constructor param for testability (pattern from auth_repository.dart)
  - [x] ONLY this file imports `supabase_flutter` in the vendor feature

- [x] **Task 4: Create `vendor_notifier.dart` and `vendor_provider.dart`** (AC: 2, 5)
  - [x] Create `lib/features/vendor/presentation/vendor_notifier.dart`
  - [x] `VendorOnboardingNotifier extends AsyncNotifier<void>` — action-oriented; `build()` returns `Future.value()`
  - [x] Method `submitOnboarding({required String userId, required String name, required List<String> services, required String phone, required XFile photo})` — calls repository upload then createVendorProfile; propagates `AppException`
  - [x] Do NOT navigate inside the notifier — navigation via `ref.listen` in screen
  - [x] Create `lib/features/vendor/presentation/vendor_provider.dart`
  - [x] `final vendorRepositoryProvider = Provider<VendorRepository>((ref) => VendorRepository());`
  - [x] `final vendorOnboardingNotifierProvider = AsyncNotifierProvider<VendorOnboardingNotifier, void>(VendorOnboardingNotifier.new);`

- [x] **Task 5: Create `vendor_onboarding_screen.dart`** (AC: 1, 2, 3, 4, 5, 6)
  - [x] Create `lib/features/vendor/presentation/screens/vendor_onboarding_screen.dart`
  - [x] Use `ConsumerStatefulWidget` (needs controllers, photo state, chip state, error state)
  - [x] AppBar: no back button (arrived via `context.go()`); title "Set Up Your Profile"
  - [x] Full Name: `TextField`, label `'Full Name *'`, `TextInputType.name`
  - [x] Service Types: `FilterChip` row (horizontal `Wrap` widget) using `AppConstants.serviceTypes`; chips toggle independently; ≥1 required
  - [x] Contact Number: `TextField`, label `'Contact Number *'`, `TextInputType.phone`
  - [x] Profile Photo: `OutlinedButton.icon` "Upload Photo" → `ImagePicker().pickImage(source: ImageSource.gallery, imageQuality: 80)`; show thumbnail `CircleAvatar` on selection (80dp radius)
  - [x] Validation on submit only: all 4 fields required; services list non-empty; show `errorText` inline or `SnackBar` for photo
  - [x] Full-width `FilledButton` at bottom: "Start Receiving Jobs" (16dp padding)
  - [x] While in-flight: disable button + `CircularProgressIndicator.adaptive()` inside button
  - [x] `ref.listen` on `vendorOnboardingNotifierProvider`: success → `context.go('/vendor/dashboard')`; error → re-enable + error `SnackBar`
  - [x] Dispose `TextEditingController`s in `dispose()`

- [x] **Task 6: Update `app_router.dart`** (AC: 6)
  - [x] Change `/vendor` route builder to `const VendorOnboardingScreen()` (replacing "Vendor Dashboard — Epic 4" placeholder)
  - [x] Add `/vendor/dashboard` route → placeholder `Scaffold(body: Center(child: Text('Vendor Dashboard — Story 5.x')))`
  - [x] Add import for `vendor_onboarding_screen.dart`

- [x] **Task 7: Write tests** (AC: 2, 4, 5)
  - [x] Create `test/features/vendor/data/vendor_repository_test.dart` — mock Supabase client; test `createVendorProfile` inserts correct row; test `uploadProfilePhoto` calls storage with correct path; test `PostgrestException` surfaces as `AppException`
  - [x] Create `test/features/vendor/presentation/vendor_notifier_test.dart` — test `submitOnboarding()` transitions loading → data; test error propagation from repository

## Dev Notes

### Critical: `vendor_extensions` Table Schema (Migration 002)

```sql
-- Migration: 002_create_vendor_extensions.sql
-- Vendor-specific profile data. Separate from profiles to avoid nullable columns on homeowner rows.

create table if not exists public.vendor_extensions (
  id                    uuid        primary key references public.profiles(id) on delete cascade,
  services              text[]      not null default '{}',
  price_range_min       numeric,
  price_range_max       numeric,
  qrph_url              text,
  avatar_url            text,
  is_available          boolean     not null default true,
  is_suspended          boolean     not null default false,
  completed_jobs_count  integer     not null default 0,
  created_at            timestamptz not null default now()
);

-- Enable Row Level Security
alter table public.vendor_extensions enable row level security;

-- Vendors can read/write their own row
create policy "vendor_own_extensions"
  on public.vendor_extensions
  for all
  using (auth.uid() = id)
  with check (auth.uid() = id);

-- Homeowners can read all non-suspended vendor rows (for vendor browse in Story 3.1)
create policy "homeowner_read_active_vendors"
  on public.vendor_extensions
  for select
  using (
    is_suspended = false
    and exists (
      select 1 from public.profiles
      where profiles.id = auth.uid()
        and profiles.user_type = 'homeowner'
    )
  );
```

> **Run order:** Apply after `001_create_profiles.sql`. The `id` column references `profiles.id` — profiles table must exist first.

[Source: `_bmad-output/planning-artifacts/architecture.md` — Data Architecture, RLS Policy Strategy]

---

### Critical: `VendorProfileModel` — Full Pattern

```dart
import 'package:flutter/foundation.dart';

@immutable
class VendorProfileModel {
  const VendorProfileModel({
    required this.id,
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
  final List<String> services;
  final double? priceRangeMin;
  final double? priceRangeMax;
  final String? qrphUrl;
  final String? avatarUrl;
  final bool isAvailable;
  final bool isSuspended;
  final int completedJobsCount;

  factory VendorProfileModel.fromJson(Map<String, dynamic> json) {
    return VendorProfileModel(
      id: json['id'] as String,
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

> ⚠️ `services` is a PostgreSQL `text[]` array. Supabase returns it as a Dart `List<dynamic>` — always cast with `List<String>.from(...)`.

[Source: `_bmad-output/planning-artifacts/architecture.md` — Data Architecture, Format Patterns]

---

### Critical: `vendor_repository.dart` — Full Pattern

```dart
import 'dart:typed_data';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/exceptions/app_exception.dart';
import '../domain/vendor_profile_model.dart';

class VendorRepository {
  VendorRepository({SupabaseClient? supabaseClient})
      : _supabase = supabaseClient ?? Supabase.instance.client;

  final SupabaseClient _supabase;

  /// Uploads profile photo to `avatars/` bucket; returns public URL.
  /// File path convention: `vendor-{userId}.{extension}`
  Future<String> uploadProfilePhoto(
    String userId,
    Uint8List imageBytes,
    String extension,
  ) async {
    final path = 'vendor-$userId.$extension';
    try {
      await _supabase.storage.from('avatars').uploadBinary(
        path,
        imageBytes,
        fileOptions: FileOptions(contentType: 'image/$extension'),
      );
      return _supabase.storage.from('avatars').getPublicUrl(path);
    } on StorageException catch (e) {
      throw AppException(code: 'storage-error', message: e.message);
    }
  }

  /// Creates the vendor_extensions row and updates the profiles row.
  /// Must be called AFTER uploadProfilePhoto — pass the returned avatarUrl.
  Future<void> createVendorProfile({
    required String userId,
    required List<String> services,
    required String avatarUrl,
    required String name,
    required String phone,
  }) async {
    try {
      // Insert vendor_extensions row (id references profiles.id)
      await _supabase.from('vendor_extensions').insert({
        'id': userId,
        'services': services,
        'avatar_url': avatarUrl,
        'is_available': true,
        'is_suspended': false,
        'completed_jobs_count': 0,
      });

      // Update profiles with name, phone, avatar_url
      await _supabase.from('profiles').update({
        'name': name,
        'phone': phone,
        'avatar_url': avatarUrl,
      }).eq('id', userId);
    } on PostgrestException catch (e) {
      throw AppException(code: e.code ?? 'db-error', message: e.message);
    }
  }
}
```

> ⚠️ **Storage API:** `uploadBinary()` for `Uint8List`. Use `upload()` only for `File` (dart:io). On mobile with `image_picker`, read bytes with `XFile.readAsBytes()`.

> ⚠️ **Bucket setup (manual):** The `avatars/` bucket must be created in Supabase Storage with public access. Run in Supabase Studio before testing:
> ```sql
> insert into storage.buckets (id, name, public) values ('avatars', 'avatars', true);
> create policy "avatar_public_read" on storage.objects for select using (bucket_id = 'avatars');
> create policy "avatar_owner_write" on storage.objects for insert with check (bucket_id = 'avatars' and auth.uid()::text = (storage.foldername(name))[1]);
> ```
> Or use the Supabase Studio UI: Storage → New Bucket → `avatars` → Public = ON.

[Source: `_bmad-output/planning-artifacts/architecture.md` — Process Patterns, Image Upload]

---

### Critical: `VendorOnboardingNotifier` — AsyncNotifier Pattern

```dart
import 'dart:typed_data';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'vendor_provider.dart';

class VendorOnboardingNotifier extends AsyncNotifier<void> {
  @override
  Future<void> build() async {}

  Future<void> submitOnboarding({
    required String name,
    required List<String> services,
    required String phone,
    required XFile photo,
  }) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final userId = Supabase.instance.client.auth.currentUser!.id;
      final bytes = await photo.readAsBytes();
      final extension = photo.name.split('.').last.toLowerCase();

      final avatarUrl = await ref
          .read(vendorRepositoryProvider)
          .uploadProfilePhoto(userId, bytes, extension);

      await ref.read(vendorRepositoryProvider).createVendorProfile(
        userId: userId,
        services: services,
        avatarUrl: avatarUrl,
        name: name,
        phone: phone,
      );
    });
  }
}
```

> ⚠️ **AsyncValue.guard** wraps all exceptions as `AsyncError`. The notifier NEVER calls `context.go()` — navigation is handled in the screen's `ref.listen` callback.

> ⚠️ `Supabase.instance.client.auth.currentUser` — safe to call here because the user is authenticated (they just completed registration + role selection in Story 0.2). If `currentUser` is null, the flow was corrupted upstream.

[Source: `_bmad-output/planning-artifacts/architecture.md` — State Management Patterns]

---

### Critical: `vendor_onboarding_screen.dart` — Key Implementation Points

```dart
// ConsumerStatefulWidget — needs local state for controllers, chips, photo
class VendorOnboardingScreen extends ConsumerStatefulWidget {
  const VendorOnboardingScreen({super.key});
  // ...
}

class _VendorOnboardingScreenState extends ConsumerState<VendorOnboardingScreen> {
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final Set<String> _selectedServices = {};
  XFile? _selectedPhoto;
  String? _nameError;
  String? _phoneError;
  String? _servicesError;

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _pickPhoto() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,   // reduce upload size
      maxWidth: 800,
    );
    if (picked != null) {
      setState(() => _selectedPhoto = picked);
    }
  }

  bool _validate() {
    setState(() {
      _nameError = _nameController.text.trim().isEmpty ? 'Full name is required' : null;
      _phoneError = _phoneController.text.trim().isEmpty ? 'Contact number is required' : null;
      _servicesError = _selectedServices.isEmpty ? 'Select at least one service type' : null;
    });
    if (_selectedPhoto == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please upload a profile photo')),
      );
    }
    return _nameError == null &&
        _phoneError == null &&
        _servicesError == null &&
        _selectedPhoto != null;
  }

  @override
  Widget build(BuildContext context) {
    // ref.listen — navigation + error handling
    ref.listen<AsyncValue<void>>(vendorOnboardingNotifierProvider, (_, next) {
      if (next.hasError) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.error.toString()),
            backgroundColor: AppConstants.statusError,
          ),
        );
      }
      if (next.hasValue && !next.isLoading) {
        context.go('/vendor/dashboard');
      }
    });

    final isLoading = ref.watch(vendorOnboardingNotifierProvider).isLoading;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Set Up Your Profile'),
        automaticallyImplyLeading: false, // no back — arrived via context.go()
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Full Name
            TextField(
              controller: _nameController,
              keyboardType: TextInputType.name,
              decoration: InputDecoration(
                labelText: 'Full Name *',
                errorText: _nameError,
              ),
            ),
            const SizedBox(height: 16),

            // Service Types (FilterChip multi-select)
            Text('Service Types *', style: Theme.of(context).textTheme.labelLarge),
            if (_servicesError != null)
              Text(_servicesError!, style: TextStyle(color: AppConstants.statusError, fontSize: 12)),
            Wrap(
              spacing: 8,
              children: AppConstants.serviceTypes.map((type) {
                final selected = _selectedServices.contains(type);
                return FilterChip(
                  label: Text(type),
                  selected: selected,
                  onSelected: (val) {
                    setState(() {
                      if (val) {
                        _selectedServices.add(type);
                      } else {
                        _selectedServices.remove(type);
                      }
                      _servicesError = null; // clear on change
                    });
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 16),

            // Contact Number
            TextField(
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              decoration: InputDecoration(
                labelText: 'Contact Number *',
                errorText: _phoneError,
              ),
            ),
            const SizedBox(height: 16),

            // Profile Photo
            if (_selectedPhoto != null)
              Center(
                child: FutureBuilder<Uint8List>(
                  future: _selectedPhoto!.readAsBytes(),
                  builder: (_, snap) => snap.hasData
                      ? CircleAvatar(
                          radius: 40,
                          backgroundImage: MemoryImage(snap.data!),
                        )
                      : const CircleAvatar(radius: 40, child: Icon(Icons.person)),
                ),
              ),
            const SizedBox(height: 8),
            OutlinedButton.icon(
              onPressed: _pickPhoto,
              icon: const Icon(Icons.camera_alt),
              label: Text(_selectedPhoto == null ? 'Upload Photo *' : 'Change Photo'),
            ),

            const SizedBox(height: 32),

            // Submit CTA — full width, anchored at bottom of form
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: isLoading
                    ? null
                    : () {
                        if (_validate()) {
                          ref.read(vendorOnboardingNotifierProvider.notifier).submitOnboarding(
                            name: _nameController.text.trim(),
                            services: _selectedServices.toList(),
                            phone: _phoneController.text.trim(),
                            photo: _selectedPhoto!,
                          );
                        }
                      },
                child: isLoading
                    ? const CircularProgressIndicator.adaptive()
                    : const Text('Start Receiving Jobs'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
```

> ⚠️ **`automaticallyImplyLeading: false`** — vendor onboarding is reached via `context.go('/vendor')` from role selection. There is no back button. The stack was replaced, not pushed.

[Source: `_bmad-output/planning-artifacts/ux-design-specification.md` — Journey 3: Vendor Fast Onboarding, Form Patterns, Button Hierarchy]

---

### Critical: `app_router.dart` Changes for This Story

Replace the existing `/vendor` placeholder builder with the real `VendorOnboardingScreen`, and add `/vendor/dashboard`:

```dart
import '../../features/vendor/presentation/screens/vendor_onboarding_screen.dart';

// Change:
GoRoute(
  path: '/vendor',
  builder: (context, state) => const VendorOnboardingScreen(), // was placeholder text
),
// Add:
GoRoute(
  path: '/vendor/dashboard',
  builder: (context, state) => const Scaffold(
    body: Center(child: Text('Vendor Dashboard — Story 5.x')),
  ),
),
```

> ⚠️ Story 0.2's `role_selection_screen.dart` already calls `context.go('/vendor')` — do NOT change that file. This router change ensures the existing navigation lands on `VendorOnboardingScreen`.

> ⚠️ Story 0.3 (Login + role-based navigation) will add session-based redirect logic to route returning vendors to `/vendor/dashboard` instead of `/vendor`. That is out of scope for this story.

[Source: `_bmad-output/planning-artifacts/architecture.md` — Frontend Architecture, Navigation]

---

### Critical: `image_picker` API (v1.x, confirmed version)

```dart
// Import
import 'package:image_picker/image_picker.dart';

// Pick from gallery (use gallery, not camera, for hackathon simplicity)
final picker = ImagePicker();
final XFile? picked = await picker.pickImage(
  source: ImageSource.gallery,
  imageQuality: 80,   // compress JPEG to 80% quality
  maxWidth: 800,      // resize large photos
);

// Read bytes for Supabase Storage upload
final Uint8List bytes = await picked!.readAsBytes();

// Get file extension
final String extension = picked.name.split('.').last.toLowerCase(); // 'jpg' or 'png'
```

> ⚠️ **Platform setup (manual, if not already done in Story 0.1):**
> - **Android** (`android/app/src/main/AndroidManifest.xml`): `READ_EXTERNAL_STORAGE` permission may be needed for Android 12-
> - **iOS** (`ios/Runner/Info.plist`): Add `NSPhotoLibraryUsageDescription` key
> These are likely already in place from Story 0.1 Firebase setup, but verify before testing.

> ⚠️ **`image_picker` 1.x breaking change from 0.x:** `pickImage()` returns `XFile?` (not `PickedFile`). Use `XFile.readAsBytes()` for bytes, not `File(xfile.path)` in all cases (path-based access is unreliable on iOS).

---

### Critical: Supabase Storage Upload — `avatars/` Bucket

```dart
// Upload binary
await _supabase.storage.from('avatars').uploadBinary(
  'vendor-$userId.jpg',   // path within bucket
  imageBytes,              // Uint8List
  fileOptions: const FileOptions(
    contentType: 'image/jpeg',
    upsert: true,          // allow re-upload if vendor changes photo later
  ),
);

// Get public URL (bucket must be public)
final String publicUrl = _supabase.storage.from('avatars').getPublicUrl('vendor-$userId.jpg');
```

> ⚠️ **`upsert: true`** prevents `StorageException` on re-upload (if vendor re-runs onboarding). Safe to include.

> ⚠️ **File naming:** Use `vendor-{userId}` prefix (not just `{userId}`) to avoid conflicts with homeowner avatar uploads in later stories.

> ⚠️ **Storage bucket must be created manually** before this story can be tested end-to-end. See Task 3 notes above for SQL or use Studio UI.

[Source: `_bmad-output/planning-artifacts/architecture.md` — Storage bucket policies, Image Upload]

---

### Architecture Compliance — Mandatory Rules (ALL Stories)

| Rule | Correct | Wrong |
|---|---|---|
| Supabase calls | Only in `vendor_repository.dart` | Never in `vendor_notifier.dart` or screens |
| Async state | `AsyncNotifier<void>` | Never `StateNotifier<AsyncValue<...>>` |
| Navigation | `context.go('/vendor/dashboard')` in `ref.listen` | Never inside notifier |
| Errors | Catch `PostgrestException`/`StorageException` → rethrow as `AppException` | Never `throw Exception('...')` |
| Storage | Upload to `avatars/` bucket → save URL string in DB | Never store binary in Postgres |
| Provider names | `vendorRepositoryProvider`, `vendorOnboardingNotifierProvider` | Any other suffix |
| DB columns | `snake_case`: `is_available`, `avatar_url`, `completed_jobs_count` | Never `camelCase` in SQL |
| Dart naming | `PascalCase` classes, `camelCase` methods | No `SCREAMING_SNAKE_CASE` |

[Source: `_bmad-output/planning-artifacts/architecture.md` — Enforcement Guidelines]

---

### Library / Framework Requirements

| Package | Version | Use in this story |
|---|---|---|
| `supabase_flutter` | ^2.12.0 | PostgREST insert, Storage upload, `PostgrestException`, `StorageException` |
| `flutter_riverpod` | ^2.x | `AsyncNotifier`, `AsyncNotifierProvider`, `ConsumerStatefulWidget` |
| `go_router` | ^14.x | `context.go('/vendor/dashboard')` in screen |
| `image_picker` | ^1.x | `ImagePicker().pickImage()`, `XFile`, `readAsBytes()` |

> All packages already in `pubspec.yaml` from Story 0.1. No new dependencies required.

---

### File Structure Requirements — What to Create / Modify

**Create (new files):**
```
supabase/migrations/002_create_vendor_extensions.sql   ← new migration
lib/features/vendor/domain/vendor_profile_model.dart   ← VendorProfileModel
lib/features/vendor/data/vendor_repository.dart        ← VendorRepository (only Supabase importer)
lib/features/vendor/presentation/vendor_notifier.dart  ← VendorOnboardingNotifier + provider
lib/features/vendor/presentation/vendor_provider.dart  ← vendorRepositoryProvider
lib/features/vendor/presentation/screens/vendor_onboarding_screen.dart
test/features/vendor/data/vendor_repository_test.dart
test/features/vendor/presentation/vendor_notifier_test.dart
```

**Modify (existing files):**
```
lib/core/router/app_router.dart  ← replace /vendor placeholder + add /vendor/dashboard
```

**Remove `.gitkeep` from (as real files fill these directories):**
```
lib/features/vendor/data/.gitkeep
lib/features/vendor/domain/.gitkeep
lib/features/vendor/presentation/screens/.gitkeep
```

> ⚠️ `lib/features/vendor/presentation/widgets/.gitkeep` — leave in place (no custom widgets in this story; `AvailabilityToggleWidget` is Story 5.2).

[Source: `_bmad-output/planning-artifacts/architecture.md` — Complete Project Directory Structure]

---

### Testing Requirements

**`test/features/vendor/data/vendor_repository_test.dart`:**
- Use `mocktail` (already in dev_dependencies from Story 0.2)
- Mock `SupabaseClient`, `SupabaseStorageClient`, `StorageFileApi`
- Test `createVendorProfile()`: verify `vendor_extensions` insert called with correct fields (`id`, `services`, `avatar_url`, `is_available: true`, `is_suspended: false`)
- Test `createVendorProfile()`: verify `profiles` update called with `name`, `phone`, `avatar_url`
- Test `PostgrestException` → `AppException` mapping
- Test `uploadProfilePhoto()`: verify storage `from('avatars').uploadBinary()` called; returns URL string

**`test/features/vendor/presentation/vendor_notifier_test.dart`:**
- Use `ProviderContainer` with override for `vendorRepositoryProvider`
- Test `submitOnboarding()` transitions: `AsyncLoading` → `AsyncData`
- Test error case: repository throws `AppException` → notifier state becomes `AsyncError`
- Use `isA<AsyncLoading>()` matcher (not `AsyncLoading<void>()`)

**Testing pattern (from Story 0.2 learnings):**
```dart
// Await build() to complete before assertions
await container.read(vendorOnboardingNotifierProvider.future);

// Register listener before action
final states = <AsyncValue<void>>[];
container.listen(vendorOnboardingNotifierProvider, (_, next) => states.add(next));

// Call action
await container.read(vendorOnboardingNotifierProvider.notifier).submitOnboarding(...);

// Assert states
expect(states[0], isA<AsyncLoading>());
expect(states[1], isA<AsyncData>());
```

[Source: Story 0.2 Dev Agent Record — Debug Log References]

---

### Previous Story Intelligence

**From Story 0.1 (Flutter Project Scaffolding):**
- `app_exception.dart` — EXISTS at `lib/core/exceptions/app_exception.dart`; do NOT recreate
- `app_constants.dart` — EXISTS with `serviceTypes` list already defined — use `AppConstants.serviceTypes` directly in the FilterChip row
- `app_constants.dart` — EXISTS with all colour constants (`primaryNavy`, `statusError`, etc.) already defined
- `app_router.dart` — EXISTS at `lib/core/router/app_router.dart`; MODIFY in-place (Edit tool), do NOT recreate
- All `lib/features/vendor/` subdirectories — EXIST with `.gitkeep` files; add `.dart` files, remove `.gitkeep` as folders are populated
- `supabase/` directory may NOT exist at repo root — Story 0.1 marked `supabase init` as a manual step. Check if `supabase/migrations/` exists before creating `002_create_vendor_extensions.sql`; if `supabase/` doesn't exist, create directory structure manually
- `firebase_core: ^4.5.0` is in pubspec.yaml — no issue; `image_picker` and other packages are already present

**From Story 0.2 (Registration & Role Selection):**
- `auth_repository.dart` — optional `supabaseClient` constructor param pattern for testability; USE SAME PATTERN in `vendor_repository.dart`
- `authNotifierProvider` placed in `auth_notifier.dart` (not in `auth_provider.dart`) to break circular import — adopt same split for vendor: `vendorOnboardingNotifierProvider` in `vendor_notifier.dart`, `vendorRepositoryProvider` in `vendor_provider.dart`
- `mocktail: ^1.0.4` is in `dev_dependencies` — reuse without adding again
- `thenAnswer((_) => queryBuilder)` (not `thenReturn`) for Supabase query mocking — critical for storage mock too
- Notifier test: await `container.read(notifierProvider.future)` BEFORE setting up listeners to prevent missing `AsyncLoading` state
- `ConsumerStatefulWidget` pattern confirmed for screens with local state + loading

**From Story 0.2 file list — these files are REAL and CONFIRMED:**
- `lib/features/auth/presentation/auth_notifier.dart` — `authNotifierProvider` is HERE
- `lib/features/auth/presentation/auth_provider.dart` — `authRepositoryProvider` is HERE
- `lib/core/router/app_router.dart` — has `/vendor` route as placeholder; change to `VendorOnboardingScreen()`

---

### Git Intelligence Summary

Recent commits (last 5 relevant):
- `bddd04f` — Merge PR #9 from `test-architecture` (ATDD checklists and test design merged)
- `e71decc` — `Fix: tests` (test fixes applied, likely for auth feature)
- `d043292` — Merge PR #8 from `epic0/role-selection` (Story 0.2 implemented)
- `40972c6` — `Added Epic 0.1 and 0.2` (Stories 0.1 and 0.2 story files added)
- `72b8240` — Merge PR #7 from `test-architecture` (test framework scaffold)

**Patterns established from commits:**
- Branch naming: `epic0/role-selection` → for this story: `epic4/vendor-onboarding`
- Story files added as separate artifacts before implementation
- Test files are committed alongside implementation (not separate PRs)
- Stories go through `review` status before merge (code review step follows dev)

---

### Project Structure Notes

- The Flutter project root is `spr_house_maintenance_tracker/` (inside repo root)
- The `supabase/` directory is at REPO ROOT (same level as `spr_house_maintenance_tracker/`), NOT inside the Flutter project
- Supabase migration may need manual setup if `supabase init` was never run — check if `supabase/config.toml` exists
- If `supabase/` doesn't exist: create `supabase/migrations/` directory and place `002_create_vendor_extensions.sql` there; the SM/dev can run `supabase init` + `supabase db push` as a manual step
- Test files go in `test/features/vendor/data/` and `test/features/vendor/presentation/` — these directories exist with `.gitkeep` from Story 0.1

### References

- Story AC: [Source: `_bmad-output/planning-artifacts/epics.md` — Epic 4, Story 4.1]
- vendor_extensions schema: [Source: `_bmad-output/planning-artifacts/architecture.md` — Data Architecture]
- RLS policy strategy: [Source: `_bmad-output/planning-artifacts/architecture.md` — Authentication & Security]
- Storage bucket policies: [Source: `_bmad-output/planning-artifacts/architecture.md` — Authentication & Security]
- Feature folder structure: [Source: `_bmad-output/planning-artifacts/architecture.md` — Structure Patterns]
- AsyncNotifier pattern: [Source: `_bmad-output/planning-artifacts/architecture.md` — State Management Patterns]
- Image upload pattern: [Source: `_bmad-output/planning-artifacts/architecture.md` — Process Patterns]
- Navigation pattern: [Source: `_bmad-output/planning-artifacts/architecture.md` — Communication Patterns]
- Enforcement rules + anti-patterns: [Source: `_bmad-output/planning-artifacts/architecture.md` — Enforcement Guidelines]
- Vendor onboarding UX journey: [Source: `_bmad-output/planning-artifacts/ux-design-specification.md` — Journey 3: Vendor Fast Onboarding]
- Form patterns + button hierarchy: [Source: `_bmad-output/planning-artifacts/ux-design-specification.md` — UX Consistency Patterns]
- Colour constants: [Source: `_bmad-output/planning-artifacts/ux-design-specification.md` — Visual Design Foundation]
- serviceTypes list: [Source: `spr_house_maintenance_tracker/lib/core/constants/app_constants.dart`]
- Previous story patterns: [Source: `_bmad-output/implementation-artifacts/0-2-user-registration-and-role-selection.md` — Dev Agent Record]

## Dev Agent Record

### Agent Model Used

claude-sonnet-4-6

### Debug Log References

None — implementation completed without blocking issues.

**Deviation from story spec:** `submitOnboarding()` accepts `userId` as an explicit parameter (instead of calling `Supabase.instance.client.auth.currentUser!.id` inside the notifier). The screen passes it in. This keeps the notifier fully testable without a live Supabase instance, and aligns better with dependency-injection patterns. The vendor_onboarding_screen reads `Supabase.instance.client.auth.currentUser!.id` just before dispatching, which is safe since the user is authenticated.

### Completion Notes List

- Implemented all 7 tasks; all 6 ACs satisfied.
- Supabase migration `002_create_vendor_extensions.sql` created with correct schema, RLS policies, and run-order documentation.
- `VendorProfileModel` is `@immutable` with `fromJson`/`toJson` and correct `List<String>.from()` cast for PostgreSQL text arrays.
- `VendorRepository` is the only vendor file importing `supabase_flutter`; uses `uploadBinary` + `getPublicUrl` pattern with `upsert: true`; catches both `PostgrestException` and `StorageException`.
- `VendorOnboardingNotifier` uses `AsyncNotifier<void>` pattern; no navigation inside; state transitions via `AsyncValue.guard`.
- `VendorOnboardingScreen` uses `ConsumerStatefulWidget` with `automaticallyImplyLeading: false`, inline validation, `FilterChip` multi-select, `CircleAvatar` photo preview, and `ref.listen` for navigation.
- Router updated: `/vendor` → `VendorOnboardingScreen`, `/vendor/dashboard` → placeholder.
- 11 tests written and passing; full suite (27 tests) passes with no regressions.

### File List

**Created:**
- `supabase/migrations/002_create_vendor_extensions.sql`
- `spr_house_maintenance_tracker/lib/features/vendor/domain/vendor_profile_model.dart`
- `spr_house_maintenance_tracker/lib/features/vendor/data/vendor_repository.dart`
- `spr_house_maintenance_tracker/lib/features/vendor/presentation/vendor_provider.dart`
- `spr_house_maintenance_tracker/lib/features/vendor/presentation/vendor_notifier.dart`
- `spr_house_maintenance_tracker/lib/features/vendor/presentation/screens/vendor_onboarding_screen.dart`
- `spr_house_maintenance_tracker/test/features/vendor/data/vendor_repository_test.dart`
- `spr_house_maintenance_tracker/test/features/vendor/presentation/vendor_notifier_test.dart`

**Modified:**
- `spr_house_maintenance_tracker/lib/core/router/app_router.dart`

**Deleted:**
- `spr_house_maintenance_tracker/lib/features/vendor/data/.gitkeep`
- `spr_house_maintenance_tracker/lib/features/vendor/domain/.gitkeep`
- `spr_house_maintenance_tracker/lib/features/vendor/presentation/screens/.gitkeep`
