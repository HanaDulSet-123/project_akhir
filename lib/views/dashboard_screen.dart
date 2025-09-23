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
    // Ambil warna dari theme
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final pages = [
      _buildDashboardPage(),
      ProfilePage(onProfileUpdated: _refreshProfile),
    ];

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.scaffoldBackgroundColor,
        elevation: 0,
        centerTitle: true,
        title: Text(
          _currentIndex == 0 ? "Dashboard" : "Profile",
          style: TextStyle(
            color: colorScheme.primary,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
      ),
      body: pages[_currentIndex],
      bottomNavigationBar: BottomNav(
        currentIndex: _currentIndex,
        onTabItemSelected: (i) {
          setState(() => _currentIndex = i);
        },
        primaryColor: colorScheme.primary,
      ),
    );
  }

  Widget _buildDashboardPage() {
    final theme = Theme.of(context);
    final textColor = theme.colorScheme.onSurface;

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
            color: textColor,
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
    final theme = Theme.of(context);
    final textColor = theme.colorScheme.onSurface;

    return FutureBuilder<GetUserModel>(
      future: _profileFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError ||
            !snapshot.hasData ||
            snapshot.data?.data == null) {
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
                    style: TextStyle(fontSize: 22, color: textColor),
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
                      color: theme.hintColor,
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
              backgroundColor: theme.colorScheme.surfaceVariant,
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
                        color: theme.hintColor,
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
    final theme = Theme.of(context);
    final isCompleted = status == "Completed";

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      decoration: BoxDecoration(
        color: theme.colorScheme.secondaryContainer,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
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
                  color: theme.colorScheme.onSecondaryContainer,
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
          Divider(color: theme.dividerColor),
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
    final theme = Theme.of(context);
    return Column(
      children: [
        Text(title, style: TextStyle(color: theme.hintColor, fontSize: 14)),
        const SizedBox(height: 8),
        Text(
          time,
          style: TextStyle(
            color: theme.colorScheme.onSurface,
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
        _buildQuickAccessCard("Check In/Out", Icons.login_outlined, () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const MapCheckInPage()),
          ).then((_) => _absenToday());
        }),
        _buildQuickAccessCard(
          "Leave Request",
          Icons.document_scanner_outlined,
          () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const LeaveRequestScreen(),
              ),
            );
          },
        ),
        _buildQuickAccessCard("Statistics", Icons.bar_chart_outlined, () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const ChartScreen()),
          );
        }),
        _buildQuickAccessCard("History", Icons.history_outlined, () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AttendanceHistoryScreen()),
          );
        }),
      ],
    );
  }

  Widget _buildQuickAccessCard(
    String title,
    IconData icon,
    VoidCallback onTap,
  ) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      elevation: 2,
      color: colorScheme.surfaceVariant, // warna variant sesuai tema
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 32,
                color: colorScheme.primary, // ikut aksen tema
              ),
              const SizedBox(height: 12),
              Text(
                title,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: colorScheme.onSurface,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
