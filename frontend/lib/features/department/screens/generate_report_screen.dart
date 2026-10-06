import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

//Design
import 'package:fahhhh/core/theme_data/app_colors.dart';
import 'package:fahhhh/core/theme_data/app_radius.dart';
import 'package:fahhhh/core/theme_data/app_text_styles.dart';
import 'package:fahhhh/core/widgets/app_back_header.dart';
import 'package:fahhhh/core/widgets/app_screen_scaffold.dart';

//Widgets
import 'package:fahhhh/features/department/widgets/attendance_chart.dart';
import 'package:fahhhh/features/department/widgets/app_search_bar.dart';
import 'package:fahhhh/features/department/widgets/sort_dropdown.dart';
import 'package:fahhhh/features/department/widgets/student_list_tile.dart';
import 'package:fahhhh/features/department/widgets/attendance_percentage_badge.dart';

//Models
import 'package:fahhhh/features/department/models/department_student.dart';

//Providers
import 'package:fahhhh/features/auth/providers/auth_provider.dart';
import 'package:fahhhh/features/timetable/providers/timetable_provider.dart';
import 'package:fahhhh/features/department/providers/department_provider.dart';

/// Attendance report: month selector, average-attendance chart, preview/download
/// actions and a searchable roster where every student ends in a percentage
/// badge. Pushed from the My Class "More" menu (hides bottom navigation).
class GenerateReportScreen extends ConsumerStatefulWidget {
  const GenerateReportScreen({super.key});

  @override
  ConsumerState<GenerateReportScreen> createState() =>
      _GenerateReportScreenState();
}

class _GenerateReportScreenState extends ConsumerState<GenerateReportScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _query = '';
  late String _selectedMonth;

  static const List<String> _monthNames = [
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

  List<String> get _months {
    final year = DateTime.now().year;
    return _monthNames.map((name) => '$name $year').toList();
  }

  // Deterministic mock percentages until report data is wired to the backend.
  static const List<int> _percentPattern = [
    95, 65, 88, 72, 90, 68, 85, 78, 92, 60, 82, 74,
  ];

  String _sortOption = 'Roll No';

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _selectedMonth = '${_monthNames[now.month - 1]} ${now.year}';
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authProvider).user;
    final classId = user?.assignedClassId ?? user?.className ?? 'S2 BCA';

    final studentsAsync = ref.watch(departmentStudentsProvider(null));
    final List<_ReportEntry> students = studentsAsync.maybeWhen(
      data: (list) {
        if (list.isNotEmpty) {
          return List.generate(list.length, (index) {
            return _ReportEntry(
              student: list[index],
              percent: _percentPattern[index % _percentPattern.length],
            );
          });
        }
        return _buildStudents(classId);
      },
      orElse: () => _buildStudents(classId),
    );
    final query = _query.trim().toLowerCase();
    final visible = students
        .where((s) =>
            query.isEmpty ||
            s.student.name.toLowerCase().contains(query) ||
            s.student.rollNumber.toLowerCase().contains(query))
        .toList();

    switch (_sortOption) {
      case 'Highest':
        visible.sort((a, b) => b.percent.compareTo(a.percent));
      case 'Lowest':
        visible.sort((a, b) => a.percent.compareTo(b.percent));
      default: // 'Roll No'
        visible.sort((a, b) => a.student.rollNumber.compareTo(b.student.rollNumber));
    }

    return Scaffold(
      body: AppScreenScaffold(
        child: Column(
          children: [
            const SizedBox(height: 8),
            AppBackHeader(
              title: 'Attendance Report',
              subtitle: 'View Attendance Analysis',
              onBack: () {
                if (context.mounted) context.pop();
              },
              padding: const EdgeInsets.symmetric(horizontal: 20),
            ),
            const SizedBox(height: 14),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 26),
              child: Align(
                alignment: Alignment.centerLeft,
                child: _MonthSelector(
                  months: _months,
                  selected: _selectedMonth,
                  onSelected: (month) =>
                      setState(() => _selectedMonth = month),
                ),
              ),
            ),
            const SizedBox(height: 14),
            const AttendanceChart(),
            const SizedBox(height: 14),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 26),
              child: Row(
                children: [
                  Expanded(
                    child: _ReportActionButton(
                      icon: Icons.visibility_outlined,
                      label: 'Show Preview',
                      onTap: () => _notify('Preview generated'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _ReportActionButton(
                      icon: Icons.file_download_outlined,
                      label: 'Download',
                      onTap: () => _notify('Report downloaded'),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 34),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Based on week , month & Overall',
                  style: AppTextStyles.small.copyWith(fontSize: 15.7),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                children: [
                  Expanded(
                    child: AppSearchBar(
                      controller: _searchController,
                      onChanged: (value) => setState(() => _query = value),
                    ),
                  ),
                  const SizedBox(width: 10),
                  SortDropdown(
                    value: _sortOption,
                    onChanged: (value) => setState(() => _sortOption = value),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 6),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.only(top: 4, bottom: 40),
                itemCount: visible.length,
                itemBuilder: (context, index) {
                  final entry = visible[index];
                  return StudentListTile(
                    student: entry.student,
                    trailing:
                        AttendancePercentageBadge(percent: entry.percent),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _notify(String message) {
    if (!context.mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text('$message · $_selectedMonth')));
  }

  List<_ReportEntry> _buildStudents(String classId) {
    final raw = getStudentsForClass(classId);
    return List.generate(raw.length, (index) {
      final student = raw[index];
      return _ReportEntry(
        student: DepartmentStudent(
          name: student.name,
          rollNumber: student.rollNumber,
        ),
        percent: _percentPattern[index % _percentPattern.length],
      );
    });
  }
}

class _ReportEntry {
  final DepartmentStudent student;
  final int percent;

  const _ReportEntry({required this.student, required this.percent});
}

/// White pill month picker: calendar icon, selected month and a dropdown chevron.
class _MonthSelector extends StatelessWidget {
  final List<String> months;
  final String selected;
  final ValueChanged<String> onSelected;

  const _MonthSelector({
    required this.months,
    required this.selected,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      onSelected: onSelected,
      offset: const Offset(0, 46),
      color: AppColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.medium),
      ),
      itemBuilder: (context) => months
          .map(
            (month) => PopupMenuItem<String>(
              value: month,
              child: Text(
                month,
                style: AppTextStyles.sfPRO.copyWith(
                  fontSize: 14,
                  fontWeight: month == selected
                      ? FontWeight.w600
                      : FontWeight.w500,
                  color: month == selected
                      ? AppColors.primary
                      : AppColors.headingText,
                ),
              ),
            ),
          )
          .toList(),
      child: Container(
        height: 34,
        padding: const EdgeInsets.symmetric(horizontal: 14),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: AppColors.outline, width: 1),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.calendar_month_outlined,
              size: 18,
              color: AppColors.headingText,
            ),
            const SizedBox(width: 8),
            Text(
              selected,
              style: AppTextStyles.sfPRO.copyWith(
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(width: 6),
            const Icon(
              Icons.keyboard_arrow_down_rounded,
              size: 20,
              color: AppColors.headingText,
            ),
          ],
        ),
      ),
    );
  }
}

/// White outlined pill action (Show Preview / Download) that fills its slot
/// and centers its icon + label.
class _ReportActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback? onTap;

  const _ReportActionButton({
    required this.icon,
    required this.label,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 30,
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: AppColors.outline, width: 0.8),
          boxShadow: const [
            BoxShadow(
              color: AppColors.controlShadow,
              blurRadius: 4,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 16, color: AppColors.headingText),
            const SizedBox(width: 6),
            Text(
              label,
              style: AppTextStyles.heading.copyWith(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
