import 'package:flutter/material.dart';

import '../../core/app_config.dart';

/// Shown when an ADMIN role is detected at login. Admin operations remain
/// entirely on the web platform by design - the mobile app carries no admin
/// routes whatsoever.
class AdminBlockedScreen extends StatelessWidget {
  const AdminBlockedScreen({super.key, required this.onBackToLogin});

  final VoidCallback onBackToLogin;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.admin_panel_settings_rounded,
                  size: 56, color: Color(0xFFE11D48)),
              const SizedBox(height: 24),
              const Text(
                AppConfig.adminBlockedMessage,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 12),
              const Text(
                'Sign in from the web portal at www.myindustryhouse.com to manage the platform.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 13, color: Colors.grey),
              ),
              const SizedBox(height: 32),
              FilledButton(onPressed: onBackToLogin, child: const Text('Back to Login')),
            ],
          ),
        ),
      ),
    );
  }
}
