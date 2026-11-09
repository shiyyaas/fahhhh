import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

//Design
import 'package:fahhhh/core/theme_data/app_colors.dart';
import 'package:fahhhh/core/theme_data/app_radius.dart';
import 'package:fahhhh/core/theme_data/app_text_styles.dart';

//Widgets
import 'package:fahhhh/features/department/widgets/attendance_chart.dart';
import 'package:fahhhh/features/department/widgets/app_search_bar.dart';
import 'package:fahhhh/features/department/widgets/sort_dropdown.dart';
import '../../../core/widgets/app_back_header.dart';
import '../../../core/widgets/app_screen_scaffold.dart';
import 'package:fahhhh/features/department/widgets/student_list_tile.dart';

//Models
import 'package:fahhhh/features/department/models/department_student.dart';
import 'package:fahhhh/features/department/models/department_subject.dart';

//Providers
import 'package:fahhhh/features/department/providers/department_provider.dart';

// Packages
import 'dart:io';
import 'dart:typed_data';
import 'package:path_provider/path_provider.dart';
import 'package:printing/printing.dart';

/// Subject details screen: month selector, attendance chart, preview/download
/// buttons and the student list for a subject. Opened by pushing to
/// /subject-details/:subjectName/:className (hides bottom nav).
class SubjectDetailsScreen extends ConsumerStatefulWidget {
  final String subjectName;
  final String className;
  final String? subjectId;

  const SubjectDetailsScreen({
    super.key,
    required this.subjectName,
    required this.className,
    this.subjectId,
  });

  @override
  ConsumerState<SubjectDetailsScreen> createState() =>
      _SubjectDetailsScreenState();
}

class _SubjectDetailsScreenState extends ConsumerState<SubjectDetailsScreen> {
  int _month = DateTime.now().month;
  final TextEditingController _searchController = TextEditingController();
  String _query = '';
  String _sortOption = 'Roll No';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  static const List<String> _months = [
    'January', 'February', 'March', 'April', 'May', 'June', 'July',
    'August', 'September', 'October', 'November', 'December',
  ];

  List<DepartmentStudent> get _students {
    final studentsAsync = ref.watch(departmentStudentsProvider(widget.className));
    return studentsAsync.value ?? [];
  }

  @override
  Widget build(BuildContext context) {
    final rawStudents = _students;
    final query = _query.trim().toLowerCase();
    final students = rawStudents
        .where((s) =>
            query.isEmpty ||
            s.name.toLowerCase().contains(query) ||
            s.rollNumber.toLowerCase().contains(query))
        .toList();

    switch (_sortOption) {
      case 'Highest':
        students.sort((a, b) => a.name.compareTo(b.name));
      case 'Lowest':
        students.sort((a, b) => b.name.compareTo(a.name));
      default: // 'Roll No'
        students.sort((a, b) => a.rollNumber.compareTo(b.rollNumber));
    }

    return Scaffold(
      body: AppScreenScaffold(
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(bottom: 40),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 8),
              AppBackHeader(
                title: widget.subjectName,
                subtitle: widget.className,
                onBack: () => context.pop(),
                padding: const EdgeInsets.symmetric(horizontal: 20),
              ),
              const SizedBox(height: 10),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 29),
                child: Text(
                  'View Attendance Analysis',
                  style: AppTextStyles.small.copyWith(fontSize: 17.7),
                ),
              ),
              const SizedBox(height: 8),
              _MonthSelector(
                month: _months[_month - 1],
                onPrevious: () => setState(
                  () => _month = _month > 1 ? _month - 1 : 12,
                ),
                onNext: () => setState(
                  () => _month = _month < 12 ? _month + 1 : 1,
                ),
              ),
              const SizedBox(height: 14),
              const AttendanceChart(),
              const SizedBox(height: 10),
              _PreviewDownloadRow(
                onPreview: () => _handleAction(context, ref, isPreview: true),
                onDownload: () => _handleAction(context, ref, isPreview: false),
              ),
              const SizedBox(height: 2),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 27),
                child: Text(
                  'Based on week , month & Overall',
                  style: AppTextStyles.small.copyWith(fontSize: 15.7),
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
                        onChanged: (val) => setState(() => _query = val),
                      ),
                    ),
                    const SizedBox(width: 10),
                    SortDropdown(
                      value: _sortOption,
                      onChanged: (val) => setState(() => _sortOption = val),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 6),
              for (final student in students)
                StudentListTile(
                  student: student,
                  onTap: () {
                    if (!context.mounted) return;
                    context.push(
                      '/student-profile/${Uri.encodeComponent(widget.className)}/'
                      '${Uri.encodeComponent(student.rollNumber)}/'
                      '${Uri.encodeComponent(student.name)}'
                      '?avatar=${Uri.encodeComponent(student.avatar ?? '')}',
                    );
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _handleAction(BuildContext context, WidgetRef ref, {required bool isPreview}) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator(color: AppColors.primary)),
    );

    try {
      final repo = ref.read(departmentRepositoryProvider);

      // Use passed subjectId if available, otherwise look it up
      String? subjectId = widget.subjectId;
      if (subjectId == null || subjectId.isEmpty) {
        final subjects = await repo.getSubjects();
        final matchingSubject = subjects.firstWhere(
          (s) => s.name.toLowerCase() == widget.subjectName.toLowerCase(),
          orElse: () => const DepartmentSubject(id: '', name: '', teacher: '', rollNumber: '', attendancePercent: 0),
        );
        subjectId = matchingSubject.id;
      }

      if (subjectId == null || subjectId.isEmpty) {
        throw Exception('Subject ID not found for ${widget.subjectName}');
      }

      final bytes = await repo.getSubjectReportPdfBytes(subjectId);

      if (!context.mounted) return;
      Navigator.pop(context); // pop loading

      if (isPreview) {
        _showPreviewDialog(context, bytes);
      } else {
        await _downloadPdf(context, bytes);
      }
    } catch (e) {
      if (!context.mounted) return;
      Navigator.pop(context); // pop loading
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e'), backgroundColor: AppColors.danger),
      );
    }
  }

  void _showPreviewDialog(BuildContext context, Uint8List bytes) {
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
                          'Subject Attendance Preview',
                          style: AppTextStyles.heading.copyWith(fontSize: 18, fontWeight: FontWeight.w700),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${widget.subjectName} · ${widget.className}',
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
                      pdfFileName: '${widget.subjectName}-attendance.pdf',
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
                    onPressed: () => _downloadPdf(context, bytes),
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
  }

  Future<void> _downloadPdf(BuildContext context, Uint8List bytes) async {
    try {
      final dir = await getApplicationDocumentsDirectory();
      final fileName = '${widget.subjectName.replaceAll(' ', '_')}_attendance.pdf';
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
  }
}

class _MonthSelector extends StatelessWidget {
  final String month;
  final VoidCallback onPrevious;
  final VoidCallback onNext;

  const _MonthSelector({
    required this.month,
    required this.onPrevious,
    required this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 35,
      margin: const EdgeInsets.symmetric(horizontal: 24),
      padding: const EdgeInsets.symmetric(horizontal: 24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFF121212), width: 1),
        boxShadow: const [
          BoxShadow(
            color: AppColors.controlShadow,
            blurRadius: 1.4,
            offset: Offset(0, 1),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          GestureDetector(
            onTap: onPrevious,
            child: const Icon(
              Icons.chevron_left,
              size: 16,
              color: Colors.black87,
            ),
          ),
          Text(
            '$month 2026',
            style: AppTextStyles.heading.copyWith(
              fontSize: 14.7,
              fontWeight: FontWeight.w600,
            ),
          ),
          GestureDetector(
            onTap: onNext,
            child: const Icon(
              Icons.chevron_right,
              size: 16,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }
}

class _PreviewDownloadRow extends StatelessWidget {
  final VoidCallback? onPreview;
  final VoidCallback? onDownload;
  const _PreviewDownloadRow({this.onPreview, this.onDownload});

  Widget _button(BuildContext context, String label, {VoidCallback? onTap, required IconData icon}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 30,
        padding: const EdgeInsets.symmetric(horizontal: 14),
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

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 26),
      child: Row(
        children: [
          Expanded(
            child: _button(context, 'Show Preview', onTap: onPreview, icon: Icons.visibility_outlined),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _button(context, 'Download', onTap: onDownload, icon: Icons.file_download_outlined),
          ),
        ],
      ),
    );
  }
}
