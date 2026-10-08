import 'api_client.dart';
import 'endpoints.dart';
import 'models/user_session.dart';

/// Mirrors the web client's SMS account flow one-for-one:
///  1. send-real-sms-otp      -> status: SUCCESS
///  2. verify-real-sms-otp    -> accountSessionToken
///  3. auth/sms-account (Bearer token + role [+ signup fields]) -> profile
class AuthRepository {
  const AuthRepository._();
  static const instance = AuthRepository._();

  /// The backend answers with `status: 'SUCCESS' | 'FAILURE'` (not `success`).
  static bool ok(Map<String, dynamic> r) =>
      r['status'] == 'SUCCESS' || r['success'] == true;

  static String msg(Map<String, dynamic> r, String fallback) =>
      (r['message'] ?? r['reason'] ?? fallback).toString();

  Future<Map<String, dynamic>> requestOtp({
    required String phone,
    String deliveryMethod = 'SMS',
  }) =>
      ApiClient.instance.post(Api.sendOtp, body: {
        'countryCode': '+91',
        'phone': phone,
        'deliveryMethod': deliveryMethod,
        'purpose': 'Phone Verification',
      });

  Future<Map<String, dynamic>> verifyOtp({
    required String phone,
    required String code,
  }) =>
      ApiClient.instance.post(Api.verifyOtp, body: {
        'countryCode': '+91',
        'phone': phone,
        'code': code,
      });

  /// Step 3: turn the verified SMS session into a buyer/seller account.
  /// Sends the SMS token explicitly (no global session yet at this point).
  Future<Map<String, dynamic>> completeAccount({
    required String token,
    required String role,
    Map<String, dynamic> fields = const {},
  }) =>
      ApiClient.instance.postWithToken(
        '/api/v1/auth/sms-account',
        token: token,
        body: {'role': role, ...fields},
      );

  UserSession? parseSession(Map<String, dynamic> accountResponse, String token) {
    final p = accountResponse['profile'];
    if (p is! Map) return null;
    final profile = Map<String, dynamic>.from(p);
    return UserSession.fromApiJson({
      ...profile,
      'user_id': profile['uid'],
      'full_name': profile['fullName'],
      'company_name': profile['companyName'],
      'session_token': token,
    });
  }
}
