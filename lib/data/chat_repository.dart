import 'api_client.dart';
import 'endpoints.dart';
import 'models/chat_message.dart';

/// Chat / voice / meetings against the EXISTING messaging + Twilio routes.
class ChatRepository {
  const ChatRepository._();
  static const instance = ChatRepository._();

  Future<List<ChatMessage>> messages({String? leadId, String? buyerId, String? buyerPhone}) async {
    final res = leadId == null
        ? await ApiClient.instance.get(Api.messages,
            query: {
              if (buyerId != null) 'buyerId': buyerId,
              if (buyerPhone != null) 'buyerPhone': buyerPhone,
            })
        : await ApiClient.instance.get(Api.at(Api.messagesForLead, 'leadId', leadId));
    final items = (res['messages'] ?? res['data']) as List? ?? const [];
    return items.map((e) => ChatMessage.fromApiJson(e as Map<String, dynamic>)).toList();
  }

  Future<Map<String, dynamic>> send({
    required String leadId,
    required String senderId,
    required String senderName,
    required String senderRole,
    required String messageText,
  }) =>
      ApiClient.instance.post(Api.sendMessage, body: {
        'leadId': leadId,
        'senderId': senderId,
        'senderName': senderName,
        'senderRole': senderRole,
        'messageText': messageText,
      });

  /// Voice bridge call - server returns honest success/failure (e.g.
  /// TWILIO_NOT_CONFIGURED when the vault has no Twilio credentials).
  Future<Map<String, dynamic>> voiceCall({
    required String leadId,
    required String callerName,
    required String callerRole,
    String? callerPhone,
    required String recipientName,
    required String recipientRole,
    required String recipientPhone,
    String? productName,
  }) =>
      ApiClient.instance.post(Api.voiceCall, body: {
        'leadId': leadId,
        'callerName': callerName,
        'callerRole': callerRole,
        if (callerPhone != null) 'callerPhone': callerPhone,
        'recipientName': recipientName,
        'recipientRole': recipientRole,
        'recipientPhone': recipientPhone,
        if (productName != null) 'productName': productName,
      });

  /// Google Meet session creation (server-side honest failure if not configured).
  Future<Map<String, dynamic>> createMeet({
    required String leadId,
    required String topic,
    required String buyerName,
    required String buyerEmail,
    required String sellerName,
    required String sellerEmail,
  }) =>
      ApiClient.instance.post(Api.meetCreate, body: {
        'leadId': leadId,
        'topic': topic,
        'buyerName': buyerName,
        'buyerEmail': buyerEmail,
        'sellerName': sellerName,
        'sellerEmail': sellerEmail,
      });
}
