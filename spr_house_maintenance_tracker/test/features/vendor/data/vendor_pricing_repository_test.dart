import 'dart:async';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:spr_house_maintenance_tracker/core/exceptions/app_exception.dart';
import 'package:spr_house_maintenance_tracker/features/vendor/data/vendor_repository.dart';

// ── Supabase mock classes ─────────────────────────────────────────────────────

class MockSupabaseClient extends Mock implements SupabaseClient {}

class MockSupabaseStorageClient extends Mock
    implements SupabaseStorageClient {}

class MockStorageFileApi extends Mock implements StorageFileApi {}

// ── Fake query builders ────────────────────────────────────────────────────────

/// Captures values passed to [update]; [eq] is supported for chaining.
class _CapturingUpdateBuilder extends Fake implements SupabaseQueryBuilder {
  Map<String, dynamic>? capturedUpdate;

  @override
  PostgrestFilterBuilder<PostgrestList> update(
    Map values, {
    bool defaultToNull = true,
  }) {
    capturedUpdate = Map<String, dynamic>.from(values as Map);
    return _CompletedFilterBuilder();
  }
}

/// Throws [PostgrestException] from [update].
class _ThrowingUpdateBuilder extends Fake implements SupabaseQueryBuilder {
  final PostgrestException error;

  _ThrowingUpdateBuilder(this.error);

  @override
  PostgrestFilterBuilder<PostgrestList> update(
    Map values, {
    bool defaultToNull = true,
  }) =>
      throw error;
}

/// A completed [PostgrestFilterBuilder] that supports [eq] chaining.
class _CompletedFilterBuilder extends Fake
    implements PostgrestFilterBuilder<PostgrestList> {
  @override
  PostgrestFilterBuilder<PostgrestList> eq(String column, Object value) => this;

  @override
  Future<R> then<R>(
    FutureOr<R> Function(PostgrestList value) onValue, {
    Function? onError,
  }) =>
      Future.value(onValue(const []));

  @override
  Future<PostgrestList> catchError(
    Function onError, {
    bool Function(Object error)? test,
  }) =>
      Future.value(const []);

  @override
  Future<PostgrestList> whenComplete(FutureOr<void> Function() action) =>
      Future.value(const []);

  @override
  Future<PostgrestList> timeout(
    Duration timeLimit, {
    FutureOr<PostgrestList> Function()? onTimeout,
  }) =>
      Future.value(const []);

  @override
  Stream<PostgrestList> asStream() => Stream.value(const []);
}

void main() {
  setUpAll(() {
    registerFallbackValue(Uint8List(0));
    registerFallbackValue(const FileOptions());
  });

  const testUserId = 'vendor-uid-456';
  final testImageBytes = Uint8List.fromList([0x89, 0x50, 0x4E, 0x47]); // PNG header
  const testQrphUrl = 'https://example.com/qrph-codes/vendor-$testUserId.png';

  // ── updateVendorProfile tests ─────────────────────────────────────────────
  group('VendorRepository.updateVendorProfile', () {
    test('sends price_range_min and price_range_max in payload', () async {
      final updateBuilder = _CapturingUpdateBuilder();
      final client = MockSupabaseClient();

      when(() => client.from('vendor_extensions'))
          .thenAnswer((_) => updateBuilder);

      final repo = VendorRepository(supabaseClient: client);
      await repo.updateVendorProfile(
        userId: testUserId,
        priceMin: 500.0,
        priceMax: 1500.0,
      );

      expect(updateBuilder.capturedUpdate?['price_range_min'], 500.0);
      expect(updateBuilder.capturedUpdate?['price_range_max'], 1500.0);
    });

    test('includes qrph_url in payload when provided', () async {
      final updateBuilder = _CapturingUpdateBuilder();
      final client = MockSupabaseClient();

      when(() => client.from('vendor_extensions'))
          .thenAnswer((_) => updateBuilder);

      final repo = VendorRepository(supabaseClient: client);
      await repo.updateVendorProfile(
        userId: testUserId,
        priceMin: 500.0,
        priceMax: 1500.0,
        qrphUrl: testQrphUrl,
      );

      expect(updateBuilder.capturedUpdate?['qrph_url'], testQrphUrl);
    });

    test('does NOT include qrph_url in payload when not provided', () async {
      final updateBuilder = _CapturingUpdateBuilder();
      final client = MockSupabaseClient();

      when(() => client.from('vendor_extensions'))
          .thenAnswer((_) => updateBuilder);

      final repo = VendorRepository(supabaseClient: client);
      await repo.updateVendorProfile(
        userId: testUserId,
        priceMin: 500.0,
        priceMax: 1500.0,
      );

      expect(updateBuilder.capturedUpdate?.containsKey('qrph_url'), isFalse);
    });

    test('sends null price fields (clears pricing)', () async {
      final updateBuilder = _CapturingUpdateBuilder();
      final client = MockSupabaseClient();

      when(() => client.from('vendor_extensions'))
          .thenAnswer((_) => updateBuilder);

      final repo = VendorRepository(supabaseClient: client);
      await repo.updateVendorProfile(
        userId: testUserId,
        priceMin: null,
        priceMax: null,
      );

      expect(updateBuilder.capturedUpdate?['price_range_min'], isNull);
      expect(updateBuilder.capturedUpdate?['price_range_max'], isNull);
    });

    test('PostgrestException → AppException with db-error code', () async {
      const pgError = PostgrestException(
        message: 'record not found',
        code: 'PGRST116',
      );
      final throwingBuilder = _ThrowingUpdateBuilder(pgError);
      final client = MockSupabaseClient();

      when(() => client.from('vendor_extensions'))
          .thenAnswer((_) => throwingBuilder);

      final repo = VendorRepository(supabaseClient: client);

      expect(
        () => repo.updateVendorProfile(
          userId: testUserId,
          priceMin: 500.0,
          priceMax: 1500.0,
        ),
        throwsA(
          isA<AppException>().having((e) => e.code, 'code', 'PGRST116'),
        ),
      );
    });

    test('PostgrestException without code → AppException(db-error)', () async {
      const pgError = PostgrestException(message: 'unknown db error');
      final throwingBuilder = _ThrowingUpdateBuilder(pgError);
      final client = MockSupabaseClient();

      when(() => client.from('vendor_extensions'))
          .thenAnswer((_) => throwingBuilder);

      final repo = VendorRepository(supabaseClient: client);

      expect(
        () => repo.updateVendorProfile(
          userId: testUserId,
          priceMin: 500.0,
          priceMax: 1500.0,
        ),
        throwsA(
          isA<AppException>().having((e) => e.code, 'code', 'db-error'),
        ),
      );
    });
  });

  // ── uploadQrphCode tests ──────────────────────────────────────────────────
  group('VendorRepository.uploadQrphCode', () {
    late MockSupabaseClient client;
    late MockSupabaseStorageClient mockStorage;
    late MockStorageFileApi mockFileApi;

    setUp(() {
      client = MockSupabaseClient();
      mockStorage = MockSupabaseStorageClient();
      mockFileApi = MockStorageFileApi();

      when(() => client.storage).thenReturn(mockStorage);
      // Ensure qrph-codes bucket is used (NOT avatars)
      when(() => mockStorage.from('qrph-codes')).thenReturn(mockFileApi);
    });

    test('uploads to qrph-codes bucket with correct path', () async {
      when(() => mockFileApi.uploadBinary(
            any(),
            any(),
            fileOptions: any(named: 'fileOptions'),
          )).thenAnswer((_) async => 'vendor-$testUserId.png');

      when(() => mockFileApi.getPublicUrl(any())).thenReturn(testQrphUrl);

      final repo = VendorRepository(supabaseClient: client);
      final result = await repo.uploadQrphCode(
        testUserId,
        testImageBytes,
        'png',
      );

      expect(result, testQrphUrl);
      verify(() => mockFileApi.uploadBinary(
            'vendor-$testUserId.png',
            testImageBytes,
            fileOptions: any(named: 'fileOptions'),
          )).called(1);
      verify(() => mockFileApi.getPublicUrl('vendor-$testUserId.png')).called(1);
      // avatars bucket must never be accessed
      verifyNever(() => mockStorage.from('avatars'));
    });

    test('StorageException → AppException(storage-error)', () async {
      when(() => mockFileApi.uploadBinary(
            any(),
            any(),
            fileOptions: any(named: 'fileOptions'),
          )).thenThrow(const StorageException('Upload failed'));

      final repo = VendorRepository(supabaseClient: client);

      expect(
        () => repo.uploadQrphCode(testUserId, testImageBytes, 'png'),
        throwsA(
          isA<AppException>().having((e) => e.code, 'code', 'storage-error'),
        ),
      );
    });
  });
}
