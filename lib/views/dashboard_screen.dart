import 'dart:async';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
// Ganti dengan path project Anda yang benar
import 'package:tugas_ujk/api/absen_Service.dart';
import 'package:tugas_ujk/api/auth_service.dart';
import 'package:tugas_ujk/models/get_user_model.dart';
import 'package:tugas_ujk/views/chart.dart';
import 'package:tugas_ujk/views/history.dart';
import 'package:tugas_ujk/views/leave_request.dart';
import 'package:tugas_ujk/views/map_checkin_screen.dart';
import 'package:tugas_ujk/views/profile_screen.dart';
import 'package:tugas_ujk/widgets/bottom_nav.dart';

class LiveClock extends StatefulWidget {
  const LiveClock({super.key});

  @override
  State<LiveClock> createState() => _LiveClockState();
}

class _LiveClockState extends State<LiveClock> {
  late Timer _timer;
  late String _timeString;

  @override
  void initState() {
    super.initState();
    _timeString = DateFormat('HH:mm:ss').format(DateTime.now());
    _timer = Timer.periodic(
      const Duration(seconds: 1),
      (Timer t) => _getTime(),
    );
  }

  void _getTime() {
    if (mounted) {
      setState(() {
        _timeString = DateFormat('HH:mm:ss').format(DateTime.now());
      });
    }
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Text(
      _timeString,
      style: TextStyle(color: Colors.grey[600], fontSize: 14),
    );
  }
}

class DashboardScreen extends StatefulWidget {
  static const id = '/dashboard';
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _currentIndex = 0;
  late Future<GetUserModel> _profileFuture;
  Map<String, dynamic>? _absenTodayData;

  final Color _backgroundColor = const Color(0xFFF8F9FD);
  final Color _primaryBlue = const Color(0xFF3E8DE8);
  final Color _darkTextColor = const Color(0xFF2D3035);
  final Color _lightTextColor = Colors.grey.shade600;

  @override
  void initState() {
    super.initState();
    _profileFuture = AuthenticationAPI.getProfile();
    _absenToday();
  }

  void _refreshProfile() {
    setState(() {
      _profileFuture = AuthenticationAPI.getProfile();
    });
  }

  Future<void> _absenToday() async {
    final response = await AbsenService.getAbsenToday();
    if (!mounted) return;
    if (response != null && response.data != null) {
      setState(() {
        _absenTodayData = {
          "status": response.data!.status ?? "On Progress",
          "check_in": response.data!.checkInTime ?? "--:--",
          "check_out": response.data!.checkOutTime ?? "--:--",
        };
      });
    } else {
      setState(() {
        _absenTodayData = {
          "status": "On Progress",
          "check_in": "--:--",
          "check_out": "--:--",
        };
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // ===== 2. PERBAIKI BAGIAN INI =====
    final pages = [
      _buildDashboardPage(),
      // Berikan method _refreshProfile ke ProfilePage
      ProfilePage(onProfileUpdated: _refreshProfile),
    ];

    return Scaffold(
      backgroundColor: _backgroundColor,
      appBar: AppBar(
        backgroundColor: _backgroundColor,
        elevation: 0,
        centerTitle: true,
        title: Text(
          _currentIndex == 0 ? "Dashboard" : "Profile",
          style: TextStyle(
            color: _primaryBlue,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        // leading: _currentIndex == 0
        //     ? IconButton(
        //         icon: Icon(Icons.arrow_back, color: _darkTextColor),
        //         onPressed: () async {
        //           await AuthenticationAPI.logout();
        //           if (mounted) {
        //             Navigator.pushReplacementNamed(context, '/login');
        //           }
        //         },
        //       )
        //     : null,
        // automaticallyImplyLeading:
        //     _currentIndex != 0,
      ),
      body: pages[_currentIndex],
      bottomNavigationBar: BottomNav(
        currentIndex: _currentIndex,
        onTabItemSelected: (i) {
          setState(() => _currentIndex = i);
        },
        primaryColor: _primaryBlue,
      ),
    );
  }

  Widget _buildDashboardPage() {
    final checkIn = _absenTodayData?['check_in'] ?? "--:--";
    final checkOut = _absenTodayData?['check_out'] ?? "--:--";
    final status =
        (_absenTodayData?['check_in'] != "--:--" &&
            _absenTodayData?['check_out'] != "--:--")
        ? "Completed"
        : "On Progress";

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      children: [
        _buildHeader(),
        const SizedBox(height: 32),
        _buildAttendanceCard(status, checkIn, checkOut),
        const SizedBox(height: 32),
        Text(
          "Quick Access",
          style: TextStyle(
            color: _darkTextColor,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        _buildQuickAccessGrid(),
      ],
    );
  }

  Widget _buildHeader() {
    return FutureBuilder<GetUserModel>(
      future: _profileFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError ||
            !snapshot.hasData ||
            snapshot.data?.data == null) {
          // Tampilan jika error atau tidak ada data
          return const Text("Gagal memuat data user");
        }

        final userData = snapshot.data!.data!;
        final name =
            userData.name
                ?.split(' ')
                .map(
                  (word) => word.isNotEmpty
                      ? '${word[0].toUpperCase()}${word.substring(1).toLowerCase()}'
                      : '',
                )
                .join(' ') ??
            "User";
        final imageUrl = userData.profilePhotoUrl;

        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                RichText(
                  text: TextSpan(
                    style: TextStyle(fontSize: 22, color: _darkTextColor),
                    children: [
                      const TextSpan(text: "Hello, "),
                      TextSpan(
                        text: name,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const TextSpan(text: "!"),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(
                      Icons.watch_later_outlined,
                      color: _lightTextColor,
                      size: 16,
                    ),
                    const SizedBox(width: 6),
                    const LiveClock(),
                  ],
                ),
              ],
            ),
            CircleAvatar(
              radius: 30,
              backgroundColor: Colors.grey[200],
              backgroundImage: (imageUrl != null && imageUrl.isNotEmpty)
                  ? NetworkImage(imageUrl)
                  : null,
              child: (imageUrl == null || imageUrl.isEmpty)
                  ? Text(
                      name.isNotEmpty
                          ? name.split(' ').map((e) => e[0]).take(2).join()
                          : "U",
                      style: TextStyle(
                        fontSize: 22,
                        color: _lightTextColor,
                        fontWeight: FontWeight.bold,
                      ),
                    )
                  : null,
            ),
          ],
        );
      },
    );
  }

  Widget _buildAttendanceCard(String status, String checkIn, String checkOut) {
    // ... (Tidak ada perubahan di sini) ...
    final bool isCompleted = status == "Completed";
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 2,
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Attendance Today",
                style: TextStyle(
                  color: _darkTextColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: isCompleted
                      ? Colors.green.shade50
                      : Colors.orange.shade50,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.circle,
                      color: isCompleted ? Colors.green : Colors.orange,
                      size: 10,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      status,
                      style: TextStyle(
                        color: isCompleted ? Colors.green : Colors.orange,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Divider(color: Colors.grey[200]),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildTimeColumn("Check-in", checkIn),
              _buildTimeColumn("Check-out", checkOut),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTimeColumn(String title, String time) {
    return Column(
      children: [
        Text(title, style: TextStyle(color: _lightTextColor, fontSize: 14)),
        const SizedBox(height: 8),
        Text(
          time,
          style: TextStyle(
            color: _darkTextColor,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildQuickAccessGrid() {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      childAspectRatio: 1.25,
      children: [
        _buildQuickAccessCard(
          "Check In/Out",
          Icons.login_outlined,
          const Color(0xFF3E8DE8),
          () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const MapCheckInPage()),
            ).then((_) => _absenToday());
          },
        ),
        _buildQuickAccessCard(
          "Leave Request",
          Icons.document_scanner_outlined,
          const Color(0xFF3E8DE8),
          () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const LeaveRequestScreen(),
              ),
            );
          },
        ),
        _buildQuickAccessCard(
          "Statistics",
          Icons.bar_chart_outlined,
          const Color(0xFF2D3035),
          () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const ChartScreen()),
            );
          },
        ),
        _buildQuickAccessCard(
          "History",
          Icons.history_outlined,
          const Color(0xFFF2994A),
          () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => AttendanceHistoryScreen(),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildQuickAccessCard(
    String title,
    IconData icon,
    Color iconColor,
    VoidCallback onTap,
  ) {
    // ... (Tidak ada perubahan di sini) ...
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.08),
              spreadRadius: 2,
              blurRadius: 10,
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: iconColor, size: 32),
            const SizedBox(height: 12),
            Text(
              title,
              style: TextStyle(
                color: _darkTextColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
