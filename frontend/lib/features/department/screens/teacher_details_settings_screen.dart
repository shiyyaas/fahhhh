import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:fahhhh/core/theme_data/app_colors.dart';
import 'package:fahhhh/core/theme_data/app_text_styles.dart';
import 'package:fahhhh/core/widgets/app_button.dart';
import 'package:fahhhh/core/widgets/app_screen_scaffold.dart';
import 'package:fahhhh/core/widgets/input_fields.dart';

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
    return SizedBox(
      height: 143,
      child: Stack(
        children: [
          Positioned(
            top: 0,
            left: 0,
            right: 2,
            child: Container(
              height: 143,
              decoration: const BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(25),
                  bottomRight: Radius.circular(25),
                ),
              ),
            ),
          ),
          Positioned(
            left: 15,
            top: 61,
            child: Row(
              children: [
                IconButton(
                  onPressed: onBack,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints.tightFor(
                    width: 26,
                    height: 41,
                  ),
                  icon: const Icon(Icons.arrow_back, size: 26, color: Colors.white),
                ),
                const SizedBox(width: 11),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Teacher details',
                        style: AppTextStyles.heading.copyWith(
                          fontSize: 25,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        'Manage teacher details here',
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.small.copyWith(fontSize: 15),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            left: 21,
            right: 19,
            bottom: 2,
            child: Row(
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
                    textStyle: AppTextStyles.heading.copyWith(fontSize: 14),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: AppButton.secondary(
                    text: 'Save',
                    onPressed: () => context.pop(),
                    height: 29,
                    borderRadius: 28,
                    textColor: AppColors.primary,
                    borderColor: AppColors.border,
                    padding: EdgeInsets.zero,
                    boxShadow: const [],
                    textStyle: AppTextStyles.heading.copyWith(fontSize: 14),
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