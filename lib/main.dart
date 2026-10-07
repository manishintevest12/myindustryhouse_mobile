import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/app_theme.dart';
import 'providers/session_provider.dart';
import 'screens/admin/admin_blocked_screen.dart';
import 'screens/auth/login_screen.dart';
import 'screens/buyer/buyer_shell.dart';
import 'screens/seller/seller_shell.dart';

void main() {
  runApp(const ProviderScope(child: MyIndustryHouseApp()));
}

class MyIndustryHouseApp extends StatelessWidget {
  const MyIndustryHouseApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MyIndustryHouse',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.dark,
      home: const _AuthGate(),
    );
  }
}

/// Single routing decision point: watch the session, then route by role.
/// Buyer -> Buyer Shell, Seller -> Seller Shell, Admin -> BLOCKED screen,
/// signed out -> Login.
class _AuthGate extends ConsumerWidget {
  const _AuthGate();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final gate = ref.watch(authGateProvider);
    return switch (gate) {
      AuthGate.loading => const Scaffold(
          body: Center(child: CircularProgressIndicator()),
        ),
      AuthGate.signedOut => const LoginScreen(),
      AuthGate.buyer => const BuyerShell(),
      AuthGate.seller => const SellerShell(),
      AuthGate.adminBlocked => AdminBlockedScreen(
          // Admin sessions are never persisted on mobile; resetting the
          // in-memory state returns the user to the login screen.
          onBackToLogin: () => ref.read(sessionProvider.notifier).signOut(),
        ),
    };
  }
}
