import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

//Design
import 'package:fahhhh/core/theme_data/app_text_styles.dart';

//Widgets
import 'package:fahhhh/features/department/widgets/attendance_chart.dart';
import 'package:fahhhh/features/department/widgets/search_sort_bar.dart';
import 'package:fahhhh/features/department/widgets/class_list_tile.dart';

//Models
import 'package:fahhhh/features/department/models/department_class.dart';

//Providers
import 'package:fahhhh/features/timetable/providers/timetable_provider.dart';

/// "Choose the class" screen: lists the classes a subject is taught in.
/// Shown when a subject is assigned to more than one class. Tapping a class
/// opens the subject detail page for that class. Pushed route (hides bottom nav).
class SubjectClassListsScreen extends StatelessWidget {
  final String subjectName;

  const SubjectClassListsScreen({super.key, required this.subjectName});

  @override
  Widget build(BuildContext context) {
    final classes = _classesForSubject(subjectName);

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
                Padding(
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
                              'Class lists',
                              style: AppTextStyles.heading.copyWith(
                                fontSize: 30,
                              ),
                            ),
                            const SizedBox(height: 1),
                            Text(
                              'Choose the class',
                              style: AppTextStyles.small.copyWith(
                                fontSize: 17.7,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                const AttendanceChart(),
                const SizedBox(height: 12),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 34),
                  child: Text(
                    'Based on week , month & Overall',
                    style: AppTextStyles.small.copyWith(fontSize: 15.7),
                  ),
                ),
                const SizedBox(height: 12),
                const SearchSortBar(),
                const SizedBox(height: 6),
                for (final classData in classes)
                  ClassListTile(
                    data: classData,
                    onTap: () {
                      if (!context.mounted) return;
                      context.push(
                        '/subject-details/${Uri.encodeComponent(subjectName)}/'
                        '${Uri.encodeComponent(classData.name)}',
                      );
                    },
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Derive the classes that teach this subject from the mock timetable data.
  List<DepartmentClass> _classesForSubject(String subject) {
    return mockDepartmentClasses.where((classData) {
      final semKey = classData.name.substring(0, 2).toUpperCase();
      return semesterSubjects[semKey]?.contains(subject) ?? false;
    }).toList();
  }
}