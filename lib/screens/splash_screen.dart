import 'package:flutter/material.dart';

/// Branded splash / loader shown while the saved session is being restored.
/// This is ALWAYS the first thing a user sees when the app starts - a clean
/// logo + loader, no data, no role hints, nothing admin-related.
class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A), // slate-900, matches web
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/logo.png',
              width: 132,
              height: 132,
              fit: BoxFit.contain,
            ),
            const SizedBox(height: 28),
            const Text(
              'MyIndustryHouse',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w900,
                letterSpacing: 0.5,
                color: Color(0xFFF8FAFC),
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'Verified industrial trading',
              style: TextStyle(
                fontSize: 12,
                color: Color(0xFF94A3B8),
                letterSpacing: 0.3,
              ),
            ),
            const SizedBox(height: 40),
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
    );
  }
}
