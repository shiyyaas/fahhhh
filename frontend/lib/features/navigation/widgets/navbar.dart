import 'package:fahhhh/features/navigation/models/nav_item.dart';
import 'package:fahhhh/core/theme_data/app_colors.dart';
import 'package:flutter/material.dart';

class Navbar extends StatelessWidget {

  final int selectedIndex;
  final Function(int) onItemTapped;
  final List<NavItem> items;
  const Navbar({
    super.key,
    required this.selectedIndex,
    required this.onItemTapped,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        margin: const EdgeInsets.all(20),
        padding: const EdgeInsets.symmetric(
          horizontal: 10,
          vertical: 10,
        ),
        decoration: BoxDecoration(
          color: AppColors.navBar,
          borderRadius: BorderRadius.circular(52),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(items.length, (index) {
            final bool isSelected = selectedIndex == index;
            return Padding(
              padding: EdgeInsets.symmetric(horizontal: index == 0 || index == items.length - 1 ? 0 : 2),
              child: GestureDetector(
                onTap: () => onItemTapped(index),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  height: 48,
                  padding: EdgeInsets.symmetric(
                    horizontal: isSelected ? 16 : 12,
                  ),
                  decoration: BoxDecoration(
                    gradient: isSelected
                        ? const LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              AppColors.gradientTop,
                              AppColors.gradientBottom,
                            ],
                          )
                        : null,
                    color: isSelected ? null : Colors.transparent,
                    borderRadius: BorderRadius.circular(21),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        items[index].icon,
                        color: Colors.white,
                        size: 24,
                      ),
                      if (isSelected) ...[
                        const SizedBox(width: 6),
                        Text(
                          items[index].label,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            fontSize: 12.8,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            );
          }),
        ),
      ),
    );
  }

}