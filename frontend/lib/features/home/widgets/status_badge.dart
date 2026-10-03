import 'package:flutter/material.dart';
import 'package:fahhhh/core/theme_data/app_colors.dart';

enum AttendanceStatus {
  recorded,
  missed,
  recordNow,
  pending,
  present,
  absent,
  late,
  ongoing,
}

class StatusBadge extends StatelessWidget {
  final AttendanceStatus status;
  const StatusBadge({
    super.key,
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    final Color textColor = _getTextColor();

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 4,
      ),

      decoration: BoxDecoration(
        color: _getBackgroundColor(),
        gradient: status == AttendanceStatus.pending
            ? const LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xFF647286), Color(0xFF496388)],
              )
            : null,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: AppColors.border.withValues(alpha: 0.55),
          width: 0.75,
        ),
      ),

      child: Text(
        _getStatusText(),
        style: TextStyle(
          color: textColor,
          fontWeight: FontWeight.bold,
          fontSize: 11.25,
        ),
      ),
    );

  }

  String _getStatusText() {
    switch (status) {
      case AttendanceStatus.recorded:
        return 'Recorded';

      case AttendanceStatus.missed:
        return 'Missed';

      case AttendanceStatus.recordNow:
        return 'Record Now';

      case AttendanceStatus.pending:
        return 'Pending';

      case AttendanceStatus.present:
        return 'Present';

      case AttendanceStatus.absent:
        return 'Absent';

      case AttendanceStatus.late:
        return 'Late';

      case AttendanceStatus.ongoing:
        return 'Ongoing';

    }

  }

  Color? _getBackgroundColor() {
    switch (status) {
      case AttendanceStatus.recorded:
      case AttendanceStatus.present:
        return AppColors.success.withValues(alpha: 0.6);

      case AttendanceStatus.recordNow:
      case AttendanceStatus.ongoing:
        return AppColors.recordNow;

      case AttendanceStatus.pending:
        return null; // gradient used instead

      case AttendanceStatus.late:
        return AppColors.warning.withValues(alpha: 0.6);

      case AttendanceStatus.missed:
      case AttendanceStatus.absent:
        return AppColors.danger.withValues(alpha: 0.6);

    }

  }

  Color _getTextColor() {

    switch (status) {
      
      case AttendanceStatus.recorded:
      case AttendanceStatus.present:
        return AppColors.surface;

      case AttendanceStatus.recordNow:
      case AttendanceStatus.ongoing:
        return AppColors.surface;

      case AttendanceStatus.pending:
        return AppColors.surface;

      case AttendanceStatus.late:
        return AppColors.warning;

      case AttendanceStatus.missed:
      case AttendanceStatus.absent:
        return AppColors.surface;

    }

  }

}