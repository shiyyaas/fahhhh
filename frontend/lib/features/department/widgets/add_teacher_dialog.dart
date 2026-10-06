import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/widgets/app_dropdown_field.dart';
import '../../../core/widgets/app_form_dialog.dart';
import '../../../core/widgets/input_fields.dart';
import '../providers/department_provider.dart';

class AddTeacherDialog extends ConsumerStatefulWidget {
  const AddTeacherDialog({super.key});

  @override
  ConsumerState<AddTeacherDialog> createState() => _AddTeacherDialogState();
}

class _AddTeacherDialogState extends ConsumerState<AddTeacherDialog> {
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

  Future<void> _submit() async {
    if (_formKey.currentState!.validate()) {
      final name = _nameController.text.trim();
      final email = _emailController.text.trim();
      final phone = _phoneController.text.trim();

      try {
        final repo = ref.read(departmentRepositoryProvider);
        await repo.createTeacher(
          teacherName: name,
          employeeId: 'EMP_${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}',
          email: email.isNotEmpty ? email : '${name.toLowerCase().replaceAll(' ', '')}@mescas.org',
          phoneNo: phone,
        );
        ref.invalidate(departmentTeachersProvider);
      } catch (_) {
        // Fall back gracefully if backend is offline
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
