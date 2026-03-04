import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'auth_provider.dart';

/// Async notifier for authentication actions.
///
/// Action-oriented: [build] returns immediately; callers use [register] and
/// [createProfile] to trigger side effects.
///
/// Navigation is NOT performed here — screens use [ref.listen] to react to
/// state transitions and call [context.go()] themselves.
class AuthNotifier extends AsyncNotifier<void> {
  @override
  Future<void> build() async {}

  /// Calls [AuthRepository.signUp] with the given credentials.
  ///
  /// On success the state becomes [AsyncData]; on failure [AsyncError] carries
  /// an [AppException] that screens can inspect to show inline errors.
  Future<void> register(String email, String password) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref.read(authRepositoryProvider).signUp(email, password),
    );
  }

  /// Creates a profile row for the currently logged-in user.
  ///
  /// Must only be called after a successful [register]; the current user must
  /// not be null at this point.
  Future<void> createProfile(String userType) async {
    state = const AsyncLoading();
    final user = ref.read(authRepositoryProvider).getCurrentUser();
    state = await AsyncValue.guard(
      () => ref.read(authRepositoryProvider).createProfile(user!.id, userType),
    );
  }
}

/// Provides the [AuthNotifier] for registration and profile creation actions.
final authNotifierProvider = AsyncNotifierProvider<AuthNotifier, void>(AuthNotifier.new);
