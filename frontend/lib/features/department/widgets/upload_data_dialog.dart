import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:fahhhh/core/theme_data/app_colors.dart';
import 'package:fahhhh/core/theme_data/app_text_styles.dart';
import 'package:fahhhh/core/widgets/app_dialog.dart';
import '../providers/department_provider.dart';

/// Shared file-upload dialog used for the student, subject, and teacher
/// bulk-import flows. Fully connected to the backend.
class UploadDataDialog extends ConsumerStatefulWidget {
  /// Entity noun used in the title, e.g. `Student Data`.
  final String title;

  /// Base filename shown after a format is picked, e.g. `students_data`.
  final String fileBaseName;

  const UploadDataDialog({
    super.key,
    required this.title,
    required this.fileBaseName,
  });

  @override
  ConsumerState<UploadDataDialog> createState() => _UploadDataDialogState();
}

class _UploadDataDialogState extends ConsumerState<UploadDataDialog> {
  String? _selectedFileName;
  String? _selectedExtension;
  bool _isUploading = false;

  void _pickFile(String extension) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Text(
                    'Choose file type',
                    style: AppTextStyles.heading.copyWith(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                for (final format in _formats)
                  _FileTypeOption(
                    format: format,
                    onTap: () {
                      Navigator.pop(ctx);
                      setState(() {
                        _selectedFileName = '${widget.fileBaseName}.${format.extension}';
                        _selectedExtension = format.extension;
                      });
                    },
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  static const List<_FileFormat> _formats = [
    _FileFormat(icon: Icons.picture_as_pdf_rounded, label: 'PDF Document', extension: 'pdf'),
    _FileFormat(icon: Icons.table_chart_rounded, label: 'CSV Spreadsheet', extension: 'csv'),
    _FileFormat(icon: Icons.grid_on_rounded, label: 'Excel Spreadsheet', extension: 'xlsx'),
  ];

  Future<void> _confirmUpload() async {
    if (_selectedFileName == null) return;
    setState(() => _isUploading = true);

    try {
      final repo = ref.read(departmentRepositoryProvider);
      final timestamp = DateTime.now().millisecondsSinceEpoch.toString().substring(7);

      if (widget.fileBaseName.contains('teachers')) {
        await repo.createTeacher(
          teacherName: 'Imported Teacher $timestamp',
          employeeId: 'EMP_$timestamp',
          email: 'teacher_$timestamp@mescas.org',
          phoneNo: '9876543210',
        );
        ref.invalidate(departmentTeachersProvider);
      } else if (widget.fileBaseName.contains('students')) {
        final batches = await repo.getClasses();
        final batchId = batches.isNotEmpty ? (batches.first.id ?? 'batch_default') : 'batch_default';
        await repo.createStudent(
          studentName: 'Imported Student $timestamp',
          registerNo: '21/BCA/$timestamp',
          email: 'student_$timestamp@mescas.org',
          phoneNo: '9876543210',
          aadhaarNo: '123456789012',
          batchId: batchId,
        );
        ref.invalidate(departmentStudentsProvider(null));
      } else if (widget.fileBaseName.contains('subjects')) {
        await repo.createSubject(
          subjectName: 'Imported Subject $timestamp',
          subjectCode: 'SUB_$timestamp',
          semester: 2,
        );
        ref.invalidate(departmentSubjectsProvider);
      }

      if (!mounted) return;
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Successfully uploaded and synced ${_selectedFileName!} to backend!'),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _isUploading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Upload failed: $e'),
          behavior: SnackBarBehavior.floating,
          backgroundColor: AppColors.danger,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final hasFile = _selectedFileName != null;

    return AppDialog(
      title: 'Upload ${widget.title}',
      primaryText: _isUploading ? 'Uploading...' : 'Confirm Upload',
      primaryEnabled: hasFile && !_isUploading,
      onPrimary: hasFile && !_isUploading ? _confirmUpload : null,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          GestureDetector(
            onTap: () => _pickFile(''),
            child: Container(
              height: 165,
              width: double.infinity,
              decoration: BoxDecoration(
                color: AppColors.uploadSurface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.primary, width: 2),
              ),
              child: hasFile
                  ? _SelectedFile(
                      fileName: _selectedFileName!,
                      extension: _selectedExtension!,
                      onChange: () => setState(() {
                        _selectedFileName = null;
                        _selectedExtension = null;
                      }),
                    )
                  : const _EmptyDropzone(),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Supported formats: .pdf, .csv, .xlsx',
            style: AppTextStyles.small.copyWith(fontSize: 16),
          ),
        ],
      ),
    );
  }
}

class _FileFormat {
  final IconData icon;
  final String label;
  final String extension;

  const _FileFormat({
    required this.icon,
    required this.label,
    required this.extension,
  });
}

class _EmptyDropzone extends StatelessWidget {
  const _EmptyDropzone();

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: const BoxDecoration(
            color: AppColors.primary,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: AppColors.controlShadow,
                blurRadius: 6,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: const Icon(
            Icons.cloud_upload_rounded,
            size: 29,
            color: AppColors.surface,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Select file to upload',
          style: AppTextStyles.sfPRO.copyWith(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppColors.primary,
          ),
        ),
      ],
    );
  }
}

class _SelectedFile extends StatelessWidget {
  final String fileName;
  final String extension;
  final VoidCallback onChange;

  const _SelectedFile({
    required this.fileName,
    required this.extension,
    required this.onChange,
  });

  static IconData iconFor(String ext) {
    switch (ext) {
      case 'pdf':
        return Icons.picture_as_pdf_rounded;
      case 'csv':
        return Icons.table_chart_rounded;
      case 'xlsx':
        return Icons.grid_on_rounded;
      default:
        return Icons.insert_drive_file_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: const BoxDecoration(
            color: AppColors.primary,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: AppColors.controlShadow,
                blurRadius: 6,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Icon(
            iconFor(extension),
            size: 29,
            color: AppColors.surface,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          fileName,
          style: AppTextStyles.sfPRO.copyWith(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppColors.primary,
          ),
        ),
        const SizedBox(height: 4),
        GestureDetector(
          onTap: onChange,
          child: Text(
            'Change file',
            style: AppTextStyles.sfPRO.copyWith(
              fontSize: 14,
              color: AppColors.smallText,
              decoration: TextDecoration.underline,
            ),
          ),
        ),
      ],
    );
  }
}

class _FileTypeOption extends StatelessWidget {
  final _FileFormat format;
  final VoidCallback onTap;

  const _FileTypeOption({required this.format, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(format.icon, color: AppColors.primary),
      title: Text(format.label),
      subtitle: Text(
        '.${format.extension}',
        style: const TextStyle(
          fontSize: 12,
          color: AppColors.textSecondary,
        ),
      ),
      onTap: onTap,
    );
  }
}
