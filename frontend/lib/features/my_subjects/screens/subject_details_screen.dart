import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

//Design
import 'package:fahhhh/core/theme_data/app_text_styles.dart';

//Widgets
import 'package:fahhhh/features/department/widgets/attendance_chart.dart';
import 'package:fahhhh/features/department/widgets/search_sort_bar.dart';
import 'package:fahhhh/features/department/widgets/student_list_tile.dart';

//Models
import 'package:fahhhh/features/department/models/department_student.dart';

//Providers
import 'package:fahhhh/features/timetable/providers/timetable_provider.dart';

/// Subject details screen: month selector, attendance chart, preview/download
/// buttons and the student list for a subject. Opened by pushing to
/// /subject-details/:subjectName/:classId (hides bottom nav).
class SubjectDetailsScreen extends ConsumerStatefulWidget {
  final String subjectName;
  final String className;

  const SubjectDetailsScreen({
    super.key,
    required this.subjectName,
    required this.className,
  });

  @override
  ConsumerState<SubjectDetailsScreen> createState() =>
      _SubjectDetailsScreenState();
}

class _SubjectDetailsScreenState extends ConsumerState<SubjectDetailsScreen> {
  int _month = 3; // start at March like the design
  bool _showPreview = false;

  static const List<String> _months = [
    'January', 'February', 'March', 'April', 'May', 'June', 'July',
    'August', 'September', 'October', 'November', 'December',
  ];

  static const List<int> _attendancePattern = [
    95, 82, 90, 65, 88, 74, 95, 78, 85, 70, 92, 80, 66,
  ];

  List<DepartmentStudent> get _students {
    final raw = getStudentsForClass(widget.className);
    return List.generate(raw.length, (index) {
      final student = raw[index];
      return DepartmentStudent(
        name: student.name,
        rollNumber: student.rollNumber,
        attendancePercent:
            _attendancePattern[index % _attendancePattern.length],
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    // Build the student list once for both the view and the header count.
    final students = _students;

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
          child: Stack(
            children: [
              SingleChildScrollView(
                padding: const EdgeInsets.only(bottom: 40),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 8),
                    _SubjectHeader(
                      subjectName: widget.subjectName,
                      className: widget.className,
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
                      onPreview: () => setState(() => _showPreview = true),
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
                    const SearchSortBar(),
                    const SizedBox(height: 6),
                    for (final student in students)
                      StudentListTile(
                        student: student,
                        onTap: () {
                          if (!context.mounted) return;
                          context.push(
                            '/student-profile/${Uri.encodeComponent(widget.className)}/'
                            '${Uri.encodeComponent(student.rollNumber)}/'
                            '${Uri.encodeComponent(student.name)}',
                          );
                        },
                      ),
                  ],
                ),
              ),
              if (_showPreview)
                _PreviewOverlay(
                  subjectName: widget.subjectName,
                  className: widget.className,
                  onDismiss: () => setState(() => _showPreview = false),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SubjectHeader extends StatelessWidget {
  final String subjectName;
  final String className;
  const _SubjectHeader({
    required this.subjectName,
    required this.className,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          IconButton(
            onPressed: () {
              if (context.mounted) context.pop();
            },
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(
              minWidth: 26,
              minHeight: 26,
            ),
            icon: const Icon(Icons.arrow_back, size: 26),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  subjectName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.heading.copyWith(fontSize: 25),
                ),
                const SizedBox(height: 1),
                Text(
                  className,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.small.copyWith(fontSize: 17.7),
                ),
              ],
            ),
          ),
        ],
      ),
    );
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
            color: Color(0x1A000000),
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
  const _PreviewDownloadRow({this.onPreview});

  Widget _button(BuildContext context, String label, {VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 168,
        height: 29,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(1061),
          border: Border.all(color: Colors.black, width: 1),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.15),
              blurRadius: 1.5,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Center(
          child: ShaderMask(
            shaderCallback: (bounds) => const LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Colors.black, Color(0xFF666666)],
            ).createShader(bounds),
            child: Text(
              label,
              style: TextStyle(
                fontSize: 12.8,
                fontWeight: FontWeight.w500,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 29),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _button(context, 'Show Preview', onTap: onPreview),
          _button(context, 'Download'),
        ],
      ),
    );
  }
}

/// Full-screen scrim with a centered report preview card.
class _PreviewOverlay extends StatelessWidget {
  final String subjectName;
  final String className;
  final VoidCallback onDismiss;

  const _PreviewOverlay({
    required this.subjectName,
    required this.className,
    required this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: GestureDetector(
        onTap: onDismiss,
        child: Container(
          color: const Color(0x804C4747),
          child: Center(
            child: Container(
              width: 362,
              height: 468,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(11),
                border: Border.all(color: Colors.black, width: 1),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    subjectName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.heading.copyWith(
                      fontSize: 22,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    className,
                    style: AppTextStyles.small.copyWith(fontSize: 15),
                  ),
                  const SizedBox(height: 16),
                  const AttendanceChart(),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Present',
                        style: AppTextStyles.sfPRO.copyWith(fontSize: 14),
                      ),
                      Text(
                        '95%',
                        style: AppTextStyles.sfPRO.copyWith(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF9EEDBB),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Absent',
                        style: AppTextStyles.sfPRO.copyWith(fontSize: 14),
                      ),
                      Text(
                        '5%',
                        style: AppTextStyles.sfPRO.copyWith(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFFFFCDCE),
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  Center(
                    child: Text(
                      'Tap to close',
                      style: AppTextStyles.small.copyWith(fontSize: 13),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}