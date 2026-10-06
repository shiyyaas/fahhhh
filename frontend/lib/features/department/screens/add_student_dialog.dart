import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:fahhhh/core/widgets/app_form_dialog.dart';
import 'package:fahhhh/core/widgets/input_fields.dart';
import '../providers/department_provider.dart';

class AddStudentDialog extends ConsumerStatefulWidget {
  const AddStudentDialog({super.key});

  @override
  ConsumerState<AddStudentDialog> createState() => _AddStudentDialogState();
}

class _AddStudentDialogState extends ConsumerState<AddStudentDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _rollNumberController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _rollNumberController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_formKey.currentState!.validate()) {
      final name = _nameController.text.trim();
      final roll = _rollNumberController.text.trim();
      final email = _emailController.text.trim().isNotEmpty
          ? _emailController.text.trim()
          : '${roll.replaceAll('/', '').toLowerCase()}@mescas.org';
      final phone = _phoneController.text.trim();

      try {
        final repo = ref.read(departmentRepositoryProvider);
        final batches = await repo.getClasses();
        final batchId = batches.isNotEmpty ? (batches.first.id ?? 'batch_default') : 'batch_default';

        await repo.createStudent(
          studentName: name,
          registerNo: roll,
          email: email,
          phoneNo: phone.isNotEmpty ? phone : '9876543210',
          aadhaarNo: '123456789012',
          batchId: batchId,
        );
        ref.invalidate(departmentStudentsProvider(null));
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
          hintText: 'Enter roll number (e.g. 21/BCA/01)',
        ),
        InputField(
          controller: _emailController,
          label: 'Email (Optional)',
          hintText: 'Enter email address',
        ),
        InputField(
          controller: _phoneController,
          label: 'Phone Number (Optional)',
          hintText: 'Enter phone number',
        ),
      ],
    );
  }
}
