// Test helpers for spr_house_maintenance_tracker
//
// Shared test helpers and mock infrastructure for ATDD tests.
//
// Add mock Supabase client setup and shared test utilities here
// as stories are implemented (starting from Story 1.2).

import 'package:mocktail/mocktail.dart';

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

// ignore: unused_element
final _placeholder = _PlaceholderMock();
