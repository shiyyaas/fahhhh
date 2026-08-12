import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

//Design
import 'package:fahhhh/core/theme_data/app_text_styles.dart';

//Widgets
import 'package:fahhhh/features/department/widgets/segmented_toggle.dart';
import 'package:fahhhh/features/department/widgets/attendance_chart.dart';
import 'package:fahhhh/features/department/widgets/search_sort_bar.dart';
import 'package:fahhhh/features/department/widgets/student_list_tile.dart';
import 'package:fahhhh/features/department/widgets/more_button.dart';

//Models
import 'package:fahhhh/features/department/models/department_student.dart';
import 'package:fahhhh/features/department/models/department_subject.dart';

//Providers
import 'package:fahhhh/features/timetable/providers/timetable_provider.dart';

//Widgets
import 'package:fahhhh/features/department/widgets/subject_list_tile.dart';

/// Department CLASS detail screen: attendance chart + class student list.
/// Opened by pushing to /department-class/:classId (hides bottom nav).
class DepartmentClassScreen extends ConsumerStatefulWidget {
  final String classId;

  const DepartmentClassScreen({super.key, required this.classId});

  @override
  ConsumerState<DepartmentClassScreen> createState() =>
      _DepartmentClassScreenState();
}

class _DepartmentClassScreenState extends ConsumerState<DepartmentClassScreen> {
  int _selectedTab = 0;

  // Deterministic mock attendance pattern (mock until backend).
  static const List<int> _attendancePattern = [
    95, 82, 90, 65, 88, 74, 95, 78, 85, 70, 92, 80, 66,
  ];

  List<DepartmentStudent> get _students {
    final raw = getStudentsForClass(widget.classId);
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

  // Build subjects for this class from mock timetable data.
  List<DepartmentSubject> get _subjects {
    final semKey = widget.classId.length >= 2
        ? widget.classId.substring(0, 2).toUpperCase()
        : 'S2';
    final subjects = semesterSubjects[semKey] ?? [];
    return subjects.map((name) {
      final teacher = subjectTeachers[name] ?? 'Anu Varghese';
      final index = subjects.indexOf(name);
      return DepartmentSubject(
        name: name,
        teacher: teacher,
        attendancePercent: _attendancePattern[index % _attendancePattern.length],
      );
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
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
          child: Column(
            children: [
              const SizedBox(height: 8),
              _ClassHeader(classId: widget.classId),
              const SizedBox(height: 14),
              SegmentedToggle(
                labels: const ['Students', 'Subjects'],
                selectedIndex: _selectedTab,
                onChanged: (index) => setState(() => _selectedTab = index),
              ),
              const SizedBox(height: 14),
              Expanded(
                child: _selectedTab == 0
                    ? _StudentsView(students: _students)
                    : _SubjectsView(subjects: _subjects),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ClassHeader extends StatelessWidget {
  final String classId;
  const _ClassHeader({required this.classId});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 26),
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
          const SizedBox(width: 4),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  classId,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.heading.copyWith(fontSize: 28.5),
                ),
                const SizedBox(height: 1),
                Text(
                  'Department of Computer Science',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.small.copyWith(fontSize: 16),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          const MoreButton(),
        ],
      ),
    );
  }
}

class _StudentsView extends StatefulWidget {
  final List<DepartmentStudent> students;
  const _StudentsView({required this.students});

  @override
  State<_StudentsView> createState() => _StudentsViewState();
}

class _StudentsViewState extends State<_StudentsView> {
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
    final students = widget.students
        .where((s) =>
            query.isEmpty ||
            s.name.toLowerCase().contains(query) ||
            s.rollNumber.toLowerCase().contains(query))
        .toList();

    return Column(
      children: [
        const AttendanceChart(),
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
        SearchSortBar(
          controller: _searchController,
          onQueryChanged: (value) => setState(() => _query = value),
        ),
        const SizedBox(height: 6),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.only(bottom: 30),
            itemCount: students.length,
            itemBuilder: (context, index) =>
                StudentListTile(student: students[index]),
          ),
        ),
      ],
    );
  }
}

class _SubjectsView extends StatefulWidget {
  final List<DepartmentSubject> subjects;
  const _SubjectsView({required this.subjects});

  @override
  State<_SubjectsView> createState() => _SubjectsViewState();
}

class _SubjectsViewState extends State<_SubjectsView> {
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
    final subjects = widget.subjects
        .where((s) =>
            query.isEmpty ||
            s.name.toLowerCase().contains(query) ||
            s.teacher.toLowerCase().contains(query))
        .toList();

    return Column(
      children: [
        const AttendanceChart(),
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
        SearchSortBar(
          controller: _searchController,
          onQueryChanged: (value) => setState(() => _query = value),
        ),
        const SizedBox(height: 6),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.only(bottom: 30),
            itemCount: subjects.length,
            itemBuilder: (context, index) =>
                SubjectListTile(subject: subjects[index]),
          ),
        ),
      ],
    );
  }
}
