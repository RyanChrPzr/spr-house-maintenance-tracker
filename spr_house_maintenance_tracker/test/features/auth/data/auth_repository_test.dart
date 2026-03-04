import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:spr_house_maintenance_tracker/core/exceptions/app_exception.dart';
import 'package:spr_house_maintenance_tracker/features/auth/data/auth_repository.dart';

// ── Mocks for signUp tests ────────────────────────────────────────────────────

class MockSupabaseClient extends Mock implements SupabaseClient {}

class MockGoTrueClient extends Mock implements GoTrueClient {}

// ── Fake for createProfile tests ──────────────────────────────────────────────
// Avoids mocking the complex postgrest query chain by recording calls directly.

/// Records the data passed to [insert] and completes successfully.
class _CapturingQueryBuilder extends Fake implements SupabaseQueryBuilder {
  final List<Map<String, dynamic>> inserts = [];

  Map<String, dynamic>? get capturedInsert => inserts.isEmpty ? null : inserts.last;

  @override
  PostgrestFilterBuilder<PostgrestList> insert(
    Object values, {
    bool defaultToNull = true,
  }) {
    inserts.add(values as Map<String, dynamic>);
    return _CompletedFilterBuilder();
  }
}

/// A [PostgrestFilterBuilder] that completes immediately with an empty list.
class _CompletedFilterBuilder extends Fake
    implements PostgrestFilterBuilder<PostgrestList> {
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

/// A [SupabaseClient] fake that throws [PostgrestException] from [from].
class _ThrowingQueryBuilder extends Fake implements SupabaseQueryBuilder {
  final PostgrestException error;

  _ThrowingQueryBuilder(this.error);

  @override
  PostgrestFilterBuilder<PostgrestList> insert(
    Object values, {
    bool defaultToNull = true,
  }) =>
      throw error;
}

// ── Helpers ───────────────────────────────────────────────────────────────────

AuthResponse _makeAuthResponse({List<UserIdentity>? identities}) {
  final user = User(
    id: 'test-uid',
    appMetadata: const {},
    userMetadata: const {},
    aud: 'authenticated',
    createdAt: DateTime(2024).toIso8601String(),
    identities: identities,
  );
  return AuthResponse(user: user);
}

void main() {
  // ── signUp tests — use MockSupabaseClient + MockGoTrueClient ──────────────
  late MockSupabaseClient mockClient;
  late MockGoTrueClient mockAuth;

  setUp(() {
    mockClient = MockSupabaseClient();
    mockAuth = MockGoTrueClient();
    when(() => mockClient.auth).thenReturn(mockAuth);
  });

  group('AuthRepository.signUp', () {
    late AuthRepository repository;

    setUp(() {
      repository = AuthRepository(supabaseClient: mockClient);
    });

    test('happy path — returns AuthResponse on success', () async {
      final response = _makeAuthResponse(
        identities: const [
          UserIdentity(
            identityId: 'test-identity-id',
            id: 'test-id',
            userId: 'test-uid',
            identityData: {},
            provider: 'email',
            createdAt: '2024-01-01T00:00:00Z',
            updatedAt: '2024-01-01T00:00:00Z',
            lastSignInAt: '2024-01-01T00:00:00Z',
          ),
        ],
      );

      when(() => mockAuth.signUp(
            email: any(named: 'email'),
            password: any(named: 'password'),
          )).thenAnswer((_) async => response);

      final result = await repository.signUp('user@example.com', 'password123');

      expect(result.user?.id, 'test-uid');
    });

    test('silent duplicate — throws AppException(user-already-exists)', () async {
      final response = _makeAuthResponse(identities: []);

      when(() => mockAuth.signUp(
            email: any(named: 'email'),
            password: any(named: 'password'),
          )).thenAnswer((_) async => response);

      expect(
        () => repository.signUp('dup@example.com', 'password123'),
        throwsA(
          isA<AppException>().having(
            (e) => e.code,
            'code',
            'user-already-exists',
          ),
        ),
      );
    });

    test('AuthException "already registered" — throws AppException(user-already-exists)',
        () async {
      when(() => mockAuth.signUp(
            email: any(named: 'email'),
            password: any(named: 'password'),
          )).thenThrow(
        const AuthException('User already registered', statusCode: '400'),
      );

      expect(
        () => repository.signUp('dup@example.com', 'password123'),
        throwsA(
          isA<AppException>()
              .having((e) => e.code, 'code', 'user-already-exists')
              .having(
                (e) => e.message,
                'message',
                'An account with this email already exists.',
              ),
        ),
      );
    });

    test('other AuthException — throws AppException with status code', () async {
      when(() => mockAuth.signUp(
            email: any(named: 'email'),
            password: any(named: 'password'),
          )).thenThrow(
        const AuthException('Network error', statusCode: '500'),
      );

      expect(
        () => repository.signUp('user@example.com', 'password123'),
        throwsA(
          isA<AppException>().having((e) => e.code, 'code', '500'),
        ),
      );
    });
  });

  // ── createProfile tests — use fake query builders ──────────────────────────
  group('AuthRepository.createProfile', () {
    test('inserts correct row into profiles table', () async {
      final queryBuilder = _CapturingQueryBuilder();
      final client = MockSupabaseClient();
      when(() => client.from('profiles')).thenAnswer((_) => queryBuilder);
      final repo = AuthRepository(supabaseClient: client);

      await repo.createProfile('user-id-123', 'homeowner');

      expect(queryBuilder.capturedInsert, {
        'id': 'user-id-123',
        'user_type': 'homeowner',
      });
    });

    test('vendor role — inserts correct user_type', () async {
      final queryBuilder = _CapturingQueryBuilder();
      final client = MockSupabaseClient();
      when(() => client.from('profiles')).thenAnswer((_) => queryBuilder);
      final repo = AuthRepository(supabaseClient: client);

      await repo.createProfile('vendor-id-456', 'vendor');

      expect(queryBuilder.capturedInsert, {
        'id': 'vendor-id-456',
        'user_type': 'vendor',
      });
    });

    test('PostgrestException — throws AppException(db-error)', () async {
      const pgError =
          PostgrestException(message: 'insert failed', code: 'DB001');
      final queryBuilder = _ThrowingQueryBuilder(pgError);
      final client = MockSupabaseClient();
      when(() => client.from('profiles')).thenAnswer((_) => queryBuilder);
      final repo = AuthRepository(supabaseClient: client);

      expect(
        () => repo.createProfile('user-id-123', 'homeowner'),
        throwsA(
          isA<AppException>().having((e) => e.code, 'code', 'DB001'),
        ),
      );
    });
  });

  // ── getCurrentUser tests ──────────────────────────────────────────────────
  group('AuthRepository.getCurrentUser', () {
    test('returns null when no session exists', () {
      when(() => mockClient.auth).thenReturn(mockAuth);
      when(() => mockAuth.currentUser).thenReturn(null);
      final repo = AuthRepository(supabaseClient: mockClient);
      expect(repo.getCurrentUser(), isNull);
    });
  });
}
