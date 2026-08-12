import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

// Widgets
import 'package:fahhhh/features/home/widgets/date_btn.dart';
import 'package:fahhhh/features/home/widgets/header_section.dart';
import 'package:fahhhh/features/home/widgets/week_calendar.dart';
import 'package:fahhhh/features/home/widgets/timetable_card.dart';
import 'package:fahhhh/features/home/widgets/teacher_subject_card.dart';
import 'package:fahhhh/features/home/widgets/status_badge.dart';

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
    final isTeacher = auth.role == UserRole.teacher;
    final isHod = user?.isHOD ?? false;
    final isClassTeacher = user?.isClassTeacher ?? false;

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
      final userClass = (user?.className ?? "S2 BCA").trim().toLowerCase();
      displaySlots = filteredByDay.where((slot) {
        final slotClass = slot.classId.trim().toLowerCase();
        if (slotClass == userClass) return true;

        final userTokens = userClass.split(' ');
        final slotTokens = slotClass.split(' ');
        if (userTokens.isNotEmpty && slotTokens.isNotEmpty) {
          if (userTokens.first == slotTokens.first) return true;
        }
        return false;
      }).toList();
    } else if (isClassTeacher) {
      // Class Teacher: show ONLY their assigned class's slots for the day
      final assignedClass = (user?.assignedClassId ?? "").trim().toLowerCase();
      displaySlots = filteredByDay.where((slot) {
        final slotClass = slot.classId.trim().toLowerCase();
        return slotClass == assignedClass;
      }).toList();
    } else {
      // Teacher / HOD: Filter view by matching logged-in user's name
      final teacherName = user?.name ?? "";
      displaySlots = filteredByDay.where((slot) {
        final cleanLoggedIn = teacherName.toLowerCase().trim();
        final cleanSlot = slot.teacherName.toLowerCase().trim();

        if (cleanLoggedIn == cleanSlot) return true;

        final ignoreWords = {'ms', 'mr', 'miss', 'mrs', 'prof', 'dr'};

        final loggedInTokens = cleanLoggedIn
            .split(' ')
            .map((t) => t.replaceAll('h', ''))
            .where((t) => !ignoreWords.contains(t) && t.isNotEmpty)
            .toList();

        final slotTokens = cleanSlot
            .split(' ')
            .map((t) => t.replaceAll('h', ''))
            .where((t) => !ignoreWords.contains(t) && t.isNotEmpty)
            .toList();

        for (final token1 in loggedInTokens) {
          for (final token2 in slotTokens) {
            if (token1 == token2) {
              return true;
            }
          }
        }

        return false;
      }).toList();
    }

    // Regular Teacher (non-HOD, non-ClassTeacher): subject cards view
    final bool isTeacherCardView = isTeacher && !isHod && !isClassTeacher;

    // Class Teacher: class-focused view (full day schedule for their class)
    final bool isClassTeacherView = isClassTeacher;

    // Group teacher slots by subject for the teacher subject card view.
    List<Widget> teacherSubjectCards = [];
    if (isTeacherCardView) {
      final Map<String, List<TimetableSlot>> grouped = {};
      for (final slot in displaySlots) {
        grouped.putIfAbsent(slot.subjectName, () => []).add(slot);
      }

      teacherSubjectCards = grouped.entries.map((entry) {
        final slots = entry.value..sort((a, b) {
          final startA = a.startTime.hour * 60 + a.startTime.minute;
          final startB = b.startTime.hour * 60 + b.startTime.minute;
          return startA.compareTo(startB);
        });

        final first = slots.first;
        final String periodText =
            '${first.startTime.hour.toString().padLeft(2, '0')}:${first.startTime.minute.toString().padLeft(2, '0')} - '
            '${first.endTime.hour.toString().padLeft(2, '0')}:${first.endTime.minute.toString().padLeft(2, '0')}';

        final classNames = slots.map((s) => s.classId).toSet().join(', ');

        int present = 0;
        for (final s in first.studentAttendance.values) {
          if (s == AttendanceStatus.present || s == AttendanceStatus.recorded) {
            present++;
          }
        }
        final int total = first.studentAttendance.length;

        return TeacherSubjectCard(
          subjectName: entry.key,
          className: classNames,
          periodText: periodText,
          statusText: '$present/$total',
          periodFilled: slots.length,
          attendanceFill: total == 0 ? 0 : present / total,
          onTap: () {
            if (!context.mounted) return;
            context.push('/attendance-view/${first.id}');
          },
        );
      }).toList();
    }

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.white, Color(0xFFAAA0A0)],
            stops: [0.25, 1.0],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              const HeaderSection(),
              WeekCalendar(
                selectedDate: selectedDate,
                onDateSelected: (date) {
                  ref.read(selectedDateProvider.notifier).selectDate(date);
                },
                chipWidth: (isTeacherCardView || isClassTeacherView) ? 80 : 72,
                chipHeight: (isTeacherCardView || isClassTeacherView) ? 64 : 56,
              ),
              const SizedBox(height: 12),
              DateBtn(
                selectedDate: selectedDate,
                horizontal: isTeacherCardView || isClassTeacherView,
              ),
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
                    : isTeacherCardView
                        ? ListView.builder(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            itemCount: teacherSubjectCards.length,
                            itemBuilder: (context, index) {
                              return Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 20,
                                  vertical: 4,
                                ),
                                child: teacherSubjectCards[index],
                              );
                            },
                          )
                        : isClassTeacherView
                            ? _buildClassTeacherView(displaySlots, isToday, isFuture)
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
      ),
    );
  }

  // Class Teacher view: full day period cards for their assigned class + student header
  Widget _buildClassTeacherView(List<TimetableSlot> slots, bool isToday, bool isFuture) {
    if (slots.isEmpty) {
      return Center(
        child: Text(
          'No scheduled periods for this class today.',
          style: TextStyle(color: Colors.grey.shade500),
        ),
      );
    }

    // Sort by time
    slots.sort((a, b) {
      final startA = a.startTime.hour * 60 + a.startTime.minute;
      final startB = b.startTime.hour * 60 + b.startTime.minute;
      return startA.compareTo(startB);
    });

    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: slots.length,
      itemBuilder: (context, index) {
        final slot = slots[index];
        final isNow = _isPeriodNow(slot.startTime, slot.endTime, isToday);

        return TimetableCard(
          subjectName: slot.subjectName,
          secondaryText: slot.classId,
          status: slot.status,
          startTime: slot.startTime,
          endTime: slot.endTime,
          profileImage: null,
          isStudent: false,
          isToday: isToday,
          isFuture: isFuture,
          onTap: () {
            if (!context.mounted) return;
            if (isNow) {
              context.push('/attendance-taking/${slot.id}');
            } else {
              context.push('/attendance-view/${slot.id}');
            }
          },
        );
      },
    );
  }
}