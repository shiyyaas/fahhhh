import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:fahhhh/core/theme_data/app_colors.dart';
import 'package:fahhhh/core/theme_data/app_text_styles.dart';
import 'package:fahhhh/core/widgets/app_back_header.dart';
import 'package:fahhhh/core/widgets/app_screen_scaffold.dart';
import 'package:fahhhh/features/department/screens/add_subject_dialog.dart';
import 'package:fahhhh/features/department/screens/upload_subject_dialog.dart';
import 'package:fahhhh/features/department/widgets/app_search_bar.dart';
import 'package:fahhhh/features/department/widgets/compact_action_button.dart';
import 'package:fahhhh/features/department/widgets/sort_dropdown.dart';
import 'package:fahhhh/features/department/widgets/subject_list_tile.dart';
import '../providers/department_provider.dart';

class SubjectSettingsScreen extends ConsumerStatefulWidget {
  const SubjectSettingsScreen({super.key});

  @override
  ConsumerState<SubjectSettingsScreen> createState() => _SubjectSettingsScreenState();
}

class _SubjectSettingsScreenState extends ConsumerState<SubjectSettingsScreen> {
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
    final subjectsAsync = ref.watch(departmentSubjectsProvider);
    final allSubjects = subjectsAsync.value ?? [];

    final query = _query.trim().toLowerCase();
    final subjects = allSubjects
        .where(
          (s) =>
              query.isEmpty ||
              s.name.toLowerCase().contains(query) ||
              s.teacher.toLowerCase().contains(query),
        )
        .toList();

    switch (_sortOption) {
      case 'Highest':
        subjects.sort((a, b) => b.attendancePercent.compareTo(a.attendancePercent));
      case 'Lowest':
        subjects.sort((a, b) => a.attendancePercent.compareTo(b.attendancePercent));
      default: // 'Roll No'
        subjects.sort((a, b) => a.rollNumber.compareTo(b.rollNumber));
    }

    return Scaffold(
      body: AppScreenScaffold(
        child: Column(
          children: [
            const SizedBox(height: 18),
            AppBackHeader(
              title: 'Subject Settings',
              subtitle: 'Manage subject details here',
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
                      icon: Icons.add_rounded,
                      label: 'Add',
                      onTap: () => showDialog(
                        context: context,
                        builder: (_) => const AddSubjectDialog(),
                      ),
                    ),
                    const SizedBox(width: 10),
                    CompactActionButton.secondary(
                      icon: Icons.upload_rounded,
                      label: 'Upload',
                      onTap: () => showDialog(
                        context: context,
                        builder: (_) => const UploadSubjectDialog(),
                      ),
                    ),
                    if (_selectedIndices.isNotEmpty) ...[
                      const SizedBox(width: 10),
                      CompactActionButton.danger(
                        icon: Icons.delete_outline_rounded,
                        label: 'Delete (${_selectedIndices.length})',
                        onTap: () async {
                          final toRemove = _selectedIndices
                              .where((i) => i < subjects.length)
                              .map((i) => subjects[i])
                              .toList();
                          setState(() {
                            _selectedIndices.clear();
                          });

                          final repo = ref.read(departmentRepositoryProvider);
                          for (final s in toRemove) {
                            if (s.id != null) {
                              try {
                                await repo.deleteSubject(s.id!);
                              } catch (_) {}
                            }
                          }
                          ref.invalidate(departmentSubjectsProvider);

                          if (!context.mounted) return;
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Selected subject(s) deleted'),
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
                itemCount: subjects.length,
                itemBuilder: (context, index) {
                  final subject = subjects[index];
                  final isSelected = _selectedIndices.contains(index);
                  return SubjectListTile(
                    subject: subject,
                    isSelected: isSelected,
                    onLongPress: () => _toggleSelection(index),
                    onTap: () {
                      if (_selectedIndices.isNotEmpty) {
                        _toggleSelection(index);
                      } else {
                        context.push(
                          '/subject-details-settings/${Uri.encodeComponent(subject.name)}/${Uri.encodeComponent(subject.teacher)}/${Uri.encodeComponent(subject.rollNumber)}',
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
