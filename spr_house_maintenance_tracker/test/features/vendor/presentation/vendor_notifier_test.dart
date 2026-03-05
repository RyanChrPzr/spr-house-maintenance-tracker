import 'dart:typed_data';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mocktail/mocktail.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:spr_house_maintenance_tracker/core/exceptions/app_exception.dart';
import 'package:spr_house_maintenance_tracker/features/vendor/data/vendor_repository.dart';
import 'package:spr_house_maintenance_tracker/features/vendor/presentation/vendor_notifier.dart';
import 'package:spr_house_maintenance_tracker/features/vendor/presentation/vendor_provider.dart';

// ── Stub SupabaseClient (satisfies VendorRepository constructor; never called) ──
class _StubSupabaseClient extends Mock implements SupabaseClient {}

// ── Fake XFile ─────────────────────────────────────────────────────────────────
class _FakeXFile extends Fake implements XFile {
  @override
  String get name => 'avatar.jpg';

  @override
  Future<Uint8List> readAsBytes() async =>
      Uint8List.fromList([0xFF, 0xD8, 0xFF]);
}

// ── Fake VendorRepository ──────────────────────────────────────────────────────
// All methods are overridden, so _supabase is never accessed at runtime.
class _FakeVendorRepository extends VendorRepository {
  _FakeVendorRepository({
    this.uploadError,
    this.createProfileError,
    this.avatarUrl = 'https://example.com/avatars/vendor-test.jpg',
  }) : super(supabaseClient: _StubSupabaseClient());

  final AppException? uploadError;
  final AppException? createProfileError;
  final String avatarUrl;

  @override
  Future<String> uploadProfilePhoto(
    String userId,
    Uint8List imageBytes,
    String extension,
  ) async {
    if (uploadError != null) throw uploadError!;
    return avatarUrl;
  }

  @override
  Future<void> createVendorProfile({
    required String userId,
    required List<String> services,
    required String avatarUrl,
    required String name,
    required String phone,
  }) async {
    if (createProfileError != null) throw createProfileError!;
  }
}

// ── Helpers ────────────────────────────────────────────────────────────────────

ProviderContainer _makeContainer(_FakeVendorRepository fakeRepo) {
  return ProviderContainer(
    overrides: [
      vendorRepositoryProvider.overrideWithValue(fakeRepo),
    ],
  );
}

/// Waits for the notifier's [build()] to complete so that the initial
/// [AsyncLoading] state settles to [AsyncData(null)] before we listen.
Future<void> _awaitBuild(ProviderContainer container) async {
  await container.read(vendorOnboardingNotifierProvider.future);
}

void main() {
  late _FakeXFile fakePhoto;

  setUp(() {
    fakePhoto = _FakeXFile();
  });

  group('VendorOnboardingNotifier.submitOnboarding', () {
    test('transitions to AsyncLoading then AsyncData on success', () async {
      final container = _makeContainer(_FakeVendorRepository());
      addTearDown(container.dispose);
      await _awaitBuild(container);

      final states = <AsyncValue<void>>[];
      container.listen<AsyncValue<void>>(
        vendorOnboardingNotifierProvider,
        (_, next) => states.add(next),
      );

      await container
          .read(vendorOnboardingNotifierProvider.notifier)
          .submitOnboarding(
            userId: 'test-vendor-uid',
            name: 'Juan dela Cruz',
            services: ['Plumbing Check', 'Electrical Check'],
            phone: '09171234567',
            photo: fakePhoto,
          );

      expect(states, [
        isA<AsyncLoading<void>>(),
        isA<AsyncData<void>>(),
      ]);
    });

    test('transitions to AsyncError when upload fails', () async {
      const error = AppException(
        code: 'storage-error',
        message: 'Upload failed',
      );
      final container = _makeContainer(
        _FakeVendorRepository(uploadError: error),
      );
      addTearDown(container.dispose);
      await _awaitBuild(container);

      final states = <AsyncValue<void>>[];
      container.listen<AsyncValue<void>>(
        vendorOnboardingNotifierProvider,
        (_, next) => states.add(next),
      );

      await container
          .read(vendorOnboardingNotifierProvider.notifier)
          .submitOnboarding(
            userId: 'test-vendor-uid',
            name: 'Juan dela Cruz',
            services: ['Aircon Cleaning'],
            phone: '09181234567',
            photo: fakePhoto,
          );

      expect(states, [
        isA<AsyncLoading<void>>(),
        isA<AsyncError<void>>(),
      ]);

      final asyncError = states.last as AsyncError<void>;
      expect(asyncError.error, isA<AppException>());
      final appEx = asyncError.error as AppException;
      expect(appEx.code, 'storage-error');
    });

    test('transitions to AsyncError when createVendorProfile fails', () async {
      const error = AppException(
        code: 'db-error',
        message: 'Insert failed',
      );
      final container = _makeContainer(
        _FakeVendorRepository(createProfileError: error),
      );
      addTearDown(container.dispose);
      await _awaitBuild(container);

      final states = <AsyncValue<void>>[];
      container.listen<AsyncValue<void>>(
        vendorOnboardingNotifierProvider,
        (_, next) => states.add(next),
      );

      await container
          .read(vendorOnboardingNotifierProvider.notifier)
          .submitOnboarding(
            userId: 'test-vendor-uid',
            name: 'Maria Santos',
            services: ['Pest Control'],
            phone: '09191234567',
            photo: fakePhoto,
          );

      expect(states, [
        isA<AsyncLoading<void>>(),
        isA<AsyncError<void>>(),
      ]);

      final appEx =
          (states.last as AsyncError<void>).error as AppException;
      expect(appEx.code, 'db-error');
    });

    test('propagates AppException code through AsyncError', () async {
      const error = AppException(
        code: '23503',
        message: 'Foreign key constraint violation',
      );
      final container = _makeContainer(
        _FakeVendorRepository(createProfileError: error),
      );
      addTearDown(container.dispose);
      await _awaitBuild(container);

      await container
          .read(vendorOnboardingNotifierProvider.notifier)
          .submitOnboarding(
            userId: 'test-vendor-uid',
            name: 'Pedro Reyes',
            services: ['Septic Tank Pump-out'],
            phone: '09001234567',
            photo: fakePhoto,
          );

      final state = container.read(vendorOnboardingNotifierProvider);
      expect(state, isA<AsyncError<void>>());
      final appEx = (state as AsyncError<void>).error as AppException;
      expect(appEx.code, '23503');
    });
  });
}
