import 'package:circle_nav_bar/circle_nav_bar.dart';
import 'package:flutter/material.dart';

class BottomNav extends StatelessWidget {
  final int currentIndex;
  // ✅ Ganti ValueChanged<int> menjadi void Function(int) agar lebih modern
  final void Function(int) onTabItemSelected;
  final Color primaryColor;

  const BottomNav({
    super.key,
    required this.currentIndex,
    required this.onTabItemSelected,
    required this.primaryColor,
  });

  // ✅ Pindahkan daftar ikon ke variabel static const.
  // Ini memastikan list dan ikon di dalamnya hanya dibuat SEKALI saat kompilasi,
  // bukan setiap kali widget di-build ulang. Inilah kunci untuk menghilangkan kedipan.
  static const List<Widget> _activeIcons = [
    Icon(Icons.home, color: Colors.white),
    // Icon(Icons.fingerprint, color: Colors.white),
    Icon(Icons.person, color: Colors.white),
  ];

  static const List<Widget> _inactiveIcons = [
    Icon(Icons.home, color: Colors.grey),
    // Icon(Icons.fingerprint, color: Colors.grey),
    Icon(Icons.person, color: Colors.grey),
  ];

  @override
  Widget build(BuildContext context) {
    return CircleNavBar(
      // ✅ Gunakan variabel yang sudah didefinisikan di atas
      activeIcons: _activeIcons,
      inactiveIcons: _inactiveIcons,
      color: Colors.white,
      circleColor: primaryColor,
      height: 60,
      circleWidth: 55,
      activeIndex: currentIndex,
      onTap: onTabItemSelected,
      padding: const EdgeInsets.only(left: 16, right: 16, bottom: 12),
      cornerRadius: const BorderRadius.only(
        topLeft: Radius.circular(16),
        topRight: Radius.circular(16),
        bottomLeft: Radius.circular(24),
        bottomRight: Radius.circular(24),
      ),
      elevation: 8,
      shadowColor: Colors.black26,
    );
  }
}
