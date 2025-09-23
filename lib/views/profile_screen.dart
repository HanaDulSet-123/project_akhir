// lib/views/profile_page.dart

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tugas_ujk/api/auth_service.dart';
import 'package:tugas_ujk/extension/navigaton.dart';
import 'package:tugas_ujk/models/get_user_model.dart';
import 'package:tugas_ujk/views/settings.dart';
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
    final theme = Theme.of(context);
    final bg = isError ? theme.colorScheme.error : theme.colorScheme.primary;
    final txtColor = isError
        ? theme.colorScheme.onError
        : theme.colorScheme.onPrimary;

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message, style: TextStyle(color: txtColor)),
          backgroundColor: bg,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Stack(
        children: [
          FutureBuilder<GetUserModel>(
            future: _futureProfile,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting &&
                  !_isLoading) {
                return Center(
                  child: CircularProgressIndicator(
                    color: theme.colorScheme.primary,
                  ),
                );
              } else if (snapshot.hasError) {
                return Center(
                  child: Text(
                    "Error: ${snapshot.error}",
                    style: TextStyle(color: theme.colorScheme.error),
                  ),
                );
              } else if (!snapshot.hasData || snapshot.data?.data == null) {
                return Center(
                  child: Text(
                    "Data tidak ditemukan",
                    style: TextStyle(color: theme.colorScheme.onSurface),
                  ),
                );
              }

              final user = snapshot.data!.data!;

              return ListView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 30,
                ),
                children: [
                  _buildProfileHeader(context, user),
                  const SizedBox(height: 32),
                  _buildAccountInfoCard(context, user),
                  const SizedBox(height: 24),
                  _buildSettingsCard(context, user), // <-- Kirim data user
                ],
              );
            },
          ),
          if (_isLoading)
            Container(
              color: Colors.black.withOpacity(0.5),
              child: Center(
                child: CircularProgressIndicator(
                  color: Theme.of(context).colorScheme.onPrimary,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildProfileHeader(BuildContext context, Data user) {
    final theme = Theme.of(context);
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
                backgroundColor: theme.colorScheme.surfaceVariant,
                backgroundImage: user.profilePhotoUrl != null
                    ? NetworkImage(user.profilePhotoUrl!)
                    : null,
                child: user.profilePhotoUrl == null
                    ? Icon(
                        Icons.person,
                        size: 60,
                        color: theme.colorScheme.onSurfaceVariant,
                      )
                    : null,
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: GestureDetector(
                  onTap: _pickImage,
                  child: CircleAvatar(
                    radius: 20,
                    backgroundColor: theme.colorScheme.primary,
                    child: Icon(
                      Icons.camera_alt,
                      color: theme.colorScheme.onPrimary,
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
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          user.email ?? '-',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }

  Widget _buildAccountInfoCard(BuildContext context, Data user) {
    return _buildCard(
      context,
      title: "Informasi Akun",
      children: [
        _buildInfoRow(
          context,
          Icons.badge_outlined,
          "Batch",
          user.batchKe ?? "-",
        ),
        _buildInfoRow(
          context,
          Icons.school_outlined,
          "Pelatihan",
          user.trainingTitle ?? "-",
        ),
        _buildInfoRow(
          context,
          Icons.person_outline,
          "Jenis Kelamin",
          user.jenisKelamin ?? "-",
        ),
      ],
    );
  }

  Widget _buildSettingsCard(BuildContext context, Data user) {
    return _buildCard(
      context,
      title: "Pengaturan & Lainnya",
      children: [
        ListTile(
          leading: Icon(
            Icons.edit_outlined,
            color: Theme.of(context).colorScheme.onSurface,
          ),
          title: Text(
            "Edit Profil",
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurface,
              fontWeight: FontWeight.w500,
            ),
          ),
          trailing: Icon(
            Icons.chevron_right,
            color: Theme.of(context).colorScheme.onSurface,
          ),
          onTap: () => _navigateToEditProfile(user),
        ),
        ListTile(
          leading: Icon(
            Icons.settings,
            color: Theme.of(context).colorScheme.onSurface,
          ),
          title: Text(
            "Pengaturan",
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurface,
              fontWeight: FontWeight.w500,
            ),
          ),
          trailing: Icon(
            Icons.chevron_right,
            color: Theme.of(context).colorScheme.onSurface,
          ),
          onTap: () {
            context.pushNamed(SettingsPresensi.id);
          },
        ),
        ListTile(
          leading: Icon(
            Icons.logout,
            color: Theme.of(context).colorScheme.error,
          ),
          title: Text(
            "Keluar",
            style: TextStyle(
              color: Theme.of(context).colorScheme.error,
              fontWeight: FontWeight.w500,
            ),
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

  Widget _buildCard(
    BuildContext context, {
    required String title,
    required List<Widget> children,
  }) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: theme.shadowColor.withOpacity(0.08),
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
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const Divider(height: 24),
          ...children,
        ],
      ),
    );
  }

  Widget _buildInfoRow(
    BuildContext context,
    IconData icon,
    String label,
    String value,
  ) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(icon, color: theme.colorScheme.onSurfaceVariant, size: 20),
          const SizedBox(width: 16),
          Text(
            label,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
              fontSize: 14,
            ),
          ),
          const Spacer(),
          Text(
            value,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface,
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}
