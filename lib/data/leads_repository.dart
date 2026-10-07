import 'api_client.dart';
import 'endpoints.dart';
import 'models/lead.dart';

/// RFQ leads against the EXISTING API. Buyers see their own RFQs;
/// sellers see matched leads and unlock with credits.
class LeadsRepository {
  const LeadsRepository._();
  static const instance = LeadsRepository._();

  Future<List<Lead>> buyerLeads({required String buyerId, String? phone, String? email}) async {
    final query = <String, dynamic>{'buyerId': buyerId};
    if (phone != null && phone.isNotEmpty) query['buyerPhone'] = phone;
    if (email != null && email.isNotEmpty) query['buyerEmail'] = email;
    final res = await ApiClient.instance.get(Api.leads, query: query);
    final items = (res['leads'] ?? res['data']) as List? ?? const [];
    return items.map((e) => Lead.fromApiJson(e as Map<String, dynamic>)).toList();
  }

  Future<List<Lead>> sellerLeads({required String sellerId}) async {
    final res = await ApiClient.instance.get(
        Api.at(Api.leads, 'sellerId', sellerId)); // /api/v1/sellers/:id/leads/matched
    // The matched route is keyed differently; use the canonical matched path.
    final res2 = (res['matched'] != null)
        ? res
        : await ApiClient.instance.get(
            Api.at('/api/v1/sellers/:id/leads/matched', 'id', sellerId));
    final items = (res2['leads'] ?? res2['matched'] ?? res2['data']) as List? ?? const [];
    return items.map((e) => Lead.fromApiJson(e as Map<String, dynamic>)).toList();
  }

  /// Unlock a lead as a seller - consumes one lead credit on the server.
  Future<Map<String, dynamic>> unlockLead({
    required String sellerId,
    required String leadId,
  }) =>
      ApiClient.instance.post(
          Api.at('/api/v1/sellers/:sellerId/leads/:leadId/unlock', 'sellerId', sellerId)
              .replaceFirst(':leadId', leadId),
          body: {'leadId': leadId});

  /// Buyer submits a new RFQ (existing lead-intake).
  Future<Map<String, dynamic>> createLead(Map<String, dynamic> body) =>
      ApiClient.instance.post(Api.leads, body: body);

  Future<Map<String, dynamic>> credits(String sellerId) async {
    final res = await ApiClient.instance.get(Api.at(Api.sellerCredits, 'id', sellerId));
    return res['credits'] is Map ? (res['credits'] as Map<String, dynamic>) : res;
  }

  Future<Map<String, dynamic>> conversions(String sellerId) async {
    final res = await ApiClient.instance.get(
        Api.at('/api/v1/sellers/:sellerId/analytics/conversions', 'sellerId', sellerId));
    return res['analytics'] is Map ? (res['analytics'] as Map<String, dynamic>) : res;
  }
}
