import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:fahhhh/core/theme_data/app_colors.dart';
import 'package:fahhhh/core/theme_data/app_text_styles.dart';
import 'package:fahhhh/features/department/widgets/teacher_list_tile.dart';
import 'package:fahhhh/features/department/widgets/app_search_bar.dart';
import 'package:fahhhh/features/department/widgets/sort_dropdown.dart';
import 'package:fahhhh/features/department/widgets/upload_teacher_dialog.dart';
import 'package:fahhhh/features/department/widgets/add_teacher_dialog.dart';
import 'package:fahhhh/features/department/widgets/compact_action_button.dart';
import '../providers/department_provider.dart';

import '../../../core/widgets/app_back_header.dart';
import '../../../core/widgets/app_screen_scaffold.dart';

class TeacherSettingsScreen extends ConsumerStatefulWidget {
  const TeacherSettingsScreen({super.key});

  @override
  ConsumerState<TeacherSettingsScreen> createState() => _TeacherSettingsScreenState();
}

class _TeacherSettingsScreenState extends ConsumerState<TeacherSettingsScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _query = '';
  String _sortOption = 'Name';
  final Set<int> _selectedIndices = {};

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final teachersAsync = ref.watch(departmentTeachersProvider);
    final allTeachers = teachersAsync.value ?? [];

    final query = _query.trim().toLowerCase();
    final teachers = allTeachers
        .where(
          (t) =>
              query.isEmpty ||
              t.name.toLowerCase().contains(query) ||
              t.subject.toLowerCase().contains(query),
        )
        .toList();

    switch (_sortOption) {
      case 'Lowest':
        teachers.sort((a, b) => b.name.compareTo(a.name));
      case 'Subject':
        teachers.sort((a, b) => a.subject.compareTo(b.subject));
      default: // 'Name' / 'Highest'
        teachers.sort((a, b) => a.name.compareTo(b.name));
    }

    return Scaffold(
      body: AppScreenScaffold(
        child: Column(
          children: [
            const SizedBox(height: 18),
            AppBackHeader(
              title: 'Teacher Settings',
              subtitle: 'Manage teacher details here',
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
                    options: const ['Name', 'Subject', 'Lowest'],
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
                      onTap: () {
                        showDialog(
                          context: context,
                          builder: (_) => const AddTeacherDialog(),
                        );
                      },
                    ),
                    const SizedBox(width: 10),
                    CompactActionButton.secondary(
                      icon: Icons.upload_rounded,
                      label: 'Upload',
                      onTap: () {
                        showDialog(
                          context: context,
                          builder: (_) => const UploadTeacherDialog(),
                        );
                      },
                    ),
                    if (_selectedIndices.isNotEmpty) ...[
                      const SizedBox(width: 10),
                      CompactActionButton.danger(
                        icon: Icons.delete_outline_rounded,
                        label: 'Delete (${_selectedIndices.length})',
                        onTap: () async {
                          final toRemove = _selectedIndices
                              .where((i) => i < teachers.length)
                              .map((i) => teachers[i])
                              .toList();
                          setState(() {
                            _selectedIndices.clear();
                          });

                          final repo = ref.read(departmentRepositoryProvider);
                          for (final t in toRemove) {
                            if (t.id != null) {
                              try {
                                await repo.deleteTeacher(t.id!);
                              } catch (_) {}
                            }
                          }
                          ref.invalidate(departmentTeachersProvider);

                          if (!context.mounted) return;
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Selected teacher(s) deleted'),
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
                itemCount: teachers.length,
                itemBuilder: (context, index) {
                  final teacher = teachers[index];
                  final isSelected = _selectedIndices.contains(index);
                  return TeacherListTile(
                    teacher: teacher,
                    isSelected: isSelected,
                    onLongPress: () {
                      setState(() {
                        if (isSelected) {
                          _selectedIndices.remove(index);
                        } else {
                          _selectedIndices.add(index);
                        }
                      });
                    },
                    onTap: () {
                      if (_selectedIndices.isNotEmpty) {
                        setState(() {
                          if (isSelected) {
                            _selectedIndices.remove(index);
                          } else {
                            _selectedIndices.add(index);
                          }
                        });
                      } else {
                        context.push(
                          '/teacher-details/${Uri.encodeComponent(teacher.name)}/${Uri.encodeComponent(teacher.subject)}',
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
