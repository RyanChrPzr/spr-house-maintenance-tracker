// integration_test/registration_test.dart
//
// ATDD RED PHASE — Story 0.2: User Registration & Role Selection
// Test IDs : 0.2-INT-001, 0.2-INT-002, 0.2-INT-003
// Priority : P0 (INT-001, INT-002, INT-003)
// Level    : Integration
//
// Full-app integration tests for registration + role selection flow.
// All tests are skipped until implementation is complete.
//
// Run command:
//   flutter test integration_test/registration_test.dart \
//     --dart-define=SUPABASE_URL=<test-url> \
//     --dart-define=SUPABASE_ANON_KEY=<test-key> \
//     -d <device-id>
//
// Widget keys expected in implementation:
//   Key('email_field')             — TextField on RegisterScreen
//   Key('password_field')          — TextField on RegisterScreen
//   Key('register_button')         — Submit button on RegisterScreen
//   Key('register_error_text')     — Inline error Text on RegisterScreen
//   Key('role_homeowner_button')   — "I am a Homeowner" on RoleSelectionScreen
//   Key('role_vendor_button')      — "I am a Vendor" on RoleSelectionScreen
//   Key('homeowner_dashboard')     — Root widget of HomeownerDashboardScreen
//   Key('vendor_onboarding')       — Root widget of VendorOnboardingScreen
//
// Supabase test seed data: none required (fresh registration each run)
// Note: Use unique email per test run (timestamp-based or UUID suffix)

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

// Production import (RED phase — does not exist yet):
// import 'package:spr_house_maintenance_tracker/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  // ── Helpers ───────────────────────────────────────────────────────────────

  /// Navigate through registration form. Call after app is launched.
  Future<void> fillRegistrationForm(
    WidgetTester tester, {
    required String email,
    required String password,
  }) async {
    await tester.enterText(find.byKey(const Key('email_field')), email);
    await tester.enterText(find.byKey(const Key('password_field')), password);
    await tester.tap(find.byKey(const Key('register_button')));
    await tester.pumpAndSettle(const Duration(seconds: 5));
  }

  // ─────────────────────────────────────────────────────────────────────────
  // 0.2-INT-001  [P0]
  // AC2 + AC3: Register → role selection → "I am a Homeowner" → dashboard.
  // ─────────────────────────────────────────────────────────────────────────
  testWidgets(
    '[P0] 0.2-INT-001: new user registers and selects homeowner role → '
    '/homeowner/dashboard',
    (WidgetTester tester) async {
      // app.main();
      // await tester.pumpAndSettle();

      // Register with unique email
      // final email = 'test_ho_${DateTime.now().millisecondsSinceEpoch}@test.spr.ph';
      // await fillRegistrationForm(tester, email: email, password: 'ValidPass1!');

      // Assert — role selection screen
      // expect(find.byKey(const Key('role_homeowner_button')), findsOneWidget);
      // expect(find.byKey(const Key('role_vendor_button')), findsOneWidget);

      // Select homeowner
      // await tester.tap(find.byKey(const Key('role_homeowner_button')));
      // await tester.pumpAndSettle(const Duration(seconds: 3));

      // Assert — homeowner dashboard
      // expect(find.byKey(const Key('homeowner_dashboard')), findsOneWidget);

      expect(true, isFalse,
          reason:
              '0.2-INT-001 RED: RegisterScreen / RoleSelectionScreen not implemented');
    },
    skip:
        true, // RED phase — RegisterScreen, RoleSelectionScreen, and homeowner route not implemented yet
  );

  // ─────────────────────────────────────────────────────────────────────────
  // 0.2-INT-002  [P0]
  // AC2 + AC4: Register → role selection → "I am a Vendor" →
  //            /vendor/onboarding.
  // ─────────────────────────────────────────────────────────────────────────
  testWidgets(
    '[P0] 0.2-INT-002: new user registers and selects vendor role → '
    '/vendor/onboarding',
    (WidgetTester tester) async {
      // app.main();
      // await tester.pumpAndSettle();
      // final email = 'test_v_${DateTime.now().millisecondsSinceEpoch}@test.spr.ph';
      // await fillRegistrationForm(tester, email: email, password: 'ValidPass1!');
      // await tester.tap(find.byKey(const Key('role_vendor_button')));
      // await tester.pumpAndSettle(const Duration(seconds: 3));
      // expect(find.byKey(const Key('vendor_onboarding')), findsOneWidget);

      expect(true, isFalse,
          reason: '0.2-INT-002 RED: VendorOnboardingScreen not implemented');
    },
    skip:
        true, // RED phase — RegisterScreen, RoleSelectionScreen, and vendor onboarding route not implemented yet
  );

  // ─────────────────────────────────────────────────────────────────────────
  // 0.2-INT-003  [P0]
  // AC5: Duplicate email → inline error shown on RegisterScreen.
  // ─────────────────────────────────────────────────────────────────────────
  testWidgets(
    '[P0] 0.2-INT-003: duplicate email shows inline error on RegisterScreen',
    (WidgetTester tester) async {
      // app.main();
      // await tester.pumpAndSettle();

      // Seed email must exist in test Supabase instance
      // await fillRegistrationForm(
      //   tester,
      //   email: 'existing@test.spr.ph',
      //   password: 'ValidPass1!',
      // );

      // Assert — still on register screen, error visible
      // expect(find.byKey(const Key('register_error_text')), findsOneWidget);
      // expect(
      //   find.text('An account with this email already exists.'),
      //   findsOneWidget,
      // );

      expect(true, isFalse,
          reason:
              '0.2-INT-003 RED: RegisterScreen inline error not implemented');
    },
    skip:
        true, // RED phase — RegistrationNotifier error handling + RegisterScreen Key(register_error_text) not implemented yet
  );
}
