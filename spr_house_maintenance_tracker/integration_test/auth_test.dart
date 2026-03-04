// integration_test/auth_test.dart
//
// ATDD RED PHASE — Story 0.3: User Login & Role-Based Navigation
// Test IDs : 0.3-INT-001, 0.3-INT-002, 0.3-INT-003
// Priority : P0 (INT-001, INT-002)  |  P1 (INT-003)
// Level    : Integration
//
// Runs on a real device or emulator via:
//   flutter test integration_test/auth_test.dart \
//     --dart-define=SUPABASE_URL=<test-url> \
//     --dart-define=SUPABASE_ANON_KEY=<test-key>
//
// Tests are SKIPPED with `skip:` because the app is not yet implemented.
// TDD cycle:
//   RED   ← you are here
//   GREEN → remove `skip:` after LoginScreen + go_router guards are implemented
//   REFACTOR → keep tests green while improving code quality
//
// Key Flutter widget identifiers expected in the implementation:
//   Key('email_field')         — TextField for email input
//   Key('password_field')      — TextField for password input
//   Key('login_button')        — ElevatedButton / FilledButton to submit
//   Key('login_error_text')    — Text widget showing inline error
//   Key('homeowner_dashboard') — root widget of HomeownerDashboardScreen
//   Key('vendor_dashboard')    — root widget of VendorDashboardScreen
//
// Supabase test seed data (seeded via migration / Makefile before test run):
//   homeowner@test.spr.ph / Test1234!  — role: homeowner
//   vendor@test.spr.ph    / Test1234!  — role: vendor

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

// Production import — main.dart does not exist yet (RED phase).
// Uncomment once the Flutter project is initialised:
// import 'package:spr_house_maintenance_tracker/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  // ── Test data ─────────────────────────────────────────────────────────────
  const homeownerEmail = 'homeowner@test.spr.ph';
  const vendorEmail = 'vendor@test.spr.ph';
  const testPassword = 'Test1234!';

  // ── Helper: log in via the UI ─────────────────────────────────────────────
  // Extracted to avoid duplication across INT-001, INT-002, INT-003.
  // Expects the login screen to already be visible.
  Future<void> performLogin(
    WidgetTester tester, {
    required String email,
    required String password,
  }) async {
    await tester.enterText(find.byKey(const Key('email_field')), email);
    await tester.enterText(find.byKey(const Key('password_field')), password);
    await tester.tap(find.byKey(const Key('login_button')));
    // pumpAndSettle waits for all animations and async gaps to complete.
    // Supabase auth response is awaited by the notifier before navigation.
    await tester.pumpAndSettle(const Duration(seconds: 5));
  }

  // ─────────────────────────────────────────────────────────────────────────
  // 0.3-INT-001  [P0]
  // AC1: Homeowner with valid credentials lands on /homeowner/dashboard.
  // ─────────────────────────────────────────────────────────────────────────
  testWidgets(
    '[P0] 0.3-INT-001: homeowner login navigates to homeowner dashboard',
    (WidgetTester tester) async {
      // Arrange — launch the full app
      // app.main();  // ← uncomment once main.dart exists
      // await tester.pumpAndSettle();

      // Pre-condition: login screen is visible
      // expect(find.byKey(const Key('login_button')), findsOneWidget);

      // Act — submit homeowner credentials
      // await performLogin(tester, email: homeownerEmail, password: testPassword);

      // Assert — homeowner dashboard rendered; vendor dashboard absent
      // expect(find.byKey(const Key('homeowner_dashboard')), findsOneWidget);
      // expect(find.byKey(const Key('vendor_dashboard')), findsNothing);
      // expect(find.byKey(const Key('login_button')), findsNothing);

      // RED phase stub — will fail once skip is removed and implementation absent
      expect(true, isFalse,
          reason: '0.3-INT-001 RED: HomeownerDashboardScreen not implemented');
    },
    skip: true, // RED phase — LoginScreen, AuthNotifier, and go_router homeowner route not implemented yet
  );

  // ─────────────────────────────────────────────────────────────────────────
  // 0.3-INT-002  [P0]
  // AC1: Vendor with valid credentials lands on /vendor/dashboard.
  // ─────────────────────────────────────────────────────────────────────────
  testWidgets(
    '[P0] 0.3-INT-002: vendor login navigates to vendor dashboard',
    (WidgetTester tester) async {
      // Arrange
      // app.main();
      // await tester.pumpAndSettle();
      // expect(find.byKey(const Key('login_button')), findsOneWidget);

      // Act
      // await performLogin(tester, email: vendorEmail, password: testPassword);

      // Assert — vendor dashboard rendered; homeowner dashboard absent
      // expect(find.byKey(const Key('vendor_dashboard')), findsOneWidget);
      // expect(find.byKey(const Key('homeowner_dashboard')), findsNothing);
      // expect(find.byKey(const Key('login_button')), findsNothing);

      expect(true, isFalse,
          reason: '0.3-INT-002 RED: VendorDashboardScreen not implemented');
    },
    skip: true, // RED phase — LoginScreen, AuthNotifier, and go_router vendor route not implemented yet
  );

  // ─────────────────────────────────────────────────────────────────────────
  // 0.3-INT-003  [P1]
  // AC2: An already-authenticated user who relaunches the app is taken
  //      directly to their role-appropriate dashboard (session persistence
  //      via Supabase's persisted auth token + go_router redirect guard).
  //
  // Implementation note:
  //   Supabase Flutter SDK stores the session in SharedPreferences/Keychain
  //   automatically.  go_router's redirect callback reads
  //   supabase.auth.currentSession to decide the initial route.
  //   A true cold-start test requires two separate integration_test runs
  //   (run 1: log in; run 2: verify redirect).  This single-run test
  //   approximates the behaviour by re-pumping the app widget tree without
  //   calling signOut(), which exercises the same go_router redirect path.
  // ─────────────────────────────────────────────────────────────────────────
  testWidgets(
    '[P1] 0.3-INT-003: authenticated session persists across app relaunch',
    (WidgetTester tester) async {
      // Arrange — first launch, sign in as homeowner
      // app.main();
      // await tester.pumpAndSettle();
      // await performLogin(tester, email: homeownerEmail, password: testPassword);
      // expect(find.byKey(const Key('homeowner_dashboard')), findsOneWidget);

      // Act — simulate relaunch by re-pumping the app without signing out
      // await tester.pumpWidget(app.buildApp());  // re-creates widget tree
      // await tester.pumpAndSettle();

      // Assert — lands on dashboard; login screen not shown
      // expect(find.byKey(const Key('homeowner_dashboard')), findsOneWidget);
      // expect(find.byKey(const Key('login_button')), findsNothing);

      expect(true, isFalse,
          reason: '0.3-INT-003 RED: session persistence guard in go_router '
              'not implemented yet');
    },
    skip: true, // RED phase — go_router redirect guard (reads supabase.auth.currentSession) not implemented yet
  );
}
