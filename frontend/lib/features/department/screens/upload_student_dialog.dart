import 'package:flutter/material.dart';

import 'package:fahhhh/features/department/widgets/upload_data_dialog.dart';

class UploadStudentDialog extends StatelessWidget {
  const UploadStudentDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return const UploadDataDialog(
      title: 'Student Data',
      fileBaseName: 'students_data',
    );
  }
}
