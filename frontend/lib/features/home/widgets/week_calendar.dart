import 'package:flutter/material.dart';

// Designs
import 'package:fahhhh/core/theme_data/app_text_styles.dart';
import 'package:fahhhh/core/theme_data/app_colors.dart';


class WeekCalendar extends StatefulWidget {

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
  State<WeekCalendar> createState() => _WeekCalendarState();
}

class _WeekCalendarState extends State<WeekCalendar> {
  // Anchored once so a rebuild at midnight doesn't shift the displayed week
  // or cause the selected chip to appear deselected until the user taps again.
  late final DateTime _today;
  late final List<DateTime> _weekDays;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _today = DateTime(now.year, now.month, now.day);
    _weekDays = List.generate(7, (index) => _today.add(Duration(days: index - 3)));
  }

  @override
  Widget build(BuildContext context) {

    return SizedBox(
      height: widget.chipHeight + 20,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _weekDays.length,
        itemBuilder: (context, index) {
          final DateTime date = _weekDays[index];
          final bool isSelected =
              widget.selectedDate.day == date.day &&
              widget.selectedDate.month == date.month &&
              widget.selectedDate.year == date.year;
          return GestureDetector(
            onTap: () {
              widget.onDateSelected(date);
            },

            child: Container(
              width: widget.chipWidth,
              height: widget.chipHeight,
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
                color: isSelected ? null : Colors.white,
                borderRadius: BorderRadius.circular(12),
                // Unselected: light border per design spec ("white outlined unselected states")
                // Selected: dark outline for depth
                border: Border.all(
                  color: isSelected
                      ? AppColors.outline.withValues(alpha: 0.6)
                      : AppColors.enabledBorder.withValues(alpha: 0.5),
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