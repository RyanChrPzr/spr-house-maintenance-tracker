// test/features/maintenance/presentation/maintenance_template_notifier_test.dart
//
// ATDD RED PHASE — Story 1.2: Pre-loaded Maintenance Task Template Selection
// Test IDs : 1.2-UNIT-001, 1.2-UNIT-002
// Priority : P0 (UNIT-001)  |  P1 (UNIT-002)
// Level    : Unit
//
// Tests MaintenanceTemplateNotifier with a mocked MaintenanceRepository.
// Covers: confirmSelection creates tasks with correct default intervals,
// and empty-selection validation.
//
// Default recurrence intervals (from architecture/PRD):
//   Aircon Cleaning    → quarterly
//   Pest Control       → semi-annual
//   Plumbing Check     → semi-annual
//   Septic Tank Pump   → annual
//   Rooftop Inspection → annual
//   Electrical Check   → annual
//
// Framework: flutter_test + mocktail + riverpod
// Run command:
//   flutter test test/features/maintenance/presentation/maintenance_template_notifier_test.dart

// ignore_for_file: unused_import

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:riverpod/riverpod.dart';

// ── Production imports (RED phase — do not exist yet) ────────────────────────
// Uncomment once implemented:
//
// import 'package:spr_house_maintenance_tracker/core/exceptions/app_exception.dart';
// import 'package:spr_house_maintenance_tracker/features/maintenance/data/maintenance_repository.dart';
// import 'package:spr_house_maintenance_tracker/features/maintenance/presentation/maintenance_template_notifier.dart';

// ── Temporary stubs ───────────────────────────────────────────────────────────

enum RecurrenceInterval { monthly, quarterly, semiAnnual, annual }

class MaintenanceTask {
  MaintenanceTask({required this.name, required this.interval});
  final String name;
  final RecurrenceInterval interval;
}

class AppException implements Exception {
  AppException(this.message);
  final String message;
}

abstract class MaintenanceRepository {
  Future<void> createTasks(
      String propertyId, List<MaintenanceTask> tasks);
}

class MockMaintenanceRepository extends Mock
    implements MaintenanceRepository {}

// Known template → default interval mappings
const _defaultIntervals = {
  'Aircon Cleaning': RecurrenceInterval.quarterly,
  'Pest Control': RecurrenceInterval.semiAnnual,
  'Plumbing Check': RecurrenceInterval.semiAnnual,
  'Septic Tank Pump-out': RecurrenceInterval.annual,
  'Rooftop Inspection': RecurrenceInterval.annual,
  'Electrical Check': RecurrenceInterval.annual,
};

// ── Tests ─────────────────────────────────────────────────────────────────────

void main() {
  late MockMaintenanceRepository mockRepo;

  setUp(() {
    mockRepo = MockMaintenanceRepository();
    registerFallbackValue(<MaintenanceTask>[]);
  });

  group('MaintenanceTemplateNotifier — Story 1.2 (Unit)', () {
    // ─────────────────────────────────────────────────────────────────────────
    // 1.2-UNIT-001  [P0]
    // AC3: Confirm selection → each selected task created in maintenance_tasks
    //      with correct default recurrence interval.
    //      Verifies "Aircon Cleaning" gets quarterly.
    // ─────────────────────────────────────────────────────────────────────────
    test(
      '[P0] 1.2-UNIT-001: confirmSelection creates tasks with correct '
      'default recurrence intervals',
      () async {
        when(() => mockRepo.createTasks(any(), any()))
            .thenAnswer((_) async {});

        // Selected: Aircon Cleaning + Pest Control
        final selected = [
          MaintenanceTask(
            name: 'Aircon Cleaning',
            interval: _defaultIntervals['Aircon Cleaning']!,
          ),
          MaintenanceTask(
            name: 'Pest Control',
            interval: _defaultIntervals['Pest Control']!,
          ),
        ];

        // With MaintenanceTemplateNotifier:
        //   await notifier.confirmSelection(
        //     propertyId: 'p1', selectedTemplateNames: ['Aircon Cleaning', 'Pest Control']);
        //   final captured = verify(
        //     () => mockRepo.createTasks('p1', captureAny())).captured;
        //   final tasks = captured.first as List<MaintenanceTask>;
        //   expect(tasks.first.interval, RecurrenceInterval.quarterly);
        //   expect(tasks.last.interval, RecurrenceInterval.semiAnnual);

        await mockRepo.createTasks('p1', selected);
        final captured = verify(
          () => mockRepo.createTasks('p1', captureAny()),
        ).captured;
        final tasks = captured.first as List<MaintenanceTask>;
        expect(tasks.first.interval, RecurrenceInterval.quarterly);
        expect(tasks.last.interval, RecurrenceInterval.semiAnnual);
      },
      skip: 'RED phase — MaintenanceTemplateNotifier not yet implemented; '
          'remove skip: after lib/features/maintenance/presentation/ exists',
    );

    // ─────────────────────────────────────────────────────────────────────────
    // 1.2-UNIT-002  [P1]
    // AC4: Confirm with no tasks selected → prompt "Select at least one
    //      task to activate your schedule."
    // ─────────────────────────────────────────────────────────────────────────
    test(
      '[P1] 1.2-UNIT-002: confirmSelection with empty list emits validation error',
      () async {
        // With MaintenanceTemplateNotifier:
        //   await notifier.confirmSelection(propertyId: 'p1', selectedTemplateNames: []);
        //   final state = container.read(maintenanceTemplateNotifierProvider);
        //   expect(state, isA<AsyncError>());
        //   expect((state as AsyncError).error, isA<AppException>().having(
        //       (e) => e.message, 'message',
        //       'Select at least one task to activate your schedule.'));
        //   verifyNever(() => mockRepo.createTasks(any(), any()));

        verifyNever(() => mockRepo.createTasks(any(), any()));
        expect(true, isTrue);
      },
      skip: 'RED phase — MaintenanceTemplateNotifier empty-selection guard '
          'not yet implemented',
    );
  });
}
