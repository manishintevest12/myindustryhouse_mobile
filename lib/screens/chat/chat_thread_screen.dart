import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/chat_repository.dart';
import '../../providers/app_data_providers.dart';
import '../../providers/session_provider.dart';

/// One conversation thread: live messages, send box, voice-call and
/// Google Meet actions - all against the EXISTING backend routes.
/// Server responses are surfaced honestly (e.g. if Twilio/Meet is not
/// configured, the app shows exactly what the server said - no fakes).
class ChatThreadScreen extends ConsumerStatefulWidget {
  const ChatThreadScreen({super.key, required this.leadId});

  final String leadId;

  @override
  ConsumerState<ChatThreadScreen> createState() => _ChatThreadScreenState();
}

class _ChatThreadScreenState extends ConsumerState<ChatThreadScreen> {
  final _input = TextEditingController();
  bool _busy = false;

  @override
  void dispose() {
    _input.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    final text = _input.text.trim();
    if (text.isEmpty || _busy) return;
    final me = ref.read(sessionProvider).valueOrNull;
    if (me == null) return;
    setState(() => _busy = true);
    final res = await ChatRepository.instance.send(
      leadId: widget.leadId,
      senderId: me.userId,
      senderName: me.fullName.isEmpty ? 'Verified Member' : me.fullName,
      senderRole: me.isSeller ? 'SELLER' : 'BUYER',
      messageText: text,
    );
    if (!mounted) return;
    if (res['status'] == 'SUCCESS' || res['success'] == true) {
      _input.clear();
      ref.invalidate(threadMessagesProvider(widget.leadId));
      ref.invalidate(chatThreadsProvider);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text((res['message'] ?? 'Could not send the message.').toString()),
      ));
    }
    setState(() => _busy = false);
  }

  Future<void> _voiceCall() async {
    final me = ref.read(sessionProvider).valueOrNull;
    if (me == null) return;
    final res = await ChatRepository.instance.voiceCall(
      leadId: widget.leadId,
      callerName: me.fullName.isEmpty ? 'App member' : me.fullName,
      callerRole: me.isSeller ? 'SELLER' : 'BUYER',
      callerPhone: me.phone,
      recipientName: 'Counterparty',
      recipientRole: me.isSeller ? 'BUYER' : 'SELLER',
      recipientPhone: '', // server resolves from the lead when empty
    );
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text((res['message'] ?? (res['success'] == true
              ? 'Call requested.'
              : 'Call could not be placed.'))
          .toString()),
    ));
  }

  Future<void> _meet() async {
    final me = ref.read(sessionProvider).valueOrNull;
    if (me == null) return;
    final res = await ChatRepository.instance.createMeet(
      leadId: widget.leadId,
      topic: 'B2B Discussion - ${widget.leadId}',
      buyerName: me.isBuyer ? me.fullName : 'Buyer',
      buyerEmail: me.isBuyer ? (me.email ?? '') : '',
      sellerName: me.isSeller ? me.fullName : 'Seller',
      sellerEmail: me.isSeller ? (me.email ?? '') : '',
    );
    if (!mounted) return;
    final link = res['meetLink'] ?? res['meetingLink'] ?? res['link'];
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(link != null
          ? 'Google Meet created: ${link.toString()}'
          : (res['message'] ?? 'Meeting could not be created.').toString()),
    ));
  }

  @override
  Widget build(BuildContext context) {
    final msgs = ref.watch(threadMessagesProvider(widget.leadId));
    final me = ref.watch(sessionProvider).valueOrNull;
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.leadId == 'lead-general' ? 'General Inquiry' : 'Chat'),
        actions: [
          IconButton(
            tooltip: 'Voice Call',
            onPressed: _voiceCall,
            icon: const Icon(Icons.call_rounded),
          ),
          IconButton(
            tooltip: 'Google Meet',
            onPressed: _meet,
            icon: const Icon(Icons.videocam_rounded),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: msgs.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text(e.toString())),
              data: (list) => ListView.builder(
                reverse: true,
                padding: const EdgeInsets.all(16),
                itemCount: list.length,
                itemBuilder: (context, i) {
                  final m = list[list.length - 1 - i];
                  final mine = me != null &&
                      (m.senderId == me.userId || m.senderRole == (me.isSeller ? 'SELLER' : 'BUYER'));
                  return Align(
                    alignment: mine ? Alignment.centerRight : Alignment.centerLeft,
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      constraints: const BoxConstraints(maxWidth: 280),
                      decoration: BoxDecoration(
                        color: mine
                            ? const Color(0xFFF59E0B).withValues(alpha: 0.18)
                            : const Color(0xFF1E293B),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: const Color(0xFF334155)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(m.senderName,
                              style: const TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.grey)),
                          const SizedBox(height: 3),
                          if (m.isQuote)
                            Text('Quote: ${m.quoteDetails}',
                                style: const TextStyle(fontSize: 12))
                          else if (m.isCallLog)
                            const Text('📞 Call log entry',
                                style: TextStyle(fontSize: 12))
                          else
                            Text(m.messageText,
                                style: const TextStyle(
                                    fontSize: 13, height: 1.3)),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 6, 12, 10),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _input,
                      minLines: 1,
                      maxLines: 3,
                      decoration: const InputDecoration(
                        hintText: 'Type a message...',
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton.filled(
                    onPressed: _busy ? null : _send,
                    icon: const Icon(Icons.send_rounded),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
