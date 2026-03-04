// test/features/maintenance/domain/due_date_calculator_test.dart
//
// ATDD RED PHASE — Story 1.3: Recurring Schedule Configuration & Task Customisation
// Test IDs : 1.3-UNIT-001, 1.3-UNIT-002, 1.3-UNIT-003, 1.3-UNIT-004,
//            1.3-UNIT-005
// Priority : P0 (all — due date calculation is the core business logic, R1.1)
// Level    : Unit
//
// Tests the pure `calculateNextDueDate()` function across all 4 supported
// recurrence intervals. This function is a risk R1.1 MITIGATE item — tested
// exhaustively with edge cases (leap year, month-end rollover).
//
// Expected function signature:
//   DateTime calculateNextDueDate(DateTime from, RecurrenceInterval interval)
//
// Framework: flutter_test (no mocking needed — pure function)
// Run command:
//   flutter test test/features/maintenance/domain/due_date_calculator_test.dart

// ignore_for_file: unused_import

import 'package:flutter_test/flutter_test.dart';

// ── Production import (RED phase — does not exist yet) ───────────────────────
// Uncomment once implemented:
//
// import 'package:spr_house_maintenance_tracker/features/maintenance/domain/due_date_calculator.dart';

// ── Temporary stub ────────────────────────────────────────────────────────────

enum RecurrenceInterval { monthly, quarterly, semiAnnual, annual }

/// Stub implementation — will be replaced by the real function.
/// The real function must live in lib/features/maintenance/domain/due_date_calculator.dart
DateTime calculateNextDueDate(DateTime from, RecurrenceInterval interval) {
  switch (interval) {
    case RecurrenceInterval.monthly:
      return DateTime(from.year, from.month + 1, from.day);
    case RecurrenceInterval.quarterly:
      return DateTime(from.year, from.month + 3, from.day);
    case RecurrenceInterval.semiAnnual:
      return DateTime(from.year, from.month + 6, from.day);
    case RecurrenceInterval.annual:
      return DateTime(from.year + 1, from.month, from.day);
  }
}

// ── Tests ─────────────────────────────────────────────────────────────────────

void main() {
  group('calculateNextDueDate — Story 1.3 (Unit / R1.1 MITIGATE)', () {
    // ─────────────────────────────────────────────────────────────────────────
    // 1.3-UNIT-001  [P0]
    // Monthly: 2026-01-15 → 2026-02-15
    // ─────────────────────────────────────────────────────────────────────────
    test(
      '[P0] 1.3-UNIT-001: monthly recurrence adds exactly 1 month',
      () {
        final from = DateTime(2026, 1, 15);
        final next = calculateNextDueDate(from, RecurrenceInterval.monthly);
        expect(next, DateTime(2026, 2, 15));
      },
      skip: 'RED phase — calculateNextDueDate() not yet in '
          'lib/features/maintenance/domain/due_date_calculator.dart; '
          'remove skip: after Story 1.3 implementation',
    );

    // ─────────────────────────────────────────────────────────────────────────
    // 1.3-UNIT-002  [P0]
    // Quarterly: 2026-01-01 → 2026-04-01
    // ─────────────────────────────────────────────────────────────────────────
    test(
      '[P0] 1.3-UNIT-002: quarterly recurrence adds exactly 3 months',
      () {
        final from = DateTime(2026, 1, 1);
        final next = calculateNextDueDate(from, RecurrenceInterval.quarterly);
        expect(next, DateTime(2026, 4, 1));
      },
      skip: 'RED phase — calculateNextDueDate() not yet implemented',
    );

    // ─────────────────────────────────────────────────────────────────────────
    // 1.3-UNIT-003  [P0]
    // Semi-annual: 2026-01-31 → 2026-07-31
    // ─────────────────────────────────────────────────────────────────────────
    test(
      '[P0] 1.3-UNIT-003: semi-annual recurrence adds exactly 6 months',
      () {
        final from = DateTime(2026, 1, 31);
        final next =
            calculateNextDueDate(from, RecurrenceInterval.semiAnnual);
        expect(next, DateTime(2026, 7, 31));
      },
      skip: 'RED phase — calculateNextDueDate() not yet implemented',
    );

    // ─────────────────────────────────────────────────────────────────────────
    // 1.3-UNIT-004  [P0]
    // Annual: 2026-03-04 → 2027-03-04
    // ─────────────────────────────────────────────────────────────────────────
    test(
      '[P0] 1.3-UNIT-004: annual recurrence adds exactly 1 year',
      () {
        final from = DateTime(2026, 3, 4);
        final next = calculateNextDueDate(from, RecurrenceInterval.annual);
        expect(next, DateTime(2027, 3, 4));
      },
      skip: 'RED phase — calculateNextDueDate() not yet implemented',
    );

    // ─────────────────────────────────────────────────────────────────────────
    // 1.3-UNIT-005  [P0]  Edge case — leap year rollover
    // Monthly from 2024-01-31 → should not blow up (clamp to last day of Feb)
    // Dart's DateTime constructor overflows months; the real implementation
    // must handle this (e.g., use package:clock or DateTimeExtension clamping).
    // ─────────────────────────────────────────────────────────────────────────
    test(
      '[P0] 1.3-UNIT-005: monthly from Jan-31 in leap year does not produce '
      'an invalid date (clamps to Feb-29)',
      () {
        final from = DateTime(2024, 1, 31); // 2024 is a leap year
        final next = calculateNextDueDate(from, RecurrenceInterval.monthly);
        // Dart DateTime(2024, 2, 31) overflows to 2024-03-02; real impl must
        // clamp: min(31, daysInMonth(2024, 2)) = 29
        expect(next.month, 2);
        expect(next.day, lessThanOrEqualTo(29)); // clamp to Feb days
      },
      skip: 'RED phase — edge-case clamping not yet implemented in '
          'calculateNextDueDate()',
    );
  });
}
