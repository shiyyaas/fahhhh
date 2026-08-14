import 'dart:math';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:fahhhh/core/theme_data/app_text_styles.dart';
import 'package:fahhhh/features/home/widgets/timetable_card.dart';
import 'package:fahhhh/features/home/widgets/status_badge.dart';

enum DayAttendanceStatus { present, partial, absent, noClass, none }

class AttendanceHistoryScreen extends StatefulWidget {
  const AttendanceHistoryScreen({super.key});

  @override
  State<AttendanceHistoryScreen> createState() =>
      _AttendanceHistoryScreenState();
}

class _AttendanceHistoryScreenState extends State<AttendanceHistoryScreen> {
  late DateTime _currentMonth;
  DateTime? _selectedDay;
  late Map<DateTime, DayAttendanceStatus> _attendanceData;

  @override
  void initState() {
    super.initState();
    _currentMonth = DateTime(DateTime.now().year, DateTime.now().month);
    _selectedDay = DateTime.now();
    _attendanceData = _generateMockAttendance();
  }

  Map<DateTime, DayAttendanceStatus> _generateMockAttendance() {
    final now = DateTime.now();
    final map = <DateTime, DayAttendanceStatus>{};
    final random = Random(42);
    final daysInMonth = DateUtils.getDaysInMonth(now.year, now.month);
    for (int d = 1; d <= daysInMonth; d++) {
      final date = DateTime(now.year, now.month, d);
      if (date.isAfter(now)) {
        continue;
      }
      if (date.weekday == DateTime.saturday ||
          date.weekday == DateTime.sunday) {
        continue;
      }
      final r = random.nextDouble();
      if (r < 0.5) {
        map[date] = DayAttendanceStatus.present;
      } else if (r < 0.75) {
        map[date] = DayAttendanceStatus.partial;
      } else {
        map[date] = DayAttendanceStatus.absent;
      }
    }
    return map;
  }

  void _prevMonth() {
    setState(() {
      _currentMonth = DateTime(_currentMonth.year, _currentMonth.month - 1);
    });
  }

  void _nextMonth() {
    setState(() {
      _currentMonth = DateTime(_currentMonth.year, _currentMonth.month + 1);
    });
  }

  String _monthLabel() {
    const months = [
      '',
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
    return '${months[_currentMonth.month]} ${_currentMonth.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.white, Color(0xFFAAA0A0)],
            stops: [0.52, 1.0],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildHeader(),
                      const SizedBox(height: 8),
                      _buildCalendarCard(),
                      const SizedBox(height: 16),
                      _buildTodayLabel(),
                      const SizedBox(height: 4),
                      _buildSubjectList(),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Row(
        children: [
          IconButton(
            onPressed: () {
              if (context.mounted) context.pop();
            },
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 26, minHeight: 26),
            icon: const Icon(Icons.arrow_back, size: 26),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Attendance History',
                  style: AppTextStyles.heading.copyWith(
                    fontSize: 20.5,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 1),
                Text(
                  "View your attendance here",
                  style: AppTextStyles.small.copyWith(fontSize: 17.7),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCalendarCard() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 14),
      padding: const EdgeInsets.all(1),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFF676767), width: 1),
        boxShadow: const [
          BoxShadow(
            color: Color(0x1A000000),
            blurRadius: 2.76,
            offset: Offset(0, 0.92),
          ),
          BoxShadow(
            color: Color(0x1A000000),
            blurRadius: 1.84,
            offset: Offset(0, 0.92),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildMonthNav(),
          _buildWeekdayHeaders(),
          _buildCalendarGrid(),
          _buildLegend(),
        ],
      ),
    );
  }

  Widget _buildMonthNav() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _NavButton(
            icon: Icons.chevron_left_rounded,
            onTap: _prevMonth,
          ),
          GestureDetector(
            onTap: () {},
            child: Text(
              _monthLabel(),
              style: AppTextStyles.heading.copyWith(
                fontSize: 14.7,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF333333),
              ),
            ),
          ),
          _NavButton(
            icon: Icons.chevron_right_rounded,
            onTap: _nextMonth,
          ),
        ],
      ),
    );
  }

  Widget _buildWeekdayHeaders() {
    const days = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      child: Row(
        children: days
            .map((d) => Expanded(
                  child: Center(
                    child: Text(
                      d,
                      style: AppTextStyles.sfPRO.copyWith(
                        fontSize: 10.1,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF9F9FA9),
                      ),
                    ),
                  ),
                ))
            .toList(),
      ),
    );
  }

  Widget _buildCalendarGrid() {
    final firstDay = DateTime(_currentMonth.year, _currentMonth.month, 1);
    final daysInMonth =
        DateUtils.getDaysInMonth(_currentMonth.year, _currentMonth.month);
    final startWeekday = firstDay.weekday % 7;
    final totalCells = startWeekday + daysInMonth;
    final rows = (totalCells / 7).ceil();

    final today = DateTime.now();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      child: Column(
        children: List.generate(rows, (row) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 5.5),
            child: Row(
              children: List.generate(7, (col) {
                final index = row * 7 + col;
                final dayNum = index - startWeekday + 1;
                if (dayNum < 1 || dayNum > daysInMonth) {
                  return const Expanded(child: SizedBox(height: 38));
                }
                final date =
                    DateTime(_currentMonth.year, _currentMonth.month, dayNum);
                final isToday = date.year == today.year &&
                    date.month == today.month &&
                    date.day == today.day;
                final isSelected = _selectedDay != null &&
                    date.year == _selectedDay!.year &&
                    date.month == _selectedDay!.month &&
                    date.day == _selectedDay!.day;
                final status = _attendanceData[date];
                final isWeekend = date.weekday == DateTime.saturday ||
                    date.weekday == DateTime.sunday;

                return Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _selectedDay = date),
                    child: SizedBox(
                      height: 38,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 38,
                            height: 38,
                            decoration: isToday
                                ? BoxDecoration(
                                    gradient: const LinearGradient(
                                      begin: Alignment.topCenter,
                                      end: Alignment.bottomCenter,
                                      colors: [
                                        Color(0xFF9F882B),
                                        Color(0xFFF3D45C),
                                      ],
                                    ),
                                    borderRadius: BorderRadius.circular(13),
                                    boxShadow: const [
                                      BoxShadow(
                                        color: Color(0x66FFB900),
                                        blurRadius: 13.8,
                                        spreadRadius: 9.2,
                                      ),
                                      BoxShadow(
                                        color: Color(0x1A000000),
                                        blurRadius: 3.68,
                                        spreadRadius: 1.84,
                                      ),
                                    ],
                                  )
                                : isSelected
                                    ? BoxDecoration(
                                        color: Colors.white,
                                        borderRadius:
                                            BorderRadius.circular(13),
                                        border: Border.all(
                                          color: const Color(0xFF615FFF),
                                          width: 1,
                                        ),
                                      )
                                    : null,
                            alignment: Alignment.center,
                            child: Text(
                              '$dayNum',
                              style: AppTextStyles.sfPRO.copyWith(
                                fontSize: 12,
                                fontWeight:
                                    isToday ? FontWeight.bold : FontWeight.w500,
                                color: isToday
                                    ? Colors.white
                                    : const Color(0xFF3F3F47),
                              ),
                            ),
                          ),
                          if (!isWeekend &&
                              status != null &&
                              status != DayAttendanceStatus.none) ...[
                            const SizedBox(height: 2),
                            _AttendanceDot(status: status),
                          ],
                        ],
                      ),
                    ),
                  ),
                );
              }),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildLegend() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
          _LegendItem(
            status: DayAttendanceStatus.present,
            label: 'Present',
          ),
          SizedBox(width: 14),
          _LegendItem(
            status: DayAttendanceStatus.partial,
            label: 'Partial',
          ),
          SizedBox(width: 14),
          _LegendItem(
            status: DayAttendanceStatus.absent,
            label: 'Absent',
          ),
          SizedBox(width: 14),
          _LegendItem(
            status: DayAttendanceStatus.noClass,
            label: 'No Class',
          ),
        ],
      ),
    );
  }

  Widget _buildTodayLabel() {
    final now = DateTime.now();
    final months = [
      '',
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
    final dateStr = '${months[now.month]} ${now.day},${now.year}';
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 30),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Today',
            style: AppTextStyles.heading.copyWith(
              fontSize: 29.5,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            dateStr,
            style: AppTextStyles.small.copyWith(fontSize: 18),
          ),
        ],
      ),
    );
  }

  Widget _buildSubjectList() {
    final subjects = [
      ('Software Engineering', 'Sheethal', const TimeOfDay(hour: 9, minute: 30),
          const TimeOfDay(hour: 10, minute: 15), AttendanceStatus.present),
      ('Data Structures', 'Rahul', const TimeOfDay(hour: 10, minute: 30),
          const TimeOfDay(hour: 11, minute: 30), AttendanceStatus.absent),
      ('Operating Systems', 'Meena', const TimeOfDay(hour: 12, minute: 0),
          const TimeOfDay(hour: 13, minute: 0), AttendanceStatus.present),
      ('Computer Networks', 'Arjun', const TimeOfDay(hour: 14, minute: 0),
          const TimeOfDay(hour: 15, minute: 0), AttendanceStatus.present),
      ('Database Management', 'Priya', const TimeOfDay(hour: 15, minute: 0),
          const TimeOfDay(hour: 16, minute: 0), AttendanceStatus.present),
      ('Mathematics', 'Suresh', const TimeOfDay(hour: 16, minute: 30),
          const TimeOfDay(hour: 17, minute: 30), AttendanceStatus.absent),
    ];

    return Column(
      children: subjects.map((s) {
        return TimetableCard(
          subjectName: s.$1,
          secondaryText: s.$2,
          status: s.$5,
          startTime: s.$3,
          endTime: s.$4,
          profileImage: 'assets/images/student.png',
          isStudent: true,
          isToday: true,
          isFuture: false,
        );
      }).toList(),
    );
  }
}

class _NavButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _NavButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 29,
        height: 29,
        decoration: BoxDecoration(
          color: const Color(0xFFF4F4F5),
          borderRadius: BorderRadius.circular(13),
        ),
        child: Icon(icon, size: 16, color: const Color(0xFF3F3F47)),
      ),
    );
  }
}

class _AttendanceDot extends StatelessWidget {
  final DayAttendanceStatus status;
  const _AttendanceDot({required this.status});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 5.5,
      height: 5.5,
      decoration: BoxDecoration(
        gradient: _gradient(),
        shape: BoxShape.circle,
      ),
    );
  }

  Gradient _gradient() {
    switch (status) {
      case DayAttendanceStatus.present:
        return const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF1D8844), Color(0xFF21DB65)],
        );
      case DayAttendanceStatus.partial:
        return const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF9F882B), Color(0xFFF3D45C)],
        );
      case DayAttendanceStatus.absent:
        return const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFFAE4040), Color(0xFFF96363)],
        );
      case DayAttendanceStatus.noClass:
        return const LinearGradient(
          colors: [Color(0xFFD4D4D8), Color(0xFFD4D4D8)],
        );
      case DayAttendanceStatus.none:
        return const LinearGradient(
          colors: [Colors.transparent, Colors.transparent],
        );
    }
  }
}

class _LegendItem extends StatelessWidget {
  final DayAttendanceStatus status;
  final String label;
  const _LegendItem({required this.status, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 9.2,
          height: 9.2,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: _legendGradient(),
          ),
        ),
        const SizedBox(width: 5.5),
        Text(
          label,
          style: AppTextStyles.sfPRO.copyWith(
            fontSize: 9.2,
            fontWeight: FontWeight.w500,
            color: const Color(0xFF9F9FA9),
          ),
        ),
      ],
    );
  }

  Gradient _legendGradient() {
    switch (status) {
      case DayAttendanceStatus.present:
        return const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF1D8844), Color(0xFF21DB65)],
        );
      case DayAttendanceStatus.partial:
        return const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF9F882B), Color(0xFFF3D45C)],
        );
      case DayAttendanceStatus.absent:
        return const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFFAE4040), Color(0xFFF96363)],
        );
      case DayAttendanceStatus.noClass:
        return const LinearGradient(
          colors: [Color(0xFFD4D4D8), Color(0xFFD4D4D8)],
        );
      case DayAttendanceStatus.none:
        return const LinearGradient(
          colors: [Colors.transparent, Colors.transparent],
        );
    }
  }
}
