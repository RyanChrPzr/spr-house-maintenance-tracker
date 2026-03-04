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

// ── Fake query builders for DB operations ────────────────────────────────────

/// Captures values passed to [insert] and completes successfully.
class _CapturingInsertBuilder extends Fake implements SupabaseQueryBuilder {
  final List<Map<String, dynamic>> inserts = [];

  Map<String, dynamic>? get capturedInsert =>
      inserts.isEmpty ? null : inserts.last;

  @override
  PostgrestFilterBuilder<PostgrestList> insert(
    Object values, {
    bool defaultToNull = true,
  }) {
    inserts.add(values as Map<String, dynamic>);
    return _CompletedFilterBuilder();
  }
}

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

/// Throws [PostgrestException] from [insert].
class _ThrowingInsertBuilder extends Fake implements SupabaseQueryBuilder {
  final PostgrestException error;

  _ThrowingInsertBuilder(this.error);

  @override
  PostgrestFilterBuilder<PostgrestList> insert(
    Object values, {
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

  const testUserId = 'vendor-uid-123';
  const testAvatarUrl = 'https://example.com/avatars/vendor-$testUserId.jpg';
  final testImageBytes = Uint8List.fromList([0xFF, 0xD8, 0xFF]); // minimal JPEG header

  // ── uploadProfilePhoto tests ───────────────────────────────────────────────
  group('VendorRepository.uploadProfilePhoto', () {
    late MockSupabaseClient client;
    late MockSupabaseStorageClient mockStorage;
    late MockStorageFileApi mockFileApi;

    setUp(() {
      client = MockSupabaseClient();
      mockStorage = MockSupabaseStorageClient();
      mockFileApi = MockStorageFileApi();

      when(() => client.storage).thenReturn(mockStorage);
      when(() => mockStorage.from('avatars')).thenReturn(mockFileApi);
    });

    test('uploads binary and returns public URL', () async {
      when(() => mockFileApi.uploadBinary(
            any(),
            any(),
            fileOptions: any(named: 'fileOptions'),
          )).thenAnswer((_) async => 'vendor-$testUserId.jpg');

      when(() => mockFileApi.getPublicUrl(any())).thenReturn(testAvatarUrl);

      final repo = VendorRepository(supabaseClient: client);
      final result = await repo.uploadProfilePhoto(
        testUserId,
        testImageBytes,
        'jpg',
      );

      expect(result, testAvatarUrl);
      verify(() => mockFileApi.uploadBinary(
            'vendor-$testUserId.jpg',
            testImageBytes,
            fileOptions: any(named: 'fileOptions'),
          )).called(1);
      verify(() => mockFileApi.getPublicUrl('vendor-$testUserId.jpg')).called(1);
    });

    test('StorageException → AppException(storage-error)', () async {
      when(() => mockFileApi.uploadBinary(
            any(),
            any(),
            fileOptions: any(named: 'fileOptions'),
          )).thenThrow(const StorageException('Upload failed'));

      final repo = VendorRepository(supabaseClient: client);

      expect(
        () => repo.uploadProfilePhoto(testUserId, testImageBytes, 'jpg'),
        throwsA(
          isA<AppException>().having((e) => e.code, 'code', 'storage-error'),
        ),
      );
    });
  });

  // ── createVendorProfile tests ──────────────────────────────────────────────
  group('VendorRepository.createVendorProfile', () {
    test('inserts correct fields into vendor_extensions', () async {
      final insertBuilder = _CapturingInsertBuilder();
      final updateBuilder = _CapturingUpdateBuilder();
      final client = MockSupabaseClient();

      when(() => client.from('vendor_extensions'))
          .thenAnswer((_) => insertBuilder);
      when(() => client.from('profiles'))
          .thenAnswer((_) => updateBuilder);

      final repo = VendorRepository(supabaseClient: client);
      await repo.createVendorProfile(
        userId: testUserId,
        services: ['Plumbing Check', 'Electrical Check'],
        avatarUrl: testAvatarUrl,
        name: 'Juan dela Cruz',
        phone: '09171234567',
      );

      expect(insertBuilder.capturedInsert, {
        'id': testUserId,
        'services': ['Plumbing Check', 'Electrical Check'],
        'avatar_url': testAvatarUrl,
        'is_available': true,
        'is_suspended': false,
        'completed_jobs_count': 0,
      });
    });

    test('updates profiles with name, phone, avatar_url', () async {
      final insertBuilder = _CapturingInsertBuilder();
      final updateBuilder = _CapturingUpdateBuilder();
      final client = MockSupabaseClient();

      when(() => client.from('vendor_extensions'))
          .thenAnswer((_) => insertBuilder);
      when(() => client.from('profiles'))
          .thenAnswer((_) => updateBuilder);

      final repo = VendorRepository(supabaseClient: client);
      await repo.createVendorProfile(
        userId: testUserId,
        services: ['Aircon Cleaning'],
        avatarUrl: testAvatarUrl,
        name: 'Maria Santos',
        phone: '09181234567',
      );

      expect(updateBuilder.capturedUpdate, {
        'name': 'Maria Santos',
        'phone': '09181234567',
        'avatar_url': testAvatarUrl,
      });
    });

    test('sets is_available=true and is_suspended=false on insert', () async {
      final insertBuilder = _CapturingInsertBuilder();
      final updateBuilder = _CapturingUpdateBuilder();
      final client = MockSupabaseClient();

      when(() => client.from('vendor_extensions'))
          .thenAnswer((_) => insertBuilder);
      when(() => client.from('profiles'))
          .thenAnswer((_) => updateBuilder);

      final repo = VendorRepository(supabaseClient: client);
      await repo.createVendorProfile(
        userId: testUserId,
        services: ['Pest Control'],
        avatarUrl: testAvatarUrl,
        name: 'Pedro Reyes',
        phone: '09191234567',
      );

      expect(insertBuilder.capturedInsert?['is_available'], isTrue);
      expect(insertBuilder.capturedInsert?['is_suspended'], isFalse);
    });

    test('PostgrestException → AppException(db-error) with code', () async {
      const pgError = PostgrestException(
        message: 'foreign key violation',
        code: '23503',
      );
      final throwingBuilder = _ThrowingInsertBuilder(pgError);
      final client = MockSupabaseClient();

      when(() => client.from('vendor_extensions'))
          .thenAnswer((_) => throwingBuilder);

      final repo = VendorRepository(supabaseClient: client);

      expect(
        () => repo.createVendorProfile(
          userId: testUserId,
          services: ['Plumbing Check'],
          avatarUrl: testAvatarUrl,
          name: 'Test Vendor',
          phone: '09001234567',
        ),
        throwsA(
          isA<AppException>().having((e) => e.code, 'code', '23503'),
        ),
      );
    });

    test('PostgrestException without code → AppException(db-error)', () async {
      const pgError = PostgrestException(message: 'unknown db error');
      final throwingBuilder = _ThrowingInsertBuilder(pgError);
      final client = MockSupabaseClient();

      when(() => client.from('vendor_extensions'))
          .thenAnswer((_) => throwingBuilder);

      final repo = VendorRepository(supabaseClient: client);

      expect(
        () => repo.createVendorProfile(
          userId: testUserId,
          services: ['Rooftop Inspection'],
          avatarUrl: testAvatarUrl,
          name: 'Test Vendor',
          phone: '09001234567',
        ),
        throwsA(
          isA<AppException>().having((e) => e.code, 'code', 'db-error'),
        ),
      );
    });
  });
}
