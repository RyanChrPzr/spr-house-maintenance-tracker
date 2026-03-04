// integration_test/setup_test.dart
//
// ATDD RED PHASE — Story 0.1: Flutter Project Initialisation & Backend Infrastructure
// Test IDs : 0.1-INT-001
// Priority : P0
// Level    : Integration
//
// Verifies that the app boots, initialises Supabase, and routes an
// unauthenticated user to /auth/login with the login/register screen visible.
//
// Run command (once Flutter project exists):
//   flutter test integration_test/setup_test.dart \
//     --dart-define=SUPABASE_URL=<test-url> \
//     --dart-define=SUPABASE_ANON_KEY=<test-key> \
//     -d <device-id>
//
// Widget keys expected in implementation:
//   Key('login_button')    — on LoginScreen
//   Key('register_button') — on LoginScreen or RegisterScreen

import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

// Production import — does not exist yet (RED phase):
// import 'package:spr_house_maintenance_tracker/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Story 0.1 — Project Setup & Boot (RED phase)', () {
    // ─────────────────────────────────────────────────────────────────────────
    // 0.1-INT-001  [P0]
    // AC1: App compiles and launches. AC2: env vars accessible.
    // Unauthenticated user lands on /auth/login (go_router redirect).
    // ─────────────────────────────────────────────────────────────────────────
    testWidgets(
      '[P0] 0.1-INT-001: app boots and routes unauthenticated user to /auth/login',
      (WidgetTester tester) async {
        // Arrange — launch app
        // app.main();
        // await tester.pumpAndSettle();

        // Assert — login/register screen is visible; no homeowner/vendor UI
        // expect(find.byKey(const Key('login_button')), findsOneWidget);
        // expect(find.byKey(const Key('homeowner_dashboard')), findsNothing);
        // expect(find.byKey(const Key('vendor_dashboard')), findsNothing);

        expect(true, isFalse,
            reason: '0.1-INT-001 RED: main.dart / LoginScreen not yet created');
      },
      skip: 'RED phase — main.dart, Supabase init, and go_router skeleton not '
          'yet created; remove skip: after Story 0.1 implementation',
    );
  });
}
