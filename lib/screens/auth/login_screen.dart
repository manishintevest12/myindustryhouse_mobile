import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/app_config.dart';
import '../../data/auth_repository.dart';
import '../../providers/session_provider.dart';

/// Unified login: phone + SMS OTP (the platform's existing auth flow),
/// then the backend's role response routes the user to the right panel.
/// Full visual UI lands in the next phase; this is the working skeleton
/// wired to the real endpoints.
class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _phoneCtrl = TextEditingController();
  final _otpCtrl = TextEditingController();
  bool _otpSent = false;
  bool _busy = false;
  String? _error;

  Future<void> _requestOtp() async {
    setState(() { _busy = true; _error = null; });
    final res = await AuthRepository.instance.requestOtp(
      phone: _phoneCtrl.text.trim(),
      role: 'BUYER', // role selection UI comes with the full login screen
    );
    if (!mounted) return;
    setState(() {
      _busy = false;
      if (res['success'] == true) {
        _otpSent = true;
      } else {
        _error = (res['message'] ?? 'Could not send the OTP.').toString();
      }
    });
  }

  Future<void> _verifyOtp() async {
    setState(() { _busy = true; _error = null; });
    final res = await AuthRepository.instance.verifyOtp(
      phone: _phoneCtrl.text.trim(),
      code: _otpCtrl.text.trim(),
    );
    if (!mounted) return;
    if (res['success'] != true) {
      setState(() { _busy = false; _error = (res['message'] ?? 'OTP verification failed.').toString(); });
      return;
    }
    final session = AuthRepository.instance.parseSession(res);
    if (session == null) {
      setState(() { _busy = false; _error = 'Login succeeded but no session token was returned.'; });
      return;
    }
    await ref.read(sessionProvider.notifier).signIn(session);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('MyIndustryHouse')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text('Sign in to your account',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900)),
            const SizedBox(height: 8),
            const Text('Verified industrial trading, direct buyer to seller.',
                style: TextStyle(fontSize: 13)),
            const SizedBox(height: 32),
            TextField(
              controller: _phoneCtrl,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(
                labelText: 'Phone number',
                prefixText: '+91 ',
                border: OutlineInputBorder(),
              ),
            ),
            if (_otpSent) ...[
              const SizedBox(height: 16),
              TextField(
                controller: _otpCtrl,
                keyboardType: TextInputType.number,
                maxLength: 6,
                decoration: const InputDecoration(
                  labelText: '6-digit OTP (sent via SMS)',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
            if (_error != null) ...[
              const SizedBox(height: 12),
              Text(_error!, style: const TextStyle(color: Color(0xFFE11D48), fontSize: 13)),
            ],
            const SizedBox(height: 24),
            FilledButton(
              onPressed: _busy ? null : (_otpSent ? _verifyOtp : _requestOtp),
              child: Text(_busy
                  ? 'Please wait...'
                  : (_otpSent ? 'Verify & Continue' : 'Get OTP via SMS')),
            ),
            const SizedBox(height: 16),
            const Text(
              AppConfig.adminBlockedMessage,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 11, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}
