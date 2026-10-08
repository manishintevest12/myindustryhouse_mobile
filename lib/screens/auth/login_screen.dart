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
  final _firstCtrl = TextEditingController();
  final _lastCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _companyCtrl = TextEditingController();
  final _gstinCtrl = TextEditingController();
  final _cityCtrl = TextEditingController();

  bool _signUp = false; // Create Account vs Sign In
  bool _passwordTab = false; // Password Login tab vs Instant OTP
  bool _otpSent = false;
  String _role = 'BUYER';
  bool _busy = false;
  String? _error;
  String? _info;
  int _resendIn = 0;

  Color get _roleColor =>
      _role == 'BUYER' ? const Color(0xFF059669) : AppPalette.sellerAccent;

  @override
  void dispose() {
    for (final c in [_phoneCtrl, _otpCtrl, _firstCtrl, _lastCtrl, _emailCtrl, _companyCtrl, _gstinCtrl, _cityCtrl]) {
      c.dispose();
    }
    super.dispose();
  }

  String get _digits => _phoneCtrl.text.replaceAll(RegExp(r'\D'), '');

  void _resetFlow({bool? signUp, bool? passwordTab, String? role}) {
    setState(() {
      if (signUp != null) _signUp = signUp;
      if (passwordTab != null) _passwordTab = passwordTab;
      if (role != null) _role = role;
      _otpSent = false;
      _otpCtrl.clear();
      _error = null;
      _info = null;
    });
  }

  /// Same field rules as the web (src/lib/validation.ts).
  String? _validateSignUp() {
    final first = _firstCtrl.text.trim();
    final last = _lastCtrl.text.trim();
    if (first.isEmpty) return 'First name is required.';
    if (!RegExp(r'^[A-Za-z]+$').hasMatch(first)) {
      return 'First name must be a single word with letters only (no spaces).';
    }
    if (last.isEmpty) return 'Last name is required.';
    if (!RegExp(r'^[A-Za-z]+$').hasMatch(last)) {
      return 'Last name must be a single word with letters only.';
    }
    if (!RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$').hasMatch(_emailCtrl.text.trim())) {
      return 'Please enter a valid business email (e.g. name@company.com).';
    }
    if (_role == 'SELLER') {
      if (_companyCtrl.text.trim().isEmpty) return 'Company name is required for sellers.';
      final g = _gstinCtrl.text.trim().toUpperCase();
      if (!RegExp(r'^[0-9]{2}[A-Z]{5}[0-9]{4}[A-Z]{1}[1-9A-Z]{1}Z[0-9A-Z]{1}$').hasMatch(g)) {
        return 'Enter a valid 15-character GSTIN (e.g. 27AABCT3518Q1ZV).';
      }
    }
    return null;
  }

  Future<void> _sendOtp({String method = 'SMS'}) async {
    if (_digits.length != 10) {
      setState(() => _error = 'Enter a valid 10-digit mobile number.');
      return;
    }
    if (_signUp) {
      final v = _validateSignUp();
      if (v != null) {
        setState(() => _error = v);
        return;
      }
    }
    setState(() {
      _busy = true;
      _error = null;
      _info = null;
    });
    final res = await AuthRepository.instance.requestOtp(phone: _digits, deliveryMethod: method);
    if (!mounted) return;
    if (AuthRepository.ok(res)) {
      setState(() {
        _busy = false;
        _otpSent = true;
        _info = AuthRepository.msg(res, 'OTP sent. Please check your phone.');
        _resendIn = 30;
      });
      _tickResend();
    } else {
      setState(() {
        _busy = false;
        _error = AuthRepository.msg(res, 'Could not send the OTP.');
      });
    }
  }

  void _tickResend() async {
    while (mounted && _resendIn > 0) {
      await Future.delayed(const Duration(seconds: 1));
      if (!mounted) return;
      setState(() => _resendIn--);
    }
  }

  Future<void> _verifyOtp() async {
    final code = _otpCtrl.text.trim();
    if (code.length < 4) {
      setState(() => _error = 'Enter the OTP you received by SMS.');
      return;
    }
    setState(() {
      _busy = true;
      _error = null;
    });
    final v = await AuthRepository.instance.verifyOtp(phone: _digits, code: code);
    if (!mounted) return;
    final token = (v['accountSessionToken'] ?? '').toString();
    if (!AuthRepository.ok(v) || token.isEmpty) {
      setState(() {
        _busy = false;
        _error = AuthRepository.msg(v, 'OTP verification failed.');
      });
      return;
    }
    final fields = <String, dynamic>{};
    if (_signUp) {
      fields.addAll({
        'firstName': _firstCtrl.text.trim(),
        'lastName': _lastCtrl.text.trim(),
        'email': _emailCtrl.text.trim().toLowerCase(),
        'companyName': _companyCtrl.text.trim(),
        'gstin': _role == 'SELLER' ? _gstinCtrl.text.trim().toUpperCase() : '',
        'city': _cityCtrl.text.trim(),
      });
    }
    final acc = await AuthRepository.instance.completeAccount(token: token, role: _role, fields: fields);
    if (!mounted) return;
    if (!AuthRepository.ok(acc)) {
      setState(() {
        _busy = false;
        _error = AuthRepository.msg(acc, 'Could not open your account.');
      });
      return;
    }
    final session = AuthRepository.instance.parseSession(acc, token);
    if (session == null) {
      setState(() {
        _busy = false;
        _error = 'Login succeeded but the account profile was missing.';
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

              // ---- Create Account / Sign In sub-nav (tappable) ----
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: const BoxDecoration(
                  color: AppPalette.page,
                  border: Border(bottom: BorderSide(color: AppPalette.border)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextButton(
                      onPressed: () => _resetFlow(signUp: true, passwordTab: false),
                      child: Text('Create Account (Sign Up)',
                          style: TextStyle(
                              color: _signUp ? _roleColor : AppPalette.textMuted,
                              fontSize: 12,
                              fontWeight: _signUp ? FontWeight.w800 : FontWeight.w600)),
                    ),
                    TextButton(
                      onPressed: () => _resetFlow(signUp: false),
                      child: Text('Sign In (Existing User)',
                          style: TextStyle(
                              color: !_signUp ? _roleColor : AppPalette.textMuted,
                              fontSize: 12,
                              fontWeight: !_signUp ? FontWeight.w800 : FontWeight.w600)),
                    ),
                  ],
                ),
              ),

              // ---- Form body ----
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (!_signUp) _methodToggle(),
                    if (!_signUp) const SizedBox(height: 18),
                    if (!_signUp && _passwordTab) ..._passwordNotice() else ..._otpForm(),
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

  Widget _methodToggle() {
    Widget tab(String label, bool selected, VoidCallback onTap, {IconData? icon}) => Expanded(
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(7),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 9),
              decoration: BoxDecoration(
                color: selected ? Colors.white : Colors.transparent,
                borderRadius: BorderRadius.circular(7),
                boxShadow: selected ? const [BoxShadow(color: Color(0x14000000), blurRadius: 2)] : null,
              ),
              alignment: Alignment.center,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (icon != null) ...[Icon(icon, size: 14, color: const Color(0xFFD97706)), const SizedBox(width: 6)],
                  Text(label,
                      style: TextStyle(
                          color: selected ? AppPalette.textPrimary : AppPalette.textMuted,
                          fontSize: 12,
                          fontWeight: FontWeight.w700)),
                ],
              ),
            ),
          ),
        );
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppPalette.border),
      ),
      child: Row(
        children: [
          tab('Password Login', _passwordTab, () => _resetFlow(passwordTab: true)),
          tab('Instant OTP Sign In', !_passwordTab, () => _resetFlow(passwordTab: false), icon: Icons.smartphone),
        ],
      ),
    );
  }

  /// Web parity: buyer/seller accounts are SMS-OTP accounts (no passwords
  /// exist on the server), so this tab explains it and routes to OTP.
  List<Widget> _passwordNotice() => [
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: const Color(0xFFFFFBEB),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: const Color(0xFFFDE68A)),
          ),
          child: const Text(
            'Buyer and seller accounts are secured with SMS OTP, so there is no password to remember. Use Instant OTP Sign In with your registered mobile number.',
            style: TextStyle(color: Color(0xFF92400E), fontSize: 12, height: 1.4),
          ),
        ),
        const SizedBox(height: 14),
        SizedBox(
          height: 46,
          child: ElevatedButton(
            onPressed: () => _resetFlow(passwordTab: false),
            style: ElevatedButton.styleFrom(
              backgroundColor: _roleColor,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text('Switch to Instant OTP Sign In',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800)),
          ),
        ),
      ];

  InputDecoration _dec(String hint, {IconData? icon}) => InputDecoration(
        counterText: '',
        hintText: hint,
        hintStyle: const TextStyle(fontSize: 13, color: Color(0xFF94A3B8)),
        prefixIcon: icon == null ? null : Icon(icon, size: 18, color: AppPalette.textMuted),
        filled: true,
        fillColor: Colors.white,
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(vertical: 13, horizontal: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppPalette.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppPalette.secondary),
        ),
      );

  Widget _label(String t) => Padding(
        padding: const EdgeInsets.only(bottom: 6, top: 2),
        child: Text(t,
            style: const TextStyle(color: AppPalette.textPrimary, fontSize: 12, fontWeight: FontWeight.w700)),
      );

  List<Widget> _otpForm() {
    final locked = _otpSent;
    return [
      if (_signUp) ...[
        Row(children: [
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              _label('First Name'),
              TextField(controller: _firstCtrl, enabled: !locked, textCapitalization: TextCapitalization.words, decoration: _dec('e.g. Rajesh')),
            ]),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              _label('Last Name'),
              TextField(controller: _lastCtrl, enabled: !locked, textCapitalization: TextCapitalization.words, decoration: _dec('e.g. Sharma')),
            ]),
          ),
        ]),
        const SizedBox(height: 12),
        _label('Business Email'),
        TextField(controller: _emailCtrl, enabled: !locked, keyboardType: TextInputType.emailAddress, decoration: _dec('name@company.com', icon: Icons.mail_outline)),
        const SizedBox(height: 12),
        _label(_role == 'SELLER' ? 'Company Name' : 'Company Name (optional)'),
        TextField(controller: _companyCtrl, enabled: !locked, textCapitalization: TextCapitalization.words, decoration: _dec('Your company', icon: Icons.business_outlined)),
        if (_role == 'SELLER') ...[
          const SizedBox(height: 12),
          _label('GSTIN (15 characters)'),
          TextField(controller: _gstinCtrl, enabled: !locked, maxLength: 15, textCapitalization: TextCapitalization.characters, decoration: _dec('27AABCT3518Q1ZV', icon: Icons.verified_user_outlined)),
        ],
        const SizedBox(height: 12),
        _label('City (optional)'),
        TextField(controller: _cityCtrl, enabled: !locked, textCapitalization: TextCapitalization.words, decoration: _dec('e.g. Mumbai', icon: Icons.location_on_outlined)),
        const SizedBox(height: 12),
      ],
      _label(_signUp ? '10-Digit Mobile Number (OTP will be sent here)' : 'Registered 10-Digit Mobile Number'),
      TextField(
        controller: _phoneCtrl,
        enabled: !locked,
        keyboardType: TextInputType.phone,
        maxLength: 10,
        style: const TextStyle(fontSize: 13),
        decoration: _dec('e.g. 9876543210', icon: Icons.smartphone),
      ),
      if (!_otpSent && !_signUp) ...[
        const SizedBox(height: 14),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFFEFF6FF),
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
        _label('Enter the 6-digit OTP'),
        TextField(
          controller: _otpCtrl,
          autofocus: true,
          keyboardType: TextInputType.number,
          maxLength: 6,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 20, letterSpacing: 8, fontWeight: FontWeight.w800),
          decoration: _dec('------'),
        ),
        const SizedBox(height: 4),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            TextButton(
              onPressed: _busy ? null : () => _resetFlow(),
              child: const Text('Change number', style: TextStyle(fontSize: 12)),
            ),
            TextButton(
              onPressed: (_busy || _resendIn > 0) ? null : () => _sendOtp(),
              child: Text(_resendIn > 0 ? 'Resend OTP in ${_resendIn}s' : 'Resend OTP',
                  style: const TextStyle(fontSize: 12)),
            ),
          ],
        ),
      ],
      if (_info != null) ...[
        const SizedBox(height: 8),
        Text(_info!, style: const TextStyle(color: Color(0xFF059669), fontSize: 12, fontWeight: FontWeight.w600)),
      ],
      if (_error != null) ...[
        const SizedBox(height: 8),
        Text(_error!, style: const TextStyle(color: AppPalette.danger, fontSize: 12, fontWeight: FontWeight.w600)),
      ],
      const SizedBox(height: 16),
      SizedBox(
        height: 48,
        child: ElevatedButton(
          onPressed: _busy ? null : (_otpSent ? _verifyOtp : () => _sendOtp()),
          style: ElevatedButton.styleFrom(
            backgroundColor: _roleColor,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            elevation: 0,
          ),
          child: _busy
              ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2.4, color: Colors.white))
              : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      _otpSent
                          ? (_signUp ? 'Verify & Create Account' : 'Verify & Sign In')
                          : (_signUp
                              ? 'Send OTP & Create ${_role == 'BUYER' ? 'BUYER' : 'SELLER'} Account'
                              : 'Sign In to ${_role == 'BUYER' ? 'BUYER' : 'SELLER'} Portal'),
                      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800),
                    ),
                    const SizedBox(width: 6),
                    const Icon(Icons.arrow_forward, size: 16),
                  ],
                ),
        ),
      ),
    ];
  }

  Widget _portalTab(String role, String label, IconData icon) {
    final selected = _role == role;
    final color = role == 'BUYER' ? const Color(0xFF059669) : AppPalette.sellerAccent;
    return InkWell(
      onTap: () => _resetFlow(role: role),
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
