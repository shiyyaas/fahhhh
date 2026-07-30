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

  void _initializeStates(TimetableSlot slot) {
    if (_initialized) return;
    final students = getStudentsForClass(slot.classId);
    for (var s in students) {
      final existing = slot.studentAttendance[s.rollNumber];
      // Default to present if pending or null, to make the teacher's life easier
      _attendanceStates[s.rollNumber] = (existing == null || existing == AttendanceStatus.pending)
          ? AttendanceStatus.present
          : existing;
    }
    _initialized = true;
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

    final students = getStudentsForClass(slot.classId);
    final filteredStudents = students.where((s) {
      return s.name.toLowerCase().contains(searchQuery.toLowerCase()) ||
          s.rollNumber.toLowerCase().contains(searchQuery.toLowerCase());
    }).toList();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            if (!context.mounted) return;
            context.pop();
          },
        ),
        title: const Text(
          "Take Attendance",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header layout elements: prominent Class Name, Subject Name, Time block metadata
                Container(
                  width: double.infinity,
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        slot.classId,
                        style: AppTextStyles.heading.copyWith(
                          color: Colors.white,
                          fontSize: 28,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        slot.subjectName,
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          const Icon(Icons.access_time_rounded, color: Colors.white70, size: 16),
                          const SizedBox(width: 6),
                          Text(
                            "${slot.startTime.hour.toString().padLeft(2, '0')}:${slot.startTime.minute.toString().padLeft(2, '0')} to ${slot.endTime.hour.toString().padLeft(2, '0')}:${slot.endTime.minute.toString().padLeft(2, '0')}",
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Search & Mark All section
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Row(
                    children: [
                      // Text search bar
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: Colors.grey.shade200),
                          ),
                          child: TextField(
                            onChanged: (val) {
                              setState(() {
                                searchQuery = val;
                              });
                            },
                            decoration: const InputDecoration(
                              hintText: "Search student...",
                              prefixIcon: Icon(Icons.search, color: Colors.grey),
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.symmetric(vertical: 12),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      // "Mark All" dropdown button
                      PopupMenuButton<AttendanceStatus>(
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
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                          decoration: BoxDecoration(
                            border: Border.all(color: AppColors.primary),
                            borderRadius: BorderRadius.circular(16),
                            color: Colors.white,
                          ),
                          child: const Row(
                            children: [
                              Text(
                                "Mark All",
                                style: TextStyle(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Icon(Icons.arrow_drop_down, color: AppColors.primary),
                            ],
                          ),
                        ),
                        itemBuilder: (context) => [
                          const PopupMenuItem(
                            value: AttendanceStatus.present,
                            child: Text("All Present"),
                          ),
                          const PopupMenuItem(
                            value: AttendanceStatus.late,
                            child: Text("All Late"),
                          ),
                          const PopupMenuItem(
                            value: AttendanceStatus.absent,
                            child: Text("All Absent"),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Students List
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.only(left: 16, right: 16, bottom: 90),
                    itemCount: filteredStudents.length,
                    itemBuilder: (context, index) {
                      final student = filteredStudents[index];
                      final currentStatus = _attendanceStates[student.rollNumber] ?? AttendanceStatus.present;

                      return Container(
                        margin: const EdgeInsets.symmetric(vertical: 6),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.grey.shade200),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.02),
                              blurRadius: 6,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            CircleAvatar(
                              radius: 20,
                              backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                              child: Text(
                                student.name.substring(0, 2).toUpperCase(),
                                style: const TextStyle(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    student.name,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15,
                                    ),
                                  ),
                                  Text(
                                    student.rollNumber,
                                    style: TextStyle(
                                      color: Colors.grey.shade600,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            // P, L, A Selection Row
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                _buildStatusButton(
                                  label: "P",
                                  targetStatus: AttendanceStatus.present,
                                  currentStatus: currentStatus,
                                  selectedColor: const Color(0xFF1F8B4C),
                                  rollNumber: student.rollNumber,
                                ),
                                const SizedBox(width: 6),
                                _buildStatusButton(
                                  label: "L",
                                  targetStatus: AttendanceStatus.late,
                                  currentStatus: currentStatus,
                                  selectedColor: const Color(0xFFE59B00),
                                  rollNumber: student.rollNumber,
                                ),
                                const SizedBox(width: 6),
                                _buildStatusButton(
                                  label: "A",
                                  targetStatus: AttendanceStatus.absent,
                                  currentStatus: currentStatus,
                                  selectedColor: const Color(0xFFD92D20),
                                  rollNumber: student.rollNumber,
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),

          // Floating Action Button in the bottom center
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: ElevatedButton(
                onPressed: () {
                  ref.read(timetableNotifierProvider.notifier).saveAttendance(
                        widget.slotId,
                        _attendanceStates,
                      );
                  if (!context.mounted) return;
                  context.pop();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  elevation: 8,
                  shadowColor: AppColors.primary.withValues(alpha: 0.4),
                ),
                child: const Text(
                  "Save Attendance",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusButton({
    required String label,
    required AttendanceStatus targetStatus,
    required AttendanceStatus currentStatus,
    required Color selectedColor,
    required String rollNumber,
  }) {
    final bool isSelected = currentStatus == targetStatus;
    return GestureDetector(
      onTap: () {
        setState(() {
          _attendanceStates[rollNumber] = targetStatus;
        });
      },
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: isSelected ? selectedColor : Colors.grey.shade100,
          border: Border.all(
            color: isSelected ? selectedColor : Colors.grey.shade300,
            width: 1,
          ),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.grey.shade600,
            fontWeight: FontWeight.bold,
            fontSize: 12,
          ),
        ),
      ),
    );
  }
}
