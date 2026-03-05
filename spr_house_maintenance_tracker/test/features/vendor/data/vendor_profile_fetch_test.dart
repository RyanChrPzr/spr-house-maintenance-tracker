import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:spr_house_maintenance_tracker/core/exceptions/app_exception.dart';
import 'package:spr_house_maintenance_tracker/features/vendor/data/vendor_repository.dart';
import 'package:spr_house_maintenance_tracker/features/vendor/domain/vendor_profile_model.dart';

// ── Fake that captures which table was queried and throws PostgrestException ──

/// Captures the table name passed to [from] and then throws [error].
/// Used to verify the correct table is queried and to test error mapping.
class _CapturingThrowingClient extends Fake implements SupabaseClient {
  final PostgrestException error;
  String? capturedTable;

  _CapturingThrowingClient(this.error);

  @override
  SupabaseQueryBuilder from(String table) {
    capturedTable = table;
    throw error;
  }
}

void main() {
  // ── VendorProfileModel.fromJson — profiles join ─────────────────────────────
  group('VendorProfileModel.fromJson — profiles join', () {
    test('populates name from nested profiles key', () {
      final model = VendorProfileModel.fromJson({
        'id': 'vendor-123',
        'services': ['Plumbing', 'Electrical'],
        'is_available': true,
        'is_suspended': false,
        'completed_jobs_count': 3,
        'profiles': {'name': 'Juan Cruz'},
      });

      expect(model.id, 'vendor-123');
      expect(model.name, 'Juan Cruz');
      expect(model.services, ['Plumbing', 'Electrical']);
      expect(model.completedJobsCount, 3);
    });

    test('defaults name to empty string when profiles key is absent', () {
      final model = VendorProfileModel.fromJson({
        'id': 'vendor-456',
        'services': [],
        'is_available': false,
        'is_suspended': false,
        'completed_jobs_count': 0,
        // no 'profiles' key
      });

      expect(model.name, '');
    });

    test('defaults name to empty string when profiles value is null', () {
      final model = VendorProfileModel.fromJson({
        'id': 'vendor-789',
        'services': [],
        'is_available': true,
        'is_suspended': false,
        'completed_jobs_count': 0,
        'profiles': null,
      });

      expect(model.name, '');
    });

    test('name is excluded from toJson output', () {
      const model = VendorProfileModel(
        id: 'vendor-123',
        name: 'Juan Cruz',
        services: ['Plumbing'],
        isAvailable: true,
        isSuspended: false,
        completedJobsCount: 0,
      );

      final json = model.toJson();
      expect(json.containsKey('name'), isFalse);
    });
  });

  // ── VendorRepository.fetchVendorProfile ─────────────────────────────────────
  group('VendorRepository.fetchVendorProfile', () {
    test('queries vendor_extensions table', () async {
      const pgError = PostgrestException(
        message: 'expected query error',
        code: 'TEST',
      );
      final client = _CapturingThrowingClient(pgError);
      final repo = VendorRepository(supabaseClient: client);

      try {
        await repo.fetchVendorProfile('vendor-id');
      } catch (_) {}

      expect(client.capturedTable, 'vendor_extensions');
    });

    test('PostgrestException with code → AppException preserving code',
        () async {
      const pgError = PostgrestException(
        message: 'vendor not found',
        code: 'PGRST116',
      );
      final client = _CapturingThrowingClient(pgError);
      final repo = VendorRepository(supabaseClient: client);

      expect(
        () => repo.fetchVendorProfile('vendor-123'),
        throwsA(
          isA<AppException>().having((e) => e.code, 'code', 'PGRST116'),
        ),
      );
    });

    test('PostgrestException without code → AppException(db-error)', () async {
      const pgError = PostgrestException(message: 'unknown db error');
      final client = _CapturingThrowingClient(pgError);
      final repo = VendorRepository(supabaseClient: client);

      expect(
        () => repo.fetchVendorProfile('vendor-123'),
        throwsA(
          isA<AppException>().having((e) => e.code, 'code', 'db-error'),
        ),
      );
    });
  });
}
