import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:spr_house_maintenance_tracker/features/booking/presentation/widgets/vendor_card_widget.dart';
import 'package:spr_house_maintenance_tracker/features/vendor/domain/vendor_profile_model.dart';

// ── Helpers ───────────────────────────────────────────────────────────────────

/// Wraps [widget] in [MaterialApp] + [ProviderScope] — required for
/// [ConsumerWidget] (VendorCardWidget) and Material widgets (Chip, etc.).
Widget _wrap(Widget widget) {
  return ProviderScope(
    child: MaterialApp(
      home: Scaffold(
        body: widget,
      ),
    ),
  );
}

VendorProfileModel _makeVendor({
  bool isAvailable = true,
  int completedJobsCount = 0,
  double? priceRangeMin,
  double? priceRangeMax,
}) {
  return VendorProfileModel(
    id: 'vendor-test',
    name: 'Test Vendor',
    services: ['Plumbing', 'Electrical'],
    isAvailable: isAvailable,
    isSuspended: false,
    completedJobsCount: completedJobsCount,
    priceRangeMin: priceRangeMin,
    priceRangeMax: priceRangeMax,
  );
}

void main() {
  group('VendorCardWidget — availability badge', () {
    testWidgets('shows green "Available" badge when isAvailable is true',
        (tester) async {
      await tester.pumpWidget(
        _wrap(VendorCardWidget(vendor: _makeVendor(isAvailable: true))),
      );

      expect(find.text('Available'), findsOneWidget);
      expect(find.text('Unavailable'), findsNothing);
    });

    testWidgets('shows grey "Unavailable" badge when isAvailable is false',
        (tester) async {
      await tester.pumpWidget(
        _wrap(VendorCardWidget(vendor: _makeVendor(isAvailable: false))),
      );

      expect(find.text('Unavailable'), findsOneWidget);
      expect(find.text('Available'), findsNothing);
    });
  });

  group('VendorCardWidget — Book button', () {
    testWidgets('Book button is enabled when isAvailable is true',
        (tester) async {
      bool tapped = false;
      await tester.pumpWidget(
        _wrap(VendorCardWidget(
          vendor: _makeVendor(isAvailable: true),
          onBook: () => tapped = true,
        )),
      );

      final button = tester.widget<FilledButton>(find.byType(FilledButton));
      expect(button.onPressed, isNotNull);

      await tester.tap(find.byType(FilledButton));
      expect(tapped, isTrue);
    });

    testWidgets('Book button is disabled when isAvailable is false',
        (tester) async {
      await tester.pumpWidget(
        _wrap(VendorCardWidget(
          vendor: _makeVendor(isAvailable: false),
          onBook: () {},
        )),
      );

      final button = tester.widget<FilledButton>(find.byType(FilledButton));
      expect(button.onPressed, isNull);
    });

    testWidgets('Book button is disabled when isAvailable is true but onBook is null',
        (tester) async {
      await tester.pumpWidget(
        _wrap(VendorCardWidget(
          vendor: _makeVendor(isAvailable: true),
          // onBook not provided
        )),
      );

      final button = tester.widget<FilledButton>(find.byType(FilledButton));
      expect(button.onPressed, isNull);
    });
  });

  group('VendorCardWidget — vendor name', () {
    testWidgets('displays vendor name', (tester) async {
      await tester.pumpWidget(
        _wrap(VendorCardWidget(vendor: _makeVendor())),
      );

      expect(find.text('Test Vendor'), findsOneWidget);
    });
  });

  group('VendorCardWidget — price range', () {
    testWidgets('shows price range when both min and max are set',
        (tester) async {
      await tester.pumpWidget(
        _wrap(VendorCardWidget(
          vendor: _makeVendor(priceRangeMin: 500, priceRangeMax: 1500),
        )),
      );

      expect(find.text('₱500 – ₱1500 per visit'), findsOneWidget);
    });

    testWidgets('shows "Price not set" when price range is null', (tester) async {
      await tester.pumpWidget(
        _wrap(VendorCardWidget(vendor: _makeVendor())),
      );

      expect(find.text('Price not set'), findsOneWidget);
    });
  });

  group('VendorCardWidget — jobs count display', () {
    testWidgets('shows new vendor text when completedJobsCount is 0',
        (tester) async {
      await tester.pumpWidget(
        _wrap(VendorCardWidget(vendor: _makeVendor(completedJobsCount: 0))),
      );

      expect(
        find.text('New vendor — no completed jobs yet.'),
        findsOneWidget,
      );
    });

    testWidgets('shows jobs count when completedJobsCount > 0', (tester) async {
      await tester.pumpWidget(
        _wrap(VendorCardWidget(vendor: _makeVendor(completedJobsCount: 5))),
      );

      expect(find.text('5 jobs completed'), findsOneWidget);
    });
  });
}
