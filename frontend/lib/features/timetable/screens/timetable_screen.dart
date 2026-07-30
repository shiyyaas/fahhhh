import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme_data/app_colors.dart';
import '../../../core/widgets/blue_btn.dart';
import '../../../core/widgets/white_btn.dart';
import '../../auth/providers/auth_provider.dart';
import '../../auth/models/user_role.dart';
import '../models/timetable_slot.dart';
import '../providers/timetable_provider.dart';

class TimetableScreen extends ConsumerStatefulWidget {
  const TimetableScreen({super.key});

  @override
  ConsumerState<TimetableScreen> createState() => _TimetableScreenState();
}

class _TimetableScreenState extends ConsumerState<TimetableScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Teacher View States
  String _teacherScope = "Classes"; // "Classes" or "Teachers"
  String _selectedClassOption = "S2"; // "S2", "S4", "S6", "S8"
  String _selectedTeacherOption = "Anju"; // "Anju", "Anu", "Rijina", "Sheetal"

  // HOD View States
  String _hodSortClass = "All"; // "All", "S2", "S4", "S6", "S8"
  bool _isHodEditing = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final auth = ref.watch(authProvider);
    final user = auth.user;
    final isStudent = auth.role == UserRole.student;
    final isHOD = user?.isHOD ?? false;

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
        title: Text(
          isHOD ? "Administrative Timetable" : "Class Timetable",
          style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Weekday selector tabs (Monday to Friday)
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(16),
              ),
              child: TabBar(
                controller: _tabController,
                indicator: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(12),
                ),
                labelColor: Colors.white,
                unselectedLabelColor: Colors.black54,
                labelStyle: const TextStyle(fontWeight: FontWeight.bold),
                tabs: const [
                  Tab(text: "Mon"),
                  Tab(text: "Tue"),
                  Tab(text: "Wed"),
                  Tab(text: "Thu"),
                  Tab(text: "Fri"),
                ],
              ),
            ),

            // Top-level custom UI controls based on roles
            if (!isStudent) _buildTopControls(isHOD),

            // Timetable grid representation for the active selected day tab
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: List.generate(5, (index) {
                  final int dayOfWeek = index + 1; // Mon = 1, etc.
                  return _buildScheduleListForDay(dayOfWeek, isStudent, isHOD);
                }),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Build controls bar for Teacher and HOD
  Widget _buildTopControls(bool isHOD) {
    if (isHOD) {
      // HOD Administrative Top Controls
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Sort By Button
            PopupMenuButton<String>(
              onSelected: (val) {
                setState(() {
                  _hodSortClass = val;
                });
              },
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.sort_rounded, size: 18, color: Colors.black87),
                    const SizedBox(width: 6),
                    Text(
                      _hodSortClass == "All" ? "Sort By: All" : "Class: $_hodSortClass",
                      style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                    ),
                  ],
                ),
              ),
              itemBuilder: (context) => [
                const PopupMenuItem(value: "All", child: Text("All Classes")),
                const PopupMenuItem(value: "S2", child: Text("S2 BCA")),
                const PopupMenuItem(value: "S4", child: Text("S4 BCA")),
                const PopupMenuItem(value: "S6", child: Text("S6 BCA")),
                const PopupMenuItem(value: "S8", child: Text("S8 BCA")),
              ],
            ),

            // "Edit" Toggle Button - Turns to solid blue when active programmatically
            GestureDetector(
              onTap: () {
                setState(() {
                  _isHodEditing = !_isHodEditing;
                });
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                decoration: BoxDecoration(
                  color: _isHodEditing ? AppColors.primary : Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: _isHodEditing ? AppColors.primary : Colors.grey.shade300,
                  ),
                  boxShadow: _isHodEditing
                      ? [
                          BoxShadow(
                            color: AppColors.primary.withValues(alpha: 0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          )
                        ]
                      : null,
                ),
                child: Row(
                  children: [
                    Icon(
                      _isHodEditing ? Icons.edit_off_rounded : Icons.edit_rounded,
                      size: 18,
                      color: _isHodEditing ? Colors.white : Colors.black87,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      _isHodEditing ? "Editing" : "Edit",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                        color: _isHodEditing ? Colors.white : Colors.black87,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
    } else {
      // Teacher Top Controls (Classes / Teachers Toggle and Dropdown)
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
          children: [
            // 2-way toggle button group
            Container(
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.all(4),
              child: Row(
                children: [
                  _buildScopeToggleButton("Classes"),
                  _buildScopeToggleButton("Teachers"),
                ],
              ),
            ),
            const SizedBox(width: 12),

            // Context aware dropdown button
            Expanded(
              child: _teacherScope == "Classes"
                  ? _buildDropdownButton(
                      value: _selectedClassOption,
                      options: ["S2", "S4", "S6", "S8"],
                      onChanged: (val) {
                        setState(() {
                          _selectedClassOption = val!;
                        });
                      },
                    )
                  : _buildDropdownButton(
                      value: _selectedTeacherOption,
                      options: ["Anju", "Anu", "Rijina", "Sheetal"],
                      onChanged: (val) {
                        setState(() {
                          _selectedTeacherOption = val!;
                        });
                      },
                    ),
            ),
          ],
        ),
      );
    }
  }

  Widget _buildScopeToggleButton(String scope) {
    final bool isSelected = _teacherScope == scope;
    return GestureDetector(
      onTap: () {
        setState(() {
          _teacherScope = scope;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  )
                ]
              : null,
        ),
        child: Text(
          scope,
          style: TextStyle(
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
            color: isSelected ? Colors.black : Colors.black54,
            fontSize: 13,
          ),
        ),
      ),
    );
  }

  Widget _buildDropdownButton({
    required String value,
    required List<String> options,
    required ValueChanged<String?> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          isExpanded: true,
          icon: const Icon(Icons.arrow_drop_down, color: Colors.black54),
          style: const TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
          onChanged: onChanged,
          items: options.map<DropdownMenuItem<String>>((String val) {
            return DropdownMenuItem<String>(
              value: val,
              child: Text(_teacherScope == "Classes" ? "$val BCA" : val),
            );
          }).toList(),
        ),
      ),
    );
  }

  // Build scrollable list of schedule slots
  Widget _buildScheduleListForDay(int dayOfWeek, bool isStudent, bool isHOD) {
    final timetable = ref.watch(timetableNotifierProvider);
    final user = ref.read(authProvider).user;

    // Filter day's slots
    final daySlots = timetable.where((slot) => slot.dayOfWeek == dayOfWeek).toList();

    // Sort/Filter based on view configuration
    List<TimetableSlot> filteredSlots = [];

    if (isStudent) {
      final userClass = user?.className ?? "S2 BCA";
      filteredSlots = daySlots.where((slot) => slot.classId == userClass).toList();
    } else if (isHOD) {
      if (_hodSortClass == "All") {
        filteredSlots = daySlots;
      } else {
        filteredSlots = daySlots.where((slot) => slot.classId.startsWith(_hodSortClass)).toList();
      }
    } else {
      // Teacher view filters
      if (_teacherScope == "Classes") {
        filteredSlots = daySlots.where((slot) => slot.classId.startsWith(_selectedClassOption)).toList();
      } else {
        filteredSlots = daySlots.where((slot) {
          final slotTeacher = slot.teacherName.toLowerCase();
          final targetTeacher = _selectedTeacherOption.toLowerCase();
          return slotTeacher.contains(targetTeacher) || (targetTeacher.contains("sheethal") && slotTeacher.contains("sheetal")) || (targetTeacher.contains("sheetal") && slotTeacher.contains("sheethal"));
        }).toList();
      }
    }

    // Sort filtered slots by start time
    filteredSlots.sort((a, b) {
      final int aMin = a.startTime.hour * 60 + a.startTime.minute;
      final int bMin = b.startTime.hour * 60 + b.startTime.minute;
      return aMin.compareTo(bMin);
    });

    if (filteredSlots.isEmpty) {
      return Center(
        child: Text(
          "No scheduled periods on this day.",
          style: TextStyle(color: Colors.grey.shade500, fontSize: 14),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: filteredSlots.length,
      itemBuilder: (context, index) {
        final slot = filteredSlots[index];

        return Container(
          margin: const EdgeInsets.symmetric(vertical: 8),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: _isHodEditing && isHOD ? AppColors.primary.withValues(alpha: 0.5) : Colors.grey.shade200,
              width: _isHodEditing && isHOD ? 2 : 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.03),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: InkWell(
            onTap: () {
              if (isHOD && _isHodEditing) {
                _showEditModal(slot);
              }
            },
            borderRadius: BorderRadius.circular(20),
            child: Row(
              children: [
                // Fixed 1-hour time block column
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        _formatTime(slot.startTime),
                        style: const TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      const Icon(Icons.arrow_downward, size: 12, color: AppColors.primary),
                      Text(
                        _formatTime(slot.endTime),
                        style: const TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),

                // Subject name, Class and Teacher details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        slot.subjectName,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          const Icon(Icons.person_outline, size: 14, color: Colors.black54),
                          const SizedBox(width: 4),
                          Text(
                            slot.teacherName,
                            style: const TextStyle(color: Colors.black54, fontSize: 13),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(Icons.class_outlined, size: 14, color: Colors.black54),
                          const SizedBox(width: 4),
                          Text(
                            slot.classId,
                            style: const TextStyle(color: Colors.black54, fontSize: 13),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Edit pencil indicator if editing is active
                if (_isHodEditing && isHOD)
                  const CircleAvatar(
                    backgroundColor: AppColors.primary,
                    radius: 14,
                    child: Icon(Icons.edit, size: 14, color: Colors.white),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  String _formatTime(TimeOfDay time) {
    return "${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}";
  }

  // Modal overlay to edit slot details
  void _showEditModal(TimetableSlot slot) {
    final TextEditingController subjectController = TextEditingController(text: slot.subjectName);
    String selectedTeacher = slot.teacherName;

    // Standard available teachers
    final List<String> teachers = ["Anju", "Anu", "Rijina", "Ms Sheethal", "Sheetal"];
    if (!teachers.contains(selectedTeacher)) {
      teachers.add(selectedTeacher);
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (BuildContext context) {
        return Padding(
          padding: EdgeInsets.only(
            top: 24,
            left: 24,
            right: 24,
            bottom: MediaQuery.of(context).viewInsets.bottom + 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Modify Schedule Period",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                "Class: ${slot.classId}  |  Time: ${_formatTime(slot.startTime)} - ${_formatTime(slot.endTime)}",
                style: const TextStyle(color: Colors.black54, fontSize: 13),
              ),
              const SizedBox(height: 20),

              // Subject text input
              const Text(
                "Subject Name",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: subjectController,
                decoration: InputDecoration(
                  hintText: "Enter subject name",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
              ),
              const SizedBox(height: 16),

              // Teacher selection dropdown
              const Text(
                "Teacher Name",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              ),
              const SizedBox(height: 8),
              StatefulBuilder(
                builder: (context, setStateModal) {
                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: selectedTeacher,
                        isExpanded: true,
                        onChanged: (val) {
                          setStateModal(() {
                            selectedTeacher = val!;
                          });
                        },
                        items: teachers.map<DropdownMenuItem<String>>((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                      ),
                    ),
                  );
                }
              ),
              const SizedBox(height: 24),

              // Save & Cancel row
              Row(
                children: [
                  Expanded(
                    child: WhiteBtn(
                      text: "Cancel",
                      onPressed: () {
                        if (!context.mounted) return;
                        context.pop();
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: BlueBtn(
                      text: "Save",
                      onPressed: () {
                        final updatedSlot = slot.copyWith(
                          subjectName: subjectController.text,
                          teacherName: selectedTeacher,
                        );
                        ref.read(timetableNotifierProvider.notifier).updateSlot(updatedSlot);
                        if (!context.mounted) return;
                        context.pop();
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
