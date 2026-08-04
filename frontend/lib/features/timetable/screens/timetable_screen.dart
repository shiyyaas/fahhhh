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

class _TimetableScreenState extends ConsumerState<TimetableScreen> {
  String _selectedSemester = "S2 BCA";
  bool _isHodEditing = false;

  late ScrollController _scrollController;
  double _scrollProgress = 0.0;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _scrollController.addListener(_onScroll);

    // Set default selected semester from logged-in user if available
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final auth = ref.read(authProvider);
      final user = auth.user;
      if (user != null) {
        if (user.role == UserRole.student && user.className != null) {
          setState(() {
            _selectedSemester = user.className!;
          });
        } else if (user.role == UserRole.teacher && user.assignedClassId != null) {
          setState(() {
            _selectedSemester = user.assignedClassId!;
          });
        }
      }
    });
  }

  void _onScroll() {
    if (_scrollController.hasClients) {
      final maxScroll = _scrollController.position.maxScrollExtent;
      final currentScroll = _scrollController.position.pixels;
      if (maxScroll > 0) {
        setState(() {
          _scrollProgress = (currentScroll / maxScroll).clamp(0.0, 1.0);
        });
      }
    }
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final auth = ref.watch(authProvider);
    final user = auth.user;
    final isHOD = user?.isHOD ?? false;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Custom Header aligning with 'Time Table - admin home (1).png'
              Padding(
                padding: const EdgeInsets.only(left: 8, top: 16, right: 16, bottom: 16),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.black, size: 20),
                      onPressed: () {
                        if (!context.mounted) return;
                        context.pop();
                      },
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Time Table",
                            style: TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                              fontSize: 24,
                              letterSpacing: -0.5,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            isHOD ? "Manage every Time table here" : "View academic class schedules",
                            style: const TextStyle(
                              color: Color(0xFF6F5E53),
                              fontWeight: FontWeight.w500,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 8),

              // Action Buttons Row (Sort by & Edit)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Row(
                  children: [
                    // Sort by Dropdown Menu Button
                    PopupMenuButton<String>(
                      onSelected: (val) {
                        setState(() {
                          _selectedSemester = val;
                        });
                      },
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      itemBuilder: (context) => [
                        const PopupMenuItem(value: "S2 BCA", child: Text("S2 BCA")),
                        const PopupMenuItem(value: "S4 BCA", child: Text("S4 BCA")),
                        const PopupMenuItem(value: "S6 BCA", child: Text("S6 BCA")),
                        const PopupMenuItem(value: "S8 BCA", child: Text("S8 BCA")),
                      ],
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(30),
                          border: Border.all(color: Colors.black, width: 1.2),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.08),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              "Sort by: ${_selectedSemester.split(' ').first}",
                              style: const TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                            ),
                            const SizedBox(width: 4),
                            const Icon(Icons.keyboard_arrow_down_rounded, color: Colors.black, size: 16),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(width: 12),

                    // Edit Button (Only visible for HOD)
                    if (isHOD)
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            _isHodEditing = !_isHodEditing;
                          });
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                          decoration: BoxDecoration(
                            color: _isHodEditing ? AppColors.primary : Colors.white,
                            borderRadius: BorderRadius.circular(30),
                            border: Border.all(
                              color: _isHodEditing ? AppColors.primary : Colors.black,
                              width: 1.2,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.08),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.edit_outlined,
                                color: _isHodEditing ? Colors.white : Colors.black,
                                size: 16,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                "Edit",
                                style: TextStyle(
                                  color: _isHodEditing ? Colors.white : Colors.black,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Horizontal Scrollable Grid Table Card
              SingleChildScrollView(
                controller: _scrollController,
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                child: Container(
                  width: 640,
                  margin: const EdgeInsets.symmetric(horizontal: 24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFF1E293B), width: 1.2),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: Table(
                    columnWidths: const {
                      0: FixedColumnWidth(40),
                      1: FixedColumnWidth(120),
                      2: FixedColumnWidth(120),
                      3: FixedColumnWidth(120),
                      4: FixedColumnWidth(120),
                      5: FixedColumnWidth(120),
                    },
                    border: const TableBorder(
                      horizontalInside: BorderSide(color: Color(0xFFE2E8F0), width: 1.0),
                      verticalInside: BorderSide(color: Color(0xFFE2E8F0), width: 1.0),
                    ),
                    children: [
                      // Header Row
                      TableRow(
                        decoration: const BoxDecoration(
                          color: Color(0xFFF8FAFC),
                        ),
                        children: [
                          const SizedBox(height: 48, child: Center(child: Text(""))),
                          _buildHeaderCell("MON"),
                          _buildHeaderCell("TUE"),
                          _buildHeaderCell("WED"),
                          _buildHeaderCell("THUS"),
                          _buildHeaderCell("FRI"),
                        ],
                      ),
                      // 5 Period Rows
                      for (int period = 1; period <= 5; period++)
                        TableRow(
                          children: [
                            // Leftmost Index Column Cell
                            SizedBox(
                              height: 80,
                              child: Center(
                                child: Text(
                                  "$period",
                                  style: const TextStyle(
                                    color: Color(0xFF64748B),
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                            ),
                            // Days Mon (1) to Fri (5)
                            for (int day = 1; day <= 5; day++)
                              _buildTableCell(day, period),
                          ],
                        ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Scroll Progress Indicator at the bottom of the table
              Center(
                child: _buildScrollIndicator(),
              ),

              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderCell(String dayName) {
    return SizedBox(
      height: 48,
      child: Center(
        child: Text(
          dayName,
          style: const TextStyle(
            color: Color(0xFF475569),
            fontWeight: FontWeight.bold,
            fontSize: 13,
            letterSpacing: 0.5,
          ),
        ),
      ),
    );
  }

  Widget _buildTableCell(int day, int period) {
    final timetable = ref.watch(timetableNotifierProvider);
    final slotId = "slot_${_selectedSemester.replaceAll(' ', '_')}_${day}_$period";
    final slotIndex = timetable.indexWhere((s) => s.id == slotId);

    if (slotIndex == -1) {
      return const SizedBox(
        height: 80,
        child: Center(
          child: Text(
            "-",
            style: TextStyle(color: Colors.grey),
          ),
        ),
      );
    }

    final slot = timetable[slotIndex];

    return InkWell(
      onTap: () {
        final auth = ref.read(authProvider);
        final isHOD = auth.user?.isHOD ?? false;
        if (isHOD && _isHodEditing) {
          _showEditModal(slot);
        }
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        height: 80,
        alignment: Alignment.center,
        color: _isHodEditing ? AppColors.primary.withValues(alpha: 0.02) : Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              slot.subjectName,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Color(0xFF0F172A),
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              slot.teacherName,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Color(0xFF64748B),
                fontSize: 11,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildScrollIndicator() {
    return Container(
      width: 150,
      height: 6,
      decoration: BoxDecoration(
        color: const Color(0xFFE2E8F0),
        borderRadius: BorderRadius.circular(3),
      ),
      child: Stack(
        children: [
          LayoutBuilder(
            builder: (context, constraints) {
              final trackWidth = constraints.maxWidth;
              final thumbWidth = trackWidth * 0.4;
              final maxOffset = trackWidth - thumbWidth;
              final offset = _scrollProgress * maxOffset;
              return Positioned(
                left: offset,
                top: 0,
                bottom: 0,
                child: Container(
                  width: thumbWidth,
                  decoration: BoxDecoration(
                    color: const Color(0xFF64748B),
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  // Modal overlay to edit slot details
  void _showEditModal(TimetableSlot slot) {
    final TextEditingController subjectController = TextEditingController(text: slot.subjectName);
    String selectedTeacher = slot.teacherName;

    // Standard available teachers
    final List<String> teachers = [
      "Anju miss",
      "Anu miss",
      "Rijina miss",
      "Ms Sheethal",
      "Sheetal miss",
      "Deepa miss",
      "Manju miss",
    ];
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
                "Class: ${slot.classId}  |  Period: ${slot.id.split('_').last}",
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
