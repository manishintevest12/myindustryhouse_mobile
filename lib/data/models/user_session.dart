import '../../core/role.dart';

/// Authenticated user session returned by the existing backend after SMS OTP
/// verification. Kept 1:1 with the API's user/session payload - the app never
/// invents fields the backend does not return.
class UserSession {
  const UserSession({
    required this.userId,
    required this.phone,
    required this.role,
    required this.fullName,
    required this.sessionToken,
    this.email,
    this.companyName,
  });

  final String userId;
  final String phone;
  final AppRole role;
  final String fullName;
  final String sessionToken;
  final String? email;
  final String? companyName;

  bool get isBuyer => role == AppRole.buyer;
  bool get isSeller => role == AppRole.seller;
  bool get isAdmin => role == AppRole.admin;

  factory UserSession.fromApiJson(Map<String, dynamic> json) {
    final roleStr = (json['role'] ?? json['user_role'] ?? '').toString().toUpperCase();
    return UserSession(
      userId: (json['user_id'] ?? json['id'] ?? '').toString(),
      phone: (json['phone'] ?? json['phone_number'] ?? '').toString(),
      role: roleStr.contains('ADMIN')
          ? AppRole.admin
          : (roleStr.contains('SELL') ? AppRole.seller : AppRole.buyer),
      fullName: (json['full_name'] ?? json['name'] ?? '').toString(),
      sessionToken: (json['session_token'] ?? json['token'] ?? '').toString(),
      email: json['email']?.toString(),
      companyName: json['company_name']?.toString(),
    );
  }
}
