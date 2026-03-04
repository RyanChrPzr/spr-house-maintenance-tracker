import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/exceptions/app_exception.dart';
import '../domain/user_model.dart';

/// Repository for all Supabase auth and profile operations.
///
/// This is the ONLY file in the auth feature that imports supabase_flutter.
/// All exceptions from Supabase are caught and rethrown as [AppException].
///
/// In tests, supply a [supabaseClient] to inject a mock and avoid hitting the
/// live Supabase instance.
class AuthRepository {
  AuthRepository({SupabaseClient? supabaseClient})
      : _supabase = supabaseClient ?? Supabase.instance.client;

  final SupabaseClient _supabase;

  /// Creates a new Supabase Auth account.
  ///
  /// Returns the [AuthResponse] on success.
  /// Throws [AppException] with code 'user-already-exists' for duplicate email,
  /// or with the Supabase status code for other auth errors.
  Future<AuthResponse> signUp(String email, String password) async {
    try {
      final res = await _supabase.auth.signUp(
        email: email,
        password: password,
      );
      // Supabase silent-duplicate: returns user with empty identities list
      if (res.user != null && (res.user!.identities?.isEmpty ?? false)) {
        throw const AppException(
          code: 'user-already-exists',
          message: 'An account with this email already exists.',
        );
      }
      return res;
    } on AppException {
      rethrow;
    } on AuthException catch (e) {
      final isDuplicate = e.message.toLowerCase().contains('already registered') ||
          e.message.toLowerCase().contains('already exists');
      throw AppException(
        code: isDuplicate ? 'user-already-exists' : (e.statusCode?.toString() ?? 'auth-error'),
        message: isDuplicate ? 'An account with this email already exists.' : e.message,
      );
    }
  }

  /// Inserts a row in the `profiles` table for the given [userId].
  ///
  /// [userType] must be either `'homeowner'` or `'vendor'`.
  /// Throws [AppException] on database errors.
  Future<void> createProfile(String userId, String userType) async {
    try {
      await _supabase.from('profiles').insert({
        'id': userId,
        'user_type': userType,
      });
    } on PostgrestException catch (e) {
      throw AppException(code: e.code ?? 'db-error', message: e.message);
    }
  }

  /// Signs in an existing user with email and password.
  ///
  /// Throws [AppException] with code 'invalid-credentials' for wrong credentials.
  Future<void> signIn(String email, String password) async {
    try {
      await _supabase.auth.signInWithPassword(email: email, password: password);
    } on AuthException catch (e) {
      final isInvalid = e.statusCode == '400' ||
          e.message.toLowerCase().contains('invalid') ||
          e.message.toLowerCase().contains('email not confirmed');
      throw AppException(
        code: isInvalid ? 'invalid-credentials' : (e.statusCode ?? 'auth-error'),
        message: isInvalid ? 'Incorrect email or password.' : e.message,
      );
    }
  }

  /// Fetches the profile row for [userId] from the `profiles` table.
  ///
  /// Throws [AppException] on database errors.
  Future<UserModel> getProfile(String userId) async {
    try {
      final data = await _supabase
          .from('profiles')
          .select()
          .eq('id', userId)
          .single();
      return UserModel.fromJson(data);
    } on PostgrestException catch (e) {
      throw AppException(code: e.code ?? 'db-error', message: e.message);
    }
  }

  /// Returns the currently authenticated Supabase user, or null if not logged in.
  User? getCurrentUser() => _supabase.auth.currentUser;

  /// Returns the current Supabase session, or null if not authenticated.
  Session? getCurrentSession() => _supabase.auth.currentSession;
}
