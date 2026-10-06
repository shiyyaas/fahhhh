import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/api_client.dart';
import '../models/inbox_message.dart';
import '../repositories/inbox_repository.dart';

final inboxRepositoryProvider = Provider<InboxRepository>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return InboxRepository(apiClient: apiClient);
});

final userNotificationsProvider = FutureProvider.family<List<InboxMessage>, String>((ref, userId) async {
  final repo = ref.watch(inboxRepositoryProvider);
  return repo.getNotifications(userId);
});

final pendingLeavesProvider = FutureProvider<List<InboxMessage>>((ref) async {
  final repo = ref.watch(inboxRepositoryProvider);
  return repo.getPendingLeaves();
});
