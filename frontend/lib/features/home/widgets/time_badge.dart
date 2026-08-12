import 'package:flutter/material.dart';

class TimeBadge extends StatelessWidget {
  final TimeOfDay startTime;
  final TimeOfDay endTime;
  final bool isToday;

  const TimeBadge({
    super.key,
    required this.startTime,
    required this.endTime,
    required this.isToday,
  });

  @override
  Widget build(BuildContext context) {
    bool isNow = false;

    if (isToday) {
      final DateTime now = DateTime.now();
      final DateTime start = DateTime(
        now.year,
        now.month,
        now.day,
        startTime.hour,
        startTime.minute,
      );

      final DateTime end = DateTime(
        now.year,
        now.month,
        now.day,
        endTime.hour,
        endTime.minute,
      );

      isNow = now.isAfter(start) && now.isBefore(end);
    }

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 8,
        vertical: 4,
      ),

      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: Colors.black.withValues(alpha: 0.4),
          width: 0.75,
        ),
      ),

      child: Text(
        isNow
            ? 'Now'
            : '${_formatTime(startTime)} - ${_formatTime(endTime)}',

        style: TextStyle(
          color: Colors.white.withValues(alpha: 0.45),
          fontWeight: FontWeight.bold,
          fontSize: 9.7,
        ),
      ),
    );
  }

  String _formatTime(TimeOfDay time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }
}
