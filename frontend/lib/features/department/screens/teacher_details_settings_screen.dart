import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:fahhhh/core/theme_data/app_colors.dart';
import 'package:fahhhh/core/theme_data/app_text_styles.dart';
import 'package:fahhhh/core/widgets/app_screen_scaffold.dart';
import 'package:fahhhh/core/widgets/input_fields.dart';
import 'package:fahhhh/core/widgets/app_back_header.dart';
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
          child: Column(
            children: [
              const SizedBox(height: 18),
              AppBackHeader(
                title: 'Teacher Details',
                subtitle: 'Manage teacher details here',
                onBack: () => context.pop(),
              ),
              const SizedBox(height: 24),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
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
