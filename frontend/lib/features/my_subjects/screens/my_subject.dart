import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

//Design
import 'package:fahhhh/core/theme_data/app_text_styles.dart';

//Widgets
import 'package:fahhhh/features/department/widgets/attendance_chart.dart';
import 'package:fahhhh/features/department/widgets/search_sort_bar.dart';
import 'package:fahhhh/features/my_subjects/widgets/my_subject_list_tile.dart';

//Models
import 'package:fahhhh/features/my_subjects/models/my_subject_item.dart';

//Providers
import 'package:fahhhh/features/auth/providers/auth_provider.dart';
import 'package:fahhhh/features/auth/models/current_user.dart';
import 'package:fahhhh/features/timetable/providers/timetable_provider.dart';

/// My Subjects screen for teacher: shows teacher's assigned subjects with attendance overview.
class MySubject extends ConsumerWidget {
  const MySubject({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authProvider);
    final user = auth.user;

    // Deterministic mock attendance pattern.
    const List<int> attendancePattern = [
      95, 82, 90, 65, 88, 74, 95, 78, 85, 70, 92, 80, 66,
    ];

    // Build teacher's subjects from activeSubjects or subjectTeachers map.
    final List<MySubjectItem> subjects = _buildSubjects(user, attendancePattern);

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
              _MySubjectHeader(subjectCount: subjects.length),
              const SizedBox(height: 14),
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
              const SearchSortBar(),
              const SizedBox(height: 6),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.only(bottom: 30),
                  itemCount: subjects.length,
                  itemBuilder: (context, index) =>
                      MySubjectListTile(item: subjects[index]),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<MySubjectItem> _buildSubjects(CurrentUser? user, List<int> pattern) {
    // Use activeSubjects from user if available, otherwise derive from subjectTeachers.
    final List<String> subjectNames;
    if (user?.activeSubjects != null && user!.activeSubjects!.isNotEmpty) {
      subjectNames = user.activeSubjects!;
    } else {
      // Fallback: derive from subjectTeachers mock map.
      subjectNames = subjectTeachers.entries
          .where((e) => e.value == (user?.name ?? ''))
          .map((e) => e.key)
          .toList();
    }

    if (subjectNames.isEmpty) {
      // Default fallback subjects for demo.
      subjectNames.addAll(['Software Engineering', 'Computer Networks', 'Data Science', 'AI', 'Python']);
    }

    return List.generate(subjectNames.length, (index) {
      // Find which classes this subject is taught in.
      final classes = _classesForSubject(subjectNames[index]);
      return MySubjectItem(
        name: subjectNames[index],
        classes: classes.isEmpty ? 'No class' : classes,
        attendancePercent: pattern[index % pattern.length],
      );
    });
  }

  String _classesForSubject(String subject) {
    // From semesterSubjects mock data - return all semesters containing this subject.
    final List<String> matchingSemesters = [];
    for (final entry in semesterSubjects.entries) {
      if (entry.value.contains(subject)) {
        matchingSemesters.add(entry.key); // e.g., "S4"
      }
    }
    return matchingSemesters.join(', ');
  }
}

class _MySubjectHeader extends StatelessWidget {
  final int subjectCount;
  const _MySubjectHeader({required this.subjectCount});

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
                  'Subjects',
                  style: AppTextStyles.heading.copyWith(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Department of Computer Science · $subjectCount Subjects',
                  style: AppTextStyles.small.copyWith(fontSize: 16),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}