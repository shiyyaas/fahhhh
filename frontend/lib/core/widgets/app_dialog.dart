import 'package:flutter/material.dart';

import '../theme_data/app_colors.dart';
import '../theme_data/app_text_styles.dart';
import 'app_button.dart';

class AppDialog extends StatelessWidget {
  final String title;
  final Widget child;
  final String primaryText;
  final VoidCallback? onPrimary;
  final String cancelText;
  final VoidCallback? onCancel;
  final bool primaryEnabled;

  const AppDialog({
    super.key,
    required this.title,
    required this.child,
    required this.primaryText,
    this.onPrimary,
    this.cancelText = 'Cancel',
    this.onCancel,
    this.primaryEnabled = true,
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
              color: AppColors.background,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: AppColors.border, width: 1),
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    title,
                    style: AppTextStyles.heading.copyWith(
                      fontSize: 26,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 20),
                  child,
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: AppButton.primary(
                      text: primaryText,
                      onPressed: () {
                        if (primaryEnabled) {
                          onPrimary?.call();
                        }
                      },
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
                      text: cancelText,
                      onPressed: () {
                        if (onCancel != null) {
                          onCancel!();
                      } else {
                          Navigator.of(context).pop();
                        }
                      },
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
    );
  }
}
