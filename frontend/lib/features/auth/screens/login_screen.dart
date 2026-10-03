import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

// provider
import 'package:fahhhh/features/auth/providers/auth_provider.dart';

// models
import 'package:fahhhh/features/auth/models/auth_state.dart';

// Design system
import '../../../core/theme_data/app_colors.dart';
import '../../../core/theme_data/app_text_styles.dart';
import '../../../core/widgets/input_fields.dart';
import '../../../features/auth/widgets/debug_role_selector.dart';

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authNotifierProvider);

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 32,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 80),

              Text(
                'Welcome',
                style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                      fontSize: 40,
                      height: 1.1,
                    ),
              ),

              Padding(
                padding: const EdgeInsets.only(
                  left: 4,
                  top: 4,
                ),
                child: Text(
                  'Sign in to your account',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),

              const SizedBox(height: 80),

              InputField(
                controller: emailController,
                label: 'Email address',
                hintText: 'Enter your email address',
              ),

              const SizedBox(height: 10),

              InputField(
                controller: passwordController,
                label: 'Password',
                hintText: 'Enter your password',
                obscureText: true,
              ),

              const SizedBox(height: 6),

              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () {},
                  child: Text(
                    'Forgot password?',
                    style: AppTextStyles.small.copyWith(
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ),

              const Spacer(),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: authState is Authenticating
                      ? null
                      : () async {
                          try {
                            final email = emailController.text.trim();
                            final password = passwordController.text;

                            if (email.isEmpty) {
                              throw Exception('Email cannot be empty');
                            }

                            if (!email.contains('@')) {
                              throw Exception(
                                'Invalid email address format',
                              );
                            }

                            if (password.isEmpty) {
                              throw Exception(
                                'Password cannot be empty',
                              );
                            }

                            if (password.length < 4) {
                              throw Exception(
                                'Password must be at least 4 characters',
                              );
                            }

                            await ref
                                .read(authNotifierProvider.notifier)
                                .login(email, password);

                            final latestState =
                                ref.read(authNotifierProvider);

                            if (latestState is AuthenticationFailed) {
                              throw Exception(latestState.message);
                            }

                            if (!context.mounted) return;

                            if (latestState is Authenticated) {
                              context.go('/home');
                            }
                          } catch (e) {
                            if (!context.mounted) return;

                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  e.toString().replaceAll(
                                        'Exception: ',
                                        '',
                                      ),
                                ),
                                backgroundColor: Colors.redAccent,
                              ),
                            );

                            debugPrint(e.toString());
                          }
                        },
                  child: authState is Authenticating
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Text(
                          'Login',
                          style: TextStyle(
                            fontSize: 20,
                          ),
                        ),
                ),
              ),

              const SizedBox(height: 40),

              // Debug: show role selector in debug mode
              if (const bool.fromEnvironment('dart.vm.product') == false)
                TextButton(
                  onPressed: () {
                    showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      backgroundColor: Colors.transparent,
                      builder: (context) => DebugRoleSelector(
                        onSelect: (email, password) {
                          emailController.text = email;
                          passwordController.text = password;
                        },
                      ),
                    );
                  },
                  child: Text(
                    'Debug Role Selector',
                    style: AppTextStyles.small.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}