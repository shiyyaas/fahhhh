import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

//Design
import 'package:fahhhh/core/theme_data/app_text_styles.dart';

//Widgets
import 'package:fahhhh/features/inbox/widgets/inbox_filter_bar.dart';
import 'package:fahhhh/features/inbox/widgets/inbox_message_tile.dart';

//Models
import 'package:fahhhh/features/inbox/models/inbox_message.dart';

//Providers
import 'package:fahhhh/features/auth/providers/auth_provider.dart';
import 'package:fahhhh/features/auth/models/user_role.dart';

/// Inbox screen: role-specific filters and notifications.
/// Admin sees All / Teacher / Student / leave with swap & issue requests.
/// Teacher sees All / Accepted / Rejected / leave with their request statuses.
/// Pushed from the notification bell (hides bottom nav).
class InboxScreen extends ConsumerStatefulWidget {
  const InboxScreen({super.key});

  @override
  ConsumerState<InboxScreen> createState() => _InboxScreenState();
}

class _InboxScreenState extends ConsumerState<InboxScreen> {
  int _selectedFilter = 0;
  final List<String> _adminIds = mockAdminInboxMessages.map((m) => m.id).toList();
  final List<String> _teacherIds = mockTeacherInboxMessages.map((m) => m.id).toList();

  static const List<String> _adminFilters = ['All', 'Teacher', 'Student', 'leave'];
  static const List<String> _teacherFilters = ['All', 'Accepted', 'Rejected', 'leave'];

  List<String> get _visibleIds {
    final bool isAdmin = _isAdmin;
    final ids = isAdmin ? _adminIds : _teacherIds;
    final all = isAdmin ? mockAdminInboxMessages : mockTeacherInboxMessages;
    final activeIds = ids.toSet().toList();

    if (_selectedFilter == 0) {
      return activeIds;
    }

    final InboxMessageType? type = isAdmin
        ? (_selectedFilter == 1
            ? InboxMessageType.teacher
            : _selectedFilter == 2
                ? InboxMessageType.student
                : InboxMessageType.leave)
        : (_selectedFilter == 1
            ? InboxMessageType.swap
            : _selectedFilter == 3
                ? InboxMessageType.leave
                : null);

    if (!isAdmin && (_selectedFilter == 1 || _selectedFilter == 2)) {
      // Teacher: Accepted / Rejected filters by status.
      final status = _selectedFilter == 1
          ? InboxMessageStatus.accepted
          : InboxMessageStatus.rejected;
      return all
          .where((m) => m.status == status && activeIds.contains(m.id))
          .map((m) => m.id)
          .toList();
    }

    if (type == null) return activeIds;
    return all
        .where((m) => m.type == type && activeIds.contains(m.id))
        .map((m) => m.id)
        .toList();
  }

  bool get _isAdmin => ref.read(authProvider).role == UserRole.teacher &&
      (ref.read(authProvider).user?.isHOD ?? false);

  void _removeMessage(String id) {
    setState(() {
      if (_isAdmin) {
        _adminIds.remove(id);
      } else {
        _teacherIds.remove(id);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final isAdmin = _isAdmin;
    final filters = isAdmin ? _adminFilters : _teacherFilters;
    final all = isAdmin ? mockAdminInboxMessages : mockTeacherInboxMessages;
    final visibleIds = _visibleIds;
    final messages =
        all.where((m) => visibleIds.contains(m.id)).toList();

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.white, Color(0xFFAAA0A0)],
            stops: [0.25, 1.0],
          ),
        ),
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () {
                        if (context.mounted) context.pop();
                      },
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(
                        minWidth: 26,
                        minHeight: 26,
                      ),
                      icon: const Icon(Icons.arrow_back, size: 26),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Inbox',
                            style: AppTextStyles.heading.copyWith(fontSize: 30),
                          ),
                          const SizedBox(height: 1),
                          Text(
                            'View messages here',
                            style: AppTextStyles.small.copyWith(fontSize: 17.7),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              InboxFilterBar(
                labels: filters,
                selectedIndex: _selectedFilter,
                onChanged: (index) => setState(() => _selectedFilter = index),
              ),
              const SizedBox(height: 14),
              Expanded(
                child: messages.isEmpty
                    ? Center(
                        child: Text(
                          'No messages',
                          style: TextStyle(color: Colors.grey.shade500),
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 18,
                          vertical: 6,
                        ),
                        itemCount: messages.length,
                        itemBuilder: (context, index) {
                          final message = messages[index];
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: InboxMessageTile(
                              message: message,
                              onAccept: () => _removeMessage(message.id),
                              onReject: () => _removeMessage(message.id),
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}