import 'api_client.dart';
import 'endpoints.dart';
import 'models/product.dart';
import 'models/seller.dart';

/// Catalog + seller discovery against the EXISTING API.
class CatalogRepository {
  const CatalogRepository._();
  static const instance = CatalogRepository._();

  Future<List<Product>> products({String? search}) async {
    final res = await ApiClient.instance.get(Api.products,
        query: (search == null || search.isEmpty) ? null : {'search': search});
    final items = (res['products'] ?? res['items'] ?? res['data']) as List? ?? const [];
    return items.map((e) => Product.fromApiJson(e as Map<String, dynamic>)).toList();
  }

  Future<List<SellerInfo>> sellers() async {
    final res = await ApiClient.instance.get(Api.sellers);
    final items = (res['sellers'] ?? res['data']) as List? ?? const [];
    return items.map((e) => SellerInfo.fromApiJson(e as Map<String, dynamic>)).toList();
  }

  Future<List<Product>> sellerCatalog(String sellerId) async {
    final res = await ApiClient.instance.get(Api.catalogItems,
        query: {'sellerId': sellerId});
    final items = (res['products'] ?? res['items'] ?? res['data']) as List? ?? const [];
    return items.map((e) => Product.fromApiJson(e as Map<String, dynamic>)).toList();
  }

  /// Seller publishes a product (existing POST /api/v1/products route).
  Future<Map<String, dynamic>> createProduct(Map<String, dynamic> body) =>
      ApiClient.instance.post(Api.products, body: body);
}
