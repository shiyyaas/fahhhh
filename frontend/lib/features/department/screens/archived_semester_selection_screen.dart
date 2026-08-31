import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:fahhhh/core/theme_data/app_text_styles.dart';
import '../../../core/widgets/app_back_header.dart';

class ArchivedSemesterSelectionScreen extends StatelessWidget {
  final String batchName;

  const ArchivedSemesterSelectionScreen({
    super.key,
    required this.batchName,
  });

  static const List<String> semesters = [
    'S1',
    'S2',
    'S3',
    'S4',
    'S5',
    'S6',
    'S7',
    'S8',
  ];

  @override
  Widget build(BuildContext context) {
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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 18),
              AppBackHeader(
                title: 'Select the semester',
                subtitle: 'View previous batches Attendance & Reports',
                onBack: () => context.pop(),
              ),
              const SizedBox(height: 36),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Wrap(
                  spacing: 16,
                  runSpacing: 16,
                  children: semesters.map((sem) {
                    return _SemesterChip(
                      semester: sem,
                      onTap: () {
                        if (!context.mounted) return;
                        final fullClassId = '$batchName $sem';
                        context.push('/department-class/${Uri.encodeComponent(fullClassId)}');
                      },
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SemesterChip extends StatelessWidget {
  final String semester;
  final VoidCallback onTap;

  const _SemesterChip({
    required this.semester,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 68,
        height: 46,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: Colors.black.withValues(alpha: 0.15),
            width: 0.8,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Center(
          child: Text(
            semester,
            style: AppTextStyles.sfPRO.copyWith(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF364153),
            ),
          ),
        ),
      ),
    );
  }
}
