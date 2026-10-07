import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../core/role.dart';
import '../data/api_client.dart';
import '../data/models/user_session.dart';

/// AsyncValue<UserSession?> - null means signed out.
final sessionProvider =
    StateNotifierProvider<SessionNotifier, AsyncValue<UserSession?>>((ref) {
  return SessionNotifier();
});

/// Where the app should route at any moment.
enum AuthGate { loading, signedOut, buyer, seller, adminBlocked }

final authGateProvider = Provider<AuthGate>((ref) {
  final session = ref.watch(sessionProvider);
  return session.when(
    loading: () => AuthGate.loading,
    error: (_, __) => AuthGate.signedOut,
    data: (user) => switch (user?.role) {
      null => AuthGate.signedOut,
      AppRole.buyer => AuthGate.buyer,
      AppRole.seller => AuthGate.seller,
      AppRole.admin => AuthGate.adminBlocked,
    },
  );
});

class SessionNotifier extends StateNotifier<AsyncValue<UserSession?>> {
  SessionNotifier() : super(const AsyncValue.loading()) {
    _restore();
  }

  static const _kToken = 'mih_session_token';
  static const _kEmail = 'mih_session_email';
  static const _kRole = 'mih_role';
  static const _kName = 'mih_full_name';
  static const _kPhone = 'mih_phone';
  static const _kUserId = 'mih_user_id';
  static const _kCompany = 'mih_company';

  Future<void> _restore() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString(_kToken);
      if (token == null || token.isEmpty) {
        state = const AsyncValue.data(null);
        return;
      }
      final roleStr = prefs.getString(_kRole) ?? 'BUYER';
      final role = roleStr.contains('ADMIN')
          ? AppRole.admin
          : (roleStr.contains('SELL') ? AppRole.seller : AppRole.buyer);
      final user = UserSession(
        userId: prefs.getString(_kUserId) ?? '',
        phone: prefs.getString(_kPhone) ?? '',
        role: role,
        fullName: prefs.getString(_kName) ?? '',
        sessionToken: token,
        email: prefs.getString(_kEmail),
        companyName: prefs.getString(_kCompany),
      );
      ApiClient.instance.attachSession(token: token, email: user.email);
      state = AsyncValue.data(user);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  /// Called by the login screen after the backend verified the OTP and
  /// returned the user + session token.
  Future<void> signIn(UserSession user) async {
    if (user.isAdmin) {
      // Block admins on mobile by design - no session is persisted.
      state = AsyncValue.data(user);
      return;
    }
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kToken, user.sessionToken);
    await prefs.setString(_kRole, user.role.name.toUpperCase());
    await prefs.setString(_kName, user.fullName);
    await prefs.setString(_kPhone, user.phone);
    await prefs.setString(_kUserId, user.userId);
    await prefs.setString(_kEmail, user.email ?? '');
    await prefs.setString(_kCompany, user.companyName ?? '');
    ApiClient.instance.attachSession(token: user.sessionToken, email: user.email);
    state = AsyncValue.data(user);
  }

  Future<void> signOut() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    ApiClient.instance.clearSession();
    state = const AsyncValue.data(null);
  }
}
