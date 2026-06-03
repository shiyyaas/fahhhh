import 'package:flutter/material.dart';

// Designs
import 'package:fahhhh/theme_data/app_text_styles.dart';
import 'package:fahhhh/theme_data/app_colors.dart';


class WeekCalendar extends StatelessWidget {

  final DateTime selectedDate;
  final Function(DateTime) onDateSelected;

  const WeekCalendar({
    super.key,
    required this.selectedDate,
    required this.onDateSelected,
  });

  @override
  Widget build(BuildContext context) {

    final DateTime today = DateTime.now();

    final List<DateTime> weekDays = List.generate(
      7,
      (index) => today.add(Duration(days: index - 3)),
    );

    return SizedBox(
      height: 70,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        // padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: weekDays.length,
        itemBuilder: (context, index) {
          final DateTime date = weekDays[index];
          final bool isSelected =
              selectedDate.day == date.day &&
              selectedDate.month == date.month &&
              selectedDate.year == date.year;
          return GestureDetector(
            onTap: () {
              onDateSelected(date);
            },

            child: Container(
              width: 80,
              margin: const EdgeInsets.only(
                left: 10,
                // right: 5,
              ),
              decoration: BoxDecoration(

                gradient: isSelected
                    ? const LinearGradient(
                        colors: [
                          Color(0xFF5B8CFF),
                          Color(0xFF1E4DB7),
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      )
                    : null,
                color: isSelected
                    ? null
                    : Colors.white,

                borderRadius: BorderRadius.circular(14),
                border: isSelected ? null : Border.all(
                                                color: AppColors.border,
                                                width: 0.6,
                                              ),
              ),

              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                    Text(
                      date.day.toString().padLeft(2, '0'),
                    style: AppTextStyles.sfPRO.copyWith(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      height: 1.0,
                      color: isSelected
                          ? Colors.white
                          : Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 0),
                  Text(
                    _getWeekDay(date),
                    style: AppTextStyles.sfPRO.copyWith(
                      fontSize: 14,
                      color: isSelected
                          ? Colors.white70
                          : Colors.black54,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  String _getWeekDay(DateTime date) {
    const List<String> days = [
      'Mon',
      'Tue',
      'Wed',
      'Thu',
      'Fri',
      'Sat',
      'Sun',
    ];
    return days[date.weekday - 1];
  }

}