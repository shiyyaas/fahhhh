import 'package:flutter/material.dart';

class TimeBadge extends StatelessWidget {
  final TimeOfDay startTime;
  final TimeOfDay endTime;
  const TimeBadge({
    super.key,
    required this.startTime,
    required this.endTime,
  });

  @override
  Widget build(BuildContext context) {
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

    final bool isNow = now.isAfter(start) && now.isBefore(end);

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 6,
      ),

      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: Colors.black.withValues(alpha: 0.2),
        ),
      ),

      child: Text(
        isNow
            ? 'Now'
            : '${_formatTime(startTime)} - ${_formatTime(endTime)}',

        style: TextStyle(
          color: Colors.white.withValues(alpha: 0.8),
          fontWeight: FontWeight.w600,
          fontSize: 10,
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