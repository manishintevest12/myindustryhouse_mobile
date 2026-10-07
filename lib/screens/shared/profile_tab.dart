import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/role.dart';
import '../../providers/session_provider.dart';

/// Profile tab (shared): real session data + logout. KYC/company info
/// shown only if the backend returned it - never invented.
class ProfileTab extends ConsumerWidget {
  const ProfileTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(sessionProvider).valueOrNull;
    if (user == null) {
      return const Center(child: CircularProgressIndicator());
    }
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 32),
      children: [
        Center(
          child: CircleAvatar(
            radius: 40,
            backgroundColor: const Color(0xFFF59E0B).withValues(alpha: 0.18),
            child: Text(
              (user.fullName.isEmpty ? user.phone : user.fullName)
                  .characters.first
                  .toUpperCase(),
              style: const TextStyle(
                  fontSize: 26, fontWeight: FontWeight.w900, color: Color(0xFFF59E0B)),
            ),
          ),
        ),
        const SizedBox(height: 14),
        Center(
          child: Text(
            user.fullName.isEmpty ? 'Verified Member' : user.fullName,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
          ),
        ),
        const SizedBox(height: 4),
        Center(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
            decoration: BoxDecoration(
              color: const Color(0xFF10B981).withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              user.role.label,
              style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF10B981)),
            ),
          ),
        ),
        const SizedBox(height: 28),
        Card(
          child: Column(
            children: [
              _row(Icons.phone_rounded, '+91 ${user.phone}'),
              if (user.email != null && user.email!.isNotEmpty)
                _row(Icons.mail_rounded, user.email!),
              if (user.companyName != null && user.companyName!.isNotEmpty)
                _row(Icons.business_rounded, user.companyName!),
              _row(Icons.badge_rounded, 'ID: ${user.userId.isEmpty ? '-' : user.userId}'),
            ],
          ),
        ),
        const SizedBox(height: 28),
        FilledButton.tonalIcon(
          style: FilledButton.styleFrom(
            backgroundColor: const Color(0xFFE11D48).withValues(alpha: 0.15),
            foregroundColor: const Color(0xFFE11D48),
          ),
          onPressed: () async {
            final ok = await showDialog<bool>(
              context: context,
              builder: (ctx) => AlertDialog(
                title: const Text('Log out?'),
                content: const Text(
                    'You will need your phone OTP to sign in again.'),
                actions: [
                  TextButton(
                      onPressed: () => Navigator.pop(ctx, false),
                      child: const Text('Cancel')),
                  FilledButton(
                      onPressed: () => Navigator.pop(ctx, true),
                      child: const Text('Log out')),
                ],
              ),
            );
            if (ok == true) {
              await ref.read(sessionProvider.notifier).signOut();
            }
          },
          icon: const Icon(Icons.logout_rounded),
          label: const Text('Log out'),
        ),
        const SizedBox(height: 16),
        const Center(
          child: Text(
            'MyIndustryHouse • Verified industrial trading',
            style: TextStyle(fontSize: 11, color: Colors.grey),
          ),
        ),
      ],
    );
  }

  Widget _row(IconData icon, String text) => ListTile(
        dense: true,
        leading: Icon(icon, size: 18, color: const Color(0xFF94A3B8)),
        title: Text(text, style: const TextStyle(fontSize: 13)),
      );
}
