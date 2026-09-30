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
    final String countLabel = _selectedTab == 0
        ? '${mockDepartmentClasses.length} Classes'
        : '${mockDepartmentTeachers.length} Teachers';

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
                    ? const _ClassesView()
                    : const _TeachersView(),
              ),
          ],
        ),
      ),
    );
  }
}

class _ClassesView extends StatelessWidget {
  const _ClassesView();

  @override
  Widget build(BuildContext context) {
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
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 24),
            child: Row(
              children: [
                Expanded(child: AppSearchBar()),
                SizedBox(width: 10),
                SortDropdown(),
              ],
            ),
          ),
          const SizedBox(height: 6),
          for (final data in mockDepartmentClasses)
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
  const _TeachersView();

  @override
  State<_TeachersView> createState() => _TeachersViewState();
}

class _TeachersViewState extends State<_TeachersView> {
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
    final List<DepartmentTeacher> teachers = mockDepartmentTeachers
        .where((t) =>
            query.isEmpty ||
            t.name.toLowerCase().contains(query) ||
            t.subject.toLowerCase().contains(query))
        .toList();

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
              const SortDropdown(),
            ],
          ),
        ),
        const SizedBox(height: 6),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.only(bottom: 110),
            itemCount: teachers.length,
            itemBuilder: (context, index) =>
                TeacherListTile(teacher: teachers[index]),
          ),
        ),
      ],
    );
  }
}
