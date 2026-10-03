import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:fahhhh/core/theme_data/app_colors.dart';
import 'package:fahhhh/core/theme_data/app_text_styles.dart';
import 'package:fahhhh/core/widgets/app_button.dart';
import 'package:fahhhh/core/widgets/app_screen_scaffold.dart';
import 'package:fahhhh/core/widgets/input_fields.dart';

/// Subject settings details screen: delete, save, and detail display.
class SubjectSettingsDetailsScreen extends StatefulWidget {
  final String name;
  final String teacher;
  final String rollNumber;

  const SubjectSettingsDetailsScreen({
    super.key,
    required this.name,
    required this.teacher,
    required this.rollNumber,
  });

  @override
  State<SubjectSettingsDetailsScreen> createState() =>
      _SubjectSettingsDetailsScreenState();
}

class _SubjectSettingsDetailsScreenState
    extends State<SubjectSettingsDetailsScreen> {
  late final TextEditingController _nameController;
  late final TextEditingController _teacherController;
  late final TextEditingController _rollController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.name);
    _teacherController = TextEditingController(text: widget.teacher);
    _rollController = TextEditingController(text: widget.rollNumber);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _teacherController.dispose();
    _rollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AppScreenScaffold(
        child: Column(
          children: [
            _HeaderSection(onBack: () => context.pop()),
            const SizedBox(height: 24),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  InputField(
                    controller: _nameController,
                    label: 'Subject Name',
                    hintText: 'Enter subject name',
                  ),
                  const SizedBox(height: 14),
                  InputField(
                    controller: _teacherController,
                    label: 'Teacher Name',
                    hintText: 'Enter teacher name',
                  ),
                  const SizedBox(height: 14),
                  InputField(
                    controller: _rollController,
                    label: 'Roll Number',
                    hintText: 'Enter roll number',
                  ),
                  const SizedBox(height: 32),
                  Row(
                    children: [
                      Expanded(
                        child: AppButton.primary(
                          text: 'Delete',
                          onPressed: () {},
                          height: 29,
                          borderRadius: 28,
                          backgroundColor: const Color(0xFFEE7373),
                          borderColor: const Color(0xFFEE7373),
                          padding: EdgeInsets.zero,
                          boxShadow: const [],
                          textStyle: AppTextStyles.heading.copyWith(
                            fontSize: 14,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: AppButton.primary(
                          text: 'Save',
                          onPressed: () => context.pop(),
                          height: 29,
                          borderRadius: 28,
                          backgroundColor: AppColors.primary,
                          borderColor: AppColors.primary,
                          padding: EdgeInsets.zero,
                          boxShadow: const [],
                          textStyle: AppTextStyles.heading.copyWith(
                            fontSize: 14,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Blue header with back arrow, title, and subtitle — matches the Figma
/// "Subject details" / "Manage subject details here" block.
class _HeaderSection extends StatelessWidget {
  final VoidCallback onBack;

  const _HeaderSection({required this.onBack});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 143,
      decoration: const BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(25),
          bottomRight: Radius.circular(25),
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            left: 15,
            top: 61,
            child: IconButton(
              onPressed: onBack,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints.tightFor(
                width: 26,
                height: 41,
              ),
              icon: const Icon(Icons.arrow_back, size: 26, color: Colors.white),
            ),
          ),
          Positioned(
            left: 47,
            top: 61,
            right: 15,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Subject details',
                  style: AppTextStyles.heading.copyWith(
                    fontSize: 25,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Manage subject details here',
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.small.copyWith(
                    fontSize: 15,
                    color: Colors.white.withValues(alpha: 0.85),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}