import 'package:fahhhh/models/nav_item.dart';
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

    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 10,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFF1F1F1F),
        borderRadius: BorderRadius.circular(40),
      ),

      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: List.generate(items.length, (index) {
          final bool isSelected = selectedIndex == index;
          return GestureDetector(
            onTap: () => onItemTapped(index),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              height: 46,
              padding: EdgeInsets.symmetric(
                horizontal: isSelected ? 16 : 10,
              ),

              decoration: BoxDecoration(
                color: isSelected
                    ? Colors.white
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(30),
              ),

              child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,

                children: [

                  Icon(
                    items[index].icon,
                    color: isSelected
                        ? Colors.black
                        : Colors.white,
                    size: 22,
                  ),

                  if (isSelected) ...[
                    const SizedBox(width: 6),
                    Text(
                      items[index].label,
                      style: const TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),

                    ),

                  ],

                ],

              ),

            ),

          );

        }),

      ),

    );

  }

}