import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:fahhhh/core/theme_data/app_colors.dart';
import 'package:fahhhh/core/theme_data/app_text_styles.dart';
import 'package:fahhhh/core/widgets/app_back_header.dart';
import 'package:fahhhh/core/widgets/app_screen_scaffold.dart';
import 'package:fahhhh/features/department/screens/add_student_dialog.dart';
import 'package:fahhhh/features/department/screens/upload_student_dialog.dart';
import 'package:fahhhh/features/department/widgets/app_search_bar.dart';
import 'package:fahhhh/features/department/widgets/compact_action_button.dart';
import 'package:fahhhh/features/department/widgets/sort_dropdown.dart';
import 'package:fahhhh/features/department/widgets/student_list_tile.dart';
import '../providers/department_provider.dart';

class StudentSettingsScreen extends ConsumerStatefulWidget {
  const StudentSettingsScreen({super.key});

  @override
  ConsumerState<StudentSettingsScreen> createState() => _StudentSettingsScreenState();
}

class _StudentSettingsScreenState extends ConsumerState<StudentSettingsScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _query = '';
  String _sortOption = 'Roll No';
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
    final studentsAsync = ref.watch(departmentStudentsProvider(null));
    final allStudents = studentsAsync.value ?? [];

    final query = _query.trim().toLowerCase();
    final students = allStudents
        .where(
          (s) =>
              query.isEmpty ||
              s.name.toLowerCase().contains(query) ||
              s.rollNumber.toLowerCase().contains(query),
        )
        .toList();

    switch (_sortOption) {
      case 'Highest':
        students.sort((a, b) => a.name.compareTo(b.name));
      case 'Lowest':
        students.sort((a, b) => b.name.compareTo(a.name));
      default: // 'Roll No'
        students.sort((a, b) => a.rollNumber.compareTo(b.rollNumber));
    }

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
                  SortDropdown(
                    value: _sortOption,
                    onChanged: (val) => setState(() => _sortOption = val),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 22),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    CompactActionButton.primary(
                      icon: Icons.person_add_alt_1_rounded,
                      label: 'Add',
                      onTap: () => showDialog(
                        context: context,
                        builder: (_) => const AddStudentDialog(),
                      ),
                    ),
                    const SizedBox(width: 10),
                    CompactActionButton.secondary(
                      icon: Icons.upload_rounded,
                      label: 'Upload',
                      onTap: () => showDialog(
                        context: context,
                        builder: (_) => const UploadStudentDialog(),
                      ),
                    ),
                    if (_selectedIndices.isNotEmpty) ...[
                      const SizedBox(width: 10),
                      CompactActionButton.danger(
                        icon: Icons.delete_outline_rounded,
                        label: 'Delete (${_selectedIndices.length})',
                        onTap: () async {
                          final toRemove = _selectedIndices
                              .where((i) => i < students.length)
                              .map((i) => students[i])
                              .toList();
                          setState(() {
                            _selectedIndices.clear();
                          });

                          final repo = ref.read(departmentRepositoryProvider);
                          for (final s in toRemove) {
                            if (s.id != null) {
                              try {
                                await repo.deleteStudent(s.id!);
                              } catch (_) {}
                            }
                          }
                          ref.invalidate(departmentStudentsProvider(null));

                          if (!context.mounted) return;
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Selected student(s) deleted'),
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        },
                      ),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: 6),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 26),
              child: Align(
                alignment: Alignment.centerRight,
                child: Text(
                  _selectedIndices.isNotEmpty
                      ? '${_selectedIndices.length} selected'
                      : 'Hold to select & delete',
                  style: AppTextStyles.small.copyWith(
                    fontSize: 13,
                    color: _selectedIndices.isNotEmpty
                        ? AppColors.danger
                        : AppColors.textSecondary,
                    fontWeight: _selectedIndices.isNotEmpty
                        ? FontWeight.w600
                        : FontWeight.normal,
                  ),
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
                  final isSelected = _selectedIndices.contains(index);
                  return StudentListTile(
                    student: student,
                    isSelected: isSelected,
                    onLongPress: () => _toggleSelection(index),
                    onTap: () {
                      if (_selectedIndices.isNotEmpty) {
                        _toggleSelection(index);
                      } else {
                        context.push(
                          '/student-details/${Uri.encodeComponent(student.rollNumber)}/${Uri.encodeComponent(student.name)}',
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
}
