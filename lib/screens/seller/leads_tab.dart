import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/leads_repository.dart';
import '../../data/models/lead.dart';
import '../../providers/app_data_providers.dart';
import '../../providers/session_provider.dart';
import '../shared/api_future_view.dart';

/// Seller Leads: matched RFQs from the existing leads routes, with
/// credit-based unlock. All costs and outcomes come from the server.
class SellerLeadsTab extends ConsumerWidget {
  const SellerLeadsTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final leads = ref.watch(myLeadsProvider);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeader('Orders & Leads'),
        Expanded(
          child: RefreshIndicator(
            onRefresh: () async => ref.refresh(myLeadsProvider.future),
            child: ApiFutureView(
              value: leads,
              isEmpty: (d) => d.isEmpty,
              empty: ListView(children: const [
                SizedBox(height: 120),
                Center(
                  child: Text(
                      'No matched leads yet. New RFQs matching your catalog will appear here.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey)),
                ),
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

class _LeadCard extends ConsumerWidget {
  const _LeadCard({required this.lead});

  final Lead lead;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final unlocked = lead.lockedBySellerId != null && lead.lockedBySellerId!.isNotEmpty;
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
                Text(lead.stage,
                    style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF0EA5E9))),
              ],
            ),
            const SizedBox(height: 6),
            Text(
                'Qty: ${lead.quantity.isEmpty ? '-' : lead.quantity}'
                '${lead.budget.isEmpty ? '' : '  •  Budget: ${lead.budget}'}',
                style: const TextStyle(fontSize: 12, color: Colors.grey)),
            const SizedBox(height: 10),
            if (unlocked) ...[
              Row(
                children: [
                  const Icon(Icons.lock_open_rounded,
                      size: 14, color: Color(0xFF10B981)),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      'Buyer: ${lead.buyerName}'
                      '${lead.buyerPhone.isEmpty ? '' : ' • ${lead.buyerPhone}'}',
                      style: const TextStyle(fontSize: 12),
                    ),
                  ),
                ],
              ),
            ] else
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  style: FilledButton.styleFrom(
                      backgroundColor: const Color(0xFFF59E0B),
                      foregroundColor: const Color(0xFF1C1917)),
                  icon: const Icon(Icons.lock_rounded, size: 16),
                  label: const Text('Unlock with lead credit'),
                  onPressed: () async {
                    final me = ref.read(sessionProvider).valueOrNull;
                    if (me == null) return;
                    final res = await LeadsRepository.instance.unlockLead(
                        sellerId: me.userId, leadId: lead.id);
                    if (res['status'] == 'SUCCESS' || res['success'] == true) {
                      ref.invalidate(myLeadsProvider);
                      ref.invalidate(sellerCreditsProvider);
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content:
                                  Text('Lead unlocked. Buyer contact revealed.')),
                        );
                      }
                    } else if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        content: Text((res['message'] ??
                                res['reason'] ??
                                'Unlock failed.')
                            .toString()),
                      ));
                    }
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}
