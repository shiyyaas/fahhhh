import 'package:flutter/material.dart';

import 'package:fahhhh/core/widgets/app_form_dialog.dart';
import 'package:fahhhh/core/widgets/input_fields.dart';

class AddStudentDialog extends StatefulWidget {
  const AddStudentDialog({super.key});

  @override
  State<AddStudentDialog> createState() => _AddStudentDialogState();
}

class _AddStudentDialogState extends State<AddStudentDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _rollNumberController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _rollNumberController.dispose();
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
      title: 'Add New Student',
      primaryText: 'Add Student',
      onPrimary: _submit,
      fields: [
        InputField(
          controller: _nameController,
          label: 'Full Name',
          hintText: 'Enter student name',
        ),
        InputField(
          controller: _rollNumberController,
          label: 'Roll Number',
          hintText: 'Enter roll number',
        ),
      ],
    );
  }
}
