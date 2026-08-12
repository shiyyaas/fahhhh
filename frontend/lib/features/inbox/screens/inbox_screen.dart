import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

//Design
import 'package:fahhhh/core/theme_data/app_text_styles.dart';

//Widgets
import 'package:fahhhh/features/inbox/widgets/inbox_filter_bar.dart';
import 'package:fahhhh/features/inbox/widgets/inbox_message_tile.dart';

//Models
import 'package:fahhhh/features/inbox/models/inbox_message.dart';

/// Admin inbox: filter tabs + notification cards.
/// Pushed from the notification bell (hides bottom nav).
class InboxScreen extends StatefulWidget {
  const InboxScreen({super.key});

  @override
  State<InboxScreen> createState() => _InboxScreenState();
}

class _InboxScreenState extends State<InboxScreen> {
  int _selectedFilter = 0;
  final List<String> _messages = mockInboxMessages.map((m) => m.id).toList();

  static const List<String> _filters = ['All', 'Teacher', 'Student', 'leave'];

  void _removeMessage(String id) {
    setState(() => _messages.remove(id));
  }

  List<InboxMessage> get _visibleMessages {
    final List<InboxMessage> all = mockInboxMessages
        .where((m) => _messages.contains(m.id))
        .toList();

    if (_selectedFilter == 0) return all;

    final type = _selectedFilter == 1
        ? InboxMessageType.teacher
        : _selectedFilter == 2
            ? InboxMessageType.student
            : InboxMessageType.leave;

    return all.where((m) => m.type == type).toList();
  }

  @override
  Widget build(BuildContext context) {
    final messages = _visibleMessages;

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
                labels: _filters,
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