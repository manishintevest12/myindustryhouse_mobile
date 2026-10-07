/// Catalog product as returned by the existing /api/v1/products route
/// (viewProduct shape). Fields are read defensively - no invented data.
class Product {
  const Product({
    required this.id,
    required this.name,
    required this.price,
    required this.unit,
    required this.moq,
    required this.category,
    required this.description,
    required this.imageUrl,
    required this.sellerId,
    required this.sellerName,
    required this.isVerifiedSeller,
    this.categoryTags = const [],
  });

  final String id;
  final String name;
  final double price;
  final String unit;
  final int moq;
  final String category;
  final String description;
  final String imageUrl;
  final String sellerId;
  final String sellerName;
  final bool isVerifiedSeller;
  final List<String> categoryTags;

  static Product fromApiJson(Map<String, dynamic> j) => Product(
        id: (j['product_id'] ?? j['id'] ?? '').toString(),
        name: (j['product_name'] ?? j['name'] ?? 'Unnamed product').toString(),
        price: (j['price'] is num) ? (j['price'] as num).toDouble() : 1000.0,
        unit: (j['unit'] ?? 'UNIT').toString(),
        moq: (j['moq'] is num) ? (j['moq'] as num).toInt() : 1,
        category: (j['category'] ?? 'Industrial Machinery').toString(),
        description: (j['description'] ?? '').toString(),
        imageUrl: (j['imageUrl'] ?? (j['images'] is List && (j['images'] as List).isNotEmpty ? (j['images'] as List).first : '') ?? '').toString(),
        sellerId: (j['seller_id'] ?? '').toString(),
        sellerName: (j['seller_name'] ?? '').toString(),
        isVerifiedSeller: j['isVerifiedSeller'] == true || j['is_verified'] == true,
        categoryTags: ((j['categoryTags'] as List?) ?? const [])
            .map((e) => e.toString())
            .toList(growable: false),
      );

  String get priceInr => '₹${price.toStringAsFixed(price == price.roundToDouble() ? 0 : 2)}';
}
