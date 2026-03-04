// test/helpers/test_helpers.dart
//
// Shared test helpers and mock infrastructure for Story 0.3 ATDD tests.
// RED phase — production code does not exist yet.
//
// Usage:
//   import 'package:spr_house_maintenance_tracker/test/helpers/test_helpers.dart';

import 'package:mocktail/mocktail.dart';

// ---------------------------------------------------------------------------
// Mock declarations
// ---------------------------------------------------------------------------
//
// These mocks reference production interfaces that DO NOT EXIST YET.
// Once `AuthRepository` is created under lib/features/auth/data/, these
// will compile and the `skip:` guards can be removed from the tests.
//
// import 'package:spr_house_maintenance_tracker/features/auth/data/auth_repository.dart';
// class MockAuthRepository extends Mock implements AuthRepository {}

// ---------------------------------------------------------------------------
// Test data constants
// ---------------------------------------------------------------------------

class AuthTestData {
  AuthTestData._();

  static const String homeownerEmail = 'homeowner@test.spr.ph';
  static const String vendorEmail = 'vendor@test.spr.ph';
  static const String testPassword = 'Test1234!';
  static const String wrongEmail = 'wrong@example.com';
  static const String wrongPassword = 'wrongpassword';
  static const String incorrectCredentialsMessage =
      'Incorrect email or password.';
}

// ---------------------------------------------------------------------------
// Placeholder to keep the file compilable before production code exists.
// ---------------------------------------------------------------------------

/// Remove this when production imports above are uncommented.
class _PlaceholderMock extends Mock {}

final _placeholder = _PlaceholderMock(); // ignore: unused_field
