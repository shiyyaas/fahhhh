// Designs
import 'package:fahhhh/theme_data/app_text_styles.dart';

import 'package:flutter/material.dart';

class DateTimetable extends StatelessWidget {
  final DateTime selectedDate;
  const DateTimetable({super.key, required this.selectedDate});

  @override
  Widget build(BuildContext context) {
    final DateTime today = DateTime.now();
    final bool isToday =
        selectedDate.day == today.day &&
        selectedDate.month == today.month &&
        selectedDate.year == today.year;

    return Container(   
      margin: EdgeInsets.symmetric(horizontal: 30 , vertical: 10),
            child:Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isToday ? 'TODAY' : _getWeekDay(selectedDate),
                      style: AppTextStyles.heading.copyWith(height: 0.9, fontSize: 22),
                    ),
                    const SizedBox(height: 0),
                    Text(
                      '${selectedDate.day} ${_getMonth(selectedDate.month)}, ${selectedDate.year}',
                      style: AppTextStyles.small.copyWith(fontSize: 16),
                    ),
                  ],
                ),
                Text(
                  isToday ? 'TODAY' : _getWeekDay(selectedDate),
                  style: AppTextStyles.heading.copyWith(height: 0.9, fontSize: 22),
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
      'MONDAY',
      'TUESDAY',
      'WEDNESDAY',
      'THURSDAY',
      'FRIDAY',
      'SATURDAY',
      'SUNDAY',
    ];
    return days[date.weekday - 1];
  }
}
