import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

//Design
import 'package:fahhhh/core/theme_data/app_text_styles.dart';
import 'package:fahhhh/core/widgets/app_screen_scaffold.dart';

//Widgets
import 'package:fahhhh/features/department/widgets/attendance_chart.dart';
import 'package:fahhhh/features/department/widgets/app_search_bar.dart';
import 'package:fahhhh/features/department/widgets/sort_dropdown.dart';
import 'package:fahhhh/features/my_subjects/widgets/student_attendance_history_tile.dart';
import '../../../core/widgets/app_back_header.dart';

//Models
import 'package:fahhhh/features/my_subjects/models/student_subject_record.dart';

/// Student's personal subject details screen: shows overall attendance chart
/// and date-wise attendance records (Present / Absent / Late).
/// Pushed when a student selects a subject (hides bottom nav).
class StudentSubjectDetailScreen extends StatefulWidget {
  final String subjectName;
  final String teacherName;

  const StudentSubjectDetailScreen({
    super.key,
    required this.subjectName,
    required this.teacherName,
  });

  @override
  State<StudentSubjectDetailScreen> createState() =>
      _StudentSubjectDetailScreenState();
}

class _StudentSubjectDetailScreenState
    extends State<StudentSubjectDetailScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _query = '';
  String _sortOption = 'Roll No';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  int _statusWeight(StudentAttendanceStatus s) {
    switch (s) {
      case StudentAttendanceStatus.present:
        return 2;
      case StudentAttendanceStatus.late:
        return 1;
      case StudentAttendanceStatus.absent:
        return 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    final query = _query.trim().toLowerCase();
    final records = mockStudentSubjectRecords
        .where((r) =>
            query.isEmpty ||
            r.dateStr.toLowerCase().contains(query) ||
            r.status.name.toLowerCase().contains(query))
        .toList();

    switch (_sortOption) {
      case 'Highest':
        records.sort((a, b) => _statusWeight(b.status).compareTo(_statusWeight(a.status)));
      case 'Lowest':
        records.sort((a, b) => _statusWeight(a.status).compareTo(_statusWeight(b.status)));
      default: // 'Roll No' / natural chronological order
        break;
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
                  subtitle: widget.teacherName,
                  onBack: () => context.pop(),
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                ),
                const SizedBox(height: 14),
                const AttendanceChart(),
                const SizedBox(height: 10),
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
                for (final record in records)
                  StudentAttendanceHistoryTile(record: record),
              ],
            ),
        ),
      ),
    );
  }
}
