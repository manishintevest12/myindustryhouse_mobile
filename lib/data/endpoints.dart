/// Every endpoint below is consumed EXACTLY as it exists on the deployed
/// MyIndustryHouse backend (server.ts). Nothing here was changed on the
/// server - this file only documents the client's view of the existing API.
class Api {
  Api._();

  // --- Auth (SMS OTP, buyer & seller only) ---
  static const sendOtp = '/api/v1/auth/send-real-sms-otp';
  static const retryOtp = '/api/v1/auth/retry-sms-otp';
  static const verifyOtp = '/api/v1/auth/verify-real-sms-otp';
  static const syncUser = '/api/v1/auth/sync-user';
  static const recordUser = '/api/v1/auth/record-user';
  static const otpProvidersHealth = '/api/v1/auth/otp-providers-health';

  // --- Catalog / discovery ---
  static const products = '/api/v1/products';
  static const productCreate = '/api/v1/products/create';
  static const catalogItems = '/api/v1/catalogs/items';
  static const catalogItem = '/api/v1/catalogs/items/:id';
  static const similarProducts = '/api/v1/catalog/similar-products';

  // --- Sellers ---
  static const sellers = '/api/v1/sellers';
  static const sellerDetail = '/api/v1/sellers/:id';
  static const sellerCredits = '/api/v1/sellers/:id/credits';
  static const sellerStaff = '/api/v1/sellers/:sellerId/staff';
  static const sellerSubscriptionUpgrade = '/api/v1/sellers/:sellerId/upgrade-subscription';

  // --- Leads (RFQ) ---
  static const leads = '/api/v1/leads';
  static const unlockLead = '/api/v1/leads/unlock';
  static const leadStage = '/api/v1/leads/:leadId/stage';
  static const leadTagsNotes = '/api/v1/leads/:leadId/tags-notes';
  static const matchedLeads = '/api/v1/sellers/:id/leads/matched';

  // --- Messaging / calls / meetings ---
  static const messages = '/api/v1/messages';
  static const messagesForLead = '/api/v1/messages/:leadId';
  static const sendMessage = '/api/v1/messages/send';
  static const twilioStatus = '/api/v1/twilio/status';
  static const voiceCall = '/api/v1/twilio/voice/call';
  static const chatSend = '/api/v1/twilio/chat/send';
  static const meetCreate = '/api/v1/meetings/google-meet/create';

  // --- B2B commerce (zero-escrow: PI -> UTR -> TI) ---
  static const acceptQuote = '/api/v1/orders/accept-quote';
  static const paymentsCreateOrder = '/api/v1/payments/create-order';
  static const paymentsVerify = '/api/v1/payments/verify-payment';

  /// Replaces `:param` placeholders with [value] (simple path templating).
  static String at(String endpoint, String param, String value) =>
      endpoint.replaceFirst(':$param', value);
}
