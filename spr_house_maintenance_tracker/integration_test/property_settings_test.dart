// integration_test/property_settings_test.dart
//
// ATDD RED PHASE — Story 1.4: Property Settings Edit
// Test IDs : 1.4-INT-001
// Priority : P0
// Level    : Integration
//
// Run command:
//   flutter test integration_test/property_settings_test.dart \
//     --dart-define=SUPABASE_URL=<test-url> \
//     --dart-define=SUPABASE_ANON_KEY=<test-key> \
//     -d <device-id>
//
// Widget keys expected in implementation:
//   Key('settings_nav_item')          — Settings tab / menu item in homeowner nav
//   Key('my_property_section')        — "My Property" section on SettingsScreen
//   Key('property_type_condo')        — PropertyType.condo selector
//   Key('property_age_field')         — Age TextField on settings edit form
//   Key('property_settings_save')     — Save button on property settings screen
//   Key('property_type_display')      — Text showing current property type on settings
//
// Pre-conditions: homeowner logged in + existing property (type: house, age: 5).

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

// import 'package:spr_house_maintenance_tracker/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  // ─────────────────────────────────────────────────────────────────────────
  // 1.4-INT-001  [P0]
  // AC1 + AC2: Navigate to settings → "My Property" section visible →
  // change property type from house to condo + update age → save →
  // change reflected in settings immediately.
  // ─────────────────────────────────────────────────────────────────────────
  testWidgets(
    '[P0] 1.4-INT-001: homeowner can update property type and age from settings',
    (WidgetTester tester) async {
      // app.main();
      // await tester.pumpAndSettle();

      // Navigate to settings
      // await tester.tap(find.byKey(const Key('settings_nav_item')));
      // await tester.pumpAndSettle();
      // expect(find.byKey(const Key('my_property_section')), findsOneWidget);

      // Change type to condo, update age
      // await tester.tap(find.byKey(const Key('property_type_condo')));
      // await tester.enterText(find.byKey(const Key('property_age_field')), '10');
      // await tester.tap(find.byKey(const Key('property_settings_save')));
      // await tester.pumpAndSettle(const Duration(seconds: 3));

      // Assert — settings now shows condo
      // expect(find.text('Condo'), findsOneWidget);

      expect(true, isFalse,
          reason: '1.4-INT-001 RED: Property settings edit screen not yet implemented');
    },
    skip: true, // RED phase — PropertySettingsScreen + PropertyNotifier.updateProperty() not yet implemented
  );
}
