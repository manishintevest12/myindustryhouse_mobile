import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/lead.dart';
import '../../providers/app_data_providers.dart';
import '../shared/api_future_view.dart';

/// Buyer Orders: your RFQs and the B2B order pipeline (PI -> UTR -> TI),
/// straight from the existing leads route.
class BuyerOrdersTab extends ConsumerWidget {
  const BuyerOrdersTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final leads = ref.watch(myLeadsProvider);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeader('My RFQs & Orders'),
        Expanded(
          child: RefreshIndicator(
            onRefresh: () async => ref.refresh(myLeadsProvider.future),
            child: ApiFutureView(
              value: leads,
              isEmpty: (d) => d.isEmpty,
              empty: ListView(children: const [
                SizedBox(height: 120),
                _EmptyHint(
                    'No RFQs yet. Browse products and send your first inquiry to a seller.'),
              ]),
              data: (list) => ListView.separated(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                itemCount: list.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, i) => _LeadCard(lead: list[i]),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _LeadCard extends StatelessWidget {
  const _LeadCard({required this.lead});

  final Lead lead;

  Color get _stageColor => switch (lead.stage) {
        'WON' || 'CLOSED' => const Color(0xFF10B981),
        'LOST' => const Color(0xFFE11D48),
        'NEGOTIATION' || 'QUOTE' => const Color(0xFFF59E0B),
        _ => const Color(0xFF0EA5E9),
      };

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(lead.productName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                          fontSize: 14, fontWeight: FontWeight.w800)),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: _stageColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(lead.stage,
                      style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          color: _stageColor)),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text('Qty: ${lead.quantity.isEmpty ? '-' : lead.quantity}'
                '${lead.budget.isEmpty ? '' : '  •  Budget: ${lead.budget}'}',
                style: const TextStyle(fontSize: 12, color: Colors.grey)),
            if (lead.createdAt.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(lead.createdAt,
                  style: const TextStyle(fontSize: 10, color: Colors.grey)),
            ],
          ],
        ),
      ),
    );
  }
}

class _EmptyHint extends StatelessWidget {
  const _EmptyHint(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Center(
        child: Text(text,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 12, color: Colors.grey)),
      ),
    );
  }
}
