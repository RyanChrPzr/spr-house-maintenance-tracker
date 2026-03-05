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
  String get name => 'qr-code.png';

  @override
  Future<Uint8List> readAsBytes() async =>
      Uint8List.fromList([0x89, 0x50, 0x4E, 0x47]);
}

// ── Fake VendorRepository ─────────────────────────────────────────────────────
class _FakeVendorRepository extends VendorRepository {
  _FakeVendorRepository({
    this.updateProfileError,
    this.uploadQrphError,
    this.qrphUrl = 'https://example.com/qrph-codes/vendor-test.png',
  }) : super(supabaseClient: _StubSupabaseClient());

  final AppException? updateProfileError;
  final AppException? uploadQrphError;
  final String qrphUrl;

  // Track whether uploadQrphCode was called
  bool uploadQrphCalled = false;

  @override
  Future<String> uploadQrphCode(
    String userId,
    Uint8List imageBytes,
    String extension,
  ) async {
    uploadQrphCalled = true;
    if (uploadQrphError != null) throw uploadQrphError!;
    return qrphUrl;
  }

  @override
  Future<void> updateVendorProfile({
    required String userId,
    double? priceMin,
    double? priceMax,
    String? qrphUrl,
  }) async {
    if (updateProfileError != null) throw updateProfileError!;
  }

  // Carry forward stub for submitOnboarding dependencies
  @override
  Future<String> uploadProfilePhoto(
    String userId,
    Uint8List imageBytes,
    String extension,
  ) async =>
      'https://example.com/avatars/vendor-test.jpg';

  @override
  Future<void> createVendorProfile({
    required String userId,
    required List<String> services,
    required String avatarUrl,
    required String name,
    required String phone,
  }) async {}
}

// ── Helpers ───────────────────────────────────────────────────────────────────

ProviderContainer _makeContainer(_FakeVendorRepository fakeRepo) {
  return ProviderContainer(
    overrides: [
      vendorRepositoryProvider.overrideWithValue(fakeRepo),
    ],
  );
}

Future<void> _awaitBuild(ProviderContainer container) async {
  await container.read(vendorOnboardingNotifierProvider.future);
}

void main() {
  setUpAll(() {
    registerFallbackValue(Uint8List(0));
    registerFallbackValue(const FileOptions());
  });

  group('VendorOnboardingNotifier.submitPricingSetup', () {
    test('transitions AsyncLoading → AsyncData on success with photo',
        () async {
      final fakeRepo = _FakeVendorRepository();
      final container = _makeContainer(fakeRepo);
      addTearDown(container.dispose);
      await _awaitBuild(container);

      final states = <AsyncValue<void>>[];
      container.listen<AsyncValue<void>>(
        vendorOnboardingNotifierProvider,
        (_, next) => states.add(next),
      );

      await container
          .read(vendorOnboardingNotifierProvider.notifier)
          .submitPricingSetup(
            userId: 'test-vendor-uid',
            priceMin: 500.0,
            priceMax: 1500.0,
            qrphPhoto: _FakeXFile(),
          );

      expect(states, [
        isA<AsyncLoading<void>>(),
        isA<AsyncData<void>>(),
      ]);
      expect(fakeRepo.uploadQrphCalled, isTrue);
    });

    test('transitions AsyncLoading → AsyncData on success without photo',
        () async {
      final fakeRepo = _FakeVendorRepository();
      final container = _makeContainer(fakeRepo);
      addTearDown(container.dispose);
      await _awaitBuild(container);

      final states = <AsyncValue<void>>[];
      container.listen<AsyncValue<void>>(
        vendorOnboardingNotifierProvider,
        (_, next) => states.add(next),
      );

      await container
          .read(vendorOnboardingNotifierProvider.notifier)
          .submitPricingSetup(
            userId: 'test-vendor-uid',
            priceMin: 500.0,
            priceMax: 1500.0,
            qrphPhoto: null,
          );

      expect(states, [
        isA<AsyncLoading<void>>(),
        isA<AsyncData<void>>(),
      ]);
      // uploadQrphCode must NOT be called when no photo provided
      expect(fakeRepo.uploadQrphCalled, isFalse);
    });

    test('does NOT call uploadQrphCode when qrphPhoto is null', () async {
      final fakeRepo = _FakeVendorRepository();
      final container = _makeContainer(fakeRepo);
      addTearDown(container.dispose);
      await _awaitBuild(container);

      await container
          .read(vendorOnboardingNotifierProvider.notifier)
          .submitPricingSetup(
            userId: 'test-vendor-uid',
            priceMin: null,
            priceMax: null,
            qrphPhoto: null,
          );

      expect(fakeRepo.uploadQrphCalled, isFalse);
    });

    test('transitions to AsyncError when updateVendorProfile fails', () async {
      const error = AppException(code: 'db-error', message: 'Update failed');
      final fakeRepo = _FakeVendorRepository(updateProfileError: error);
      final container = _makeContainer(fakeRepo);
      addTearDown(container.dispose);
      await _awaitBuild(container);

      final states = <AsyncValue<void>>[];
      container.listen<AsyncValue<void>>(
        vendorOnboardingNotifierProvider,
        (_, next) => states.add(next),
      );

      await container
          .read(vendorOnboardingNotifierProvider.notifier)
          .submitPricingSetup(
            userId: 'test-vendor-uid',
            priceMin: 500.0,
            priceMax: 1500.0,
          );

      expect(states, [
        isA<AsyncLoading<void>>(),
        isA<AsyncError<void>>(),
      ]);

      final appEx = (states.last as AsyncError<void>).error as AppException;
      expect(appEx.code, 'db-error');
    });

    test('transitions to AsyncError when uploadQrphCode fails', () async {
      const error =
          AppException(code: 'storage-error', message: 'Upload failed');
      final fakeRepo = _FakeVendorRepository(uploadQrphError: error);
      final container = _makeContainer(fakeRepo);
      addTearDown(container.dispose);
      await _awaitBuild(container);

      final states = <AsyncValue<void>>[];
      container.listen<AsyncValue<void>>(
        vendorOnboardingNotifierProvider,
        (_, next) => states.add(next),
      );

      await container
          .read(vendorOnboardingNotifierProvider.notifier)
          .submitPricingSetup(
            userId: 'test-vendor-uid',
            priceMin: 500.0,
            priceMax: 1500.0,
            qrphPhoto: _FakeXFile(),
          );

      expect(states, [
        isA<AsyncLoading<void>>(),
        isA<AsyncError<void>>(),
      ]);

      final appEx = (states.last as AsyncError<void>).error as AppException;
      expect(appEx.code, 'storage-error');
    });
  });
}
