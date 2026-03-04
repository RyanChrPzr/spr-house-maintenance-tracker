// integration_test/property_setup_test.dart
//
// ATDD RED PHASE — Story 1.1: Property Setup Onboarding Flow
// Test IDs : 1.1-INT-001, 1.1-INT-002
// Priority : P0
// Level    : Integration
//
// Full-app integration tests for property setup flow.
//
// Run command:
//   flutter test integration_test/property_setup_test.dart \
//     --dart-define=SUPABASE_URL=<test-url> \
//     --dart-define=SUPABASE_ANON_KEY=<test-key> \
//     -d <device-id>
//
// Widget keys expected in implementation:
//   Key('property_type_house')        — PropertyType.house selection chip/button
//   Key('property_type_condo')        — PropertyType.condo selection chip/button
//   Key('property_type_lot')          — PropertyType.lot selection chip/button
//   Key('property_age_field')         — Optional age TextField
//   Key('property_save_button')       — Save / Continue button
//   Key('property_type_error')        — Inline validation error Text
//   Key('task_template_screen')       — Root widget of TaskTemplateSelectionScreen
//
// Pre-conditions: User logged in as homeowner with no property set up.
// Seed: homeowner@setup.test.spr.ph / Test1234! (no property record)

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

// import 'package:spr_house_maintenance_tracker/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  // ─────────────────────────────────────────────────────────────────────────
  // 1.1-INT-001  [P0]
  // AC1 + AC2 + AC4: First-time homeowner is redirected to property setup;
  // selects "House" + age 5; saves → properties row created + tasks seeded
  // → navigated to task template selection screen.
  // ─────────────────────────────────────────────────────────────────────────
  testWidgets(
    '[P0] 1.1-INT-001: first-time homeowner completes property setup and '
    'lands on task template selection screen',
    (WidgetTester tester) async {
      // app.main();
      // await tester.pumpAndSettle();

      // Pre-condition: after login, property setup screen is shown
      // expect(find.byKey(const Key('property_save_button')), findsOneWidget);

      // Select property type
      // await tester.tap(find.byKey(const Key('property_type_house')));
      // await tester.enterText(find.byKey(const Key('property_age_field')), '5');
      // await tester.tap(find.byKey(const Key('property_save_button')));
      // await tester.pumpAndSettle(const Duration(seconds: 5));

      // Assert — task template screen shown
      // expect(find.byKey(const Key('task_template_screen')), findsOneWidget);

      expect(true, isFalse,
          reason: '1.1-INT-001 RED: PropertySetupScreen not yet implemented');
    },
    skip: true, // RED phase — PropertySetupScreen + PropertyNotifier + go_router first-property redirect not implemented yet
  );

  // ─────────────────────────────────────────────────────────────────────────
  // 1.1-INT-002  [P0]
  // AC3: Tapping Save without selecting a property type shows validation
  //      error "Please select a property type."
  // ─────────────────────────────────────────────────────────────────────────
  testWidgets(
    '[P0] 1.1-INT-002: tapping Save without property type shows validation error',
    (WidgetTester tester) async {
      // app.main();
      // await tester.pumpAndSettle();

      // Tap Save without selecting type
      // await tester.tap(find.byKey(const Key('property_save_button')));
      // await tester.pumpAndSettle();

      // Assert — still on setup screen, error visible
      // expect(find.byKey(const Key('property_type_error')), findsOneWidget);
      // expect(find.text('Please select a property type.'), findsOneWidget);

      expect(true, isFalse,
          reason: '1.1-INT-002 RED: PropertySetupScreen validation not implemented');
    },
    skip: true, // RED phase — PropertySetupScreen inline validation not implemented yet
  );
}
