// Smoke test for app-wide constants.
//
// The full-app widget test is covered by integration_test/ once screens are
// implemented. This file replaces the stale default Flutter counter test.

import 'package:flutter_test/flutter_test.dart';
import 'package:spr_house_maintenance_tracker/core/constants/app_constants.dart';

void main() {
  group('AppConstants', () {
    test('user type constants are correct', () {
      expect(AppConstants.userTypeHomeowner, 'homeowner');
      expect(AppConstants.userTypeVendor, 'vendor');
    });

    test('service types list is non-empty', () {
      expect(AppConstants.serviceTypes, isNotEmpty);
    });

    test('recurrence options list is non-empty', () {
      expect(AppConstants.recurrenceOptions, isNotEmpty);
    });
  });
}
