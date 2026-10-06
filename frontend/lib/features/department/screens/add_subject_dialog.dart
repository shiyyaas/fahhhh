import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:fahhhh/core/widgets/app_form_dialog.dart';
import 'package:fahhhh/core/widgets/input_fields.dart';
import '../providers/department_provider.dart';

class AddSubjectDialog extends ConsumerStatefulWidget {
  const AddSubjectDialog({super.key});

  @override
  ConsumerState<AddSubjectDialog> createState() => _AddSubjectDialogState();
}

class _AddSubjectDialogState extends ConsumerState<AddSubjectDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _teacherController = TextEditingController();
  final _codeController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _teacherController.dispose();
    _codeController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_formKey.currentState!.validate()) {
      final name = _nameController.text.trim();
      final code = _codeController.text.trim();

      try {
        final repo = ref.read(departmentRepositoryProvider);
        await repo.createSubject(
          subjectName: name,
          subjectCode: code.isNotEmpty ? code : 'SUB_${name.substring(0, 3).toUpperCase()}',
          semester: 2,
        );
        ref.invalidate(departmentSubjectsProvider);
      } catch (_) {
        // Fall back gracefully if offline
      }

      if (!mounted) return;
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
          controller: _codeController,
          label: 'Subject Code',
          hintText: 'Enter subject code (e.g. CS201)',
        ),
      ],
    );
  }
}
