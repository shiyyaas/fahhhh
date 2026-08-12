// Designs
import 'package:fahhhh/core/theme_data/app_text_styles.dart';

// Widgets
import 'package:fahhhh/core/widgets/white_btn.dart';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class DateBtn extends StatelessWidget {
  final DateTime selectedDate;
  const DateBtn({super.key, required this.selectedDate});

  @override
  Widget build(BuildContext context) {
    final DateTime today = DateTime.now();
    final bool isToday =
        selectedDate.day == today.day &&
        selectedDate.month == today.month &&
        selectedDate.year == today.year;

    return Container(   
      margin: const EdgeInsets.symmetric(horizontal: 30 , vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                isToday ? 'Today' : _getWeekDay(selectedDate),
                style: AppTextStyles.heading.copyWith(height: 1.1, fontSize: 24),
              ),
              Text(
                '${_getMonth(selectedDate.month)} ${selectedDate.day.toString().padLeft(2, '0')},${selectedDate.year}',
                style: AppTextStyles.small.copyWith(fontSize: 18),
              ),
            ],
          ),
          WhiteBtn(
            icon: Icons.calendar_today,
            text: 'Time Table',
            onPressed: () {
              if (!context.mounted) return;
              context.push('/timetable');
            },
            width: 139,
            height: 40,
            borderRadius: 10,
            iconSize: 20,
            borderColor: const Color(0xFF666666),
            padding: const EdgeInsets.symmetric(horizontal: 12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.15),
                blurRadius: 3,
                offset: const Offset(0, 2),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _getMonth(int month) {
    const months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];
    return months[month - 1];
  }

  String _getWeekDay(DateTime date) {
    const days = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday',
    ];
    return days[date.weekday - 1];
  }
}
