// lib/views/profile_page.dart

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
// Ganti dengan path project Anda yang benar
import 'package:tugas_ujk/api/auth_service.dart';
import 'package:tugas_ujk/models/get_user_model.dart';
import 'package:tugas_ujk/views/edit_profile.dart';

class ProfilePage extends StatefulWidget {
  static const id = '/profile';

  final VoidCallback onProfileUpdated;

  const ProfilePage({super.key, required this.onProfileUpdated});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  late Future<GetUserModel> _futureProfile;
  final ImagePicker _picker = ImagePicker();
  bool _isLoading = false;

  // Palet Warna Sesuai Dashboard
  final Color _backgroundColor = const Color(0xFFF8F9FD);
  final Color _primaryBlue = const Color(0xFF3E8DE8);
  final Color _darkTextColor = const Color(0xFF2D3035);
  final Color _lightTextColor = Colors.grey.shade600;

  @override
  void initState() {
    super.initState();
    _futureProfile = AuthenticationAPI.getProfile();
  }

  void _refreshProfile() {
    setState(() {
      _futureProfile = AuthenticationAPI.getProfile();
    });
    widget.onProfileUpdated();
  }

  Future<void> _pickImage() async {
    try {
      final pickedFile = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
      );
      if (pickedFile != null) {
        await _uploadImage(File(pickedFile.path));
      }
    } catch (e) {
      _showSnackbar("Gagal memilih gambar: $e", isError: true);
    }
  }

  Future<void> _uploadImage(File imageFile) async {
    try {
      setState(() => _isLoading = true);

      await AuthenticationAPI.updateFoto(imageFile: imageFile);
      _refreshProfile(); // Refresh data setelah berhasil
      _showSnackbar("Foto profil berhasil diperbarui");
    } catch (e) {
      _showSnackbar("Gagal update foto: $e", isError: true);
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  // ===== NAVIGASI KE HALAMAN EDIT =====
  void _navigateToEditProfile(Data currentUser) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditProfilePage(currentUser: currentUser),
      ),
    );

    // Jika `result` adalah true, berarti ada pembaruan
    if (result == true) {
      _refreshProfile();
    }
  }

  void _showSnackbar(String message, {bool isError = false}) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: isError ? Colors.red : Colors.green,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _backgroundColor,
      body: Stack(
        children: [
          FutureBuilder<GetUserModel>(
            future: _futureProfile,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting &&
                  !_isLoading) {
                return const Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return Center(
                  child: Text(
                    "Error: ${snapshot.error}",
                    style: const TextStyle(color: Colors.red),
                  ),
                );
              } else if (!snapshot.hasData || snapshot.data?.data == null) {
                return const Center(child: Text("Data tidak ditemukan"));
              }

              final user = snapshot.data!.data!;

              return ListView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 30,
                ),
                children: [
                  _buildProfileHeader(user),
                  const SizedBox(height: 32),
                  _buildAccountInfoCard(user),
                  const SizedBox(height: 24),
                  _buildSettingsCard(user), // <-- Kirim data user
                ],
              );
            },
          ),
          if (_isLoading)
            Container(
              color: Colors.black.withOpacity(0.5),
              child: const Center(
                child: CircularProgressIndicator(color: Colors.white),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildProfileHeader(Data user) {
    final name =
        user.name
            ?.split(' ')
            .map(
              (word) => word.isNotEmpty
                  ? '${word[0].toUpperCase()}${word.substring(1).toLowerCase()}'
                  : '',
            )
            .join(' ') ??
        "User";

    return Column(
      children: [
        Center(
          child: Stack(
            children: [
              CircleAvatar(
                radius: 60,
                backgroundColor: Colors.grey[200],
                backgroundImage: user.profilePhotoUrl != null
                    ? NetworkImage(user.profilePhotoUrl!)
                    : null,
                child: user.profilePhotoUrl == null
                    ? Icon(Icons.person, size: 60, color: _lightTextColor)
                    : null,
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: GestureDetector(
                  onTap: _pickImage,
                  child: CircleAvatar(
                    radius: 20,
                    backgroundColor: _primaryBlue,
                    child: const Icon(
                      Icons.camera_alt,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Text(
          name,
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: _darkTextColor,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          user.email ?? '-',
          style: TextStyle(fontSize: 16, color: _lightTextColor),
        ),
      ],
    );
  }

  Widget _buildAccountInfoCard(Data user) {
    return _buildCard(
      title: "Informasi Akun",
      children: [
        _buildInfoRow(Icons.badge_outlined, "Batch", user.batchKe ?? "-"),
        _buildInfoRow(
          Icons.school_outlined,
          "Pelatihan",
          user.trainingTitle ?? "-",
        ),
        _buildInfoRow(
          Icons.person_outline,
          "Jenis Kelamin",
          user.jenisKelamin ?? "-",
        ),
      ],
    );
  }

  Widget _buildSettingsCard(Data user) {
    // <-- Terima data user
    return _buildCard(
      title: "Pengaturan & Lainnya",
      children: [
        ListTile(
          leading: Icon(Icons.edit_outlined, color: _darkTextColor),
          title: Text(
            "Edit Profil",
            style: TextStyle(
              color: _darkTextColor,
              fontWeight: FontWeight.w500,
            ),
          ),
          trailing: const Icon(Icons.chevron_right),
          onTap: () =>
              _navigateToEditProfile(user), // <-- Panggil fungsi navigasi
        ),
        ListTile(
          leading: const Icon(Icons.logout, color: Colors.red),
          title: const Text(
            "Keluar",
            style: TextStyle(color: Colors.red, fontWeight: FontWeight.w500),
          ),
          onTap: () async {
            await AuthenticationAPI.logout();
            if (mounted) {
              Navigator.pushReplacementNamed(context, "/login");
            }
          },
        ),
      ],
    );
  }

  Widget _buildCard({required String title, required List<Widget> children}) {
    return Container(
      padding: const EdgeInsets.all(16),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: _darkTextColor,
            ),
          ),
          const Divider(height: 24),
          ...children,
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(icon, color: _lightTextColor, size: 20),
          const SizedBox(width: 16),
          Text(label, style: TextStyle(color: _lightTextColor, fontSize: 14)),
          const Spacer(),
          Text(
            value,
            style: TextStyle(
              color: _darkTextColor,
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}
