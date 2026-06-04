import 'package:flutter/material.dart';

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
    final Color backgroundColor = _getBackgroundColor();
    final Color textColor = _getTextColor();

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 14,
        vertical: 6,
      ),

      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(16),
      ),

      child: Text(
        _getStatusText(),
        style: TextStyle(
          color: textColor,
          fontWeight: FontWeight.w600,
          fontSize: 12,
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

  Color _getBackgroundColor() {
    switch (status) {
      case AttendanceStatus.recorded:
        return const Color(0xFFE7F8EC);

      case AttendanceStatus.present:
        return const Color(0xFFE7F8EC);

      case AttendanceStatus.recordNow:
        return const Color(0xFFEAF2FF);

      case AttendanceStatus.ongoing:
        return const Color(0xFFEAF2FF);

      case AttendanceStatus.pending:
        return const Color(0xFFF3F4F6);

      case AttendanceStatus.late:
        return const Color(0xFFFFF4E5);

      case AttendanceStatus.missed:
        return const Color(0xFFFFEBEB);

      case AttendanceStatus.absent:
        return const Color(0xFFFFEBEB);

    }

  }

  Color _getTextColor() {

    switch (status) {
      
      case AttendanceStatus.recorded:
        return const Color(0xFF1F8B4C);

      case AttendanceStatus.present:
        return const Color(0xFF1F8B4C);

      case AttendanceStatus.recordNow:
        return const Color(0xFF2F6BFF);

      case AttendanceStatus.ongoing:
        return const Color(0xFF2F6BFF);

      case AttendanceStatus.pending:
        return const Color(0xFF6B7280);

      case AttendanceStatus.late:
        return const Color(0xFFE59B00);

      case AttendanceStatus.missed:
        return const Color(0xFFD92D20);

      case AttendanceStatus.absent:
        return const Color(0xFFD92D20);

    }

  }

}