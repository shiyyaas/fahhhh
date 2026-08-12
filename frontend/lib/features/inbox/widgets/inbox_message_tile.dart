//Design
import 'package:fahhhh/core/theme_data/app_text_styles.dart';

//Models
import 'package:fahhhh/features/inbox/models/inbox_message.dart';

import 'package:flutter/material.dart';

/// Inbox message card: avatar, sender name, message body and either
/// Accept/Review + Reject actions (actionable) or a colored status label.
class InboxMessageTile extends StatelessWidget {
  final InboxMessage message;
  final VoidCallback? onAccept;
  final VoidCallback? onReject;

  const InboxMessageTile({
    super.key,
    required this.message,
    this.onAccept,
    this.onReject,
  });

  bool get _isStudent => message.type == InboxMessageType.student;

  String get _imageAsset {
    if (message.type == InboxMessageType.student) {
      return 'assets/images/student.png';
    }
    if (message.type == InboxMessageType.leave) {
      return 'assets/images/teacher.png';
    }
    return message.status == InboxMessageStatus.accepted ||
            message.status == InboxMessageStatus.rejected
        ? 'assets/images/teacher.png'
        : 'assets/images/teacher.png';
  }

  @override
  Widget build(BuildContext context) {
    final bool hasStatus = message.status != InboxMessageStatus.none;

    return Container(
      width: double.infinity,
      height: 128,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFFBFBFB),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFF8D8D8D), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Avatar + name + body
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 49,
                  height: 49,
                  margin: const EdgeInsets.only(top: 10),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white,
                    border: Border.all(
                      color: const Color(0xFF141212),
                      width: 0.8,
                    ),
                    image: DecorationImage(
                      image: AssetImage(_imageAsset),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                const SizedBox(width: 9),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 4),
                      Text(
                        message.senderName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.heading.copyWith(fontSize: 16),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        message.body,
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.small.copyWith(
                          fontSize: 15.7,
                          height: 1.3,
                          color: const Color(0xFF7B7B7B),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Status or actions
          if (hasStatus)
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                message.status == InboxMessageStatus.accepted
                    ? 'Accepted'
                    : 'Rejected',
                style: AppTextStyles.small.copyWith(
                  fontSize: 17.7,
                  color: message.status == InboxMessageStatus.accepted
                      ? const Color(0xFF0B55F8)
                      : const Color(0xFFEB2E2E),
                ),
              ),
            )
          else
            Row(
              children: [
                GestureDetector(
                  onTap: onAccept,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        _isStudent
                            ? Icons.arrow_forward_rounded
                            : Icons.check_rounded,
                        size: 16,
                        color: const Color(0xFF0B55F8),
                      ),
                      const SizedBox(width: 3),
                      Text(
                        _isStudent ? 'Review' : 'Accept',
                        style: AppTextStyles.small.copyWith(
                          fontSize: 17.7,
                          color: const Color(0xFF0B55F8),
                        ),
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                GestureDetector(
                  onTap: onReject,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        'x',
                        style: TextStyle(
                          fontFamily: 'Quicksand',
                          fontWeight: FontWeight.w600,
                          fontSize: 18.7,
                          color: Color(0xFFEB2E2E),
                        ),
                      ),
                      const SizedBox(width: 5),
                      Text(
                        'Reject',
                        style: AppTextStyles.small.copyWith(
                          fontSize: 17.7,
                          color: const Color(0xFFEB2E2E),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }
}