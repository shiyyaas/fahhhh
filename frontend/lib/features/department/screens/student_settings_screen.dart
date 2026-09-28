import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:fahhhh/core/widgets/app_back_header.dart';
import 'package:fahhhh/core/widgets/app_screen_scaffold.dart';
import 'package:fahhhh/features/department/models/department_student.dart';
import 'package:fahhhh/features/department/screens/add_student_dialog.dart';
import 'package:fahhhh/features/department/screens/upload_student_dialog.dart';
import 'package:fahhhh/features/department/widgets/app_search_bar.dart';
import 'package:fahhhh/features/department/widgets/compact_action_button.dart';
import 'package:fahhhh/features/department/widgets/sort_dropdown.dart';
import 'package:fahhhh/features/department/widgets/student_list_tile.dart';

class StudentSettingsScreen extends StatefulWidget {
  const StudentSettingsScreen({super.key});

  @override
  State<StudentSettingsScreen> createState() => _StudentSettingsScreenState();
}

class _StudentSettingsScreenState extends State<StudentSettingsScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _query = '';
  final Set<int> _selectedIndices = {};

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _toggleSelection(int index) {
    setState(() {
      if (!_selectedIndices.remove(index)) {
        _selectedIndices.add(index);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final query = _query.trim().toLowerCase();
    final students = mockDepartmentStudents
        .where(
          (s) =>
              query.isEmpty ||
              s.name.toLowerCase().contains(query) ||
              s.rollNumber.toLowerCase().contains(query),
        )
        .toList();

    return Scaffold(
      body: AppScreenScaffold(
        child: Column(
          children: [
            const SizedBox(height: 18),
            AppBackHeader(
              title: 'Student Settings',
              subtitle: 'Manage student details here',
              onBack: () => context.pop(),
            ),
            const SizedBox(height: 16),
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
                  const SortDropdown(),
                ],
              ),
            ),
            const SizedBox(height: 14),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 22),
              child: Row(
                children: [
                  CompactActionButton(
                    icon: Icons.person_add_alt_1_rounded,
                    label: 'Add',
                    onTap: () => showDialog(
                      context: context,
                      builder: (_) => const AddStudentDialog(),
                    ),
                  ),
                  const SizedBox(width: 12),
                  CompactActionButton(
                    icon: Icons.upload_rounded,
                    label: 'Upload',
                    onTap: () => showDialog(
                      context: context,
                      builder: (_) => const UploadStudentDialog(),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 6),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 26),
              child: Align(
                alignment: Alignment.centerRight,
                child: Text(
                  'Hold to select & delete',
                  style: TextStyle(fontSize: 14),
                ),
              ),
            ),
            const SizedBox(height: 6),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.only(bottom: 32),
                itemCount: students.length,
                itemBuilder: (context, index) {
                  final student = students[index];
                  return StudentListTile(
                    student: student,
                    isSelected: _selectedIndices.contains(index),
                    onLongPress: () => _toggleSelection(index),
                    onTap: () => context.push(
                      '/student-details/${Uri.encodeComponent(student.rollNumber)}/${Uri.encodeComponent(student.name)}',
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
