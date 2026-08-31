import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme_data/app_colors.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_dropdown_field.dart';
import '../../../core/widgets/input_fields.dart';
import '../../../core/widgets/app_back_header.dart';

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

class _TeacherDetailsSettingsScreenState
    extends State<TeacherDetailsSettingsScreen> {
  late final TextEditingController _nameController;
  late final TextEditingController _emailController;
  late final TextEditingController _phoneController;
  late String _selectedSubject;
  String _selectedClass = 'S2 BCA';

  static const _classes = ['S2 BCA', 'S4 BCA', 'S6 BCA', 'S8 BCA'];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.name);
    _emailController = TextEditingController(
      text: '${widget.name.toLowerCase().replaceAll(' ', '.')}@mescas.org',
    );
    _phoneController = TextEditingController(text: '9876543210');
    _selectedSubject = widget.subject;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final subjects = [
      'Software Engineering',
      'Data Science',
      'Computer Networks',
      'AI',
      'Digital Marketing',
      'Image Processing',
      'Cybersecurity',
      'Maths',
      'NLP',
      'Flutter',
      'Android',
    ];
    if (!subjects.contains(_selectedSubject)) subjects.add(_selectedSubject);

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [AppColors.background, AppColors.screenGradientEnd],
            stops: const [0.25, 1.0],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.only(bottom: 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 18),
                AppBackHeader(
                  title: 'Teacher Details',
                  subtitle: 'Manage teacher details here',
                  onBack: () => context.pop(),
                ),
                const SizedBox(height: 34),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 26),
                  child: Column(
                    children: [
                      InputField(
                        controller: _nameController,
                        label: 'Teacher Name',
                        hintText: 'Enter teacher name',
                      ),
                      const SizedBox(height: 16),
                      InputField(
                        controller: _emailController,
                        label: 'Email',
                        hintText: 'Enter email',
                      ),
                      const SizedBox(height: 16),
                      InputField(
                        controller: _phoneController,
                        label: 'Phone Number',
                        hintText: 'Enter phone number',
                      ),
                      const SizedBox(height: 16),
                      AppDropdownField(
                        label: 'Assigned Subject',
                        value: _selectedSubject,
                        items: subjects,
                        onChanged: (value) {
                          if (value != null) {
                            setState(() => _selectedSubject = value);
                          }
                        },
                      ),
                      const SizedBox(height: 16),
                      AppDropdownField(
                        label: 'Assigned Class',
                        value: _selectedClass,
                        items: _classes,
                        onChanged: (value) {
                          if (value != null) {
                            setState(() => _selectedClass = value);
                          }
                        },
                      ),
                      const SizedBox(height: 28),
                      Row(
                        children: [
                          Expanded(
                            child: AppButton.secondary(
                              text: 'Cancel',
                              onPressed: () => context.pop(),
                              borderRadius: 28,
                              textColor: AppColors.primary,
                              borderColor: AppColors.border,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 10,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: AppButton.primary(
                              text: 'Save',
                              onPressed: () {
                                context.pop();
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      '${_nameController.text} details updated',
                                    ),
                                    behavior: SnackBarBehavior.floating,
                                  ),
                                );
                              },
                              borderRadius: 28,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 10,
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
        ),
      ),
    );
  }
}
