import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/catalog_repository.dart';
import '../../providers/app_data_providers.dart';
import '../../providers/session_provider.dart';
import '../shared/api_future_view.dart';
import '../shared/product_card.dart';

/// Seller Products: your catalog from the existing products route +
/// publish sheet hitting POST /api/v1/products.
class SellerProductsTab extends ConsumerWidget {
  const SellerProductsTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final products = ref.watch(productsProvider);
    return Column(
      children: [
        SectionHeader('Manage Products', action: FilledButton.tonalIcon(
          onPressed: () => _openCreateSheet(context, ref),
          icon: const Icon(Icons.add_rounded, size: 18),
          label: const Text('Publish'),
        )),
        Expanded(
          child: RefreshIndicator(
            onRefresh: () async => ref.refresh(productsProvider.future),
            child: ApiFutureView(
              value: products,
              isEmpty: (d) => d.isEmpty,
              empty: ListView(children: const [
                SizedBox(height: 120),
                Center(
                  child: Text(
                      'No products yet. Tap "Publish" to list your first product.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey)),
                ),
              ]),
              data: (list) => ListView.builder(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                itemCount: list.length,
                itemBuilder: (context, i) => ProductCard(product: list[i]),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _openCreateSheet(BuildContext context, WidgetRef ref) async {
    final name = TextEditingController();
    final price = TextEditingController();
    final category = TextEditingController();
    final description = TextEditingController();
    final imageUrl = TextEditingController();
    bool busy = false;

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheet) => Padding(
          padding: EdgeInsets.only(
            left: 16, right: 16, top: 16,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 16,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text('Publish Product',
                  style: TextStyle(fontSize: 17, fontWeight: FontWeight.w900)),
              const SizedBox(height: 14),
              TextField(
                  controller: name,
                  decoration: const InputDecoration(labelText: 'Product name')),
              const SizedBox(height: 10),
              TextField(
                  controller: price,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Price (₹)')),
              const SizedBox(height: 10),
              TextField(
                  controller: category,
                  decoration: const InputDecoration(labelText: 'Category')),
              const SizedBox(height: 10),
              TextField(
                  controller: description,
                  maxLines: 3,
                  decoration: const InputDecoration(labelText: 'Description')),
              const SizedBox(height: 10),
              TextField(
                  controller: imageUrl,
                  keyboardType: TextInputType.url,
                  decoration: const InputDecoration(
                      labelText: 'Image URL (optional)',
                      helperText: 'Paste a hosted image link')),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: busy
                    ? null
                    : () async {
                        if (name.text.trim().isEmpty ||
                            price.text.trim().isEmpty) {
                          ScaffoldMessenger.of(ctx).showSnackBar(
                            const SnackBar(
                                content: Text('Name and price are required.')),
                          );
                          return;
                        }
                        setSheet(() => busy = true);
                        final me =
                            ref.read(sessionProvider).valueOrNull;
                        final res = await CatalogRepository.instance
                            .createProduct({
                          'productName': name.text.trim(),
                          'price': num.tryParse(price.text.trim()) ?? 0,
                          'category': category.text.trim(),
                          'description': description.text.trim(),
                          'sellerId': me?.userId ?? '',
                          'imageUrl': imageUrl.text.trim().isEmpty
                              ? null
                              : imageUrl.text.trim(),
                        });
                        if (ctx.mounted) Navigator.pop(ctx);
                        if (res['status'] == 'SUCCESS' || res['success'] == true) {
                          ref.invalidate(productsProvider);
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text('Product published.')),
                            );
                          }
                        } else if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                                content: Text(
                                    (res['message'] ?? 'Publish failed.')
                                        .toString())),
                          );
                        }
                      },
                child: const Text('Publish Product'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
