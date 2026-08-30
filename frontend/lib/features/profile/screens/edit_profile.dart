import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

// Design
import 'package:fahhhh/core/theme_data/app_text_styles.dart';

// Providers
import 'package:fahhhh/features/auth/providers/auth_provider.dart';

// Widgets
import 'package:fahhhh/core/widgets/blue_btn.dart';

class EditProfileScreen extends ConsumerStatefulWidget {
  const EditProfileScreen({super.key});

  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _phoneController;
  late final TextEditingController _emailController;

  @override
  void initState() {
    super.initState();
    final user = ref.read(authProvider).user;
    _nameController = TextEditingController(text: user?.name ?? '');
    _phoneController = TextEditingController(text: user?.phone ?? '');
    _emailController = TextEditingController(text: user?.email ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authProvider).user;

    if (user == null) {
      return const Scaffold(
        body: Center(
          child: Text('No authenticated user session found.'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Edit Profile',
          style: AppTextStyles.heading.copyWith(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (!context.mounted) return;
            context.pop();
          },
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.black,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Column(
                    children: [
                      CircleAvatar(
                        radius: 55,
                        backgroundImage: user.imageUrl != null
                            ? AssetImage(user.imageUrl!)
                            : null,
                        child: user.imageUrl == null
                            ? const Icon(
                                Icons.person,
                                size: 60,
                                color: Colors.white,
                              )
                            : null,
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'Modify your core credentials below',
                        style: AppTextStyles.sfPRO.copyWith(
                          fontSize: 14,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 30),

                // NAME FIELD
                _buildLabel('Full Name'),
                const SizedBox(height: 6),
                _buildTextFormField(
                  controller: _nameController,
                  hintText: 'Enter your name',
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Name cannot be empty';
                    }
                    if (value.trim().length < 2) {
                      return 'Please enter a valid name';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),

                // EMAIL FIELD
                _buildLabel('Email Address'),
                const SizedBox(height: 6),
                _buildTextFormField(
                  controller: _emailController,
                  hintText: 'Enter your email address',
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Email address cannot be empty';
                    }
                    final trimmed = value.trim();
                    if (!trimmed.contains('@') || !trimmed.contains('.')) {
                      return 'Please enter a valid email address';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),

                // PHONE FIELD
                _buildLabel('Phone Number'),
                const SizedBox(height: 6),
                _buildTextFormField(
                  controller: _phoneController,
                  hintText: 'Enter your phone number',
                  keyboardType: TextInputType.phone,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Phone number cannot be empty';
                    }
                    final trimmed = value.trim();
                    if (trimmed.length < 8) {
                      return 'Please enter a valid phone number';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 40),

                // SAVE BUTTON
                BlueBtn(
                  text: "Save Changes",
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                      await ref.read(authNotifierProvider.notifier).updateProfile(
                            name: _nameController.text.trim(),
                            email: _emailController.text.trim(),
                            phone: _phoneController.text.trim(),
                          );
                      if (!context.mounted) return;
                      context.pop();
                    }
                  },
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 14,
                  ),
                  mainAxisAlignment: MainAxisAlignment.center,
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String label) {
    return Text(
      label,
      style: AppTextStyles.sfPRO.copyWith(
        fontSize: 16,
        color: const Color.fromARGB(255, 59, 59, 59),
        fontWeight: FontWeight.w600,
      ),
    );
  }

  Widget _buildTextFormField({
    required TextEditingController controller,
    required String hintText,
    required String? Function(String?) validator,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextFormField(
      cursorColor: Colors.black,
      controller: controller,
      keyboardType: keyboardType,
      validator: validator,
      decoration: InputDecoration(
        hintText: hintText,
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(
          vertical: 12,
          horizontal: 16,
        ),
        hintStyle: const TextStyle(
          color: Color.fromARGB(255, 172, 172, 172),
          fontSize: 14,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: const BorderSide(
            color: Color.fromARGB(255, 172, 172, 172),
            width: 2,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: const BorderSide(
            color: Color.fromRGBO(0, 0, 0, 1.0),
            width: 1,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: const BorderSide(
            color: Colors.red,
            width: 2,
          ),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: const BorderSide(
            color: Colors.red,
            width: 2,
          ),
        ),
      ),
    );
  }
}
