// test/features/auth/presentation/auth_notifier_test.dart
//
// ATDD RED PHASE — Story 0.3: User Login & Role-Based Navigation
// Test ID : 0.3-UNIT-001
// Priority: P1
// Level   : Unit
//
// Tests are SKIPPED with `skip:` because production code does not exist yet.
// TDD cycle:
//   RED   ← you are here (tests written, skipped, all will "fail" conceptually)
//   GREEN → remove `skip:` after AuthNotifier is implemented; run tests; all pass
//   REFACTOR → clean up implementation keeping tests green
//
// Dependencies (not yet implemented):
//   lib/features/auth/data/auth_repository.dart   — AuthRepository + AuthException
//   lib/features/auth/presentation/auth_notifier.dart — AuthNotifier (AsyncNotifier)
//   lib/features/auth/presentation/auth_providers.dart — authNotifierProvider
//
// Framework: flutter_test + mocktail + riverpod
// Run command (once Flutter project is initialised):
//   flutter test test/features/auth/presentation/auth_notifier_test.dart

// ignore_for_file: unused_import

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:riverpod/riverpod.dart';

// ── Production imports (RED phase — files do not exist yet) ──────────────────
// Uncomment once implementation is in place:
//
// import 'package:spr_house_maintenance_tracker/features/auth/data/auth_repository.dart';
// import 'package:spr_house_maintenance_tracker/features/auth/presentation/auth_notifier.dart';
// import 'package:spr_house_maintenance_tracker/features/auth/presentation/auth_providers.dart';
//
// class MockAuthRepository extends Mock implements AuthRepository {}

import '../../helpers/test_helpers.dart';

// ── Temporary stubs so the file compiles in RED phase ───────────────────────
// DELETE these stubs once the real production classes exist.

abstract class AuthRepository {
  Future<void> signIn({required String email, required String password});
}

class AuthException implements Exception {
  AuthException(this.message);
  final String message;
  @override
  String toString() => 'AuthException: $message';
}

class MockAuthRepository extends Mock implements AuthRepository {}

// ── Tests ────────────────────────────────────────────────────────────────────

void main() {
  late MockAuthRepository mockAuthRepository;

  setUp(() {
    mockAuthRepository = MockAuthRepository();
  });

  group('AuthNotifier — Story 0.3 (Unit)', () {
    // ─────────────────────────────────────────────────────────────────────────
    // 0.3-UNIT-001  [P1]
    // AC3: When the user submits incorrect credentials, the screen displays
    //      an inline error message "Incorrect email or password." without
    //      navigating away.
    // ─────────────────────────────────────────────────────────────────────────
    test(
      '[P1] 0.3-UNIT-001: incorrect credentials emit AsyncError with '
      '"Incorrect email or password." message',
      () async {
        // ── Arrange ──────────────────────────────────────────────────────────
        // Repository throws AuthException when credentials are wrong.
        when(
          () => mockAuthRepository.signIn(
            email: AuthTestData.wrongEmail,
            password: AuthTestData.wrongPassword,
          ),
        ).thenThrow(AuthException(AuthTestData.incorrectCredentialsMessage));

        // ── Act ───────────────────────────────────────────────────────────────
        // AuthNotifier.signIn() calls authRepository.signIn() and captures
        // the exception into its AsyncNotifier state.
        //
        // Once implemented, replace with:
        //   final container = ProviderContainer(overrides: [
        //     authRepositoryProvider.overrideWithValue(mockAuthRepository),
        //   ]);
        //   await container.read(authNotifierProvider.notifier).signIn(
        //     email: AuthTestData.wrongEmail,
        //     password: AuthTestData.wrongPassword,
        //   );
        //   final state = container.read(authNotifierProvider);
        //
        // RED phase placeholder — the act section is a stub:
        Exception? caughtError;
        try {
          await mockAuthRepository.signIn(
            email: AuthTestData.wrongEmail,
            password: AuthTestData.wrongPassword,
          );
        } on AuthException catch (e) {
          caughtError = e;
        }

        // ── Assert ────────────────────────────────────────────────────────────
        // When AuthNotifier is implemented, the state should be AsyncError:
        //   expect(state, isA<AsyncError<void>>());
        //   final error = (state as AsyncError).error as AuthException;
        //   expect(error.message, AuthTestData.incorrectCredentialsMessage);
        //
        // For now, verify the repository throws the correct exception so the
        // test documents the expected contract.
        expect(caughtError, isA<AuthException>());
        expect(
          (caughtError! as AuthException).message,
          AuthTestData.incorrectCredentialsMessage,
        );
      },
      skip: 'RED phase — AuthNotifier (AsyncNotifier) not implemented yet; '
          'remove skip: once lib/features/auth/presentation/auth_notifier.dart exists',
    );
  });
}
