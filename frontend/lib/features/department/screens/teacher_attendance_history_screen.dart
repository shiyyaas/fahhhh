import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:fahhhh/core/widgets/app_back_header.dart';
import 'package:fahhhh/core/theme_data/app_colors.dart';
import 'package:fahhhh/core/theme_data/app_text_styles.dart';
import 'package:fahhhh/core/theme_data/app_radius.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/department_provider.dart';
import '../models/department_student.dart';
import '../models/department_subject.dart';

/// One student's attendance for the selected day.
class StudentAttendance {
  final String name;
  final String rollNumber;
  final Map<String, String> subjects; // subject -> status (a/p/l)

  StudentAttendance(this.name, this.rollNumber, this.subjects);
}

class TeacherAttendanceHistoryScreen extends ConsumerStatefulWidget {
  const TeacherAttendanceHistoryScreen({super.key});

  @override
  ConsumerState<TeacherAttendanceHistoryScreen> createState() =>
      _TeacherAttendanceHistoryScreenState();
}

class _TeacherAttendanceHistoryScreenState
    extends ConsumerState<TeacherAttendanceHistoryScreen> {
  static const List<String> _subjectNames = [
    'PYTHON',
    'SOFTWARE ENG.',
    'MATHS',
    'SE',
    'DS',
    'DBMS',
  ];

  // Cycle: absent -> present -> late -> absent.
  static const List<String> _statusCycle = ['a', 'p', 'l'];

  late DateTime _selectedDate;
  List<StudentAttendance> _attendanceData = [];
  bool _dataInitialized = false;
  final TextEditingController _searchController = TextEditingController();
  String _query = '';
  String _sort = 'sort_default';
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    _selectedDate = DateTime.now();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _populateFromLive(List<DepartmentStudent> students, List<DepartmentSubject> subjects) {
    if (_dataInitialized || students.isEmpty) return;
    final subjectList = subjects.isNotEmpty
        ? subjects.map((s) => s.name).toList()
        : _subjectNames;
    _attendanceData = students.map((s) {
      return StudentAttendance(
        s.name,
        s.rollNumber,
        {
          for (final sub in subjectList)
            sub: 'p',
        },
      );
    }).toList();
    _dataInitialized = true;
  }

  // Commented out fallback mock data generator:
  // List<StudentAttendance> _generateMockData() {
  //   const names = [
  //     'Shiyas', 'Anjali', 'Rahul', 'Meera', 'Kiran', 'Priya',
  //     'Vishnu', 'Sneha', 'Arjun', 'Kavya', 'Ravi', 'Sara',
  //     'John', 'Alice', 'Bob',
  //   ];
  //   final random = Random(DateTime.now().day);
  //   return List.generate(15, (i) {
  //     return StudentAttendance(
  //       names[i % names.length],
  //       '${i + 1}',
  //       {
  //         for (final s in _subjectNames)
  //           s: _statusCycle[random.nextInt(_statusCycle.length)],
  //       },
  //     );
  //   });
  // }

  void _toggleStatus(int studentIndex, String subject) {
    final student = _attendanceData[studentIndex];
    final current = student.subjects[subject]!;
    student.subjects[subject] =
        _statusCycle[(_statusCycle.indexOf(current) + 1) % _statusCycle.length];
    setState(() {});
  }

  void _onSave() {
    setState(() => _isEditing = false);
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(now.year, now.month - 2),
      lastDate: now,
      helpText: 'Select attendance date',
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.light(
            primary: AppColors.primary,
            onPrimary: Colors.white,
            surface: AppColors.surface,
            onSurface: AppColors.headingText,
          ),
        ),
        child: child!,
      ),
    );
    if (picked == null) return;
    setState(() => _selectedDate = picked);
  }

  @override
  Widget build(BuildContext context) {
    final students = ref.watch(departmentStudentsProvider(null)).value ?? [];
    final subjects = ref.watch(departmentSubjectsProvider).value ?? [];
    _populateFromLive(students, subjects);

    final query = _query.trim().toLowerCase();
    final indexes = [
      for (var i = 0; i < _attendanceData.length; i++)
        if (query.isEmpty ||
            _attendanceData[i].name.toLowerCase().contains(query))
          i,
    ];

    if (_sort == 'sort_name_asc') {
      indexes.sort((a, b) => _attendanceData[a].name.compareTo(_attendanceData[b].name));
    } else if (_sort == 'sort_name_desc') {
      indexes.sort((a, b) => _attendanceData[b].name.compareTo(_attendanceData[a].name));
    }

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            AppBackHeader(
              title: 'Attendance History',
              subtitle: 'View past attendance here',
              onBack: () => context.pop(),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
              child: Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: _ActionPill(
                      icon: Icons.calendar_today,
                      label:
                          '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
                      onTap: _pickDate,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    flex: 1,
                    child: _ActionPill(
                      icon: _isEditing
                          ? Icons.save_outlined
                          : Icons.edit_outlined,
                      label: _isEditing ? 'Save' : 'Edit',
                      filled: _isEditing,
                      onTap: _isEditing
                          ? _onSave
                          : () => setState(() => _isEditing = true),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
              child: Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: TextField(
                      controller: _searchController,
                      onChanged: (value) => setState(() => _query = value),
                      decoration: InputDecoration(
                        prefixIcon: const Icon(Icons.search, size: 18),
                        hintText: 'Search',
                        hintStyle: AppTextStyles.small,
                        contentPadding:
                            const EdgeInsets.symmetric(vertical: 10),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(AppRadius.pill),
                          borderSide: BorderSide(
                            color: AppColors.outline,
                            width: 1,
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(AppRadius.pill),
                          borderSide: BorderSide(
                            color: AppColors.outline,
                            width: 1,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(AppRadius.pill),
                          borderSide: BorderSide(
                            color: AppColors.primary,
                            width: 1,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    flex: 2,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(AppRadius.pill),
                        border: Border.all(color: AppColors.outline, width: 1),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: _sort,
                          isExpanded: true,
                          items: const [
                            DropdownMenuItem(
                              value: 'sort_default',
                              child: Text('Sort by'),
                            ),
                            DropdownMenuItem(
                              value: 'sort_name_asc',
                              child: Text('Name (A-Z)'),
                            ),
                            DropdownMenuItem(
                              value: 'sort_name_desc',
                              child: Text('Name (Z-A)'),
                            ),
                          ],
                          onChanged: (val) => setState(() => _sort = val ?? 'sort_default'),
                          style: AppTextStyles.body,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Container(
                margin:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(AppRadius.card),
                  border: Border.all(color: AppColors.outline, width: 1),
                ),
                child: SingleChildScrollView(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        child: Row(
                          children: [
                            _headerCell('NO', 44),
                            _headerCell('NAME', 80),
                            for (final s in _subjectNames)
                              _headerCell(s, 68),
                          ],
                        ),
                      ),
                      const Divider(height: 1, color: AppColors.outline),
                      for (final idx in indexes)
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                          child: Row(
                            children: [
                              SizedBox(
                                width: 44,
                                child: Text(
                                  _attendanceData[idx].rollNumber,
                                  style: AppTextStyles.body.copyWith(
                                    fontWeight: FontWeight.w500,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ),
                              SizedBox(
                                width: 80,
                                child: Text(
                                  _attendanceData[idx].name,
                                  style: AppTextStyles.body.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              for (final s in _subjectNames)
                                SizedBox(
                                  width: 68,
                                  child: Center(
                                    child: _StatusCell(
                                      status:
                                          _attendanceData[idx].subjects[s]!,
                                      onTap: _isEditing
                                          ? () => _toggleStatus(idx, s)
                                          : null,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _headerCell(String text, double width) {
    return SizedBox(
      width: width,
      child: Text(
        text,
        style: AppTextStyles.body.copyWith(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: AppColors.headingText,
        ),
        overflow: TextOverflow.ellipsis,
      ),
    );
  }
}

/// Pill-shaped outlined (or filled) action button.
class _ActionPill extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool filled;
  final VoidCallback? onTap;

  const _ActionPill({
    required this.icon,
    required this.label,
    this.filled = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.pill),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: filled ? AppColors.primary : AppColors.surface,
            borderRadius: BorderRadius.circular(AppRadius.pill),
            border: Border.all(
              color: filled ? AppColors.primary : AppColors.outline,
              width: 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 16,
                color: filled ? Colors.white : AppColors.headingText,
              ),
              const SizedBox(width: 6),
              Text(
                label,
                style: AppTextStyles.body.copyWith(
                  fontWeight: FontWeight.w500,
                  fontSize: 14,
                  color: filled ? Colors.white : AppColors.headingText,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// 32x32 rounded status cell: p = present, l = late, a = absent.
class _StatusCell extends StatelessWidget {
  final String status;
  final VoidCallback? onTap;

  const _StatusCell({required this.status, this.onTap});

  @override
  Widget build(BuildContext context) {
    final (Color bg, Color fg) = switch (status) {
      'p' => (
          AppColors.secondary.withValues(alpha: 0.5),
          const Color(0xFF1D71B8)
        ),
      'l' => (
          AppColors.warning.withValues(alpha: 0.5),
          const Color(0xFF79630B)
        ),
      _ => (
          const Color(0xFFFFDAD6).withValues(alpha: 0.5),
          const Color(0xFF93000A)
        ),
    };
    final cell = Container(
      width: 32,
      height: 32,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(AppRadius.small),
        border: Border.all(
          color: AppColors.outline.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Text(
        status,
        style: AppTextStyles.body.copyWith(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: fg,
        ),
      ),
    );
    if (onTap == null) return cell;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.small),
        child: cell,
      ),
    );
  }
}
