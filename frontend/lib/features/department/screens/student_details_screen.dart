import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:fahhhh/core/theme_data/app_colors.dart';
import 'package:fahhhh/core/theme_data/app_text_styles.dart';
import 'package:fahhhh/core/widgets/input_fields.dart';
import 'package:fahhhh/core/widgets/app_screen_scaffold.dart';
import 'package:fahhhh/core/widgets/app_button.dart';

/// Student details screen (Figma node 1562:7810).
///
/// Blue header with back arrow, Delete/Edit pill buttons, and five floating
/// labelled input fields: Student Name, Apaar ID, Aadhar No, Phone No, Email.
class StudentDetailsScreen extends StatefulWidget {
  final String rollNumber;
  final String name;

  const StudentDetailsScreen({
    super.key,
    required this.rollNumber,
    required this.name,
  });

  @override
  State<StudentDetailsScreen> createState() => _StudentDetailsScreenState();
}

class _StudentDetailsScreenState extends State<StudentDetailsScreen> {
  late final TextEditingController _nameController;
  late final TextEditingController _appaarController;
  late final TextEditingController _aadharController;
  late final TextEditingController _phoneController;
  late final TextEditingController _emailController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.name);
    _appaarController = TextEditingController(text: widget.rollNumber);
    _aadharController = TextEditingController(text: '9893 8145 9338');
    _phoneController = TextEditingController(text: '6235223761');
    _emailController =
        TextEditingController(text: 'shiyasps@mescas.org');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _appaarController.dispose();
    _aadharController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AppScreenScaffold(
        child: Column(
          children: [
            _HeaderSection(onBack: () => context.pop()),
            const SizedBox(height: 24),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  InputField(
                    controller: _nameController,
                    label: 'Student Name',
                    hintText: 'Enter student name',
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter student name';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 14),
                  InputField(
                    controller: _appaarController,
                    label: 'Apaar ID',
                    hintText: 'Enter apaar id',
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter apaar ID';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 14),
                  InputField(
                    controller: _aadharController,
                    label: 'Aadhar No',
                    hintText: 'Enter aadhar no',
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter aadhar number';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 14),
                  InputField(
                    controller: _phoneController,
                    label: 'Phone No',
                    hintText: 'Enter phone no',
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter phone number';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 14),
                  InputField(
                    controller: _emailController,
                    label: 'Email',
                    hintText: 'Enter email',
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter email';
                      }
                      if (!value.contains('@')) {
                        return 'Please enter a valid email';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 32),
                  Row(
                    children: [
                      Expanded(
                        child: _DeleteButton(
                          onPressed: () {},
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: AppButton.primary(
                          text: 'Edit',
                          onPressed: () {},
                          height: 29,
                          borderRadius: 28,
                          backgroundColor: AppColors.primary,
                          borderColor: AppColors.primary,
                          padding: EdgeInsets.zero,
                          boxShadow: const [],
                          textStyle: AppTextStyles.heading.copyWith(
                            fontSize: 14,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Blue header with back arrow, title, and subtitle — matches the Figma
/// "Student details" / "Manage student details here" block.
class _HeaderSection extends StatelessWidget {
  final VoidCallback onBack;

  const _HeaderSection({required this.onBack});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 143,
      decoration: const BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(25),
          bottomRight: Radius.circular(25),
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            left: 15,
            top: 61,
            child: IconButton(
              onPressed: onBack,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints.tightFor(
                width: 26,
                height: 41,
              ),
              icon: const Icon(Icons.arrow_back, size: 26, color: Colors.white),
            ),
          ),
          Positioned(
            left: 47,
            top: 61,
            right: 15,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Student details',
                  style: AppTextStyles.heading.copyWith(
                    fontSize: 25,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Manage student details here',
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.small.copyWith(
                    fontSize: 15,
                    color: Colors.white.withValues(alpha: 0.85),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Red "Delete" pill button matching the Figma white btn variant.
class _DeleteButton extends StatefulWidget {
  final VoidCallback onPressed;

  const _DeleteButton({required this.onPressed});

  @override
  State<_DeleteButton> createState() => _DeleteButtonState();
}

class _DeleteButtonState extends State<_DeleteButton> {
  bool _isPressed = false;

  static const Color _deleteColor = Color(0xFFEE7373);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) {
        setState(() => _isPressed = false);
        widget.onPressed();
      },
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 120),
        height: 29,
        decoration: BoxDecoration(
          color: _isPressed ? _deleteColor.withValues(alpha: 0.85) : _deleteColor,
          borderRadius: const BorderRadius.all(Radius.circular(28)),
          border: Border.all(color: _deleteColor),
          boxShadow: const [
            BoxShadow(
              color: Color(0x1A000000),
              blurRadius: 3,
              offset: Offset(0, 1),
            ),
          ],
        ),
        alignment: Alignment.center,
        child: Text(
          'Delete',
          style: AppTextStyles.heading.copyWith(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}