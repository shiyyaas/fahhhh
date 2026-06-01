import 'package:flutter/material.dart';

// Routes
import 'package:fahhhh/app_routes.dart';

// Design system
import '../theme_data/app_colors.dart';
import '../theme_data/app_text_styles.dart';
import '../widgets/input_fields.dart';

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
                    Navigator.pushReplacementNamed(
                      context,
                      AppRoutes.home,
                    );
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