import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/chat_message.dart';
import '../../providers/app_data_providers.dart';
import '../chat/chat_thread_screen.dart';
import 'api_future_view.dart';

/// Chats & Calls tab (shared by buyer and seller): conversation threads
/// from the existing messaging API, opening into a native chat screen with
/// voice-call and Google Meet actions.
class ChatsTab extends ConsumerWidget {
  const ChatsTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final threads = ref.watch(chatThreadsProvider);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeader('Chats & Calls'),
        Expanded(
          child: RefreshIndicator(
            onRefresh: () async => ref.refresh(chatThreadsProvider.future),
            child: ApiFutureView(
              value: threads,
              isEmpty: (d) => d.isEmpty,
              empty: ListView(children: const [
                SizedBox(height: 120),
                _Hint(
                    'No conversations yet. Chats appear here once you start an inquiry.'),
              ]),
              data: (list) => ListView.separated(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                itemCount: list.length,
                separatorBuilder: (_, __) => const SizedBox(height: 10),
                itemBuilder: (context, i) =>
                    _ThreadTile(message: list[i]),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _ThreadTile extends StatelessWidget {
  const _ThreadTile({required this.message});

  final ChatMessage message;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        leading: CircleAvatar(
          backgroundColor: const Color(0xFF1E293B),
          child: Icon(
            message.isCallLog ? Icons.call_rounded : Icons.chat_bubble_rounded,
            size: 20,
            color: message.isCallLog ? const Color(0xFF10B981) : const Color(0xFFF59E0B),
          ),
        ),
        title: Text(
          message.leadId == 'lead-general' ? 'General Inquiry' : message.senderName,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800),
        ),
        subtitle: Text(
          message.isCallLog ? '📞 Call log' : message.messageText,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontSize: 12),
        ),
        trailing: const Icon(Icons.chevron_right_rounded, color: Colors.grey),
        onTap: () => Navigator.of(context).push(MaterialPageRoute(
          builder: (_) => ChatThreadScreen(leadId: message.leadId),
        )),
      ),
    );
  }
}

class _Hint extends StatelessWidget {
  const _Hint(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Center(
        child: Text(text,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 12, color: Colors.grey)),
      ),
    );
  }
}
