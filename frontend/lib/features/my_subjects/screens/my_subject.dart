import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

//Design
import 'package:fahhhh/core/theme_data/app_text_styles.dart';
import 'package:fahhhh/core/widgets/app_screen_scaffold.dart';

//Widgets
import 'package:fahhhh/features/department/widgets/attendance_chart.dart';
import 'package:fahhhh/features/department/widgets/app_search_bar.dart';
import 'package:fahhhh/features/department/widgets/sort_dropdown.dart';
import 'package:fahhhh/features/my_subjects/widgets/my_subject_list_tile.dart';

//Models
import 'package:fahhhh/features/my_subjects/models/my_subject_item.dart';

//Providers
import 'package:fahhhh/features/auth/providers/auth_provider.dart';
import 'package:fahhhh/features/auth/models/user_role.dart';
import 'package:fahhhh/features/department/providers/department_provider.dart';

/// My Subjects screen for teacher: shows teacher's assigned subjects with attendance overview.
class MySubject extends ConsumerStatefulWidget {
  const MySubject({super.key});

  @override
  ConsumerState<MySubject> createState() => _MySubjectState();
}

class _MySubjectState extends ConsumerState<MySubject> {
  final TextEditingController _searchController = TextEditingController();
  String _query = '';
  String _sortOption = 'Roll No';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final auth = ref.watch(authProvider);
    final user = auth.user;
    final bool isStudent = auth.role == UserRole.student;

    // Deterministic mock attendance pattern.
    const List<int> attendancePattern = [
      95, 82, 90, 65, 88, 74, 95, 78, 85, 70, 92, 80, 66,
    ];

    final subjectsAsync = ref.watch(departmentSubjectsProvider);

    // Build subjects list based on role.
    final List<MySubjectItem> rawSubjects = subjectsAsync.maybeWhen(
      data: (deptSubjects) {
        if (deptSubjects.isNotEmpty) {
          if (isStudent) {
            final String sem = user?.semester ?? '2';
            final filtered = deptSubjects.where((s) => s.semester == null || s.semester.toString() == sem).toList();
            final listToUse = filtered.isNotEmpty ? filtered : deptSubjects;
            return List.generate(listToUse.length, (index) {
              final sub = listToUse[index];
              return MySubjectItem(
                name: sub.name,
                classes: sub.teacher.isNotEmpty ? sub.teacher : 'Faculty',
                attendancePercent: attendancePattern[index % attendancePattern.length],
              );
            });
          } else {
            final teacherName = user?.name ?? '';
            final filtered = deptSubjects.where((s) => s.teacher.toLowerCase().contains(teacherName.toLowerCase())).toList();
            final listToUse = filtered.isNotEmpty ? filtered : deptSubjects;
            return List.generate(listToUse.length, (index) {
              final sub = listToUse[index];
              final classes = _classesForSubject(sub.name);
              return MySubjectItem(
                name: sub.name,
                classes: classes.isEmpty ? 'No class' : classes,
                attendancePercent: attendancePattern[index % attendancePattern.length],
              );
            });
          }
        }
        return <MySubjectItem>[];
      },
      orElse: () => <MySubjectItem>[],
    );

    final query = _query.trim().toLowerCase();
    final subjects = rawSubjects
        .where((s) =>
            query.isEmpty ||
            s.name.toLowerCase().contains(query) ||
            s.classes.toLowerCase().contains(query))
        .toList();

    switch (_sortOption) {
      case 'Highest':
        subjects.sort((a, b) => b.attendancePercent.compareTo(a.attendancePercent));
      case 'Lowest':
        subjects.sort((a, b) => a.attendancePercent.compareTo(b.attendancePercent));
      default: // 'Roll No'
        subjects.sort((a, b) => a.name.compareTo(b.name));
    }

    return Scaffold(
      body: AppScreenScaffold(
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
    );
  }



  String _classesForSubject(String subject) {
    return 'BCA';
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