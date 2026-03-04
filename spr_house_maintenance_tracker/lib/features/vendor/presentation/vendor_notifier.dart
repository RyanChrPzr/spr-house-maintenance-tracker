import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'vendor_provider.dart';

/// Async notifier for vendor onboarding actions.
///
/// Action-oriented: [build] returns immediately; callers use [submitOnboarding]
/// to trigger side effects.
///
/// Navigation is NOT performed here — screens use [ref.listen] to react to
/// state transitions and call [context.go()] themselves.
class VendorOnboardingNotifier extends AsyncNotifier<void> {
  @override
  Future<void> build() async {}

  /// Uploads QRPH code (if provided) then updates price range on vendor_extensions.
  ///
  /// [userId] is supplied by the screen (same pattern as [submitOnboarding]).
  /// Navigation is NOT performed here — screens use [ref.listen] to react.
  ///
  /// QRPH upload is optional — pass null [qrphPhoto] to skip it.
  /// When no photo is provided, the existing qrph_url is preserved.
  Future<void> submitPricingSetup({
    required String userId,
    required double? priceMin,
    required double? priceMax,
    XFile? qrphPhoto,
  }) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      String? qrphUrl;
      if (qrphPhoto != null) {
        final bytes = await qrphPhoto.readAsBytes();
        final extension = qrphPhoto.name.split('.').last.toLowerCase();
        qrphUrl = await ref
            .read(vendorRepositoryProvider)
            .uploadQrphCode(userId, bytes, extension);
      }

      await ref.read(vendorRepositoryProvider).updateVendorProfile(
            userId: userId,
            priceMin: priceMin,
            priceMax: priceMax,
            qrphUrl: qrphUrl,
          );
    });
  }

  /// Uploads the profile photo then creates the vendor_extensions row.
  ///
  /// [userId] is the authenticated user's ID — supplied by the screen, which
  /// reads it from the live Supabase auth session.
  ///
  /// On success state becomes [AsyncData]; on failure [AsyncError] carries
  /// an [AppException] that screens can inspect to show error messages.
  Future<void> submitOnboarding({
    required String userId,
    required String name,
    required List<String> services,
    required String phone,
    required XFile photo,
  }) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final bytes = await photo.readAsBytes();
      final extension = photo.name.split('.').last.toLowerCase();

      final avatarUrl = await ref
          .read(vendorRepositoryProvider)
          .uploadProfilePhoto(userId, bytes, extension);

      await ref.read(vendorRepositoryProvider).createVendorProfile(
            userId: userId,
            services: services,
            avatarUrl: avatarUrl,
            name: name,
            phone: phone,
          );
    });
  }
}

/// Provides the [VendorOnboardingNotifier] for vendor onboarding actions.
final vendorOnboardingNotifierProvider =
    AsyncNotifierProvider<VendorOnboardingNotifier, void>(
        VendorOnboardingNotifier.new);
