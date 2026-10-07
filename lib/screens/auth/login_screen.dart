import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/app_theme.dart';
import '../../data/auth_repository.dart';
import '../../providers/session_provider.dart';

/// Mirrors the web AuthModal 1:1 (same dark "Identity Gate" header, Buyer/
/// Seller portal tabs, Password/OTP toggle, mobile-number field, info strip
/// and footer) so the app and the website are visually the same product.
class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _phoneCtrl = TextEditingController();
  final _otpCtrl = TextEditingController();
  bool _otpSent = false;
  String _role = 'BUYER';
  bool _busy = false;
  String? _error;

  Color get _roleColor =>
      _role == 'BUYER' ? const Color(0xFF059669) /* emerald-600 */ : AppPalette.sellerAccent;

  Future<void> _requestOtp() async {
    setState(() {
      _busy = true;
      _error = null;
    });
    final res = await AuthRepository.instance.requestOtp(
      phone: _phoneCtrl.text.trim(),
      role: _role,
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
    setState(() {
      _busy = true;
      _error = null;
    });
    final res = await AuthRepository.instance.verifyOtp(
      phone: _phoneCtrl.text.trim(),
      code: _otpCtrl.text.trim(),
    );
    if (!mounted) return;
    if (res['success'] != true) {
      setState(() {
        _busy = false;
        _error = (res['message'] ?? 'OTP verification failed.').toString();
      });
      return;
    }
    final session = AuthRepository.instance.parseSession(res);
    if (session == null) {
      setState(() {
        _busy = false;
        _error = 'Login succeeded but no session token was returned.';
      });
      return;
    }
    await ref.read(sessionProvider.notifier).signIn(session);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppPalette.page,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ---- Dark "Identity Gate" header (mirrors web bg-slate-900) ----
              Container(
                color: const Color(0xFF0F172A), // slate-900
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: AppPalette.primary,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          alignment: Alignment.center,
                          child: const Text('M',
                              style: TextStyle(
                                  color: Colors.white, fontWeight: FontWeight.w900, fontSize: 18)),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  const Flexible(
                                    child: Text('My Industry House',
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.w800,
                                            fontSize: 16)),
                                  ),
                                  const SizedBox(width: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFFBBF24), // amber-400
                                      borderRadius: BorderRadius.circular(999),
                                    ),
                                    child: const Text('IDENTITY GATE',
                                        style: TextStyle(
                                            color: Color(0xFF020617),
                                            fontSize: 9,
                                            fontWeight: FontWeight.w800,
                                            letterSpacing: 0.4)),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 2),
                              const Text('Secure Multi-Tenant Industrial Trade & Compliance Ecosystem',
                                  style: TextStyle(color: Color(0xFF94A3B8), fontSize: 11)),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    // Buyer / Seller portal tabs
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1E293B), // slate-800/90
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFF334155)),
                      ),
                      child: Row(
                        children: [
                          Expanded(child: _portalTab('BUYER', 'Buyer Portal', Icons.shopping_cart_outlined)),
                          const SizedBox(width: 8),
                          Expanded(child: _portalTab('SELLER', 'Seller Portal', Icons.storefront_outlined)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // ---- Create Account / Sign In sub-nav (mirrors bg-slate-50) ----
              Container(
                color: AppPalette.page,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                decoration: const BoxDecoration(
                  border: Border(bottom: BorderSide(color: AppPalette.border)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Create Account (Sign Up)',
                        style: TextStyle(color: AppPalette.textMuted, fontSize: 12, fontWeight: FontWeight.w600)),
                    Text('Sign In (Existing User)',
                        style: TextStyle(color: _roleColor, fontSize: 12, fontWeight: FontWeight.w800)),
                  ],
                ),
              ),

              // ---- Form body ----
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Password / OTP toggle (OTP permanently selected - this is
                    // the only login method the backend exposes to buyers/sellers)
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF1F5F9), // slate-100
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: AppPalette.border),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 7),
                              alignment: Alignment.center,
                              child: const Text('Password Login',
                                  style: TextStyle(color: AppPalette.textMuted, fontSize: 12, fontWeight: FontWeight.w700)),
                            ),
                          ),
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 7),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(7),
                                boxShadow: const [BoxShadow(color: Color(0x14000000), blurRadius: 2)],
                              ),
                              alignment: Alignment.center,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: const [
                                  Icon(Icons.smartphone, size: 14, color: Color(0xFFD97706)),
                                  SizedBox(width: 6),
                                  Text('Instant OTP Sign In',
                                      style: TextStyle(
                                          color: AppPalette.textPrimary, fontSize: 12, fontWeight: FontWeight.w700)),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 18),
                    const Text('Registered 10-Digit Mobile Number',
                        style: TextStyle(color: AppPalette.textPrimary, fontSize: 12, fontWeight: FontWeight.w700)),
                    const SizedBox(height: 6),
                    TextField(
                      controller: _phoneCtrl,
                      keyboardType: TextInputType.phone,
                      maxLength: 10,
                      style: const TextStyle(fontSize: 13),
                      decoration: InputDecoration(
                        counterText: '',
                        hintText: 'e.g. 9876543210',
                        prefixIcon: const Icon(Icons.smartphone, size: 18, color: AppPalette.textMuted),
                        filled: true,
                        fillColor: Colors.white,
                        contentPadding: const EdgeInsets.symmetric(vertical: 13),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(color: AppPalette.border),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(color: AppPalette.secondary),
                        ),
                      ),
                    ),
                    if (!_otpSent) ...[
                      const SizedBox(height: 14),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFEFF6FF), // blue-50
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: const Color(0xFFBFDBFE)),
                        ),
                        child: const Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(Icons.info_outline, size: 16, color: Color(0xFF2563EB)),
                            SizedBox(width: 8),
                            Expanded(
                              child: Text('Enter your mobile number to access your My Industry House account.',
                                  style: TextStyle(color: Color(0xFF1E40AF), fontSize: 12)),
                            ),
                          ],
                        ),
                      ),
                    ],
                    if (_otpSent) ...[
                      const SizedBox(height: 14),
                      const Text('6-Digit OTP (sent via SMS)',
                          style: TextStyle(color: AppPalette.textPrimary, fontSize: 12, fontWeight: FontWeight.w700)),
                      const SizedBox(height: 6),
                      TextField(
                        controller: _otpCtrl,
                        keyboardType: TextInputType.number,
                        maxLength: 6,
                        style: const TextStyle(fontSize: 13, letterSpacing: 3),
                        decoration: InputDecoration(
                          counterText: '',
                          hintText: '••••••',
                          filled: true,
                          fillColor: Colors.white,
                          contentPadding: const EdgeInsets.symmetric(vertical: 13, horizontal: 14),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: const BorderSide(color: AppPalette.border),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: const BorderSide(color: AppPalette.secondary),
                          ),
                        ),
                      ),
                    ],
                    if (_error != null) ...[
                      const SizedBox(height: 12),
                      Text(_error!, style: const TextStyle(color: AppPalette.danger, fontSize: 12)),
                    ],
                    const SizedBox(height: 18),
                    SizedBox(
                      height: 48,
                      child: ElevatedButton(
                        onPressed: _busy ? null : (_otpSent ? _verifyOtp : _requestOtp),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _roleColor,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          elevation: 0,
                        ),
                        child: _busy
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(strokeWidth: 2.4, color: Colors.white))
                            : Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    _otpSent ? 'Verify & Continue' : 'Sign In to ${_role == 'BUYER' ? 'BUYER' : 'SELLER'} Portal',
                                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800),
                                  ),
                                  const SizedBox(width: 6),
                                  const Icon(Icons.arrow_forward, size: 16),
                                ],
                              ),
                      ),
                    ),
                  ],
                ),
              ),

              // ---- Footer (mirrors bg-slate-50 border-t) ----
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                decoration: const BoxDecoration(
                  color: AppPalette.page,
                  border: Border(top: BorderSide(color: AppPalette.border)),
                ),
                child: Wrap(
                  alignment: WrapAlignment.spaceBetween,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  spacing: 12,
                  runSpacing: 6,
                  children: const [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.verified_outlined, size: 14, color: Color(0xFF059669)),
                        SizedBox(width: 6),
                        Text('256-Bit SSL Encrypted & OTP Protected',
                            style: TextStyle(color: AppPalette.textMuted, fontSize: 11)),
                      ],
                    ),
                    Text('Need help? support@myindustryhouse.com',
                        style: TextStyle(color: AppPalette.textMuted, fontSize: 11)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _portalTab(String role, String label, IconData icon) {
    final selected = _role == role;
    final color = role == 'BUYER' ? const Color(0xFF059669) : AppPalette.sellerAccent;
    return InkWell(
      onTap: () => setState(() {
        _role = role;
        _otpSent = false;
        _error = null;
      }),
      borderRadius: BorderRadius.circular(9),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 9),
        decoration: BoxDecoration(
          color: selected ? color : Colors.transparent,
          borderRadius: BorderRadius.circular(9),
        ),
        alignment: Alignment.center,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 15, color: selected ? Colors.white : const Color(0xFFCBD5E1)),
            const SizedBox(width: 6),
            Text(label,
                style: TextStyle(
                    color: selected ? Colors.white : const Color(0xFFCBD5E1),
                    fontSize: 12,
                    fontWeight: FontWeight.w700)),
          ],
        ),
      ),
    );
  }
}
