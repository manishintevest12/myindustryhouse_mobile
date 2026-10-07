/// Chat message as returned by /api/v1/messages and /api/v1/messages/:leadId.
class ChatMessage {
  const ChatMessage({
    required this.chatId,
    required this.leadId,
    required this.senderId,
    required this.senderName,
    required this.senderRole,
    required this.messageText,
    required this.timestamp,
    required this.quoteDetails,
    required this.callLog,
  });

  final String chatId;
  final String leadId;
  final String senderId;
  final String senderName;
  final String senderRole;
  final String messageText;
  final String timestamp;
  final Map<String, dynamic>? quoteDetails;
  final Map<String, dynamic>? callLog;

  static ChatMessage fromApiJson(Map<String, dynamic> j) => ChatMessage(
        chatId: (j['chat_id'] ?? j['id'] ?? '').toString(),
        leadId: (j['lead_id'] ?? 'lead-general').toString(),
        senderId: (j['sender_id'] ?? '').toString(),
        senderName: (j['sender_name'] ?? 'Verified Member').toString(),
        senderRole: (j['sender_role'] ?? 'BUYER').toString().toUpperCase(),
        messageText: (j['message_text'] ?? j['message'] ?? '').toString(),
        timestamp: (j['timestamp'] ?? j['created_at'] ?? '').toString(),
        quoteDetails: j['quoteDetails'] is Map<String, dynamic>
            ? j['quoteDetails'] as Map<String, dynamic>
            : null,
        callLog: j['call_log'] is Map<String, dynamic> ? j['call_log'] as Map<String, dynamic> : null,
      );

  bool get isQuote => quoteDetails != null && quoteDetails!.isNotEmpty;
  bool get isCallLog => callLog != null;
}
