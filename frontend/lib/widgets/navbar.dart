import 'package:flutter/material.dart';

class Navbar extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onItemTapped;

  const Navbar({
    super.key,
    required this.selectedIndex,
    required this.onItemTapped,
  });

  @override
  Widget build(BuildContext context) {
    final List<IconData> icons = [
      Icons.home_outlined,
      Icons.apartment_outlined,
      Icons.groups_outlined,
      Icons.menu_book_outlined,
      Icons.person_outline,
    ];

    final List<String> labels = [
      'Home',
      'Department',
      'Class',
      'Subjects',
      'Profile',
    ];

    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFF1F1F1F),
        borderRadius: BorderRadius.circular(40),
      ),
      child: Row(
        mainAxisAlignment:MainAxisAlignment.spaceBetween,
          // selectedIndex == 0 || selectedIndex == 4
          //     ? MainAxisAlignment.spaceBetween
          //     : MainAxisAlignment.spaceAround,
        children: List.generate(icons.length, (index) {
          final bool isSelected = selectedIndex == index;
  
          return GestureDetector(
            onTap: () => onItemTapped(index),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              // width: isSelected ? 130 : 50,
              height: 46,
              padding: EdgeInsets.symmetric(
                horizontal: isSelected ? 16 : 10 ,
              ),
              decoration: BoxDecoration(
                color: isSelected ? Colors.white : Colors.transparent,
                borderRadius: BorderRadius.circular(30),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    icons[index],
                    color: isSelected ? Colors.black : Colors.white,
                    size: 22,
                  ),
                  if (isSelected) ...[
                    const SizedBox(width: 6),
                    Text(
                      labels[index],
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