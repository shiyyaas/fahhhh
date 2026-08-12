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
import 'package:fahhhh/features/department/widgets/subject_list_tile.dart';
import 'package:fahhhh/features/department/widgets/more_button.dart';

//Models
import 'package:fahhhh/features/department/models/department_student.dart';
import 'package:fahhhh/features/department/models/department_subject.dart';

//Providers
import 'package:fahhhh/features/auth/providers/auth_provider.dart';
import 'package:fahhhh/features/timetable/providers/timetable_provider.dart';

class MyClass extends ConsumerStatefulWidget {
  const MyClass({super.key});

  @override
  ConsumerState<MyClass> createState() => _MyClassState();
}

class _MyClassState extends ConsumerState<MyClass> {
  int _selectedTab = 0;

  static const List<int> _attendancePattern = [
    95, 82, 90, 65, 88, 74, 95, 78, 85, 70, 92, 80, 66,
  ];

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authProvider).user;
    final classId = user?.assignedClassId ?? user?.className ?? 'S2 BCA';

    final students = _buildStudents(classId);
    final subjects = _buildSubjects(classId);

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
              _MyClassHeader(classId: classId),
              const SizedBox(height: 14),
              SegmentedToggle(
                labels: const ['Students', 'Subjects'],
                selectedIndex: _selectedTab,
                onChanged: (index) => setState(() => _selectedTab = index),
              ),
              const SizedBox(height: 14),
              Expanded(
                child: _selectedTab == 0
                    ? _StudentsTab(
                        students: students,
                        classId: classId,
                      )
                    : _SubjectsTab(
                        subjects: subjects,
                        classId: classId,
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<DepartmentStudent> _buildStudents(String classId) {
    final raw = getStudentsForClass(classId);
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

  List<DepartmentSubject> _buildSubjects(String classId) {
    final semKey = classId.length >= 2
        ? classId.substring(0, 2).toUpperCase()
        : 'S2';
    final subjects = semesterSubjects[semKey] ?? [];
    return subjects.map((name) {
      final teacher = subjectTeachers[name] ?? 'Anu Varghese';
      final index = subjects.indexOf(name);
      return DepartmentSubject(
        name: name,
        teacher: teacher,
        attendancePercent:
            _attendancePattern[index % _attendancePattern.length],
      );
    }).toList();
  }
}

class _MyClassHeader extends StatelessWidget {
  final String classId;
  const _MyClassHeader({required this.classId});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 26),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  classId,
                  style: AppTextStyles.heading.copyWith(fontSize: 30),
                ),
                const SizedBox(height: 2),
                Text(
                  'Department of Computer Science',
                  style: AppTextStyles.small.copyWith(fontSize: 16),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          const MoreButton(),
        ],
      ),
    );
  }
}

class _StudentsTab extends StatefulWidget {
  final List<DepartmentStudent> students;
  final String classId;
  const _StudentsTab({required this.students, required this.classId});

  @override
  State<_StudentsTab> createState() => _StudentsTabState();
}

class _StudentsTabState extends State<_StudentsTab> {
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
            padding: const EdgeInsets.only(bottom: 110),
            itemCount: students.length,
            itemBuilder: (context, index) {
              final student = students[index];
              return StudentListTile(
                student: student,
                onTap: () {
                  if (!context.mounted) return;
                  context.push(
                    '/student-profile/${Uri.encodeComponent(widget.classId)}/'
                    '${Uri.encodeComponent(student.rollNumber)}/'
                    '${Uri.encodeComponent(student.name)}',
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}

class _SubjectsTab extends StatefulWidget {
  final List<DepartmentSubject> subjects;
  final String classId;
  const _SubjectsTab({required this.subjects, required this.classId});

  @override
  State<_SubjectsTab> createState() => _SubjectsTabState();
}

class _SubjectsTabState extends State<_SubjectsTab> {
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
            padding: const EdgeInsets.only(bottom: 110),
            itemCount: subjects.length,
            itemBuilder: (context, index) {
              final subject = subjects[index];
              return SubjectListTile(
                subject: subject,
                onTap: () {
                  if (!context.mounted) return;
                  context.push(
                    '/subject-details/${Uri.encodeComponent(subject.name)}/${Uri.encodeComponent(widget.classId)}',
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}