import 'package:flutter/material.dart';
import 'package:circle_nav_bar/circle_nav_bar.dart';

class BottomNav extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTabItemSelected;
  final Color primaryColor;

  const BottomNav({
    super.key,
    required this.currentIndex,
    required this.onTabItemSelected,
    required this.primaryColor,
  });

  @override
  Widget build(BuildContext context) {
    return CircleNavBar(
      activeIcons: const [
        Icon(Icons.home, color: Colors.white),
        Icon(Icons.fingerprint, color: Colors.white), // Absen fingerprint
        Icon(Icons.person, color: Colors.white),
      ],
      inactiveIcons: const [
        Icon(Icons.home, color: Colors.grey),
        Icon(Icons.fingerprint, color: Colors.grey),
        Icon(Icons.person, color: Colors.grey),
      ],
      color: Colors.white,
      height: 60,
      circleWidth: 55,
      activeIndex: currentIndex,
      onTap: (index) {
        onTabItemSelected(index);
      },
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      cornerRadius: BorderRadius.circular(24),
      circleColor: primaryColor,
      elevation: 10,
    );
  }
}
