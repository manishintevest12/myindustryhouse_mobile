import 'package:flutter/material.dart';

import '../../data/models/product.dart';

/// Product card with honest placeholder when the image fails or is empty.
class ProductCard extends StatelessWidget {
  const ProductCard({super.key, required this.product, this.onTap});

  final Product product;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AspectRatio(
              aspectRatio: 16 / 9,
              child: product.imageUrl.isEmpty
                  ? Container(
                      color: Theme.of(context).colorScheme.surface,
                      child: const Center(
                        child: Icon(Icons.precision_manufacturing_rounded,
                            size: 40, color: Colors.grey),
                      ),
                    )
                  : Image.network(
                      product.imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        color: Theme.of(context).colorScheme.surface,
                        child: const Center(
                          child: Icon(Icons.image_not_supported_outlined,
                              size: 36, color: Colors.grey),
                        ),
                      ),
                    ),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      if (product.isVerifiedSeller) ...[
                        const Icon(Icons.verified_rounded,
                            size: 14, color: Color(0xFF10B981)),
                        const SizedBox(width: 4),
                      ],
                      Expanded(
                        child: Text(product.sellerName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: Colors.grey)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(product.name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                          fontSize: 14, fontWeight: FontWeight.w800)),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Text(product.priceInr,
                          style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w900,
                              color: Color(0xFFF59E0B))),
                      const SizedBox(width: 6),
                      Text('/ ${product.unit}',
                          style: const TextStyle(fontSize: 11, color: Colors.grey)),
                      const Spacer(),
                      Text('MOQ ${product.moq}',
                          style: const TextStyle(
                              fontSize: 11, color: Colors.grey)),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(product.category,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 11, color: Colors.grey)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
