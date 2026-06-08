import 'package:flutter/material.dart';
import '../../../core/theme_data/app_text_styles.dart';

class HeaderSection extends StatelessWidget {

  const HeaderSection({super.key});

  @override
  Widget build(BuildContext context) {

    return Padding(

      padding: const EdgeInsets.symmetric(
        horizontal: 24,
        vertical: 16,
      ),

      child: Row(

        children: [

          Container(

            width: 60,
            height: 60,

            decoration: BoxDecoration(

              shape: BoxShape.circle,

              color: Colors.grey.shade300,

              image: const DecorationImage(

                image: AssetImage(
                  'assets/images/profile.png',
                ),

                fit: BoxFit.cover,

              ),

            ),

          ),

          const SizedBox(width: 16),

          Expanded(

            child: Column(

              crossAxisAlignment: CrossAxisAlignment.start,

              children: [
                Text(
                  'Anu Varghese',
                  style: AppTextStyles.heading.copyWith(
                    height: 0.9,
                  ),
                ),
                Text(
                  'HOD - Computer Science',
                  style: AppTextStyles.small.copyWith(
                    height: 1,
                  ),
                ),
              ],

            ),

          ),

          Container(

            width: 55,
            height: 55,

            decoration: const BoxDecoration(

              shape: BoxShape.circle,

              gradient: LinearGradient(

                colors: [

                  Color(0xFF4A7DFF),
                  Color(0xFF1B3EA7),

                ],

                begin: Alignment.topLeft,
                end: Alignment.bottomRight,

              ),

            ),

            child: IconButton(

              onPressed: () {},

              icon: const Icon(

                Icons.notifications_none_rounded,

                color: Colors.white,

                size: 28,

              ),

            ),

          ),

        ],

      ),

    );

  }

}