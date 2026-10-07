/// Verified seller as returned by /api/v1/sellers (viewSeller shape).
class SellerInfo {
  const SellerInfo({
    required this.id,
    required this.name,
    required this.companyName,
    required this.city,
    required this.isVerified,
    required this.rating,
    required this.specialties,
  });

  final String id;
  final String name;
  final String companyName;
  final String city;
  final bool isVerified;
  final double rating;
  final List<String> specialties;

  static SellerInfo fromApiJson(Map<String, dynamic> j) => SellerInfo(
        id: (j['seller_id'] ?? j['id'] ?? '').toString(),
        name: (j['seller_name'] ?? j['name'] ?? '').toString(),
        companyName: (j['company_name'] ?? '').toString(),
        city: (j['city'] ?? j['location'] ?? '').toString(),
        isVerified: j['is_verified'] == true || j['isVerified'] == true,
        rating: (j['rating'] is num) ? (j['rating'] as num).toDouble() : 4.5,
        specialties: ((j['specialties'] as List?) ?? const [])
            .map((e) => e.toString())
            .toList(growable: false),
      );
}
