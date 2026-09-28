import 'package:flutter/material.dart';

import '../theme_data/app_colors.dart';
import '../theme_data/app_text_styles.dart';
import 'app_button.dart';

/// Shared dialog shell for the "Add New X" forms.
///
/// Owns the surface, border, title, and the primary/cancel button pair so
/// the student, subject, and teacher variants only declare their fields.
class AppFormDialog extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final String title;
  final List<Widget> fields;
  final String primaryText;
  final VoidCallback onPrimary;

  const AppFormDialog({
    super.key,
    required this.formKey,
    required this.title,
    required this.fields,
    required this.primaryText,
    required this.onPrimary,
  });

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
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: AppColors.border, width: 1),
            ),
            child: SingleChildScrollView(
              child: Form(
                key: formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      title,
                      style: AppTextStyles.heading.copyWith(
                        fontSize: 24,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 24),
                    for (var i = 0; i < fields.length; i++) ...[
                      if (i > 0) const SizedBox(height: 14),
                      fields[i],
                    ],
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: AppButton.primary(
                        text: primaryText,
                        onPressed: onPrimary,
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

/// Shows the standard "Added X successfully" confirmation.
void showAddedSnackBar(BuildContext context, String entity) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text('Added $entity successfully'),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
    ),
  );
}
