import 'package:flutter/material.dart';

import '../../../core/theme_data/app_colors.dart';
import '../../../core/theme_data/app_text_styles.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_dropdown_field.dart';
import '../../../core/widgets/input_fields.dart';

class AddTeacherDialog extends StatefulWidget {
  const AddTeacherDialog({super.key});

  @override
  State<AddTeacherDialog> createState() => _AddTeacherDialogState();
}

class _AddTeacherDialogState extends State<AddTeacherDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  String? _selectedSubject;
  String? _selectedClass;

  static const List<String> _subjects = [
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

  static const List<String> _classes = [
    'S2 BCA',
    'S4 BCA',
    'S6 BCA',
    'S8 BCA',
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Added ${_nameController.text} successfully'),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 12),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 384),
          child: Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: AppColors.border, width: 1),
            ),
            child: SingleChildScrollView(
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Add New Teacher',
                      style: AppTextStyles.heading.copyWith(
                        fontSize: 26,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 24),
                    InputField(
                      controller: _nameController,
                      label: 'Full Name',
                      hintText: 'Enter teacher name',
                    ),
                    const SizedBox(height: 14),
                    InputField(
                      controller: _emailController,
                      label: 'Email',
                      hintText: 'Enter email address',
                    ),
                    const SizedBox(height: 14),
                    InputField(
                      controller: _phoneController,
                      label: 'Phone Number',
                      hintText: 'Enter phone number',
                    ),
                    const SizedBox(height: 14),
                    AppDropdownField(
                      label: 'Assigned Subject',
                      value: _selectedSubject,
                      items: _subjects,
                      onChanged: (value) => setState(() => _selectedSubject = value),
                    ),
                    const SizedBox(height: 14),
                    AppDropdownField(
                      label: 'Assigned Class',
                      value: _selectedClass,
                      items: _classes,
                      onChanged: (value) => setState(() => _selectedClass = value),
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: AppButton.primary(
                        text: 'Add Teacher',
                        onPressed: _submit,
                        borderRadius: 28,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 10,
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    SizedBox(
                      width: double.infinity,
                      child: AppButton.secondary(
                        text: 'Cancel',
                        onPressed: () => Navigator.pop(context),
                        borderRadius: 26,
                        textColor: AppColors.primary,
                        borderColor: AppColors.border,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 10,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
