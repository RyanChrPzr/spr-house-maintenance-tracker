import 'dart:typed_data';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/exceptions/app_exception.dart';
import '../domain/vendor_profile_model.dart';

/// Repository for all vendor Supabase operations.
///
/// This is the ONLY file in the vendor feature that imports supabase_flutter.
/// All exceptions from Supabase are caught and rethrown as [AppException].
///
/// In tests, supply a [supabaseClient] to inject a mock and avoid hitting the
/// live Supabase instance.
class VendorRepository {
  VendorRepository({SupabaseClient? supabaseClient})
      : _supabase = supabaseClient ?? Supabase.instance.client;

  final SupabaseClient _supabase;

  /// Uploads profile photo to the `avatars/` bucket.
  ///
  /// File path convention: `vendor-{userId}.{extension}`
  /// Returns the public URL of the uploaded photo.
  /// Throws [AppException] with code 'storage-error' on upload failure.
  Future<String> uploadProfilePhoto(
    String userId,
    Uint8List imageBytes,
    String extension,
  ) async {
    final path = 'vendor-$userId.$extension';
    try {
      await _supabase.storage.from('avatars').uploadBinary(
        path,
        imageBytes,
        fileOptions: FileOptions(
          contentType: 'image/$extension',
          upsert: true,
        ),
      );
      return _supabase.storage.from('avatars').getPublicUrl(path);
    } on StorageException catch (e) {
      throw AppException(code: 'storage-error', message: e.message);
    }
  }

  /// Updates the price range (and optionally QRPH URL) on `vendor_extensions`.
  ///
  /// Pass [qrphUrl] only when a new QRPH image was uploaded — omitting it
  /// prevents overwriting an existing URL with null on every pricing save.
  /// Pass null to [priceMin]/[priceMax] to explicitly clear the price range.
  /// Throws [AppException] on database errors.
  Future<void> updateVendorProfile({
    required String userId,
    double? priceMin,
    double? priceMax,
    String? qrphUrl,
  }) async {
    final payload = <String, dynamic>{
      'price_range_min': priceMin,
      'price_range_max': priceMax,
    };
    if (qrphUrl != null) payload['qrph_url'] = qrphUrl;

    try {
      await _supabase
          .from('vendor_extensions')
          .update(payload)
          .eq('id', userId);
    } on PostgrestException catch (e) {
      throw AppException(code: e.code ?? 'db-error', message: e.message);
    }
  }

  /// Uploads a QRPH code image to the `qrph-codes/` bucket.
  ///
  /// File path convention: `vendor-{userId}.{extension}`
  /// Uses upsert so re-uploading replaces the existing file.
  /// Returns the public URL of the uploaded image.
  /// Throws [AppException] with code 'storage-error' on upload failure.
  Future<String> uploadQrphCode(
    String userId,
    Uint8List imageBytes,
    String extension,
  ) async {
    final path = 'vendor-$userId.$extension';
    try {
      await _supabase.storage.from('qrph-codes').uploadBinary(
        path,
        imageBytes,
        fileOptions: FileOptions(
          contentType: 'image/$extension',
          upsert: true,
        ),
      );
      return _supabase.storage.from('qrph-codes').getPublicUrl(path);
    } on StorageException catch (e) {
      throw AppException(code: 'storage-error', message: e.message);
    }
  }

  /// Creates the `vendor_extensions` row and updates the `profiles` row.
  ///
  /// Must be called AFTER [uploadProfilePhoto] — pass the returned [avatarUrl].
  /// Throws [AppException] on database errors.
  Future<void> createVendorProfile({
    required String userId,
    required List<String> services,
    required String avatarUrl,
    required String name,
    required String phone,
  }) async {
    try {
      await _supabase.from('vendor_extensions').insert({
        'id': userId,
        'services': services,
        'avatar_url': avatarUrl,
        'is_available': true,
        'is_suspended': false,
        'completed_jobs_count': 0,
      });

      await _supabase.from('profiles').update({
        'name': name,
        'phone': phone,
        'avatar_url': avatarUrl,
      }).eq('id', userId);
    } on PostgrestException catch (e) {
      throw AppException(code: e.code ?? 'db-error', message: e.message);
    }
  }

  /// Fetches a single vendor's public profile, joining name from profiles.
  ///
  /// Throws [AppException] if the vendor is not found or a DB error occurs.
  Future<VendorProfileModel> fetchVendorProfile(String vendorId) async {
    try {
      final data = await _supabase
          .from('vendor_extensions')
          .select('*, profiles!inner(name)')
          .eq('id', vendorId)
          .single();
      return VendorProfileModel.fromJson(data);
    } on PostgrestException catch (e) {
      throw AppException(code: e.code ?? 'db-error', message: e.message);
    }
  }
}
