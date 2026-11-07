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
import 'package:fahhhh/features/department/widgets/app_search_bar.dart';
import 'package:fahhhh/features/department/widgets/sort_dropdown.dart';
import 'package:fahhhh/features/department/widgets/condonation_percentage_badge.dart';
import 'package:fahhhh/features/department/widgets/student_list_tile.dart';

//Models
import 'package:fahhhh/features/department/models/department_student.dart';
import 'package:fahhhh/features/department/models/department_class.dart';

//Providers
import 'package:fahhhh/features/auth/providers/auth_provider.dart';
import 'package:fahhhh/features/department/providers/department_provider.dart';

// Packages
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:printing/printing.dart';

/// Condonation Report: a searchable roster of students whose sessions have
/// been condoned, each row ending in an attendance-percentage pill.
class CondonationScreen extends ConsumerStatefulWidget {
  const CondonationScreen({super.key});

  @override
  ConsumerState<CondonationScreen> createState() => _CondonationScreenState();
}

class _CondonationScreenState extends ConsumerState<CondonationScreen> {
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

    final defaultersAsync = ref.watch(defaultersProvider);
    final List<_CondonationEntry> students = defaultersAsync.maybeWhen(
      data: (defaulters) {
        return defaulters.map((d) {
          final percent = double.tryParse(d['attendancePercentage']?.toString() ?? '0')?.round() ?? 0;
          return _CondonationEntry(
            student: DepartmentStudent(
              id: d['studentId']?.toString(),
              name: d['studentName']?.toString() ?? 'Student',
              rollNumber: d['registerNo']?.toString() ?? '',
            ),
            percent: percent,
          );
        }).toList();
      },
      orElse: () => const [],
    );
    final query = _query.trim().toLowerCase();
    var visible = students
        .where((s) =>
            query.isEmpty ||
            s.student.name.toLowerCase().contains(query) ||
            s.student.rollNumber.toLowerCase().contains(query))
        .toList();

    visible = _sort(visible, _sortOption);

    return Scaffold(
      body: AppScreenScaffold(
        child: Column(
          children: [
            const SizedBox(height: 8),
            AppBackHeader(
              title: 'Condonation Report',
              subtitle: 'View List of Students with Condonation.',
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
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 26),
              child: Row(
                children: [
                  Expanded(
                    child: _ReportActionButton(
                      icon: Icons.visibility_outlined,
                      label: 'Show Preview',
                      onTap: () async {
                        try {
                          final repo = ref.read(departmentRepositoryProvider);
                          final batches = await repo.getClasses();
                          final matchingBatch = batches.firstWhere(
                            (b) => b.id == classId || b.name.toLowerCase() == classId.toLowerCase(),
                            orElse: () => batches.isNotEmpty ? batches.first : const DepartmentClass(name: 'default', classTeacher: '', attendancePercent: 0),
                          );
                          final batchId = matchingBatch.id ?? classId;
                          final batchName = matchingBatch.name;
                          if (!context.mounted) return;
                          _showCustomPreviewDialog(context, ref, batchId, batchName);
                        } catch (e) {
                          if (!context.mounted) return;
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Preview error: $e'), backgroundColor: AppColors.danger),
                          );
                        }
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _ReportActionButton(
                      icon: Icons.file_download_outlined,
                      label: 'Download',
                      onTap: () async {
                        try {
                          final repo = ref.read(departmentRepositoryProvider);
                          final batches = await repo.getClasses();
                          final matchingBatch = batches.firstWhere(
                            (b) => b.id == classId || b.name.toLowerCase() == classId.toLowerCase(),
                            orElse: () => batches.isNotEmpty ? batches.first : const DepartmentClass(name: 'default', classTeacher: '', attendancePercent: 0),
                          );
                          final batchId = matchingBatch.id ?? classId;
                          final now = DateTime.now();
                          final monthIdx = _monthNames.indexOf(_selectedMonth.split(' ').first) + 1;
                          final month = monthIdx > 0 ? monthIdx : now.month;
                          final year = now.year;

                          final bytes = await repo.getBatchMonthlyPdfBytes(batchId, month, year);
                          final dir = await getApplicationDocumentsDirectory();
                          final fileName = 'Condonation_Report_${_selectedMonth.replaceAll(' ', '_')}.pdf';
                          final file = File('${dir.path}/$fileName');
                          await file.writeAsBytes(bytes);

                          if (!context.mounted) return;
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Downloaded to ${file.path}'),
                              action: SnackBarAction(
                                label: 'Open',
                                onPressed: () {
                                  Printing.sharePdf(bytes: bytes, filename: fileName);
                                },
                              ),
                            ),
                          );

                          await Printing.sharePdf(bytes: bytes, filename: fileName);
                        } catch (e) {
                          if (!context.mounted) return;
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Download error: $e'), backgroundColor: AppColors.danger),
                          );
                        }
                      },
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
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
              child: visible.isEmpty
                  ? const _EmptyState()
                  : ListView.builder(
                      padding: const EdgeInsets.only(top: 4, bottom: 40),
                      itemCount: visible.length,
                      itemBuilder: (context, index) {
                        final entry = visible[index];
                        return StudentListTile(
                          student: entry.student,
                          trailing:
                              CondonationPercentageBadge(percent: entry.percent),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  void _showCustomPreviewDialog(BuildContext context, WidgetRef ref, String batchId, String batchName) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator(color: AppColors.primary)),
    );

    try {
      final repo = ref.read(departmentRepositoryProvider);
      final now = DateTime.now();
      final monthIdx = _monthNames.indexOf(_selectedMonth.split(' ').first) + 1;
      final month = monthIdx > 0 ? monthIdx : now.month;
      final year = now.year;

      final bytes = await repo.getBatchMonthlyPdfBytes(batchId, month, year);

      if (!context.mounted) return;
      Navigator.pop(context); // pop loading

      showDialog(
        context: context,
        barrierDismissible: true,
        barrierColor: Colors.black54,
        builder: (context) => Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          child: Container(
            width: 700,
            height: MediaQuery.of(context).size.height * 0.85,
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: AppColors.outline, width: 1.5),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 16,
                  offset: Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              children: [
                const SizedBox(height: 16),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Condonation Report Preview',
                            style: AppTextStyles.heading.copyWith(fontSize: 18, fontWeight: FontWeight.w700),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '$batchName · $_selectedMonth',
                            style: AppTextStyles.small.copyWith(color: AppColors.textSecondary),
                          ),
                        ],
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, color: AppColors.headingText),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                ),
                const Divider(height: 24, thickness: 1, color: AppColors.outline),
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: PdfPreview(
                        build: (format) async => bytes,
                        canChangeOrientation: false,
                        canChangePageFormat: false,
                        canDebug: false,
                        allowPrinting: false,
                        allowSharing: false,
                        maxPageWidth: 700,
                        pdfFileName: 'Condonation_Report_${_selectedMonth.replaceAll(' ', '_')}.pdf',
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(24),
                  child: SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppRadius.medium),
                          side: const BorderSide(color: AppColors.outline, width: 1),
                        ),
                      ),
                      onPressed: () async {
                        try {
                          final dir = await getApplicationDocumentsDirectory();
                          final fileName = 'Condonation_Report_${_selectedMonth.replaceAll(' ', '_')}.pdf';
                          final file = File('${dir.path}/$fileName');
                          await file.writeAsBytes(bytes);

                          if (!context.mounted) return;
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Downloaded to ${file.path}'),
                              backgroundColor: AppColors.success,
                            ),
                          );
                          await Printing.sharePdf(bytes: bytes, filename: fileName);
                        } catch (e) {
                          if (!context.mounted) return;
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Download error: $e'), backgroundColor: AppColors.danger),
                          );
                        }
                      },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.file_download_outlined, color: Colors.white, size: 20),
                          const SizedBox(width: 8),
                          Text(
                            'Download PDF',
                            style: AppTextStyles.heading.copyWith(color: Colors.white, fontSize: 15),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    } catch (e) {
      if (!context.mounted) return;
      Navigator.pop(context); // pop loading
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Preview error: $e'), backgroundColor: AppColors.danger),
      );
    }
  }

  List<_CondonationEntry> _sort(
      List<_CondonationEntry> entries, String option) {
    final sorted = List<_CondonationEntry>.from(entries);
    switch (option) {
      case 'Highest':
        sorted.sort((a, b) => b.percent.compareTo(a.percent));
      case 'Lowest':
        sorted.sort((a, b) => a.percent.compareTo(b.percent));
      default:
        // 'Roll No' — keep natural order.
    }
    return sorted;
  }
}

class _CondonationEntry {
  final DepartmentStudent student;
  final int percent;

  const _CondonationEntry({required this.student, required this.percent});
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

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        'No students with condonation',
        style: AppTextStyles.small.copyWith(fontSize: 15),
      ),
    );
  }
}
