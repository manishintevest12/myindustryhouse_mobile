import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/app_data_providers.dart';
import '../shared/api_future_view.dart';

/// Seller Dashboard: lead credits balance + conversion analytics, all from
/// the existing seller routes. Numbers shown are server numbers only.
class SellerDashboardTab extends ConsumerWidget {
  const SellerDashboardTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final credits = ref.watch(sellerCreditsProvider);
    final conversions = ref.watch(sellerConversionsProvider);
    return RefreshIndicator(
      onRefresh: () async {
        await Future.wait([
          ref.refresh(sellerCreditsProvider.future),
          ref.refresh(sellerConversionsProvider.future),
        ]);
      },
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 20, 16, 24),
        children: [
          const Text('Dashboard',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900)),
          const SizedBox(height: 16),
          ApiFutureView(
            value: credits,
            isEmpty: (d) => d.isEmpty,
            empty: const SizedBox.shrink(),
            data: (c) => Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    const Icon(Icons.toll_rounded,
                        size: 30, color: Color(0xFFF59E0B)),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Lead Credits',
                            style: TextStyle(
                                fontSize: 11, color: Colors.grey)),
                        Text(
                          '${c['balance'] ?? c['credits_balance'] ?? c['remaining'] ?? '-'}',
                          style: const TextStyle(
                              fontSize: 22, fontWeight: FontWeight.w900),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 14),
          ApiFutureView(
            value: conversions,
            isEmpty: (d) => d.isEmpty,
            empty: const SizedBox.shrink(),
            data: (a) => Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Conversion Analytics',
                        style: TextStyle(
                            fontSize: 13, fontWeight: FontWeight.w800)),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: [
                        _stat('Won', '${a['wonLeads'] ?? a['won'] ?? '-'}'),
                        _stat('Lost', '${a['lostLeads'] ?? a['lost'] ?? '-'}'),
                        _stat(
                            'Win rate',
                            '${a['winRate'] ?? a['win_rate'] ?? '-'}'
                            '${(a['winRate'] ?? a['win_rate']) != null ? '%' : ''}'),
                        _stat('Pipeline', '${a['pipeline'] ?? a['open'] ?? '-'}'),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _stat(String label, String value) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label,
                style: const TextStyle(fontSize: 10, color: Colors.grey)),
            Text(value,
                style: const TextStyle(
                    fontSize: 16, fontWeight: FontWeight.w900)),
          ],
        ),
      );
}
