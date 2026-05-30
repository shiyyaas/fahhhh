import 'package:flutter/material.dart';

import '../theme_data/app_colors.dart';
import '../theme_data/app_text_styles.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {

  final TextEditingController emailController = TextEditingController();

  final TextEditingController passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {

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
                style: Theme.of(context)
                    .textTheme
                    .headlineMedium,
              ),

              const SizedBox(height: 4),

              Text(
                "Sign in to your account",
                style: Theme.of(context)
                    .textTheme
                    .titleMedium,
              ),

              const SizedBox(height: 80),

              Text(
                'Email address',
                style: AppTextStyles.small.copyWith(
                  color: AppColors.headingText,
                ),
              ),

              const SizedBox(height: 8),

              TextField(
                controller: emailController,

                decoration: const InputDecoration(
                  hintText: "Enter your email address",
                ),
              ),

              const SizedBox(height: 24),

              Text(
                'Password',
                style: AppTextStyles.small.copyWith(
                  color: AppColors.headingText,
                ),
              ),

              const SizedBox(height: 8),

              TextField(
                controller: passwordController,
                obscureText: true,

                decoration: const InputDecoration(
                  hintText: "Enter your password",
                ),
              ),

              const SizedBox(height: 10),

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

                  onPressed: () {},

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