import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:fahhhh/core/theme_data/app_colors.dart';
import 'package:fahhhh/core/theme_data/app_text_styles.dart';
import 'package:fahhhh/core/widgets/app_screen_scaffold.dart';
import 'package:fahhhh/core/widgets/input_fields.dart';
import 'package:fahhhh/features/department/widgets/detail_action_button.dart';

class TeacherDetailsSettingsScreen extends StatefulWidget {
  final String name;
  final String subject;

  const TeacherDetailsSettingsScreen({
    super.key,
    required this.name,
    required this.subject,
  });

  @override
  State<TeacherDetailsSettingsScreen> createState() =>
      _TeacherDetailsSettingsScreenState();
}

class _TeacherDetailsSettingsScreenState extends State<TeacherDetailsSettingsScreen> {
  late final TextEditingController _nameController;
  late final TextEditingController _emailController;
  late final TextEditingController _phoneController;
  late final TextEditingController _subjectController;
  late final TextEditingController _classController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.name);
    _emailController = TextEditingController(
      text: '${widget.name.toLowerCase().replaceAll(' ', '.')}@mescas.org',
    );
    _phoneController = TextEditingController(text: '9876543210');
    _subjectController = TextEditingController(text: widget.subject);
    _classController = TextEditingController(text: 'S2 BCA');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _subjectController.dispose();
    _classController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AppScreenScaffold(
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(bottom: 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _HeaderSection(onBack: () => context.pop()),
              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 30),
                child: Column(
                  children: [
                    InputField(
                      controller: _nameController,
                      label: 'Teacher Name',
                      hintText: 'Enter teacher name',
                    ),
                    const SizedBox(height: 14),
                    InputField(
                      controller: _subjectController,
                      label: 'Subject',
                      hintText: 'Enter subject',
                    ),
                    const SizedBox(height: 14),
                    InputField(
                      controller: _emailController,
                      label: 'Email',
                      hintText: 'Enter email',
                    ),
                    const SizedBox(height: 14),
                    InputField(
                      controller: _phoneController,
                      label: 'Phone Number',
                      hintText: 'Enter phone number',
                    ),
                    const SizedBox(height: 14),
                    InputField(
                      controller: _classController,
                      label: 'Class',
                      hintText: 'Enter class',
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
                                  content: Text('Teacher deleted'),
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
                                  content: Text('Teacher details saved'),
                                  behavior: SnackBarBehavior.floating,
                                ),
                              );
                            },
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
      ),
    );
  }
}

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
                  'Teacher details',
                  style: AppTextStyles.heading.copyWith(
                    fontSize: 25,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Manage teacher details here',
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