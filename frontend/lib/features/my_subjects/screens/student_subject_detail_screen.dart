import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

//Design
import 'package:fahhhh/core/theme_data/app_text_styles.dart';

//Widgets
import 'package:fahhhh/features/department/widgets/attendance_chart.dart';
import 'package:fahhhh/features/department/widgets/search_sort_bar.dart';
import 'package:fahhhh/features/my_subjects/widgets/student_attendance_history_tile.dart';

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

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
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
          child: SingleChildScrollView(
            padding: const EdgeInsets.only(bottom: 40),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 8),
                _StudentSubjectHeader(
                  subjectName: widget.subjectName,
                  teacherName: widget.teacherName,
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
                SearchSortBar(
                  controller: _searchController,
                  onQueryChanged: (val) => setState(() => _query = val),
                ),
                const SizedBox(height: 6),
                for (final record in records)
                  StudentAttendanceHistoryTile(record: record),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _StudentSubjectHeader extends StatelessWidget {
  final String subjectName;
  final String teacherName;

  const _StudentSubjectHeader({
    required this.subjectName,
    required this.teacherName,
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
                  teacherName,
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
