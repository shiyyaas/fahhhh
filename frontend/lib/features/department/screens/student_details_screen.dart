import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:fahhhh/core/theme_data/app_colors.dart';
import 'package:fahhhh/core/theme_data/app_text_styles.dart';
import 'package:fahhhh/core/widgets/input_fields.dart';
import 'package:fahhhh/core/widgets/app_screen_scaffold.dart';
import 'package:fahhhh/core/widgets/app_back_header.dart';
import 'package:fahhhh/features/department/widgets/detail_action_button.dart';

/// Student details screen.
class StudentDetailsScreen extends StatefulWidget {
  final String rollNumber;
  final String name;

  const StudentDetailsScreen({
    super.key,
    required this.rollNumber,
    required this.name,
  });

  @override
  State<StudentDetailsScreen> createState() => _StudentDetailsScreenState();
}

class _StudentDetailsScreenState extends State<StudentDetailsScreen> {
  late final TextEditingController _nameController;
  late final TextEditingController _appaarController;
  late final TextEditingController _aadharController;
  late final TextEditingController _phoneController;
  late final TextEditingController _emailController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.name);
    _appaarController = TextEditingController(text: widget.rollNumber);
    _aadharController = TextEditingController(text: '9893 8145 9338');
    _phoneController = TextEditingController(text: '6235223761');
    _emailController =
        TextEditingController(text: 'shiyasps@mescas.org');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _appaarController.dispose();
    _aadharController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
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
              title: 'Student Details',
              subtitle: 'Manage student details here',
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
                      label: 'Student Name',
                      hintText: 'Enter student name',
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter student name';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 14),
                    InputField(
                      controller: _appaarController,
                      label: 'Apaar ID',
                      hintText: 'Enter apaar id',
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter apaar ID';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 14),
                    InputField(
                      controller: _aadharController,
                      label: 'Aadhar No',
                      hintText: 'Enter aadhar no',
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter aadhar number';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 14),
                    InputField(
                      controller: _phoneController,
                      label: 'Phone No',
                      hintText: 'Enter phone no',
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter phone number';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 14),
                    InputField(
                      controller: _emailController,
                      label: 'Email',
                      hintText: 'Enter email',
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter email';
                        }
                        if (!value.contains('@')) {
                          return 'Please enter a valid email';
                        }
                        return null;
                      },
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
                                  content: Text('Student deleted'),
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
                                  content: Text('Student details updated'),
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
