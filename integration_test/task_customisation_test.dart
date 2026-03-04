// integration_test/task_customisation_test.dart
//
// ATDD RED PHASE — Story 1.3: Recurring Schedule Configuration & Task Customisation
// Test IDs : 1.3-INT-001, 1.3-INT-002
// Priority : P0
// Level    : Integration
//
// Run command:
//   flutter test integration_test/task_customisation_test.dart \
//     --dart-define=SUPABASE_URL=<test-url> \
//     --dart-define=SUPABASE_ANON_KEY=<test-key> \
//     -d <device-id>
//
// Widget keys expected in implementation:
//   Key('task_card_{taskId}')          — TaskCardWidget in task list (use first available)
//   Key('task_name_field')             — Task name TextField on task detail screen
//   Key('task_interval_dropdown')      — RecurrenceInterval DropdownButton
//   Key('task_notes_field')            — Notes TextField
//   Key('task_next_due_date_text')     — Text showing next due date
//   Key('task_save_button')            — Save button on task detail screen
//   Key('task_add_button')             — "Add Task" FAB/button on task list
//   Key('homeowner_tasks_screen')      — Root of /homeowner/tasks
//
// Pre-conditions: homeowner logged in + at least one task in maintenance_tasks.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

// import 'package:spr_house_maintenance_tracker/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  // ─────────────────────────────────────────────────────────────────────────
  // 1.3-INT-001  [P0]
  // AC2: Change recurrence interval → next due date recalculated immediately.
  // ─────────────────────────────────────────────────────────────────────────
  testWidgets(
    '[P0] 1.3-INT-001: changing recurrence interval updates next due date '
    'on task detail screen',
    (WidgetTester tester) async {
      // app.main();
      // await tester.pumpAndSettle();

      // Tap first task card to open detail screen
      // await tester.tap(find.byKey(const Key('task_card_0')));
      // await tester.pumpAndSettle();

      // Record current next due date text
      // final currentDue = tester.widget<Text>(
      //   find.byKey(const Key('task_next_due_date_text'))).data;

      // Change interval via dropdown
      // await tester.tap(find.byKey(const Key('task_interval_dropdown')));
      // await tester.pumpAndSettle();
      // await tester.tap(find.text('Monthly'));
      // await tester.pumpAndSettle();

      // Assert — next due date text has changed
      // final newDue = tester.widget<Text>(
      //   find.byKey(const Key('task_next_due_date_text'))).data;
      // expect(newDue, isNot(equals(currentDue)));

      expect(true, isFalse,
          reason: '1.3-INT-001 RED: TaskDetailScreen + RecurrenceInterval '
              'dropdown not yet implemented');
    },
    skip: 'RED phase — TaskDetailScreen + RecurrenceInterval dropdown '
        'not yet implemented',
  );

  // ─────────────────────────────────────────────────────────────────────────
  // 1.3-INT-002  [P0]
  // AC3: Update task name + notes → save → changes visible in task list.
  // ─────────────────────────────────────────────────────────────────────────
  testWidgets(
    '[P0] 1.3-INT-002: updating task name and notes is reflected in task list',
    (WidgetTester tester) async {
      // app.main();
      // await tester.pumpAndSettle();

      // await tester.tap(find.byKey(const Key('task_card_0')));
      // await tester.pumpAndSettle();

      // Update name
      // await tester.enterText(
      //   find.byKey(const Key('task_name_field')), 'Custom Aircon Clean');
      // await tester.enterText(
      //   find.byKey(const Key('task_notes_field')), 'Split-type only');
      // await tester.tap(find.byKey(const Key('task_save_button')));
      // await tester.pumpAndSettle(const Duration(seconds: 3));

      // Assert — back on task list with updated name
      // expect(find.text('Custom Aircon Clean'), findsOneWidget);

      expect(true, isFalse,
          reason: '1.3-INT-002 RED: TaskDetailScreen save + list refresh '
              'not yet implemented');
    },
    skip: 'RED phase — TaskDetailScreen name/notes edit not yet implemented',
  );
}
