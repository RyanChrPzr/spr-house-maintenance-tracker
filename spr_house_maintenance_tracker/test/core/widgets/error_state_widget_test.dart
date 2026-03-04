// test/core/widgets/error_state_widget_test.dart
//
// ATDD RED PHASE — Story 0.1: Flutter Project Initialisation & Backend Infrastructure
// Test IDs : 0.1-WIDGET-001
// Priority : P1
// Level    : Widget
//
// Verifies that ErrorStateWidget renders with a message and a Retry button,
// and that the Retry callback is invoked on tap.
//
// Framework: flutter_test
// Run command:
//   flutter test test/core/widgets/error_state_widget_test.dart

// ignore_for_file: unused_import

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

// ── Production import (RED phase — does not exist yet) ───────────────────────
// Uncomment once lib/core/widgets/error_state_widget.dart is created:
//
// import 'package:spr_house_maintenance_tracker/core/widgets/error_state_widget.dart';

// ── Temporary stub ────────────────────────────────────────────────────────────

class ErrorStateWidget extends StatelessWidget {
  const ErrorStateWidget({
    super.key,
    required this.message,
    required this.onRetry,
  });
  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) => Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(message),
          ElevatedButton(onPressed: onRetry, child: const Text('Retry')),
        ],
      );
}

// ── Tests ─────────────────────────────────────────────────────────────────────

void main() {
  group('ErrorStateWidget — Story 0.1 (Widget)', () {
    // ─────────────────────────────────────────────────────────────────────────
    // 0.1-WIDGET-001  [P1]
    // AC4: ErrorStateWidget exists in lib/core/widgets/, shows error message
    //      and a Retry button that calls onRetry when tapped.
    // ─────────────────────────────────────────────────────────────────────────
    testWidgets(
      '[P1] 0.1-WIDGET-001: ErrorStateWidget shows message and Retry button',
      (WidgetTester tester) async {
        bool retryCalled = false;

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: ErrorStateWidget(
                message: 'Something went wrong',
                onRetry: () => retryCalled = true,
              ),
            ),
          ),
        );

        // Assert — message rendered
        expect(find.text('Something went wrong'), findsOneWidget);
        // Assert — Retry button present
        expect(find.text('Retry'), findsOneWidget);

        // Act — tap Retry
        await tester.tap(find.text('Retry'));
        expect(retryCalled, isTrue);
      },
      skip: true, // RED phase — lib/core/widgets/error_state_widget.dart not yet created
    );
  });
}
