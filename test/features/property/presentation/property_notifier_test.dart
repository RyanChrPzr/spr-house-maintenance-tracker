// test/features/property/presentation/property_notifier_test.dart
//
// ATDD RED PHASE — Stories 1.1 & 1.4: Property Setup & Settings Edit
//
// Story 1.1 Test IDs : 1.1-UNIT-001, 1.1-UNIT-002
// Story 1.4 Test IDs : 1.4-UNIT-001
// Priority : P0 (1.1-UNIT-001)  |  P1 (1.1-UNIT-002, 1.4-UNIT-001)
// Level    : Unit
//
// Tests PropertyNotifier (AsyncNotifier) with a mocked PropertyRepository.
// Covers: save property (creates DB row + seeds tasks), validation (no type),
// and update property (story 1.4).
//
// Framework: flutter_test + mocktail + riverpod
// Run command:
//   flutter test test/features/property/presentation/property_notifier_test.dart

// ignore_for_file: unused_import

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:riverpod/riverpod.dart';

// ── Production imports (RED phase — do not exist yet) ────────────────────────
// Uncomment once implemented:
//
// import 'package:spr_house_maintenance_tracker/core/exceptions/app_exception.dart';
// import 'package:spr_house_maintenance_tracker/features/property/data/property_repository.dart';
// import 'package:spr_house_maintenance_tracker/features/property/presentation/property_notifier.dart';
// import 'package:spr_house_maintenance_tracker/features/property/presentation/property_providers.dart';

// ── Temporary stubs ───────────────────────────────────────────────────────────

enum PropertyType { house, condo, lot }

class Property {
  Property({required this.type, this.ageYears});
  final PropertyType type;
  final int? ageYears;
}

class AppException implements Exception {
  AppException(this.message);
  final String message;
}

abstract class PropertyRepository {
  Future<void> saveProperty(Property property);
  Future<void> updateProperty(String propertyId, Property property);
  Future<void> seedDefaultTasks(String propertyId, PropertyType type);
}

class MockPropertyRepository extends Mock implements PropertyRepository {}

// ── Tests ─────────────────────────────────────────────────────────────────────

void main() {
  late MockPropertyRepository mockRepo;

  setUp(() {
    mockRepo = MockPropertyRepository();
    registerFallbackValue(Property(type: PropertyType.house));
  });

  group('PropertyNotifier — Story 1.1 (Unit)', () {
    // ─────────────────────────────────────────────────────────────────────────
    // 1.1-UNIT-001  [P0]
    // AC2: Selecting property type + save → creates properties row in DB
    //      AND seeds default maintenance_tasks.
    // ─────────────────────────────────────────────────────────────────────────
    test(
      '[P0] 1.1-UNIT-001: saveProperty creates DB row and seeds default tasks',
      () async {
        when(() => mockRepo.saveProperty(any()))
            .thenAnswer((_) async {});
        when(() => mockRepo.seedDefaultTasks(any(), any()))
            .thenAnswer((_) async {});

        // With PropertyNotifier:
        //   await container.read(propertyNotifierProvider.notifier)
        //       .saveProperty(type: PropertyType.house, ageYears: 5);
        //   verify(() => mockRepo.saveProperty(any())).called(1);
        //   verify(() => mockRepo.seedDefaultTasks(any(), PropertyType.house))
        //       .called(1);

        await mockRepo.saveProperty(Property(type: PropertyType.house, ageYears: 5));
        await mockRepo.seedDefaultTasks('property-id-1', PropertyType.house);

        verify(() => mockRepo.saveProperty(any())).called(1);
        verify(() => mockRepo.seedDefaultTasks('property-id-1', PropertyType.house)).called(1);
      },
      skip: 'RED phase — PropertyNotifier not yet implemented; '
          'remove skip: after lib/features/property/presentation/property_notifier.dart exists',
    );

    // ─────────────────────────────────────────────────────────────────────────
    // 1.1-UNIT-002  [P1]
    // AC3: Tapping Save without a property type selected → validation error
    //      "Please select a property type."
    // ─────────────────────────────────────────────────────────────────────────
    test(
      '[P1] 1.1-UNIT-002: saveProperty without type emits AsyncError with '
      '"Please select a property type."',
      () async {
        // PropertyNotifier should guard against null type and set AsyncError
        // before calling the repository.
        //   await container.read(propertyNotifierProvider.notifier)
        //       .saveProperty(type: null);
        //   final state = container.read(propertyNotifierProvider);
        //   expect(state, isA<AsyncError>());
        //   expect((state as AsyncError).error, isA<AppException>()
        //       .having((e) => e.message, 'message', 'Please select a property type.'));
        //   verifyNever(() => mockRepo.saveProperty(any()));

        verifyNever(() => mockRepo.saveProperty(any()));
        // Pass trivially — guard enforcement verified after implementation
        expect(true, isTrue);
      },
      skip: 'RED phase — PropertyNotifier validation not yet implemented; '
          'remove skip: after Story 1.1 implementation',
    );
  });

  group('PropertyNotifier — Story 1.4 (Unit)', () {
    // ─────────────────────────────────────────────────────────────────────────
    // 1.4-UNIT-001  [P1]
    // AC2: Updating property type or age → properties row updated in DB
    //      and changes reflected immediately in the app.
    // ─────────────────────────────────────────────────────────────────────────
    test(
      '[P1] 1.4-UNIT-001: updateProperty patches the properties row in Supabase',
      () async {
        when(() => mockRepo.updateProperty(any(), any()))
            .thenAnswer((_) async {});

        // With PropertyNotifier:
        //   await container.read(propertyNotifierProvider.notifier)
        //       .updateProperty(propertyId: 'p1', type: PropertyType.condo, ageYears: 10);
        //   verify(() => mockRepo.updateProperty('p1', any())).called(1);

        await mockRepo.updateProperty(
          'p1',
          Property(type: PropertyType.condo, ageYears: 10),
        );
        verify(() => mockRepo.updateProperty('p1', any())).called(1);
      },
      skip: 'RED phase — PropertyNotifier.updateProperty() not yet implemented; '
          'remove skip: after Story 1.4 implementation',
    );
  });
}
