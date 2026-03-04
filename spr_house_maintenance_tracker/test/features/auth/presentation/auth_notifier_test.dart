import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:spr_house_maintenance_tracker/core/exceptions/app_exception.dart';
import 'package:spr_house_maintenance_tracker/features/auth/data/auth_repository.dart';
import 'package:spr_house_maintenance_tracker/features/auth/presentation/auth_notifier.dart';
import 'package:spr_house_maintenance_tracker/features/auth/presentation/auth_provider.dart';

// ── Placeholder stub (satisfies AuthRepository constructor; never called) ─────
class _StubSupabaseClient extends Mock implements SupabaseClient {}

// ── Fake repository ───────────────────────────────────────────────────────────
// All methods are overridden, so _supabase is never accessed at runtime.

class _FakeAuthRepository extends AuthRepository {
  _FakeAuthRepository({
    this.signUpError,
    this.createProfileError,
    this.currentUser,
  }) : super(supabaseClient: _StubSupabaseClient());

  final AppException? signUpError;
  final AppException? createProfileError;
  final User? currentUser;

  @override
  Future<AuthResponse> signUp(String email, String password) async {
    if (signUpError != null) throw signUpError!;
    return AuthResponse();
  }

  @override
  Future<void> createProfile(String userId, String userType) async {
    if (createProfileError != null) throw createProfileError!;
  }

  @override
  User? getCurrentUser() => currentUser;
}

// ── Helpers ────────────────────────────────────────────────────────────────────

ProviderContainer _makeContainer(_FakeAuthRepository fakeRepo) {
  return ProviderContainer(
    overrides: [
      authRepositoryProvider.overrideWithValue(fakeRepo),
    ],
  );
}

/// Waits for the notifier's [build()] to complete so that the initial
/// [AsyncLoading] state settles to [AsyncData(null)] before we listen.
Future<void> _awaitBuild(ProviderContainer container) async {
  await container.read(authNotifierProvider.future);
}

void main() {
  group('AuthNotifier.register', () {
    test('transitions to AsyncLoading then AsyncData on success', () async {
      final container = _makeContainer(_FakeAuthRepository());
      addTearDown(container.dispose);
      await _awaitBuild(container);

      final states = <AsyncValue<void>>[];
      container.listen<AsyncValue<void>>(
        authNotifierProvider,
        (_, next) => states.add(next),
      );

      await container
          .read(authNotifierProvider.notifier)
          .register('user@test.com', 'password123');

      expect(states, [
        isA<AsyncLoading<void>>(),
        isA<AsyncData<void>>(),
      ]);
    });

    test('transitions to AsyncLoading then AsyncError on failure', () async {
      const error = AppException(
        code: 'user-already-exists',
        message: 'An account with this email already exists.',
      );
      final container = _makeContainer(_FakeAuthRepository(signUpError: error));
      addTearDown(container.dispose);
      await _awaitBuild(container);

      final states = <AsyncValue<void>>[];
      container.listen<AsyncValue<void>>(
        authNotifierProvider,
        (_, next) => states.add(next),
      );

      await container
          .read(authNotifierProvider.notifier)
          .register('dup@test.com', 'password123');

      expect(states, [
        isA<AsyncLoading<void>>(),
        isA<AsyncError<void>>(),
      ]);

      final asyncError = states.last as AsyncError<void>;
      expect(asyncError.error, isA<AppException>());
      final appEx = asyncError.error as AppException;
      expect(appEx.code, 'user-already-exists');
    });

    test('propagates AppException code through AsyncError', () async {
      const error = AppException(code: 'auth-error', message: 'Something went wrong');
      final container = _makeContainer(_FakeAuthRepository(signUpError: error));
      addTearDown(container.dispose);
      await _awaitBuild(container);

      await container
          .read(authNotifierProvider.notifier)
          .register('user@test.com', 'pass');

      final state = container.read(authNotifierProvider);
      expect(state, isA<AsyncError<void>>());
      final appEx = (state as AsyncError<void>).error as AppException;
      expect(appEx.code, 'auth-error');
    });
  });

  group('AuthNotifier.createProfile', () {
    test('transitions to AsyncData on success', () async {
      final user = User(
        id: 'test-uid',
        appMetadata: const {},
        userMetadata: const {},
        aud: 'authenticated',
        createdAt: DateTime(2024).toIso8601String(),
      );
      final container = _makeContainer(
        _FakeAuthRepository(currentUser: user),
      );
      addTearDown(container.dispose);
      await _awaitBuild(container);

      final states = <AsyncValue<void>>[];
      container.listen<AsyncValue<void>>(
        authNotifierProvider,
        (_, next) => states.add(next),
      );

      await container
          .read(authNotifierProvider.notifier)
          .createProfile('homeowner');

      expect(states, [
        isA<AsyncLoading<void>>(),
        isA<AsyncData<void>>(),
      ]);
    });

    test('transitions to AsyncError when createProfile throws', () async {
      final user = User(
        id: 'test-uid',
        appMetadata: const {},
        userMetadata: const {},
        aud: 'authenticated',
        createdAt: DateTime(2024).toIso8601String(),
      );
      const error = AppException(code: 'db-error', message: 'Insert failed');
      final container = _makeContainer(
        _FakeAuthRepository(currentUser: user, createProfileError: error),
      );
      addTearDown(container.dispose);
      await _awaitBuild(container);

      await container
          .read(authNotifierProvider.notifier)
          .createProfile('homeowner');

      final state = container.read(authNotifierProvider);
      expect(state, isA<AsyncError<void>>());
      final appEx = (state as AsyncError<void>).error as AppException;
      expect(appEx.code, 'db-error');
    });
  });
}
