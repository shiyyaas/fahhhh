import 'package:flutter/material.dart';

/// Gradient circle with three white dots used in department headers.
class MoreButton extends StatelessWidget {
  final VoidCallback? onTap;
  const MoreButton({super.key, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: 43,
        height: 36,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Container(
              width: 37,
              height: 36,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0xFF7198EE), Color(0xFF163B8E)],
                ),
              ),
            ),
            Column(
              mainAxisSize: MainAxisSize.min,
              children: List.generate(
                3,
                (index) => Container(
                  width: 18,
                  height: 3.9,
                  margin: const EdgeInsets.symmetric(vertical: 1),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(26),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
