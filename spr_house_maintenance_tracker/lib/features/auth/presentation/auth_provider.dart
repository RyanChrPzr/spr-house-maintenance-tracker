import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/auth_repository.dart';

/// Provides the [AuthRepository] singleton.
///
/// This is the only provider that references [AuthRepository] directly.
/// Notifier and screen imports should consume this to access repository methods.
final authRepositoryProvider = Provider<AuthRepository>((ref) => AuthRepository());
