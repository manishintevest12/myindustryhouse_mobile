import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/leads_repository.dart';
import '../../data/models/product.dart';

/// RFQ bottom sheet: quantity, budget, requirement -> existing
/// POST /api/v1/leads/broadcast intake (server matches sellers itself).
/// Returns the created lead payload on success; null on failure/cancel.
class RfqSheet extends ConsumerStatefulWidget {
  const RfqSheet({
    super.key,
    required this.product,
    required this.buyerName,
    required this.buyerPhone,
    this.buyerEmail,
  });

  final Product product;
  final String buyerName;
  final String buyerPhone;
  final String? buyerEmail;

  @override
  ConsumerState<RfqSheet> createState() => _RfqSheetState();
}

class _RfqSheetState extends ConsumerState<RfqSheet> {
  final _quantity = TextEditingController(text: '100');
  final _budget = TextEditingController(text: '250000');
  final _requirement = TextEditingController();
  bool _busy = false;

  @override
  void dispose() {
    _quantity.dispose();
    _budget.dispose();
    _requirement.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_busy) return;
    setState(() => _busy = true);
    final res = await LeadsRepository.instance.createLead({
      'rfqTitle': 'RFQ: ${widget.product.name}',
      'buyerName': widget.buyerName,
      'buyerPhone': widget.buyerPhone,
      if (widget.buyerEmail != null) 'buyerEmail': widget.buyerEmail,
      'category': widget.product.category,
      'targetCategoryTags': [
        widget.product.category,
        ...widget.product.categoryTags,
      ],
      'targetingSellerId': widget.product.sellerId,
      'quantity': num.tryParse(_quantity.text.trim()) ?? 100,
      'unit': widget.product.unit,
      'estimatedBudget': num.tryParse(_budget.text.trim()) ?? 0,
      'requirementDetails': _requirement.text.trim().isEmpty
          ? 'Requirement: ${widget.product.name} (from catalog)'
          : _requirement.text.trim(),
    });
    if (!mounted) return;
    final leadId = res['leadId'] ?? res['lead_id'] ?? (res['lead'] is Map
        ? (res['lead'] as Map)['lead_id']
        : null);
    if (res['status'] == 'SUCCESS' ||
        res['success'] == true ||
        leadId != null) {
      Navigator.pop(context, {'leadId': leadId?.toString()});
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(
            (res['message'] ?? res['reason'] ?? 'RFQ could not be sent.')
                .toString()),
      ));
      setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 16, right: 16, top: 16,
        bottom: MediaQuery.of(context).viewInsets.bottom + 16,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('Send RFQ — ${widget.product.name}',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900)),
          const SizedBox(height: 4),
          const Text(
              'Sellers matched to this category will receive your requirement.',
              style: TextStyle(fontSize: 11, color: Colors.grey)),
          const SizedBox(height: 14),
          TextField(
              controller: _quantity,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(labelText: 'Quantity (${widget.product.unit.isEmpty ? 'units' : widget.product.unit})')),
          const SizedBox(height: 10),
          TextField(
              controller: _budget,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Estimated budget (₹)')),
          const SizedBox(height: 10),
          TextField(
              controller: _requirement,
              maxLines: 3,
              decoration: const InputDecoration(
                  labelText: 'Requirement details (specs, delivery city...)')),
          const SizedBox(height: 16),
          FilledButton(
            onPressed: _busy ? null : _submit,
            child: _busy
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2))
                : const Text('Send RFQ'),
          ),
        ],
      ),
    );
  }
}
