//Design
import 'package:fahhhh/core/theme_data/app_colors.dart';
import 'package:fahhhh/core/theme_data/app_text_styles.dart';

//Models
import 'package:fahhhh/features/my_subjects/models/my_subject_item.dart';

//Widgets
import 'package:fahhhh/features/department/widgets/attendance_percentage_badge.dart';

import 'package:flutter/material.dart';

/// Subject row card for My Subjects screen: subject name, classes, attendance pill.
class MySubjectListTile extends StatelessWidget {
  final MySubjectItem item;
  final VoidCallback? onTap;

  const MySubjectListTile({
    super.key,
    required this.item,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 72,
        margin: const EdgeInsets.symmetric(horizontal: 26, vertical: 5),
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: AppColors.primary,
          borderRadius: BorderRadius.circular(17),
          border: Border.all(color: Colors.black, width: 1),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.heading.copyWith(
                      color: Colors.white,
                      fontSize: 16.6,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    item.classes,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.sfPRO.copyWith(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            AttendancePercentageBadge(percent: item.attendancePercent),
          ],
        ),
      ),
    );
  }
}