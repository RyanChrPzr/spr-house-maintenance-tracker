/// Domain model for an authenticated user.
///
/// Maps to the `profiles` table in Supabase.
/// Only [id], [email], and [userType] are populated in Story 0.2;
/// name, phone, and avatar_url are set in later stories.
class UserModel {
  const UserModel({
    required this.id,
    required this.email,
    required this.userType,
  });

  final String id;
  final String email;
  final String userType; // 'homeowner' | 'vendor'

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String,
      email: json['email'] as String? ?? '',
      userType: json['user_type'] as String,
    );
  }
}
