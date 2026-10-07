import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

//Design
import 'package:fahhhh/core/theme_data/app_colors.dart';
import 'package:fahhhh/core/theme_data/app_text_styles.dart';
import 'package:fahhhh/core/widgets/app_back_header.dart';
import 'package:fahhhh/core/widgets/app_screen_scaffold.dart';

//Widgets
import 'package:fahhhh/features/department/widgets/app_search_bar.dart';
import 'package:fahhhh/features/department/widgets/sort_dropdown.dart';
import 'package:fahhhh/features/department/widgets/condonation_percentage_badge.dart';
import 'package:fahhhh/features/department/widgets/student_list_tile.dart';

//Models
import 'package:fahhhh/features/department/models/department_student.dart';

//Providers
import 'package:fahhhh/features/department/providers/department_provider.dart';

/// Condonation Register: a searchable roster of students whose sessions have
/// been condoned, each row ending in an attendance-percentage pill.
///
/// Pushed from the My Class "More" menu (`Check Condonation`) — outside the
/// StatefulShellRoute so the bottom navigation is hidden.
class CondonationScreen extends ConsumerStatefulWidget {
  const CondonationScreen({super.key});

  @override
  ConsumerState<CondonationScreen> createState() => _CondonationScreenState();
}

class _CondonationScreenState extends ConsumerState<CondonationScreen> {
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
    final defaultersAsync = ref.watch(defaultersProvider);
    final List<_CondonationEntry> students = defaultersAsync.maybeWhen(
      data: (defaulters) {
        return defaulters.map((d) {
          final percent = double.tryParse(d['attendancePercentage']?.toString() ?? '0')?.round() ?? 0;
          return _CondonationEntry(
            student: DepartmentStudent(
              id: d['studentId']?.toString(),
              name: d['studentName']?.toString() ?? 'Student',
              rollNumber: d['registerNo']?.toString() ?? '',
            ),
            percent: percent,
          );
        }).toList();
      },
      orElse: () => const [],
    );
    final query = _query.trim().toLowerCase();
    var visible = students
        .where((s) =>
            query.isEmpty ||
            s.student.name.toLowerCase().contains(query) ||
            s.student.rollNumber.toLowerCase().contains(query))
        .toList();

    visible = _sort(visible, _sortOption);

    return Scaffold(
      body: AppScreenScaffold(
        child: Column(
          children: [
            const SizedBox(height: 8),
            AppBackHeader(
              title: 'Condonation Register',
              subtitle: 'View List of Students with Condonation.',
              onBack: () {
                if (context.mounted) context.pop();
              },
              padding: const EdgeInsets.symmetric(horizontal: 20),
            ),
            const SizedBox(height: 14),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 26),
              child: Row(
                children: [
                  Expanded(
                    child: _CondonationActionButton(
                      icon: Icons.visibility_outlined,
                      label: 'Show Preview',
                      onTap: () => _notify('Preview generated'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _CondonationActionButton(
                      icon: Icons.file_download_outlined,
                      label: 'Download',
                      onTap: () => _notify('Register downloaded'),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
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
            Expanded(
              child: visible.isEmpty
                  ? const _EmptyState()
                  : ListView.builder(
                      padding: const EdgeInsets.only(top: 4, bottom: 40),
                      itemCount: visible.length,
                      itemBuilder: (context, index) {
                        final entry = visible[index];
                        return StudentListTile(
                          student: entry.student,
                          trailing:
                              CondonationPercentageBadge(percent: entry.percent),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  void _notify(String message) {
    if (!context.mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }



  List<_CondonationEntry> _sort(
      List<_CondonationEntry> entries, String option) {
    final sorted = List<_CondonationEntry>.from(entries);
    switch (option) {
      case 'Highest':
        sorted.sort((a, b) => b.percent.compareTo(a.percent));
      case 'Lowest':
        sorted.sort((a, b) => a.percent.compareTo(b.percent));
      default:
        // 'Roll No' — keep natural order.
    }
    return sorted;
  }
}

class _CondonationEntry {
  final DepartmentStudent student;
  final int percent;

  const _CondonationEntry({required this.student, required this.percent});
}

/// White outlined pill action (Show Preview / Download).
class _CondonationActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback? onTap;

  const _CondonationActionButton({
    required this.icon,
    required this.label,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 30,
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: AppColors.outline, width: 0.8),
          boxShadow: const [
            BoxShadow(
              color: AppColors.controlShadow,
              blurRadius: 4,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 16, color: AppColors.headingText),
            const SizedBox(width: 6),
            Text(
              label,
              style: AppTextStyles.heading.copyWith(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        'No students with condonation',
        style: AppTextStyles.small.copyWith(fontSize: 15),
      ),
    );
  }
}
