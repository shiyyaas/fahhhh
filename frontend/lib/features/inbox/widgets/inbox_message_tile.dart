import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:fahhhh/core/theme_data/app_colors.dart';
import '../models/inbox_message.dart';

/// Inbox message card matching Figma node 1888-18306.
/// Sized with minHeight: 128 to adapt flexibly on small devices without overflow.
class InboxMessageTile extends StatelessWidget {
  final InboxMessage message;
  final VoidCallback? onAccept;
  final VoidCallback? onReject;
  final VoidCallback? onReview;

  const InboxMessageTile({
    super.key,
    required this.message,
    this.onAccept,
    this.onReject,
    this.onReview,
  });

  String get _imageAsset {
    if (message.isStudentAvatar) {
      return 'assets/images/student.png';
    }
    return 'assets/images/teacher.png';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(minHeight: 128),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFFBFBFB),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFF8D8D8D), width: 1),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Avatar (49 x 49)
              Container(
                width: 49,
                height: 49,
                margin: const EdgeInsets.only(top: 4),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                  border: Border.all(
                    color: AppColors.border,
                    width: 0.8,
                  ),
                  image: DecorationImage(
                    image: AssetImage(_imageAsset),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              // Sender name + message body
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      message.senderName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.poppins(
                        fontSize: 15.5,
                        fontWeight: FontWeight.w600,
                        color: AppColors.headingText,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      message.body,
                      style: GoogleFonts.inter(
                        fontSize: 13.5,
                        height: 1.35,
                        color: const Color(0xFF7B7B7B),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          // Action buttons on bottom right (only for actionable requests)
          if (message.hasActions) ...[
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (message.isStudentReport) ...[
                  // Student issue Review button: "Review" + right arrow icon
                  GestureDetector(
                    onTap: onReview ?? onAccept,
                    behavior: HitTestBehavior.opaque,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 4,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Review',
                            style: GoogleFonts.inter(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF0B55F8),
                            ),
                          ),
                          const SizedBox(width: 4),
                          const Icon(
                            Icons.arrow_forward_rounded,
                            size: 16,
                            color: Color(0xFF0B55F8),
                          ),
                        ],
                      ),
                    ),
                  ),
                ] else ...[
                  // Teacher swap / leave Accept button: checkmark icon + "Accept"
                  GestureDetector(
                    onTap: onAccept,
                    behavior: HitTestBehavior.opaque,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 4,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.check_rounded,
                            size: 16,
                            color: Color(0xFF0B55F8),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Accept',
                            style: GoogleFonts.inter(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF0B55F8),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
                const SizedBox(width: 22),
                // Reject button: "✕" icon + "Reject"
                GestureDetector(
                  onTap: onReject,
                  behavior: HitTestBehavior.opaque,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 4,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text(
                          '✕',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFFEB2E2E),
                          ),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Reject',
                          style: GoogleFonts.inter(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFFEB2E2E),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}