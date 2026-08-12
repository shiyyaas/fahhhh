//Design
import 'package:fahhhh/core/theme_data/app_colors.dart';
import 'package:fahhhh/core/theme_data/app_text_styles.dart';

//Models
import 'package:fahhhh/features/department/models/department_subject.dart';

//Widgets
import 'package:fahhhh/features/department/widgets/attendance_percentage_badge.dart';

import 'package:flutter/material.dart';

/// Blue subject row card with teacher avatar, subject name, teacher name and attendance pill.
class SubjectListTile extends StatelessWidget {
  final DepartmentSubject subject;
  final VoidCallback? onTap;

  const SubjectListTile({
    super.key,
    required this.subject,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 72,
        margin: const EdgeInsets.symmetric(horizontal: 26, vertical: 5),
        padding: const EdgeInsets.only(left: 12, right: 12),
        decoration: BoxDecoration(
          color: AppColors.primary,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: Colors.black,
            width: 0.8,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              width: 47,
              height: 47,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white,
                border: Border.all(color: const Color(0xFF141212), width: 0.8),
                image: const DecorationImage(
                  image: AssetImage('assets/images/teacher.png'),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    subject.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.sfPRO.copyWith(
                      color: Colors.white,
                      fontSize: 16.6,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subject.teacher,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.sfPRO.copyWith(
                      color: Colors.white,
                      fontSize: 12.1,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            AttendancePercentageBadge(percent: subject.attendancePercent),
          ],
        ),
      ),
    );
  }
}