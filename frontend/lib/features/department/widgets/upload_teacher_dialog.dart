import 'package:flutter/material.dart';
import 'package:fahhhh/core/theme_data/app_text_styles.dart';

class UploadTeacherDialog extends StatefulWidget {
  const UploadTeacherDialog({super.key});

  @override
  State<UploadTeacherDialog> createState() => _UploadTeacherDialogState();
}

class _UploadTeacherDialogState extends State<UploadTeacherDialog> {
  String? _selectedFileName;
  String? _selectedExtension;

  void _pickFile() {
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
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                _FileTypeOption(
                  icon: Icons.picture_as_pdf_rounded,
                  label: 'PDF Document',
                  extension: 'pdf',
                  onTap: () {
                    Navigator.pop(ctx);
                    setState(() {
                      _selectedFileName = 'teachers_data.pdf';
                      _selectedExtension = 'pdf';
                    });
                  },
                ),
                _FileTypeOption(
                  icon: Icons.table_chart_rounded,
                  label: 'CSV Spreadsheet',
                  extension: 'csv',
                  onTap: () {
                    Navigator.pop(ctx);
                    setState(() {
                      _selectedFileName = 'teachers_data.csv';
                      _selectedExtension = 'csv';
                    });
                  },
                ),
                _FileTypeOption(
                  icon: Icons.grid_on_rounded,
                  label: 'Excel Spreadsheet',
                  extension: 'xlsx',
                  onTap: () {
                    Navigator.pop(ctx);
                    setState(() {
                      _selectedFileName = 'teachers_data.xlsx';
                      _selectedExtension = 'xlsx';
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
              border: Border.all(color: Colors.black, width: 1),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Upload Teacher Data',
                  style: AppTextStyles.heading.copyWith(
                    fontSize: 26,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 20),
                GestureDetector(
                  onTap: _pickFile,
                  child: Container(
                    height: 165,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF0F7FF),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: const Color(0xFF1A6BB6),
                        width: 2,
                        style: BorderStyle.solid,
                      ),
                    ),
                    child: _selectedFileName != null
                        ? Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: const BoxDecoration(
                                  color: Color(0xFF1A6BB6),
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Color(0x1A000000),
                                      blurRadius: 6,
                                      offset: Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: Icon(
                                  _getFileIcon(_selectedExtension!),
                                  size: 29,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(height: 10),
                              Text(
                                _selectedFileName!,
                                style: AppTextStyles.sfPRO.copyWith(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: const Color(0xFF1A6BB6),
                                ),
                              ),
                              const SizedBox(height: 4),
                              GestureDetector(
                                onTap: () {
                                  setState(() {
                                    _selectedFileName = null;
                                    _selectedExtension = null;
                                  });
                                },
                                child: Text(
                                  'Change file',
                                  style: AppTextStyles.sfPRO.copyWith(
                                    fontSize: 13,
                                    color: const Color(0xFF635959),
                                    decoration: TextDecoration.underline,
                                  ),
                                ),
                              ),
                            ],
                          )
                        : Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: const BoxDecoration(
                                  color: Color(0xFF1A6BB6),
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Color(0x1A000000),
                                      blurRadius: 6,
                                      offset: Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: const Icon(
                                  Icons.cloud_upload_rounded,
                                  size: 29,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Select file to upload',
                                style: AppTextStyles.sfPRO.copyWith(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: const Color(0xFF1A6BB6),
                                ),
                              ),
                            ],
                          ),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Supported formats: .pdf, .csv, .xlsx',
                  style: AppTextStyles.small.copyWith(fontSize: 17.7),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  height: 31,
                  child: ElevatedButton(
                    onPressed: _selectedFileName != null
                        ? () {
                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  'Uploading $_selectedFileName...',
                                ),
                                behavior: SnackBarBehavior.floating,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                            );
                          }
                        : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF136BB3),
                      foregroundColor: Colors.white,
                      disabledBackgroundColor:
                          const Color(0xFF136BB3).withValues(alpha: 0.5),
                      elevation: 3,
                      shadowColor: Colors.black.withValues(alpha: 0.15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(28),
                        side: const BorderSide(
                          color: Colors.black,
                          width: 1,
                        ),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                    ),
                    child: Text(
                      'Confirm Upload',
                      style: AppTextStyles.heading.copyWith(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  height: 28,
                  child: TextButton(
                    onPressed: () => Navigator.pop(context),
                    style: TextButton.styleFrom(
                      foregroundColor: const Color(0xFF136BB3),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(26),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                    ),
                    child: Text(
                      'Cancel',
                      style: AppTextStyles.heading.copyWith(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF136BB3),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  IconData _getFileIcon(String ext) {
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
}

class _FileTypeOption extends StatelessWidget {
  final IconData icon;
  final String label;
  final String extension;
  final VoidCallback onTap;

  const _FileTypeOption({
    required this.icon,
    required this.label,
    required this.extension,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: const Color(0xFF136BB3)),
      title: Text(label),
      subtitle: Text(
        '.$extension',
        style: const TextStyle(fontSize: 12, color: Color(0xFF635959)),
      ),
      onTap: onTap,
    );
  }
}
