import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/catalog_repository.dart';
import '../data/chat_repository.dart';
import '../data/leads_repository.dart';
import '../data/models/chat_message.dart';
import '../data/models/lead.dart';
import '../data/models/product.dart';
import '../data/models/seller.dart';
import 'session_provider.dart';

/// Products feed (buyer home).
final productsProvider = FutureProvider.autoDispose<List<Product>>((ref) async {
  ref.watch(sessionProvider); // re-fetch when the session changes
  return CatalogRepository.instance.products();
});

/// Verified sellers (buyer home).
final sellersProvider = FutureProvider.autoDispose<List<SellerInfo>>((ref) async {
  ref.watch(sessionProvider);
  return CatalogRepository.instance.sellers();
});

/// Catalog search (buyer search tab).
final searchQueryProvider = StateProvider<String>((_) => '');
final searchResultsProvider =
    FutureProvider.autoDispose<List<Product>>((ref) async {
  final q = ref.watch(searchQueryProvider);
  if (q.trim().isEmpty) return const [];
  return CatalogRepository.instance.products(search: q.trim());
});

/// Signed-in user's leads (buyer: my RFQs, seller: matched leads).
final myLeadsProvider = FutureProvider.autoDispose<List<Lead>>((ref) async {
  final user = ref.watch(sessionProvider).valueOrNull;
  if (user == null) return const [];
  if (user.isSeller) {
    return LeadsRepository.instance.sellerLeads(sellerId: user.userId);
  }
  return LeadsRepository.instance.buyerLeads(
      buyerId: user.userId, phone: user.phone, email: user.email);
});

/// All chat threads visible to the signed-in user.
final chatThreadsProvider =
    FutureProvider.autoDispose<List<ChatMessage>>((ref) async {
  final user = ref.watch(sessionProvider).valueOrNull;
  if (user == null) return const [];
  final all = await ChatRepository.instance.messages(
      buyerId: user.isBuyer ? user.userId : null,
      buyerPhone: user.isBuyer ? user.phone : null);
  // Thread = latest message per lead.
  final byLead = <String, ChatMessage>{};
  for (final m in all) {
    byLead[m.leadId] = m; // API order = chronological; last wins
  }
  return byLead.values.toList();
});

/// Messages of one thread, refreshable.
final threadMessagesProvider = FutureProvider.autoDispose
    .family<List<ChatMessage>, String>((ref, leadId) async {
  return ChatRepository.instance.messages(leadId: leadId);
});

/// Seller dashboard numbers (credits + conversion analytics).
final sellerCreditsProvider =
    FutureProvider.autoDispose<Map<String, dynamic>>((ref) async {
  final user = ref.watch(sessionProvider).valueOrNull;
  if (user == null) return const {};
  return LeadsRepository.instance.credits(user.userId);
});

final sellerConversionsProvider =
    FutureProvider.autoDispose<Map<String, dynamic>>((ref) async {
  final user = ref.watch(sessionProvider).valueOrNull;
  if (user == null) return const {};
  return LeadsRepository.instance.conversions(user.userId);
});

/// Global invalidation helper after writes.
void invalidateData(Ref ref) {
  ref.invalidate(productsProvider);
  ref.invalidate(sellersProvider);
  ref.invalidate(myLeadsProvider);
  ref.invalidate(chatThreadsProvider);
  ref.invalidate(sellerCreditsProvider);
  ref.invalidate(sellerConversionsProvider);
}
