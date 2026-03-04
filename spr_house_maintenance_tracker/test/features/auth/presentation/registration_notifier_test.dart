// test/features/auth/presentation/registration_notifier_test.dart
//
// ATDD RED PHASE — Story 0.2: User Registration & Role Selection
// Test IDs : 0.2-UNIT-001, 0.2-UNIT-002, 0.2-UNIT-003
// Priority : P0 (UNIT-001)  |  P1 (UNIT-002, UNIT-003)
// Level    : Unit
//
// Tests RegistrationNotifier (AsyncNotifier) with a mocked AuthRepository.
// Covers: successful register → role selection state, duplicate email error,
// and client-side validation (email format, password length).
//
// Framework: flutter_test + mocktail + riverpod
// Run command:
//   flutter test test/features/auth/presentation/registration_notifier_test.dart

// ignore_for_file: unused_import

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

// ── Production imports (RED phase — do not exist yet) ────────────────────────
// Uncomment once implemented:
//
// import 'package:spr_house_maintenance_tracker/core/exceptions/app_exception.dart';
// import 'package:spr_house_maintenance_tracker/features/auth/data/auth_repository.dart';
// import 'package:spr_house_maintenance_tracker/features/auth/presentation/registration_notifier.dart';
// import 'package:spr_house_maintenance_tracker/features/auth/presentation/auth_providers.dart';

// ── Temporary stubs (delete once production code exists) ─────────────────────

class AppException implements Exception {
  AppException(this.message, {this.code});
  final String message;
  final String? code;
}

abstract class AuthRepository {
  Future<void> register({required String email, required String password});
}

class MockAuthRepository extends Mock implements AuthRepository {}

// ── Tests ─────────────────────────────────────────────────────────────────────

void main() {
  late MockAuthRepository mockRepo;

  setUp(() {
    mockRepo = MockAuthRepository();
  });

  group('RegistrationNotifier — Story 0.2 (Unit)', () {
    // ─────────────────────────────────────────────────────────────────────────
    // 0.2-UNIT-001  [P0]
    // AC2: Valid email + password → Supabase account created → navigate to
    //      role selection screen.
    // The notifier should transition to AsyncData(registered: true) so the
    // UI can route to /auth/role-selection.
    // ─────────────────────────────────────────────────────────────────────────
    test(
      '[P0] 0.2-UNIT-001: successful registration emits AsyncData without error',
      () async {
        // Arrange — repository succeeds silently
        when(
          () => mockRepo.register(
            email: 'new@test.spr.ph',
            password: 'ValidPass1!',
          ),
        ).thenAnswer((_) async {});

        // Act + Assert — call succeeds; no exception thrown
        // Once RegistrationNotifier exists, test like:
        //   final container = ProviderContainer(overrides: [
        //     authRepositoryProvider.overrideWithValue(mockRepo),
        //   ]);
        //   await container
        //       .read(registrationNotifierProvider.notifier)
        //       .register(email: 'new@test.spr.ph', password: 'ValidPass1!');
        //   final state = container.read(registrationNotifierProvider);
        //   expect(state, isA<AsyncData>());

        await expectLater(
          mockRepo.register(
              email: 'new@test.spr.ph', password: 'ValidPass1!'),
          completes,
        );
      },
      skip: true, // RED phase — RegistrationNotifier not yet implemented
    );

    // ─────────────────────────────────────────────────────────────────────────
    // 0.2-UNIT-002  [P1]
    // AC5: Duplicate email → inline error "An account with this email
    //      already exists."
    // ─────────────────────────────────────────────────────────────────────────
    test(
      '[P1] 0.2-UNIT-002: duplicate email emits AsyncError with expected message',
      () async {
        const duplicateEmail = 'existing@test.spr.ph';

        when(
          () => mockRepo.register(
            email: duplicateEmail,
            password: 'ValidPass1!',
          ),
        ).thenThrow(
          AppException('An account with this email already exists.'),
        );

        // Once RegistrationNotifier exists, assert state is AsyncError with
        // the exact message so LoginScreen can display it inline.
        Exception? caught;
        try {
          await mockRepo.register(
              email: duplicateEmail, password: 'ValidPass1!');
        } on AppException catch (e) {
          caught = e;
        }

        expect(caught, isA<AppException>());
        expect(
          (caught! as AppException).message,
          'An account with this email already exists.',
        );
      },
      skip: true, // RED phase — RegistrationNotifier not yet implemented
    );

    // ─────────────────────────────────────────────────────────────────────────
    // 0.2-UNIT-003  [P1]
    // AC6: Client-side validation — invalid email format or password < 6
    //      chars should prevent the repository call entirely.
    // ─────────────────────────────────────────────────────────────────────────
    test(
      '[P1] 0.2-UNIT-003: client validation rejects blank/short password '
      'before calling repository',
      () async {
        // The notifier should validate and return early — repo is never called.
        // With RegistrationNotifier:
        //   await notifier.register(email: 'bad', password: '123');
        //   final state = container.read(registrationNotifierProvider);
        //   expect(state, isA<AsyncError>());
        //   verifyNever(() => mockRepo.register(email: any(), password: any()));

        // RED phase — repository should not be called for invalid inputs.
        verifyNever(() => mockRepo.register(
              email: any(named: 'email'),
              password: any(named: 'password'),
            ));
      },
      skip: true, // RED phase — RegistrationNotifier validation logic not yet implemented
    );
  });
}
