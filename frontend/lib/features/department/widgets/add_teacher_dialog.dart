import 'package:flutter/material.dart';

import '../../../core/widgets/app_dropdown_field.dart';
import '../../../core/widgets/app_form_dialog.dart';
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
      final name = _nameController.text;
      Navigator.pop(context);
      showAddedSnackBar(context, name);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppFormDialog(
      formKey: _formKey,
      title: 'Add New Teacher',
      primaryText: 'Add Teacher',
      onPrimary: _submit,
      fields: [
        InputField(
          controller: _nameController,
          label: 'Full Name',
          hintText: 'Enter teacher name',
        ),
        InputField(
          controller: _emailController,
          label: 'Email',
          hintText: 'Enter email address',
        ),
        InputField(
          controller: _phoneController,
          label: 'Phone Number',
          hintText: 'Enter phone number',
        ),
        AppDropdownField(
          label: 'Assigned Subject',
          value: _selectedSubject,
          items: _subjects,
          onChanged: (value) => setState(() => _selectedSubject = value),
        ),
        AppDropdownField(
          label: 'Assigned Class',
          value: _selectedClass,
          items: _classes,
          onChanged: (value) => setState(() => _selectedClass = value),
        ),
      ],
    );
  }
}
