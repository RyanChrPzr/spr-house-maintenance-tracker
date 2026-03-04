// integration_test/template_selection_test.dart
//
// ATDD RED PHASE — Story 1.2: Pre-loaded Maintenance Task Template Selection
// Test IDs : 1.2-INT-001, 1.2-INT-002
// Priority : P0
// Level    : Integration
//
// Run command:
//   flutter test integration_test/template_selection_test.dart \
//     --dart-define=SUPABASE_URL=<test-url> \
//     --dart-define=SUPABASE_ANON_KEY=<test-key> \
//     -d <device-id>
//
// Widget keys expected in implementation:
//   Key('template_aircon')          — Aircon Cleaning task chip/tile
//   Key('template_pest')            — Pest Control chip/tile
//   Key('template_plumbing')        — Plumbing Check chip/tile
//   Key('template_septic')          — Septic Tank Pump-out chip/tile
//   Key('template_rooftop')         — Rooftop Inspection chip/tile
//   Key('template_electrical')      — Electrical Check chip/tile
//   Key('template_confirm_button')  — "Confirm Selection" button
//   Key('template_empty_error')     — Inline prompt text when none selected
//   Key('homeowner_tasks_screen')   — Root widget of /homeowner/tasks
//
// Pre-conditions: homeowner logged in + property setup already completed.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

// import 'package:spr_house_maintenance_tracker/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  // ─────────────────────────────────────────────────────────────────────────
  // 1.2-INT-001  [P0]
  // AC1 + AC2 + AC3: All 6 templates shown; select Aircon + Pest; confirm
  // → tasks created with correct intervals → /homeowner/tasks.
  // ─────────────────────────────────────────────────────────────────────────
  testWidgets(
    '[P0] 1.2-INT-001: all 6 Filipino task templates shown; selecting and '
    'confirming navigates to /homeowner/tasks',
    (WidgetTester tester) async {
      // app.main();
      // await tester.pumpAndSettle();

      // Assert all 6 templates present
      // for (final key in [
      //   'template_aircon', 'template_pest', 'template_plumbing',
      //   'template_septic', 'template_rooftop', 'template_electrical',
      // ]) {
      //   expect(find.byKey(Key(key)), findsOneWidget);
      // }

      // Select two tasks
      // await tester.tap(find.byKey(const Key('template_aircon')));
      // await tester.tap(find.byKey(const Key('template_pest')));
      // await tester.tap(find.byKey(const Key('template_confirm_button')));
      // await tester.pumpAndSettle(const Duration(seconds: 5));

      // Assert navigated to tasks screen
      // expect(find.byKey(const Key('homeowner_tasks_screen')), findsOneWidget);

      expect(true, isFalse,
          reason: '1.2-INT-001 RED: TaskTemplateSelectionScreen not yet implemented');
    },
    skip: true, // RED phase — TaskTemplateSelectionScreen + MaintenanceTemplateNotifier not yet implemented
  );

  // ─────────────────────────────────────────────────────────────────────────
  // 1.2-INT-002  [P0]
  // AC4: No templates selected → prompt "Select at least one task to
  //      activate your schedule."
  // ─────────────────────────────────────────────────────────────────────────
  testWidgets(
    '[P0] 1.2-INT-002: confirming with no selection shows validation prompt',
    (WidgetTester tester) async {
      // app.main();
      // await tester.pumpAndSettle();
      // await tester.tap(find.byKey(const Key('template_confirm_button')));
      // await tester.pumpAndSettle();
      // expect(
      //   find.text('Select at least one task to activate your schedule.'),
      //   findsOneWidget,
      // );

      expect(true, isFalse,
          reason: '1.2-INT-002 RED: TaskTemplateSelectionScreen empty-selection '
              'guard not yet implemented');
    },
    skip: true, // RED phase — TaskTemplateSelectionScreen validation prompt not yet implemented
  );
}
