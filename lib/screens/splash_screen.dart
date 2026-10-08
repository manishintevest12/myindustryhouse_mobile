import 'package:flutter/material.dart';

/// Branded splash / loader - always the first thing the app shows (like the
/// website's page loader), while the saved session is restored.
class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: TweenAnimationBuilder<double>(
          tween: Tween(begin: 0, end: 1),
          duration: const Duration(milliseconds: 700),
          curve: Curves.easeOut,
          builder: (context, t, child) => Opacity(
            opacity: t,
            child: Transform.scale(scale: 0.92 + 0.08 * t, child: child),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset('assets/logo_mark.png', width: 120, height: 120, fit: BoxFit.contain),
              const SizedBox(height: 24),
              const Text(
                'My Industry House',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0.3,
                  color: Color(0xFF0F172A),
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'Verified industrial trading, direct buyer to seller',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 12, color: Color(0xFF64748B)),
              ),
              const SizedBox(height: 36),
              const SizedBox(
                width: 28,
                height: 28,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  valueColor: AlwaysStoppedAnimation(Color(0xFFF59E0B)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
