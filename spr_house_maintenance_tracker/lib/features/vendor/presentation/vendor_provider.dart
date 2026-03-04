import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/vendor_repository.dart';
import '../domain/vendor_profile_model.dart';

/// Provides the [VendorRepository] singleton.
///
/// This is the only provider that references [VendorRepository] directly.
final vendorRepositoryProvider =
    Provider<VendorRepository>((ref) => VendorRepository());

/// Fetches a single vendor's public profile by ID.
/// Invalidate with ref.invalidate(vendorProfileProvider(vendorId)) to retry.
final vendorProfileProvider =
    FutureProvider.family<VendorProfileModel, String>(
  (ref, vendorId) =>
      ref.read(vendorRepositoryProvider).fetchVendorProfile(vendorId),
);
