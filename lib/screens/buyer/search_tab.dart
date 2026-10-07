import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/app_data_providers.dart';
import '../shared/api_future_view.dart';
import '../shared/product_card.dart';

/// Buyer Search: live catalog search over the existing products route.
class BuyerSearchTab extends ConsumerWidget {
  const BuyerSearchTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final query = ref.watch(searchQueryProvider);
    final results = ref.watch(searchResultsProvider);
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
          child: SearchBar(
            hintText: 'Search industrial products, categories...',
            leading: const Icon(Icons.search_rounded),
            onChanged: (v) => ref.read(searchQueryProvider.notifier).state = v,
          ),
        ),
        Expanded(
          child: query.trim().isEmpty
              ? const Center(
                  child: Text(
                    'Type to search the live catalog.',
                    style: TextStyle(color: Colors.grey),
                  ),
                )
              : ApiFutureView(
                  value: results,
                  isEmpty: (d) => d.isEmpty,
                  empty: Center(
                    child: Text('No products matched "$query".',
                        style: const TextStyle(color: Colors.grey)),
                  ),
                  data: (list) => ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                    itemCount: list.length,
                    itemBuilder: (context, i) => ProductCard(product: list[i]),
                  ),
                ),
        ),
      ],
    );
  }
}
