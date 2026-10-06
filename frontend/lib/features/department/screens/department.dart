import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

//Design
import 'package:fahhhh/core/theme_data/app_text_styles.dart';
import 'package:fahhhh/core/widgets/app_screen_scaffold.dart';

//Utils
import 'package:fahhhh/features/department/utils/header_menu_config.dart';

//Widgets
import 'package:fahhhh/features/department/widgets/department_header.dart';
import 'package:fahhhh/features/department/widgets/segmented_toggle.dart';
import 'package:fahhhh/features/department/widgets/attendance_chart.dart';
import 'package:fahhhh/features/department/widgets/class_list_tile.dart';
import 'package:fahhhh/features/department/widgets/teacher_list_tile.dart';
import 'package:fahhhh/features/department/widgets/app_search_bar.dart';
import 'package:fahhhh/features/department/widgets/sort_dropdown.dart';

//Providers
import 'package:fahhhh/features/department/providers/department_provider.dart';

//Models
import 'package:fahhhh/features/department/models/department_class.dart';
import 'package:fahhhh/features/department/models/department_teacher.dart';

class Department extends ConsumerStatefulWidget {
  const Department({super.key});

  @override
  ConsumerState<Department> createState() => _DepartmentState();
}

class _DepartmentState extends ConsumerState<Department> {
  int _selectedTab = 0;

  @override
  Widget build(BuildContext context) {
    final classesAsync = ref.watch(departmentClassesProvider);
    final teachersAsync = ref.watch(departmentTeachersProvider);
    final classes = classesAsync.value ?? mockDepartmentClasses;
    final teachers = teachersAsync.value ?? mockDepartmentTeachers;

    final String countLabel = _selectedTab == 0
        ? '${classes.length} Classes'
        : '${teachers.length} Teachers';

    return Scaffold(
      body: AppScreenScaffold(
        child: Column(
          children: [
              const SizedBox(height: 12),
              DepartmentHeader(
                countLabel: countLabel,
                selectedSegmentIndex: _selectedTab,
                onOptionSelected: (option) {
                  final route = HeaderMenuConfig.routeFor(
                    option,
                    pageType: HeaderPageType.department,
                  );
                  if (route != null && context.mounted) {
                    context.push(route);
                  }
                },
              ),
              const SizedBox(height: 20),
              SegmentedToggle(
                labels: const ['Classes', 'Teachers'],
                selectedIndex: _selectedTab,
                onChanged: (index) => setState(() => _selectedTab = index),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: _selectedTab == 0
                    ? _ClassesView(classes: classes)
                    : _TeachersView(teachers: teachers),
              ),
          ],
        ),
      ),
    );
  }
}

class _ClassesView extends StatefulWidget {
  final List<DepartmentClass> classes;
  const _ClassesView({required this.classes});

  @override
  State<_ClassesView> createState() => _ClassesViewState();
}

class _ClassesViewState extends State<_ClassesView> {
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
    final query = _query.trim().toLowerCase();
    final classes = List<DepartmentClass>.from(widget.classes)
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
      default: // 'Roll No' / natural name
        classes.sort((a, b) => a.name.compareTo(b.name));
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.only(top: 4, bottom: 110),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
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
                    onChanged: (value) => setState(() => _query = value),
                  ),
                ),
                const SizedBox(width: 10),
                SortDropdown(
                  value: _sortOption,
                  onChanged: (value) => setState(() => _sortOption = value),
                ),
              ],
            ),
          ),
          const SizedBox(height: 6),
          for (final data in classes)
            ClassListTile(
              data: data,
              onTap: () {
                if (!context.mounted) return;
                context.push('/department-class/${Uri.encodeComponent(data.name)}');
              },
            ),
        ],
      ),
    );
  }
}

class _TeachersView extends StatefulWidget {
  final List<DepartmentTeacher> teachers;
  const _TeachersView({required this.teachers});

  @override
  State<_TeachersView> createState() => _TeachersViewState();
}

class _TeachersViewState extends State<_TeachersView> {
  final TextEditingController _searchController = TextEditingController();
  String _query = '';
  String _sortOption = 'Name';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final query = _query.trim().toLowerCase();
    final List<DepartmentTeacher> teachers = List<DepartmentTeacher>.from(widget.teachers)
        .where((t) =>
            query.isEmpty ||
            t.name.toLowerCase().contains(query) ||
            t.subject.toLowerCase().contains(query))
        .toList();

    switch (_sortOption) {
      case 'Highest':
      case 'Name':
        teachers.sort((a, b) => a.name.compareTo(b.name));
      case 'Lowest':
        teachers.sort((a, b) => b.name.compareTo(a.name));
      case 'Subject':
        teachers.sort((a, b) => a.subject.compareTo(b.subject));
      default:
        teachers.sort((a, b) => a.name.compareTo(b.name));
    }

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Row(
            children: [
              Expanded(
                child: AppSearchBar(
                  controller: _searchController,
                  onChanged: (value) => setState(() => _query = value),
                ),
              ),
              const SizedBox(width: 10),
              SortDropdown(
                value: _sortOption,
                options: const ['Name', 'Subject', 'Lowest'],
                onChanged: (value) => setState(() => _sortOption = value),
              ),
            ],
          ),
        ),
        const SizedBox(height: 6),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.only(bottom: 110),
            itemCount: teachers.length,
            itemBuilder: (context, index) => TeacherListTile(
              teacher: teachers[index],
              onTap: () {
                if (!context.mounted) return;
                context.push('/teacher-profile');
              },
            ),
          ),
        ),
      ],
    );
  }
}
