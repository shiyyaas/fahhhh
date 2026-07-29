import 'package:flutter/material.dart';

class DebugRoleSelector extends StatelessWidget {
  final Function(String email, String password) onSelect;

  const DebugRoleSelector({
    super.key,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 24),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Debug Profile Selector',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: 10),
            const Text(
              'Select a mock profile to auto-fill credentials for testing:',
              style: TextStyle(color: Colors.grey, fontSize: 14),
            ),
            const SizedBox(height: 20),
            _buildProfileButton(
              context,
              title: '1. Student Profile',
              subtitle: 'student@mescas.org',
              color: Colors.blue.shade50,
              textColor: Colors.blue.shade900,
              onTap: () => onSelect('student@mescas.org', 'password123'),
            ),
            const SizedBox(height: 12),
            _buildProfileButton(
              context,
              title: '2. Pure Teacher Profile',
              subtitle: 'teacher@mescas.org',
              color: Colors.green.shade50,
              textColor: Colors.green.shade900,
              onTap: () => onSelect('teacher@mescas.org', 'password123'),
            ),
            const SizedBox(height: 12),
            _buildProfileButton(
              context,
              title: '3. Class Teacher Profile',
              subtitle: 'classteacher@mescas.org',
              color: Colors.purple.shade50,
              textColor: Colors.purple.shade900,
              onTap: () => onSelect('classteacher@mescas.org', 'password123'),
            ),
            const SizedBox(height: 12),
            _buildProfileButton(
              context,
              title: '4. HOD + Class Teacher Profile',
              subtitle: 'sheetal@mescas.org',
              color: Colors.orange.shade50,
              textColor: Colors.orange.shade900,
              onTap: () => onSelect('sheetal@mescas.org', 'password123'),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileButton(
    BuildContext context, {
    required String title,
    required String subtitle,
    required Color color,
    required Color textColor,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: () {
        onTap();
        Navigator.pop(context);
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: textColor.withOpacity(0.2)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: textColor,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: textColor.withOpacity(0.7),
                    fontSize: 13,
                  ),
                ),
              ],
            ),
            Icon(Icons.arrow_forward_ios, size: 16, color: textColor),
          ],
        ),
      ),
    );
  }
}
