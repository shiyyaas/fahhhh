import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

// Design
import 'package:fahhhh/core/widgets/app_screen_scaffold.dart';
import 'package:fahhhh/core/theme_data/app_colors.dart';
import 'package:fahhhh/core/widgets/app_back_header.dart';

// Widgets
import 'package:fahhhh/features/inbox/widgets/inbox_filter_bar.dart';
import 'package:fahhhh/features/inbox/widgets/inbox_message_tile.dart';

// Models
import 'package:fahhhh/features/inbox/models/inbox_message.dart';

// Providers
import 'package:fahhhh/features/auth/providers/auth_provider.dart';
import 'package:fahhhh/features/auth/models/user_role.dart';
import 'package:fahhhh/features/inbox/providers/inbox_provider.dart';

/// Inbox screen supporting role-specific filters and all 7 notification variants
/// from Figma node 1888-18306 (Admin/HOD, Teacher, and Student).
class InboxScreen extends ConsumerStatefulWidget {
  const InboxScreen({super.key});

  @override
  ConsumerState<InboxScreen> createState() => _InboxScreenState();
}

class _InboxScreenState extends ConsumerState<InboxScreen> {
  int _selectedFilter = 0;

  // Local state for interactive acceptance / dismissal
  late List<InboxMessage> _adminMessages;
  late List<InboxMessage> _teacherMessages;
  late List<InboxMessage> _studentMessages;

  static const List<String> _adminFilters = ['All', 'Teacher', 'Student', 'Leave'];
  static const List<String> _teacherFilters = ['All', 'Accepted', 'Rejected', 'Leave'];
  static const List<String> _studentFilters = ['All', 'Under Review', 'Verified', 'Rejected'];

  @override
  void initState() {
    super.initState();
    _adminMessages = [];
    _teacherMessages = [];
    _studentMessages = [];
  }

  bool get _isAdmin {
    final auth = ref.read(authProvider);
    return auth.role == UserRole.teacher && (auth.user?.isHOD ?? false);
  }

  bool get _isStudent {
    final auth = ref.read(authProvider);
    return auth.role == UserRole.student;
  }

  List<InboxMessage> _getFilteredMessages(List<InboxMessage> source) {
    if (_isAdmin) {
      if (_selectedFilter == 1) {
        return source
            .where((m) => m.type == InboxMessageType.teacherSwapRequest)
            .toList();
      } else if (_selectedFilter == 2) {
        return source
            .where((m) => m.type == InboxMessageType.studentIssueReport)
            .toList();
      } else if (_selectedFilter == 3) {
        return source
            .where((m) => m.type == InboxMessageType.leaveRequest)
            .toList();
      }
      return source;
    } else if (!_isStudent) {
      // Teacher role
      if (_selectedFilter == 1) {
        return source
            .where((m) => m.type == InboxMessageType.teacherSwapAccepted)
            .toList();
      } else if (_selectedFilter == 2) {
        return source
            .where((m) => m.type == InboxMessageType.teacherSwapRejected)
            .toList();
      } else if (_selectedFilter == 3) {
        return source
            .where((m) => m.type == InboxMessageType.leaveApproved)
            .toList();
      }
      return source;
    } else {
      // Student role
      if (_selectedFilter == 1) {
        return source
            .where((m) => m.type == InboxMessageType.studentIssueReview)
            .toList();
      } else if (_selectedFilter == 2) {
        return source
            .where((m) => m.type == InboxMessageType.studentIssueVerified)
            .toList();
      } else if (_selectedFilter == 3) {
        return source
            .where((m) => m.type == InboxMessageType.studentIssueRejected)
            .toList();
      }
      return source;
    }
  }

  void _handleAccept(InboxMessage message) {
    if (message.type == InboxMessageType.leaveRequest) {
      ref.read(inboxRepositoryProvider).approveLeave(message.id);
    }
    setState(() {
      _adminMessages.removeWhere((m) => m.id == message.id);
    });

    if (!mounted) return;
    final text = message.type == InboxMessageType.leaveRequest
        ? 'Leave request approved.'
        : 'Swap request accepted. Timetable updated.';
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(text),
        backgroundColor: AppColors.primary,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _handleReject(InboxMessage message) {
    if (message.type == InboxMessageType.leaveRequest) {
      ref.read(inboxRepositoryProvider).rejectLeave(message.id);
    }
    setState(() {
      _adminMessages.removeWhere((m) => m.id == message.id);
    });

    if (!mounted) return;
    final text = message.type == InboxMessageType.studentIssueReport
        ? 'Attendance issue rejected.'
        : message.type == InboxMessageType.leaveRequest
            ? 'Leave request rejected.'
            : 'Swap request rejected.';
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(text),
        backgroundColor: const Color(0xFFEB2E2E),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _handleReview(InboxMessage message) {
    setState(() {
      _adminMessages.removeWhere((m) => m.id == message.id);
    });

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Attendance issue marked for review.'),
        backgroundColor: AppColors.primary,
        duration: Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final List<String> filters = _isAdmin
        ? _adminFilters
        : _isStudent
            ? _studentFilters
            : _teacherFilters;

    final authUser = ref.watch(authProvider).user;
    final userId = authUser?.id ?? '';
    final liveLeaves = ref.watch(pendingLeavesProvider).value ?? [];
    final liveNotifications = ref.watch(userNotificationsProvider(userId)).value ?? [];

    final activeLocal = _isAdmin
        ? _adminMessages
        : (!_isStudent ? _teacherMessages : _studentMessages);
    final combined = [...liveLeaves, ...liveNotifications, ...activeLocal];
    final messages = _getFilteredMessages(combined);

    return Scaffold(
      backgroundColor: AppColors.surface,
      body: AppScreenScaffold(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppBackHeader(
              title: 'Inbox',
              subtitle: 'View messages here',
              onBack: () => context.pop(),
              padding: const EdgeInsets.symmetric(horizontal: 20),
            ),
            const SizedBox(height: 14),
            // Horizontally scrollable filter bar that never overflows on small screens
            InboxFilterBar(
              labels: filters,
              selectedIndex: _selectedFilter,
              onChanged: (index) {
                setState(() => _selectedFilter = index);
              },
            ),
            const SizedBox(height: 14),
            // Messages list
            Expanded(
              child: messages.isEmpty
                  ? Center(
                      child: Text(
                        'No messages',
                        style: GoogleFonts.inter(
                          color: Colors.grey.shade500,
                          fontSize: 15,
                        ),
                      ),
                    )
                  : ListView.builder(
                      physics: const BouncingScrollPhysics(),
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
                            onAccept: () => _handleAccept(message),
                            onReject: () => _handleReject(message),
                            onReview: () => _handleReview(message),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}