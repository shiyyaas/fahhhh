import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:fahhhh/core/theme_data/app_colors.dart';
import 'package:fahhhh/core/theme_data/app_text_styles.dart';
import 'package:fahhhh/core/widgets/app_screen_scaffold.dart';
import 'package:fahhhh/core/widgets/input_fields.dart';
import 'package:fahhhh/core/widgets/app_back_header.dart';
import 'package:fahhhh/features/department/widgets/detail_action_button.dart';

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
      backgroundColor: AppColors.surface,
      body: AppScreenScaffold(
        child: Column(
          children: [
            const SizedBox(height: 18),
            AppBackHeader(
              title: 'Subject details',
              subtitle: 'Manage subject details here',
              onBack: () => context.pop(),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: SingleChildScrollView(
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
                          child: DetailActionButton.danger(
                            text: 'Delete',
                            onPressed: () {
                              Navigator.pop(context);
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Subject deleted'),
                                  behavior: SnackBarBehavior.floating,
                                ),
                              );
                            },
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: DetailActionButton.primary(
                            text: 'Save',
                            onPressed: () {
                              Navigator.pop(context);
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Subject details saved'),
                                  behavior: SnackBarBehavior.floating,
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
