import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tugas_ujk/api/auth_service.dart';
import 'package:tugas_ujk/models/get_user_model.dart';

class ProfilePage extends StatefulWidget {
  static const id = '/profile';
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  late Future<GetUserModel> futureProfile;
  final ImagePicker _picker = ImagePicker();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    futureProfile = AuthenticationAPI.getProfile();
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
      _showErrorSnackbar("Gagal memilih gambar: $e");
    }
  }

  Future<void> _uploadImage(File imageFile) async {
    try {
      setState(() {
        _isLoading = true;
      });

      await AuthenticationAPI.updateFoto(imageFile: imageFile);

      // Refresh data profile
      setState(() {
        futureProfile = AuthenticationAPI.getProfile();
      });

      _showSuccessSnackbar("Foto berhasil diperbarui");
    } catch (e) {
      _showErrorSnackbar("Gagal update foto: $e");
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showErrorSnackbar(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  void _showSuccessSnackbar(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFFFFF),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : FutureBuilder<GetUserModel>(
              future: futureProfile,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
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

                return SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      // Foto profil
                      Center(
                        child: Stack(
                          children: [
                            CircleAvatar(
                              radius: 50,
                              backgroundColor: const Color(0xFFA5BF99),
                              backgroundImage: user.profilePhotoUrl != null
                                  ? NetworkImage(user.profilePhotoUrl!)
                                  : null,
                              child: user.profilePhotoUrl == null
                                  ? const Icon(
                                      Icons.person,
                                      size: 50,
                                      color: Colors.white,
                                    )
                                  : null,
                            ),
                            Positioned(
                              bottom: 0,
                              right: 0,
                              child: CircleAvatar(
                                backgroundColor: const Color(0xFF347338),
                                child: IconButton(
                                  icon: const Icon(
                                    Icons.camera_alt,
                                    color: Colors.white,
                                  ),
                                  onPressed: _isLoading ? null : _pickImage,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Tombol Edit Profil & Keluar
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF347338),
                          minimumSize: const Size(double.infinity, 50),
                        ),
                        onPressed: _isLoading
                            ? null
                            : () {
                                // TODO: ke halaman edit profil
                              },
                        icon: const Icon(Icons.edit, color: Colors.white),
                        label: const Text(
                          "Edit Profil",
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                      const SizedBox(height: 8),
                      OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Colors.red),
                          minimumSize: const Size(double.infinity, 50),
                        ),
                        onPressed: _isLoading
                            ? null
                            : () async {
                                await AuthenticationAPI.logout();
                                if (mounted) {
                                  Navigator.pushReplacementNamed(
                                    context,
                                    "/login",
                                  );
                                }
                              },
                        icon: const Icon(Icons.logout, color: Colors.red),
                        label: const Text(
                          "Keluar",
                          style: TextStyle(color: Colors.red),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Statistik singkat
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.2),
                              blurRadius: 5,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "Statistik Singkat",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF11261A),
                              ),
                            ),
                            const SizedBox(height: 12),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                _statCard("15", "Hari Berturut"),
                                _statCard("168", "Total Jam"),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Informasi Profil
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.2),
                              blurRadius: 5,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "Informasi Profil",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF11261A),
                              ),
                            ),
                            const SizedBox(height: 12),
                            _infoTile("Nama Lengkap", user.name ?? "-"),
                            _infoTile("Email", user.email ?? "-"),
                            _infoTile("Batch", user.batchKe ?? "-"),
                            _infoTile("Pelatihan", user.trainingTitle ?? "-"),
                            _infoTile(
                              "Jenis Kelamin",
                              user.jenisKelamin ?? "-",
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }

  Widget _statCard(String value, String label) {
    return Container(
      width: 120,
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFA5BF99).withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF347338),
            ),
          ),
          const SizedBox(height: 4),
          Text(label, style: const TextStyle(color: Color(0xFF11261A))),
        ],
      ),
    );
  }

  Widget _infoTile(String title, String value) {
    return Column(
      children: [
        ListTile(
          title: Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.w500,
              color: Color(0xFF11261A),
            ),
          ),
          subtitle: Text(value, style: const TextStyle(color: Colors.black87)),
        ),
        const Divider(),
      ],
    );
  }
}
