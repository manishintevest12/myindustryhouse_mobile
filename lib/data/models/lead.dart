/// RFQ / commerce lead (BuyLead) as returned by /api/v1/leads.
class Lead {
  const Lead({
    required this.id,
    required this.buyerName,
    required this.buyerCompany,
    required this.buyerPhone,
    required this.productName,
    required this.quantity,
    required this.stage,
    required this.createdAt,
    required this.budget,
    required this.notes,
    this.lockedBySellerId,
  });

  final String id;
  final String buyerName;
  final String buyerCompany;
  final String buyerPhone;
  final String productName;
  final String quantity;
  final String stage;
  final String createdAt;
  final String budget;
  final String notes;
  final String? lockedBySellerId;

  static Lead fromApiJson(Map<String, dynamic> j) => Lead(
        id: (j['lead_id'] ?? j['id'] ?? '').toString(),
        buyerName: (j['buyer_name'] ?? j['buyerName'] ?? 'Buyer').toString(),
        buyerCompany: (j['buyer_company'] ?? j['company_name'] ?? '').toString(),
        buyerPhone: (j['buyer_phone'] ?? j['phone'] ?? '').toString(),
        productName: (j['product_name'] ?? j['product'] ?? 'Product').toString(),
        quantity: (j['quantity'] ?? j['qty'] ?? '').toString(),
        stage: (j['stage'] ?? j['status'] ?? 'NEW').toString().toUpperCase(),
        createdAt: (j['created_at'] ?? j['createdAt'] ?? '').toString(),
        budget: (j['budget'] ?? j['budget_range'] ?? '').toString(),
        notes: (j['notes'] ?? j['message'] ?? '').toString(),
        lockedBySellerId: j['locked_by']?.toString(),
      );
}
