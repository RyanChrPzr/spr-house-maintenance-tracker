// test/core/app_exception_test.dart
//
// ATDD RED PHASE — Story 0.1: Flutter Project Initialisation & Backend Infrastructure
// Test IDs : 0.1-UNIT-001, 0.1-UNIT-002
// Priority : P0 (UNIT-001)  |  P1 (UNIT-002)
// Level    : Unit
//
// Verifies that AppException exists and carries a typed message, and that
// AppConstants exposes the correct Calm Blue seed colour.
//
// Framework: flutter_test
// Run command (once Flutter project exists):
//   flutter test test/core/app_exception_test.dart

// ignore_for_file: unused_import

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

// ── Production imports (RED phase — files do not exist yet) ──────────────────
// Uncomment once lib/core/ is in place:
//
// import 'package:spr_house_maintenance_tracker/core/exceptions/app_exception.dart';
// import 'package:spr_house_maintenance_tracker/core/app_constants.dart';

// ── Temporary stubs (delete once production code exists) ─────────────────────

class AppException implements Exception {
  AppException(this.message, {this.code});
  final String message;
  final String? code;
  @override
  String toString() => code != null
      ? 'AppException[$code]: $message'
      : 'AppException: $message';
}

class AppConstants {
  AppConstants._();
  static const Color calmBlue = Color(0xFF2E6BC6);
  static const Color trustBlue = Color(0xFF1B3A6B);
}

// ── Tests ─────────────────────────────────────────────────────────────────────

void main() {
  group('AppException — Story 0.1 (Unit)', () {
    // ─────────────────────────────────────────────────────────────────────────
    // 0.1-UNIT-001  [P0]
    // AC4: lib/core/exceptions/app_exception.dart exists and carries a typed
    //      message. Repositories catch PostgrestException and rethrow as
    //      AppException.
    // ─────────────────────────────────────────────────────────────────────────
    test(
      '[P0] 0.1-UNIT-001: AppException carries message and optional code',
      () {
        final ex = AppException('Something went wrong', code: 'DB_ERROR');
        expect(ex.message, 'Something went wrong');
        expect(ex.code, 'DB_ERROR');
        expect(ex, isA<Exception>());
      },
      skip: 'RED phase — lib/core/exceptions/app_exception.dart not yet created; '
          'remove skip: after Story 0.1 implementation',
    );

    test(
      '[P1] 0.1-UNIT-002: AppConstants.calmBlue equals #2E6BC6 seed colour',
      () {
        expect(AppConstants.calmBlue, const Color(0xFF2E6BC6));
        expect(AppConstants.trustBlue, const Color(0xFF1B3A6B));
      },
      skip: 'RED phase — lib/core/app_constants.dart not yet created; '
          'remove skip: after Story 0.1 implementation',
    );
  });
}
