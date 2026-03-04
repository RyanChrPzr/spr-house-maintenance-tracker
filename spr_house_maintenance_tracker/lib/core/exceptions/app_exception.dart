/// Typed application exception.
///
/// All repositories MUST catch [PostgrestException] from supabase_flutter
/// and rethrow as [AppException]. Never throw a raw [Exception].
///
/// Example:
/// ```dart
/// try {
///   return await supabase.from('profiles').select();
/// } on PostgrestException catch (e) {
///   throw AppException(code: e.code ?? 'unknown', message: e.message);
/// }
/// ```
class AppException implements Exception {
  const AppException({required this.code, required this.message});

  final String code;
  final String message;

  @override
  String toString() => 'AppException($code): $message';
}
