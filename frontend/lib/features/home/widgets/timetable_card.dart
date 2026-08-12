//Design
import 'package:fahhhh/core/theme_data/app_colors.dart';
import 'package:fahhhh/core/theme_data/app_text_styles.dart';

//Widgets
import 'package:fahhhh/features/home/widgets/status_badge.dart';
import 'package:fahhhh/features/home/widgets/time_badge.dart';

import 'package:flutter/material.dart';

class TimetableCard extends StatelessWidget {
  final String subjectName;
  final String secondaryText;
  final AttendanceStatus status;
  final TimeOfDay startTime;
  final TimeOfDay endTime;
  final String? profileImage;
  final bool isStudent;
  final bool isToday;
  final bool isFuture;
  final VoidCallback? onTap;

  const TimetableCard({
    super.key,
    required this.subjectName,
    required this.secondaryText,
    required this.status,
    required this.startTime,
    required this.endTime,
    this.profileImage,
    required this.isStudent,
    required this.isToday,
    required this.isFuture,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    Widget cardContent = Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
      padding: const EdgeInsets.only(
        left: 12,
        right: 12,
        top: 11,
        bottom: 10,
      ),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(17),
        border: Border.all(color: Colors.black, width: 1),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Left side: Text metadata (Subject Name & Teacher or Class Batch)
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    subjectName,
                    style: AppTextStyles.heading.copyWith(
                      color: Colors.white,
                      fontSize: 16.6,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  secondaryText,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: 10),

          // Right side: Time Badge and Status Badge
          Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              TimeBadge(
                startTime: startTime,
                endTime: endTime,
                isToday: isToday,
              ),
              if (!isFuture) ...[
                const SizedBox(height: 5),
                StatusBadge(
                  status: status,
                ),
              ],
            ],
          ),

          // Far Right: Student Profile Photo (Only for student and when profileImage is provided)
          if (isStudent && profileImage != null) ...[
            const SizedBox(width: 12),
            CircleAvatar(
              radius: 24,
              backgroundImage: AssetImage(profileImage!),
            ),
          ],
        ],
      ),
    );

    if (onTap != null) {
      return GestureDetector(
        onTap: onTap,
        child: cardContent,
      );
    }

    return cardContent;
  }
}
