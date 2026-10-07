import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/seller.dart';
import '../../providers/app_data_providers.dart';
import '../shared/api_future_view.dart';
import '../shared/product_card.dart';

/// Buyer Home: live product feed + verified sellers strip.
class BuyerHomeTab extends ConsumerWidget {
  const BuyerHomeTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final products = ref.watch(productsProvider);
    final sellers = ref.watch(sellersProvider);
    return RefreshIndicator(
      onRefresh: () async => ref.refresh(productsProvider.future),
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.only(bottom: 24),
        children: [
          const SectionHeader('Featured Products'),
          ApiFutureView(
            value: products,
            isEmpty: (d) => d.isEmpty,
            empty: const _EmptyHint(
                'No products are published yet. Sellers are onboarding.'),
            data: (list) => Column(
              children: [
                for (final p in list.take(12))
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: ProductCard(product: p),
                  ),
              ],
            ),
          ),
          const SectionHeader('Verified Sellers'),
          ApiFutureView(
            value: sellers,
            isEmpty: (d) => d.isEmpty,
            empty: const _EmptyHint('No sellers onboarded yet.'),
            data: (list) => SizedBox(
              height: 106,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: list.length,
                separatorBuilder: (_, __) => const SizedBox(width: 10),
                itemBuilder: (context, i) => _SellerChip(seller: list[i]),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SellerChip extends StatelessWidget {
  const _SellerChip({required this.seller});

  final SellerInfo seller;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Container(
        width: 210,
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              children: [
                Icon(
                  seller.isVerified ? Icons.verified_rounded : Icons.store_rounded,
                  size: 16,
                  color: seller.isVerified ? const Color(0xFF10B981) : Colors.grey,
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(seller.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                          fontSize: 13, fontWeight: FontWeight.w800)),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              seller.companyName.isEmpty ? seller.city : seller.companyName,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 11, color: Colors.grey),
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(Icons.star_rounded, size: 13, color: Color(0xFFF59E0B)),
                Text(' ${seller.rating.toStringAsFixed(1)}',
                    style: const TextStyle(
                        fontSize: 11, fontWeight: FontWeight.w700)),
              ],
            ),
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
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: Center(
        child: Text(text,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 12, color: Colors.grey)),
      ),
    );
  }
}
