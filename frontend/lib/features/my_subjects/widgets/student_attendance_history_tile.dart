//Design
import 'package:fahhhh/core/theme_data/app_colors.dart';
import 'package:fahhhh/core/theme_data/app_text_styles.dart';

//Models
import 'package:fahhhh/features/my_subjects/models/student_subject_record.dart';

import 'package:flutter/material.dart';

/// 44px blue card showing a single date-wise attendance record (Jan 10 | Monday)
/// with a Present / Absent / Late status pill.
class StudentAttendanceHistoryTile extends StatelessWidget {
  final StudentSubjectRecord record;

  const StudentAttendanceHistoryTile({
    super.key,
    required this.record,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 44,
      margin: const EdgeInsets.symmetric(horizontal: 26, vertical: 5),
      padding: const EdgeInsets.only(left: 16, right: 12),
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
          Expanded(
            child: Text(
              record.dateStr,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.sfPRO.copyWith(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const SizedBox(width: 10),
          _StatusBadge(status: record.status),
        ],
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final StudentAttendanceStatus status;

  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    final Color bgColor;
    final Color textColor;
    final String label;

    switch (status) {
      case StudentAttendanceStatus.present:
        bgColor = const Color(0x996BDB72);
        textColor = const Color(0xFFE8E8E8);
        label = 'Present';
        break;
      case StudentAttendanceStatus.absent:
        bgColor = const Color(0x99BA4545);
        textColor = const Color(0xFFF9C4C4);
        label = 'Absent';
        break;
      case StudentAttendanceStatus.late:
        bgColor = const Color(0xCCCCB55B);
        textColor = Colors.white;
        label = 'Late';
        break;
    }

    return Container(
      width: 85,
      height: 28,
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(13),
        border: Border.all(
          color: Colors.black.withValues(alpha: 0.6),
          width: 1,
        ),
      ),
      child: Center(
        child: Text(
          label,
          style: AppTextStyles.sfPRO.copyWith(
            fontSize: 15,
            fontWeight: FontWeight.bold,
            color: textColor,
          ),
        ),
      ),
    );
  }
}
