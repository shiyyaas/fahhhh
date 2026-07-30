import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

// Widgets
import 'package:fahhhh/features/home/widgets/date_btn.dart';
import 'package:fahhhh/features/home/widgets/header_section.dart';
import 'package:fahhhh/features/home/widgets/week_calendar.dart';
import 'package:fahhhh/features/home/widgets/timetable_card.dart';

// Providers & Models
import '../../auth/providers/auth_provider.dart';
import '../../auth/models/user_role.dart';
import '../../timetable/providers/timetable_provider.dart';
import '../../timetable/models/timetable_slot.dart';

class Home extends ConsumerWidget {
  const Home({super.key});

  bool _isPeriodNow(TimeOfDay start, TimeOfDay end, bool isToday) {
    if (!isToday) return false;
    final now = DateTime.now();
    final startDt = DateTime(now.year, now.month, now.day, start.hour, start.minute);
    final endDt = DateTime(now.year, now.month, now.day, end.hour, end.minute);
    return now.isAfter(startDt) && now.isBefore(endDt);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authProvider);
    final user = auth.user;
    final isStudent = auth.role == UserRole.student;

    final selectedDate = ref.watch(selectedDateProvider);
    final timetable = ref.watch(timetableNotifierProvider);

    final today = DateTime.now();
    final todayZero = DateTime(today.year, today.month, today.day);
    final selectedZero = DateTime(selectedDate.year, selectedDate.month, selectedDate.day);

    final bool isToday = selectedZero.isAtSameMomentAs(todayZero);
    final bool isFuture = selectedZero.isAfter(todayZero);

    // Saturday or Sunday holiday check
    final bool isWeekend = selectedDate.weekday == 6 || selectedDate.weekday == 7;

    // Filter slots by weekday
    final filteredByDay = timetable.where((slot) => slot.dayOfWeek == selectedDate.weekday).toList();

    // Profile specific filtering
    final List<TimetableSlot> displaySlots;
    if (isStudent) {
      final userClass = user?.className ?? "S2 BCA";
      displaySlots = filteredByDay.where((slot) => slot.classId == userClass).toList();
    } else {
      // Teacher: show slots they teach
      final teacherName = user?.name ?? "";
      displaySlots = filteredByDay.where((slot) {
        final nameLower = teacherName.toLowerCase();
        final slotTeacherLower = slot.teacherName.toLowerCase();
        return slotTeacherLower == nameLower ||
            (nameLower.contains("sheethal") && slotTeacherLower.contains("sheethal")) ||
            (nameLower.contains("sheethal") && slotTeacherLower.contains("sheetal"));
      }).toList();
    }

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 5),
            const HeaderSection(),
            WeekCalendar(
              selectedDate: selectedDate,
              onDateSelected: (date) {
                ref.read(selectedDateProvider.notifier).selectDate(date);
              },
            ),
            const SizedBox(height: 25),
            DateBtn(selectedDate: selectedDate),
            Expanded(
              child: isWeekend
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.weekend_rounded,
                            size: 64,
                            color: Colors.grey.shade400,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No Class',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey.shade600,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Enjoy your weekend!',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey.shade500,
                            ),
                          ),
                        ],
                      ),
                    )
                  : displaySlots.isEmpty
                      ? Center(
                          child: Text(
                            'No scheduled periods found for this day.',
                            style: TextStyle(color: Colors.grey.shade500),
                          ),
                        )
                      : ListView.builder(
                          itemCount: displaySlots.length,
                          itemBuilder: (context, index) {
                            final slot = displaySlots[index];
                            final isNow = _isPeriodNow(slot.startTime, slot.endTime, isToday);

                            return TimetableCard(
                              subjectName: slot.subjectName,
                              secondaryText: isStudent ? slot.teacherName : slot.classId,
                              status: isStudent ? slot.studentStatus : slot.status,
                              startTime: slot.startTime,
                              endTime: slot.endTime,
                              profileImage: isStudent ? "assets/images/student.png" : null,
                              isStudent: isStudent,
                              isToday: isToday,
                              isFuture: isFuture,
                              onTap: isStudent
                                  ? null
                                  : () {
                                      if (!context.mounted) return;
                                      if (isNow) {
                                        context.push('/attendance-taking/${slot.id}');
                                      } else {
                                        context.push('/attendance-view/${slot.id}');
                                      }
                                    },
                            );
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }
}
