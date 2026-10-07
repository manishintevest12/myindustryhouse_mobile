import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/chat_repository.dart';
import '../../data/models/product.dart';
import '../../data/models/seller.dart';
import '../../providers/app_data_providers.dart';
import '../../providers/session_provider.dart';
import '../chat/chat_thread_screen.dart';
import 'rfq_sheet.dart';

/// Product detail: full specs, seller identity, real RFQ + chat actions.
class ProductDetailScreen extends ConsumerStatefulWidget {
  const ProductDetailScreen({super.key, required this.product});

  final Product product;

  @override
  ConsumerState<ProductDetailScreen> createState() =>
      _ProductDetailScreenState();
}

class _ProductDetailScreenState extends ConsumerState<ProductDetailScreen> {
  SellerInfo? _seller;
  bool _loadingSeller = true;

  @override
  void initState() {
    super.initState();
    _loadSeller();
  }

  Future<void> _loadSeller() async {
    try {
      final all = await ref.read(sellersProvider.future);
      if (!mounted) return;
      setState(() {
        _seller = all.where((s) => s.id == widget.product.sellerId).firstOrNull;
        _loadingSeller = false;
      });
    } catch (_) {
      if (mounted) setState(() => _loadingSeller = false);
    }
  }

  Future<void> _openRfq() async {
    final me = ref.read(sessionProvider).valueOrNull;
    if (me == null) return;
    final created = await showModalBottomSheet<Map<String, dynamic>>(
      context: context,
      isScrollControlled: true,
      builder: (_) => RfqSheet(
        product: widget.product,
        buyerName: me.fullName.isEmpty ? 'App Buyer' : me.fullName,
        buyerPhone: me.phone,
        buyerEmail: me.email,
      ),
    );
    if (created == null) return;
    final leadId = created['leadId']?.toString();
    ref.invalidate(myLeadsProvider);
    if (leadId != null && leadId.isNotEmpty && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('RFQ sent. Opening chat with seller...')),
      );
      Navigator.of(context).push(MaterialPageRoute(
        builder: (_) => ChatThreadScreen(leadId: leadId),
      ));
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('RFQ sent to matching sellers.')),
      );
    }
  }

  void _openChat() {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (_) =>
          ChatThreadScreen(leadId: 'lead-${widget.product.sellerId}'),
    ));
  }

  Future<void> _callSeller() async {
    final me = ref.read(sessionProvider).valueOrNull;
    if (me == null) return;
    final res = await ChatRepository.instance.voiceCall(
      leadId: 'lead-${widget.product.sellerId}',
      callerName: me.fullName.isEmpty ? 'App Buyer' : me.fullName,
      callerRole: 'BUYER',
      callerPhone: me.phone,
      recipientName: widget.product.sellerName,
      recipientRole: 'SELLER',
      recipientPhone: '',
    );
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text((res['message'] ??
              (res['success'] == true ? 'Call requested.' : 'Call failed.'))
          .toString()),
    ));
  }

  @override
  Widget build(BuildContext context) {
    final p = widget.product;
    return Scaffold(
      appBar: AppBar(title: const Text('Product')),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
          child: Row(
            children: [
              Expanded(
                child: FilledButton.icon(
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFFF59E0B),
                    foregroundColor: const Color(0xFF1C1917),
                  ),
                  onPressed: _openRfq,
                  icon: const Icon(Icons.send_rounded, size: 18),
                  label: const Text('Send RFQ'),
                ),
              ),
              const SizedBox(width: 8),
              IconButton.outlined(
                tooltip: 'Chat',
                onPressed: _openChat,
                icon: const Icon(Icons.chat_bubble_rounded),
              ),
              IconButton.outlined(
                tooltip: 'Call',
                onPressed: _callSeller,
                icon: const Icon(Icons.call_rounded),
              ),
            ],
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.only(bottom: 16),
        children: [
          if (p.imageUrl.isNotEmpty)
            Image.network(
              p.imageUrl,
              height: 240,
              width: double.infinity,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                height: 240,
                color: Theme.of(context).colorScheme.surface,
                child: const Icon(Icons.image_not_supported_outlined,
                    size: 48, color: Colors.grey),
              ),
            )
            else
              Container(
                height: 240,
                color: Theme.of(context).colorScheme.surface,
                child: const Icon(Icons.precision_manufacturing_rounded,
                    size: 48, color: Colors.grey),
              ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(p.name,
                          style: const TextStyle(
                              fontSize: 20, fontWeight: FontWeight.w900)),
                    ),
                    Text(p.priceInr,
                        style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w900,
                            color: Color(0xFFF59E0B))),
                  ],
                ),
                const SizedBox(height: 6),
                Text('per ${p.unit}  •  MOQ ${p.moq}',
                    style: const TextStyle(fontSize: 12, color: Colors.grey)),
                const SizedBox(height: 16),
                _row('Category', p.category),
                _row('Seller',
                    '${p.sellerName}${p.isVerifiedSeller ? '  ✓ verified' : ''}'),
                if (p.categoryTags.isNotEmpty)
                  _row('Tags', p.categoryTags.join(', ')),
                const SizedBox(height: 16),
                const Text('Description',
                    style:
                        TextStyle(fontSize: 14, fontWeight: FontWeight.w800)),
                const SizedBox(height: 6),
                Text(
                  p.description.isEmpty
                      ? 'No description provided by the seller yet.'
                      : p.description,
                  style: const TextStyle(fontSize: 13, height: 1.4),
                ),
                if (_loadingSeller) ...[
                  const SizedBox(height: 20),
                  const Center(
                      child: SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2))),
                ] else if (_seller != null) ...[
                  const SizedBox(height: 20),
                  Card(
                    child: ListTile(
                      leading: const Icon(Icons.storefront_rounded,
                          color: Color(0xFFF59E0B)),
                      title: Text(_seller!.name,
                          style: const TextStyle(fontWeight: FontWeight.w800)),
                      subtitle: Text(
                        _seller!.companyName.isEmpty
                            ? _seller!.city
                            : '${_seller!.companyName} • ${_seller!.city}',
                        style: const TextStyle(fontSize: 12),
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.star_rounded,
                              size: 16, color: Color(0xFFF59E0B)),
                          Text(_seller!.rating.toStringAsFixed(1),
                              style: const TextStyle(
                                  fontSize: 12, fontWeight: FontWeight.w800)),
                        ],
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _row(String label, String value) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 90,
              child: Text(label,
                  style: const TextStyle(fontSize: 12, color: Colors.grey)),
            ),
            Expanded(
              child: Text(value, style: const TextStyle(fontSize: 13)),
            ),
          ],
        ),
      );
}
