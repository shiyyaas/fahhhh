import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme_data/app_colors.dart';
import '../../../core/theme_data/app_text_styles.dart';
import '../../home/widgets/status_badge.dart';
import '../../timetable/models/timetable_slot.dart';
import '../../timetable/providers/timetable_provider.dart';

class AttendanceTakingScreen extends ConsumerStatefulWidget {
  final String slotId;

  const AttendanceTakingScreen({
    super.key,
    required this.slotId,
  });

  @override
  ConsumerState<AttendanceTakingScreen> createState() => _AttendanceTakingScreenState();
}

class _AttendanceTakingScreenState extends ConsumerState<AttendanceTakingScreen> {
  String searchQuery = "";
  final Map<String, AttendanceStatus> _attendanceStates = {};
  bool _initialized = false;
  String _selectedSortFilter = "all"; // "all", "present", "absent", "late"

  void _initializeStates(TimetableSlot slot) {
    if (_initialized) return;
    final students = getStudentsForClass(slot.classId);
    for (var s in students) {
      final existing = slot.studentAttendance[s.rollNumber];
      // Default to pending initially as specified in the prompt
      _attendanceStates[s.rollNumber] = existing ?? AttendanceStatus.pending;
    }
    _initialized = true;
  }

  void _cycleStatus(String rollNumber) {
    final current = _attendanceStates[rollNumber] ?? AttendanceStatus.pending;
    final next = _getNextStatus(current);
    setState(() {
      _attendanceStates[rollNumber] = next;
    });
  }

  AttendanceStatus _getNextStatus(AttendanceStatus current) {
    switch (current) {
      case AttendanceStatus.pending:
        return AttendanceStatus.present;
      case AttendanceStatus.present:
        return AttendanceStatus.absent;
      case AttendanceStatus.absent:
        return AttendanceStatus.late;
      case AttendanceStatus.late:
        return AttendanceStatus.pending;
      default:
        return AttendanceStatus.pending;
    }
  }

  String _getSortFilterLabel(String val) {
    if (val == "present") return "Present";
    if (val == "absent") return "Absent";
    if (val == "late") return "Late";
    return "Sort by";
  }

  @override
  Widget build(BuildContext context) {
    final timetable = ref.watch(timetableNotifierProvider);
    final slotIndex = timetable.indexWhere((s) => s.id == widget.slotId);

    if (slotIndex == -1) {
      return Scaffold(
        appBar: AppBar(title: const Text("Error")),
        body: const Center(child: Text("Schedule slot not found")),
      );
    }

    final slot = timetable[slotIndex];
    _initializeStates(slot);

    // Date calculations to determine past vs today vs future behavior
    final selectedDate = ref.watch(selectedDateProvider);
    final now = DateTime.now();
    final todayZero = DateTime(now.year, now.month, now.day);
    final selectedZero = DateTime(selectedDate.year, selectedDate.month, selectedDate.day);

    final bool isToday = selectedZero.isAtSameMomentAs(todayZero);
    final bool isPast = selectedZero.isBefore(todayZero);
    final bool isFuture = selectedZero.isAfter(todayZero);

    final students = getStudentsForClass(slot.classId);
    final filteredStudents = students.where((s) {
      final matchesSearch = s.name.toLowerCase().contains(searchQuery.toLowerCase()) ||
          s.rollNumber.toLowerCase().contains(searchQuery.toLowerCase());
      if (!matchesSearch) return false;

      if (isPast && _selectedSortFilter != "all") {
        final currentStatus = _attendanceStates[s.rollNumber] ?? AttendanceStatus.pending;
        if (_selectedSortFilter == "present" && currentStatus != AttendanceStatus.present) return false;
        if (_selectedSortFilter == "absent" && currentStatus != AttendanceStatus.absent) return false;
        if (_selectedSortFilter == "late" && currentStatus != AttendanceStatus.late) return false;
      }
      return true;
    }).toList();

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.white, Color(0xFFAAA0A0)],
            stops: [0.4, 1.0],
          ),
        ),
        child: SafeArea(
        child: isFuture
            ? Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Minimal App Header for Future dates empty state
                  _buildHeader(slot),
                  Expanded(
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 32),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.calendar_today_rounded,
                              size: 64,
                              color: Colors.grey.shade400,
                            ),
                            const SizedBox(height: 16),
                            const Text(
                              'Attendance Not Available',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.black54,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Attendance is not available for future dates.',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey.shade500,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              )
            : Stack(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header Section
                      _buildHeader(slot),

                      // Controls section (Search & Mark All / Sort By)
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                        child: Row(
                          children: [
                            // Search Field
                            Expanded(
                              flex: 3,
                              child: Container(
                                height: 34,
                                padding: const EdgeInsets.symmetric(horizontal: 14),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(17),
                                  border: Border.all(color: Colors.black, width: 0.5),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withValues(alpha: 0.04),
                                      blurRadius: 4,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: Row(
                                  children: [
                                    const Icon(Icons.search, color: Colors.black54, size: 16),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: TextField(
                                        onChanged: (val) {
                                          setState(() {
                                            searchQuery = val;
                                          });
                                        },
                                        decoration: const InputDecoration(
                                          hintText: "Search",
                                          border: InputBorder.none,
                                          isDense: true,
                                          contentPadding: EdgeInsets.zero,
                                        ),
                                        style: const TextStyle(fontSize: 13, color: Colors.black),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            // Action Dropdown
                            Expanded(
                              flex: 2,
                              child: isPast
                                  ? PopupMenuButton<String>(
                                      onSelected: (val) {
                                        setState(() {
                                          _selectedSortFilter = val;
                                        });
                                      },
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                      child: Container(
                                        height: 44,
                                        padding: const EdgeInsets.symmetric(horizontal: 12),
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius: BorderRadius.circular(30),
                                          border: Border.all(color: Colors.grey.shade300, width: 1.2),
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.black.withValues(alpha: 0.04),
                                              blurRadius: 4,
                                              offset: const Offset(0, 2),
                                            ),
                                          ],
                                        ),
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Expanded(
                                              child: Text(
                                                _getSortFilterLabel(_selectedSortFilter),
                                                overflow: TextOverflow.ellipsis,
                                                style: const TextStyle(
                                                  color: Colors.black,
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 13,
                                                ),
                                              ),
                                            ),
                                            const Icon(Icons.keyboard_arrow_down_rounded, color: Colors.black, size: 16),
                                          ],
                                        ),
                                      ),
                                      itemBuilder: (context) => [
                                        const PopupMenuItem(
                                          value: "all",
                                          child: Text("All"),
                                        ),
                                        const PopupMenuItem(
                                          value: "present",
                                          child: Text("All Present"),
                                        ),
                                        const PopupMenuItem(
                                          value: "absent",
                                          child: Text("All Absent"),
                                        ),
                                        const PopupMenuItem(
                                          value: "late",
                                          child: Text("All Late"),
                                        ),
                                      ],
                                    )
                                  : PopupMenuButton<AttendanceStatus>(
                                      onSelected: (status) {
                                        setState(() {
                                          for (var s in students) {
                                            _attendanceStates[s.rollNumber] = status;
                                          }
                                        });
                                      },
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                      child: Container(
                                        height: 44,
                                        padding: const EdgeInsets.symmetric(horizontal: 12),
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius: BorderRadius.circular(30),
                                          border: Border.all(color: Colors.grey.shade300, width: 1.2),
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.black.withValues(alpha: 0.04),
                                              blurRadius: 4,
                                              offset: const Offset(0, 2),
                                            ),
                                          ],
                                        ),
                                        child: const Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              "Mark All",
                                              style: TextStyle(
                                                color: Colors.black,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 13,
                                              ),
                                            ),
                                            Icon(Icons.keyboard_arrow_down_rounded, color: Colors.black, size: 16),
                                          ],
                                        ),
                                      ),
                                      itemBuilder: (context) => [
                                        const PopupMenuItem(
                                          value: AttendanceStatus.present,
                                          child: Text("All Present"),
                                        ),
                                        const PopupMenuItem(
                                          value: AttendanceStatus.absent,
                                          child: Text("All Absent"),
                                        ),
                                        const PopupMenuItem(
                                          value: AttendanceStatus.late,
                                          child: Text("All Late"),
                                        ),
                                      ],
                                    ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 8),

                      // Student list view
                      Expanded(
                        child: ListView.builder(
                          padding: EdgeInsets.only(
                            top: 8,
                            left: 0,
                            right: 0,
                            bottom: isToday ? 100 : 24,
                          ),
                          itemCount: filteredStudents.length,
                          itemBuilder: (context, index) {
                            final student = filteredStudents[index];
                            final currentStatus = _attendanceStates[student.rollNumber] ?? AttendanceStatus.pending;

                            return Container(
                              margin: const EdgeInsets.symmetric(vertical: 7, horizontal: 24),
                              padding: const EdgeInsets.only(
                                left: 16,
                                right: 12,
                                top: 11,
                                bottom: 10,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.primary,
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(color: Colors.black, width: 0.8),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.1),
                                    blurRadius: 4,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Text(
                                      student.name,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w500,
                                        fontSize: 20,
                                      ),
                                    ),
                                  ),
                                  _buildStatusCapsule(currentStatus, isPast, student.rollNumber),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),

                  // Black center floating Save Button (only for today)
                  if (isToday)
                    Align(
                      alignment: Alignment.bottomCenter,
                      child: Padding(
                        padding: const EdgeInsets.all(24.0),
                        child: GestureDetector(
                          onTap: () {
                            ref.read(timetableNotifierProvider.notifier).saveAttendance(
                                  widget.slotId,
                                  _attendanceStates,
                                );
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text("Attendance saved successfully!"),
                                backgroundColor: AppColors.primary,
                                duration: Duration(seconds: 2),
                              ),
                            );
                            if (!context.mounted) return;
                            context.pop();
                          },
                          child: Container(
                            width: 180,
                            height: 44,
                            decoration: BoxDecoration(
                              color: Colors.black,
                              borderRadius: BorderRadius.circular(22),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.3),
                                  blurRadius: 8,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            alignment: Alignment.center,
                            child: const Text(
                              "Save",
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 20,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
      ),
      ),
    );
  }

  Widget _buildHeader(TimetableSlot slot) {
    return Padding(
      padding: const EdgeInsets.only(left: 8, top: 16, right: 16, bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.black, size: 26),
                onPressed: () {
                  if (!context.mounted) return;
                  context.pop();
                },
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      slot.classId,
                      style: AppTextStyles.heading.copyWith(
                        color: Colors.black,
                        fontSize: 30,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      "${slot.subjectName} - ${slot.startTime.hour}:${slot.startTime.minute.toString().padLeft(2, '0')} to ${slot.endTime.hour}:${slot.endTime.minute.toString().padLeft(2, '0')}",
                      style: AppTextStyles.small.copyWith(fontSize: 16),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatusCapsule(AttendanceStatus status, bool isReadOnly, String rollNumber) {
    final Color? bg;
    final Color textCol;
    final String text;

    switch (status) {
      case AttendanceStatus.present:
        bg = const Color(0xFF6BDB72).withValues(alpha: 0.6);
        textCol = const Color(0xFFE8E8E8);
        text = "Present";
        break;
      case AttendanceStatus.absent:
        bg = const Color(0xFFA93232).withValues(alpha: 0.6);
        textCol = const Color(0xFFF9C4C4);
        text = "Absent";
        break;
      case AttendanceStatus.late:
        bg = const Color(0xFFD0B238).withValues(alpha: 0.8);
        textCol = Colors.white;
        text = "Late";
        break;
      case AttendanceStatus.pending:
      default:
        bg = null;
        textCol = const Color(0xFFE6E6E6);
        text = "Pending";
        break;
    }

    return GestureDetector(
      onTap: isReadOnly ? null : () => _cycleStatus(rollNumber),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        constraints: const BoxConstraints(minWidth: 85, minHeight: 28),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: bg,
          gradient: status == AttendanceStatus.pending
              ? const LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0xFF647286), Color(0xFF496388)],
                )
              : null,
          borderRadius: BorderRadius.circular(13),
          border: Border.all(
            color: Colors.black.withValues(alpha: 0.55),
            width: 0.8,
          ),
        ),
        child: Text(
          text,
          style: TextStyle(
            color: textCol,
            fontWeight: FontWeight.bold,
            fontSize: 15,
          ),
        ),
      ),
    );
  }
}
