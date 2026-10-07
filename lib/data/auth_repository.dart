import 'api_client.dart';
import 'endpoints.dart';
import 'models/user_session.dart';

/// Wraps the EXISTING SMS OTP auth flow. No server changes; this mirrors
/// the web client's calls one-for-one.
class AuthRepository {
  const AuthRepository._();
  static const instance = AuthRepository._();

  Future<Map<String, dynamic>> requestOtp({
    required String phone,
    String? fullName,
    String? email,
    required String role,
  }) =>
      ApiClient.instance.post(Api.sendOtp, body: {
        'phone': phone,
        'full_name': fullName,
        'email': email,
        'role': role,
      });

  Future<Map<String, dynamic>> verifyOtp({
    required String phone,
    required String code,
  }) =>
      ApiClient.instance.post(Api.verifyOtp, body: {
        'phone': phone,
        'code': code,
      });

  Future<Map<String, dynamic>> syncProfile(Map<String, dynamic> profile) =>
      ApiClient.instance.post(Api.syncUser, body: profile);

  /// Post-verification session assembly. Reads the API's user payload and
  /// produces the client-side session (or flags admin for the mobile block).
  UserSession? parseSession(Map<String, dynamic> verifyResponse) {
    final user = (verifyResponse['user'] ??
        verifyResponse['profile'] ??
        verifyResponse) as Map<String, dynamic>;
    final token = (verifyResponse['session_token'] ??
        verifyResponse['token'] ??
        '') as String;
    if (token.isEmpty) return null;
    return UserSession.fromApiJson({...user, 'session_token': token});
  }
}
