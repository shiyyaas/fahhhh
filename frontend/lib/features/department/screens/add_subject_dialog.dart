import 'package:flutter/material.dart';

import 'package:fahhhh/core/widgets/app_form_dialog.dart';
import 'package:fahhhh/core/widgets/input_fields.dart';

class AddSubjectDialog extends StatefulWidget {
  const AddSubjectDialog({super.key});

  @override
  State<AddSubjectDialog> createState() => _AddSubjectDialogState();
}

class _AddSubjectDialogState extends State<AddSubjectDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _teacherController = TextEditingController();
  final _rollNumberController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _teacherController.dispose();
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
      title: 'Add New Subject',
      primaryText: 'Add Subject',
      onPrimary: _submit,
      fields: [
        InputField(
          controller: _nameController,
          label: 'Subject Name',
          hintText: 'Enter subject name',
        ),
        InputField(
          controller: _teacherController,
          label: 'Teacher Name',
          hintText: 'Enter teacher name',
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
