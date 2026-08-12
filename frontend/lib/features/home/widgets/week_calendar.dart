import 'package:flutter/material.dart';

// Designs
import 'package:fahhhh/core/theme_data/app_text_styles.dart';
import 'package:fahhhh/core/theme_data/app_colors.dart';


class WeekCalendar extends StatelessWidget {

  final DateTime selectedDate;
  final Function(DateTime) onDateSelected;
  final double chipWidth;
  final double chipHeight;

  const WeekCalendar({
    super.key,
    required this.selectedDate,
    required this.onDateSelected,
    this.chipWidth = 72,
    this.chipHeight = 56,
  });

  @override
  Widget build(BuildContext context) {

    final DateTime today = DateTime.now();

    final List<DateTime> weekDays = List.generate(
      7,
      (index) => today.add(Duration(days: index - 3)),
    );

    return SizedBox(
      height: chipHeight + 20,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
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
              width: chipWidth,
              height: chipHeight,
              margin: const EdgeInsets.symmetric(horizontal: 7),
              decoration: BoxDecoration(
                gradient: isSelected
                    ? const LinearGradient(
                        colors: [
                          AppColors.gradientTop,
                          AppColors.gradientBottom,
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      )
                    : null,
                color: isSelected
                    ? null
                    : Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Colors.black.withValues(alpha: 0.6),
                  width: isSelected ? 0.9 : 1,
                ),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.2),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ]
                    : null,
              ),

              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                    Text(
                      date.day.toString().padLeft(2, '0'),
                    style: AppTextStyles.sfPRO.copyWith(
                      fontSize: 26,
                      fontWeight: FontWeight.w600,
                      height: 1.0,
                      color: isSelected
                          ? Colors.white
                          : const Color(0xFF364153),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    _getWeekDay(date),
                    style: AppTextStyles.sfPRO.copyWith(
                      fontSize: 12,
                      color: isSelected
                          ? Colors.white
                          : const Color(0xFF364153),
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