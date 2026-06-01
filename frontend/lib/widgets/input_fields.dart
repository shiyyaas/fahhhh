import 'package:flutter/material.dart';
import '../theme_data/app_text_styles.dart';

class InputField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String hintText;
  final bool obscureText;

  const InputField({
    super.key,
    required this.controller,
    required this.label,
    required this.hintText,
    this.obscureText = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [

        Text(
          label,
          style: AppTextStyles.sfPRO.copyWith(
            fontSize: 16,
            color: const Color.fromARGB(255, 59, 59, 59),
            fontWeight: FontWeight.w600,
          ),
        ),

        const SizedBox(height: 1),

        TextField(
          cursorColor: Colors.black,
          controller: controller,
          obscureText: obscureText,
          decoration: InputDecoration(
            hintText: hintText,
            isDense: true,
            contentPadding: const EdgeInsets.symmetric(
              vertical: 10,
              horizontal: 16,
            ),
            hintStyle: const TextStyle(
              color: Color.fromARGB(255, 80, 79, 79),
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
            disabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(30),
              borderSide: BorderSide(
                color: Colors.grey.shade300,
                width: 2,
              ),
            ),
          ),
        ),

      ],
    );
  }
}