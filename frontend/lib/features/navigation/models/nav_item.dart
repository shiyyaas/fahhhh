import 'package:flutter/material.dart';

class NavItem {
  final IconData icon;
  final String label;
  final int branchIndex;
  
  const NavItem({
    required this.icon,
    required this.label,
    required this.branchIndex,
  });
}
