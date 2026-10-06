import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

//Design
import 'package:fahhhh/core/theme_data/app_text_styles.dart';
import 'package:fahhhh/core/widgets/app_screen_scaffold.dart';

//Widgets
import 'package:fahhhh/features/department/widgets/attendance_chart.dart';
import 'package:fahhhh/features/department/widgets/app_search_bar.dart';
import 'package:fahhhh/features/department/widgets/sort_dropdown.dart';
import '../../../core/widgets/app_back_header.dart';
import 'package:fahhhh/features/department/widgets/class_list_tile.dart';

//Models
import 'package:fahhhh/features/department/models/department_class.dart';

//Providers
import 'package:fahhhh/features/timetable/providers/timetable_provider.dart';

/// "Choose the class" screen: lists the classes a subject is taught in.
/// Shown when a subject is assigned to more than one class. Tapping a class
/// opens the subject detail page for that class. Pushed route (hides bottom nav).
class SubjectClassListsScreen extends StatefulWidget {
  final String subjectName;

  const SubjectClassListsScreen({super.key, required this.subjectName});

  @override
  State<SubjectClassListsScreen> createState() => _SubjectClassListsScreenState();
}

class _SubjectClassListsScreenState extends State<SubjectClassListsScreen> {
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
    final rawClasses = _classesForSubject(widget.subjectName);
    final query = _query.trim().toLowerCase();
    final classes = rawClasses
        .where((c) =>
            query.isEmpty ||
            c.name.toLowerCase().contains(query) ||
            c.classTeacher.toLowerCase().contains(query))
        .toList();

    switch (_sortOption) {
      case 'Highest':
        classes.sort((a, b) => b.attendancePercent.compareTo(a.attendancePercent));
      case 'Lowest':
        classes.sort((a, b) => a.attendancePercent.compareTo(b.attendancePercent));
      default: // 'Roll No'
        classes.sort((a, b) => a.name.compareTo(b.name));
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
                  title: 'Class lists',
                  subtitle: 'Choose the class',
                  onBack: () => context.pop(),
                  padding: const EdgeInsets.symmetric(horizontal: 20),
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
                for (final classData in classes)
                  ClassListTile(
                    data: classData,
                    onTap: () {
                      if (!context.mounted) return;
                      context.push(
                        '/subject-details/${Uri.encodeComponent(widget.subjectName)}/'
                        '${Uri.encodeComponent(classData.name)}',
                      );
                    },
                  ),
              ],
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