import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

//Design
import 'package:fahhhh/core/theme_data/app_text_styles.dart';

//Widgets
import 'package:fahhhh/features/department/widgets/attendance_chart.dart';
import 'package:fahhhh/features/department/widgets/search_sort_bar.dart';
import 'package:fahhhh/features/my_subjects/widgets/my_subject_list_tile.dart';

//Models
import 'package:fahhhh/features/my_subjects/models/my_subject_item.dart';
import 'package:fahhhh/features/department/models/department_class.dart';

//Providers
import 'package:fahhhh/features/auth/providers/auth_provider.dart';
import 'package:fahhhh/features/auth/models/current_user.dart';
import 'package:fahhhh/features/auth/models/user_role.dart';
import 'package:fahhhh/features/timetable/providers/timetable_provider.dart';

/// My Subjects screen for teacher: shows teacher's assigned subjects with attendance overview.
class MySubject extends ConsumerWidget {
  const MySubject({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authProvider);
    final user = auth.user;
    final bool isStudent = auth.role == UserRole.student;

    // Deterministic mock attendance pattern.
    const List<int> attendancePattern = [
      95, 82, 90, 65, 88, 74, 95, 78, 85, 70, 92, 80, 66,
    ];

    // Build subjects list based on role.
    final List<MySubjectItem> subjects = isStudent
        ? _buildStudentSubjects(user, attendancePattern)
        : _buildSubjects(user, attendancePattern);

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
                  itemBuilder: (context, index) {
                    final item = subjects[index];
                    if (isStudent) {
                      return MySubjectListTile(
                        item: item,
                        onTap: () {
                          if (!context.mounted) return;
                          context.push(
                            '/student-subject-details/${Uri.encodeComponent(item.name)}/${Uri.encodeComponent(item.classes)}',
                          );
                        },
                      );
                    }
                    // Teacher / Class Teacher flow
                    final classList = item.classes.isEmpty
                        ? <String>[]
                        : item.classes
                            .split(',')
                            .map((c) => c.trim())
                            .where((c) => c.isNotEmpty)
                            .toList();
                    final bool hasMultipleClasses = classList.length > 1;
                    final String primaryClass =
                        hasMultipleClasses ? '' : (classList.isNotEmpty ? classList.first : 'S2 BCA');
                    return MySubjectListTile(
                      item: item,
                      onTap: () {
                        if (!context.mounted) return;
                        if (hasMultipleClasses) {
                          context.push(
                            '/subject-classes/${Uri.encodeComponent(item.name)}',
                          );
                        } else {
                          context.push(
                            '/subject-details/${Uri.encodeComponent(item.name)}/${Uri.encodeComponent(primaryClass)}',
                          );
                        }
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<MySubjectItem> _buildStudentSubjects(
      CurrentUser? user, List<int> pattern) {
    final String sem = user?.semester ?? '2';
    final semKey = 'S$sem';
    final names = semesterSubjects[semKey] ?? semesterSubjects['S2']!;
    return List.generate(names.length, (index) {
      final name = names[index];
      final teacher = subjectTeachers[name] ?? 'Sheetal';
      return MySubjectItem(
        name: name,
        classes: teacher,
        attendancePercent: pattern[index % pattern.length],
      );
    });
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
    // From mockDepartmentClasses - return the actual class names teaching this subject.
    final List<String> matchingClasses = [];
    for (final classData in mockDepartmentClasses) {
      final semKey = classData.name.substring(0, 2).toUpperCase();
      if ((semesterSubjects[semKey] ?? []).contains(subject)) {
        matchingClasses.add(classData.name); // e.g., "S2 BCA"
      }
    }
    return matchingClasses.join(', ');
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