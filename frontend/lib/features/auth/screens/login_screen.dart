import 'package:flutter/material.dart';

//provider
import 'package:fahhhh/features/auth/providers/auth_provider.dart';

//
import 'package:fahhhh/features/auth/models/auth_state.dart';
import 'package:fahhhh/features/auth/models/user_role.dart';

// Routes
import 'package:fahhhh/core/routes/app_routes.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Design system
import '../../../core/theme_data/app_colors.dart';
import '../../../core/theme_data/app_text_styles.dart';
import '../../../core/widgets/input_fields.dart';

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {

  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      resizeToAvoidBottomInset: false,
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
                style: Theme.of(context)
                    .textTheme
                    .headlineLarge
                    ?.copyWith(
                      fontSize: 40,
                      height: 1.1,
                      ),
              ),

              Padding(
                padding: const EdgeInsets.only(
                  left: 4, // ← only left padding
                  top: 4,  // ← only top padding
                ),
                child: Text(
                  "Sign in to your account",
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium,
                ),
              ),

              const SizedBox(height: 80),

              InputField(
                controller: emailController,
                label: "Email address",
                hintText: "Enter your email address"
                ),

              const SizedBox(height: 10),

              InputField(
                controller: passwordController,
                label: "Password", 
                hintText: "Enter your password",
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

                  onPressed: () {
                    if (
                      emailController.text == "shiyas" &&
                      passwordController.text == "shiyas"
                    ){
                      ref.read(authProvider.notifier).state =
                        const AuthState(
                          isLoggedIn: true,
                          role: UserRole.student,
                        );
                      Navigator.pushReplacementNamed(
                        context,
                        AppRoutes.main,
                      );
                    }else if(
                      emailController.text == "teacher" &&
                      passwordController.text == "teacher"
                    ){
                      ref.read(authProvider.notifier).state =
                        const AuthState(
                          isLoggedIn: true,
                          role: UserRole.teacher,
                        );
                      Navigator.pushReplacementNamed(
                        context,
                        AppRoutes.main,
                      );
                    }else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("Invalid credentials"),
                        ),
                      );
                    }
                  },

                  child: const Text(
                    'Login',
                    style: TextStyle(
                      fontSize: 20, 
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 40),

            ],
          ),
        ),
      ),
    );
  }
}