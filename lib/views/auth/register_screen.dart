import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tugas_ujk/api/auth_service.dart';
import 'package:tugas_ujk/api/batch_service.dart';
import 'package:tugas_ujk/api/training_service.dart';
import 'package:tugas_ujk/models/list_batch_model.dart' as batch_model;
import 'package:tugas_ujk/models/list_training_model.dart' as training_model;
import 'package:tugas_ujk/models/register_user_model.dart';
import 'package:tugas_ujk/shared_preferenced/shared_preferenced.dart';

class RegisterPage extends StatefulWidget {
  static const id = "/register";

  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  RegisterUserModel? user;
  String? errorMessage;
  bool isLoading = false;
  File? _selectedImage;
  final ImagePicker _picker = ImagePicker();

  String? _selectedJk;

  List<batch_model.Datum> _batches = [];
  int? _selectedBatchId;
  bool _isBatchesLoading = true;

  List<training_model.TrainingData> _trainings = [];
  int? _selectedTrainingId;
  bool _isTrainingsLoading = true;

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _loadInitialData();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(_animationController);
    _animationController.forward();
  }

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _loadInitialData() async {
    _loadBatches();
    _loadTrainings();
  }

  Future<void> _loadBatches() async {
    try {
      final batches = await BatchService.fetchbatch();
      if (mounted) {
        setState(() {
          _batches = batches;
          _isBatchesLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isBatchesLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Gagal memuat data batch: ${e.toString()}")),
        );
      }
    }
  }

  Future<void> _loadTrainings() async {
    try {
      final trainings = await TrainingService.fetchtinemas();
      if (mounted) {
        setState(() {
          _trainings = trainings;
          _isTrainingsLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isTrainingsLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Gagal memuat data training: ${e.toString()}"),
          ),
        );
      }
    }
  }

  Future<void> _pickImage() async {
    final picked = await _picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() => _selectedImage = File(picked.path));
    }
  }

  void registerUser() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    final email = emailController.text.trim();
    final password = passwordController.text.trim();
    final name = nameController.text.trim();

    if (email.isEmpty || password.isEmpty || name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Nama, Email, dan Password tidak boleh kosong"),
        ),
      );
      setState(() => isLoading = false);
      return;
    }
    if (_selectedJk == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Silakan pilih Jenis Kelamin")),
      );
      setState(() => isLoading = false);
      return;
    }
    if (_selectedTrainingId == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Silakan pilih Training")));
      setState(() => isLoading = false);
      return;
    }
    if (_selectedBatchId == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Silakan pilih Batch")));
      setState(() => isLoading = false);
      return;
    }

    try {
      final result = await AuthenticationAPI.registerUser(
        email: email,
        password: password,
        name: name,
        jk: _selectedJk!,
        batchID: _selectedBatchId!,
        trainingID: _selectedTrainingId!,
        imageFile: _selectedImage,
      );
      setState(() => user = result);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Pendaftaran berhasil")));
      PreferenceHandler.saveToken(user?.data?.token.toString() ?? "");
      print(user?.toJson());
    } catch (e) {
      print(e);
      setState(() => errorMessage = e.toString());
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(errorMessage.toString())));
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFE9F2FF), Color(0xFFD9EAFD)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(
              horizontal: 24.0,
              vertical: 32.0,
            ),
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildHeader(),
                  const SizedBox(height: 32),
                  _buildImagePicker(),
                  const SizedBox(height: 24),
                  _buildTextField(
                    nameController,
                    "Nama Lengkap",
                    Icons.person_outline,
                  ),
                  const SizedBox(height: 16),
                  _buildTextField(
                    emailController,
                    "Email Kantor",
                    Icons.email_outlined,
                    keyboardType: TextInputType.emailAddress,
                  ),
                  const SizedBox(height: 16),
                  _buildTextField(
                    passwordController,
                    "Kata Sandi",
                    Icons.lock_outline,
                    isPassword: true,
                  ),
                  const SizedBox(height: 24),
                  _buildGenderPicker(),
                  const SizedBox(height: 16),
                  _buildTrainingDropdown(),
                  const SizedBox(height: 16),
                  _buildBatchDropdown(),
                  const SizedBox(height: 32),
                  _buildRegisterButton(),
                  const SizedBox(height: 24),
                  _buildLoginLink(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return const Column(
      children: [
        Text(
          "Buat Akun Baru",
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Color(0xFF124170),
          ),
        ),
        SizedBox(height: 8),
        Text(
          "Isi data diri Anda untuk memulai",
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 16, color: Colors.black54),
        ),
      ],
    );
  }

  Widget _buildImagePicker() {
    return Center(
      child: Stack(
        children: [
          CircleAvatar(
            radius: 60,
            backgroundColor: Colors.white,
            backgroundImage: _selectedImage != null
                ? FileImage(_selectedImage!)
                : null,
            child: _selectedImage == null
                ? const Icon(Icons.person, size: 60, color: Color(0xFF476EAE))
                : null,
          ),
          Positioned(
            bottom: 0,
            right: 0,
            child: GestureDetector(
              onTap: _pickImage,
              child: const CircleAvatar(
                radius: 20,
                backgroundColor: Color(0xFF124170),
                child: Icon(Icons.camera_alt, color: Colors.white, size: 20),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String label,
    IconData icon, {
    bool isPassword = false,
    TextInputType? keyboardType,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: isPassword,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: const Color(0xFF476EAE)),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF124170), width: 2),
        ),
      ),
    );
  }

  // ===== WIDGET YANG DIPERBAIKI ADA DI SINI =====
  Widget _buildGenderPicker() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Text(
            "Jenis Kelamin:",
            style: TextStyle(fontSize: 16, color: Colors.grey.shade700),
          ),
          const SizedBox(width: 16),
          _buildGenderOption("L", "Pria"),
          _buildGenderOption("P", "Wanita"),
        ],
      ),
    );
  }

  // Widget helper baru untuk membuat setiap pilihan radio
  Widget _buildGenderOption(String value, String title) {
    return Expanded(
      child: InkWell(
        onTap: () {
          setState(() {
            _selectedJk = value;
          });
        },
        borderRadius: BorderRadius.circular(8),
        child: Row(
          children: [
            Radio<String>(
              value: value,
              groupValue: _selectedJk,
              onChanged: (newValue) {
                setState(() {
                  _selectedJk = newValue;
                });
              },
              activeColor: const Color(0xFF124170),
            ),
            Text(title),
          ],
        ),
      ),
    );
  }
  // ===============================================

  Widget _buildTrainingDropdown() {
    return DropdownButtonFormField<int>(
      initialValue: _selectedTrainingId,
      isExpanded: true,
      hint: Text(_isTrainingsLoading ? "Memuat..." : "Pilih Training"),
      decoration: InputDecoration(
        prefixIcon: const Icon(Icons.school_outlined, color: Color(0xFF476EAE)),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
      items: _trainings.map((training) {
        return DropdownMenuItem<int>(
          value: training.id,
          child: Text(training.title ?? "Tanpa Nama"),
        );
      }).toList(),
      onChanged: _isTrainingsLoading
          ? null
          : (value) => setState(() => _selectedTrainingId = value),
    );
  }

  Widget _buildBatchDropdown() {
    return DropdownButtonFormField<int>(
      initialValue: _selectedBatchId,
      isExpanded: true,
      hint: Text(_isBatchesLoading ? "Memuat..." : "Pilih Batch"),
      decoration: InputDecoration(
        prefixIcon: const Icon(
          Icons.group_work_outlined,
          color: Color(0xFF476EAE),
        ),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
      items: _batches.map((batch) {
        return DropdownMenuItem<int>(
          value: batch.id,
          child: Text("Batch: ${batch.batchKe ?? "Tanpa Nama"}"),
        );
      }).toList(),
      onChanged: _isBatchesLoading
          ? null
          : (value) => setState(() => _selectedBatchId = value),
    );
  }

  Widget _buildRegisterButton() {
    return SizedBox(
      height: 55,
      child: ElevatedButton(
        onPressed: isLoading ? null : registerUser,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF124170),
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 5,
        ),
        child: isLoading
            ? const SizedBox(
                height: 24,
                width: 24,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 3,
                ),
              )
            : const Text(
                "DAFTAR SEKARANG",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
      ),
    );
  }

  Widget _buildLoginLink() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          "Sudah punya akun? ",
          style: TextStyle(color: Colors.grey.shade700),
        ),
        GestureDetector(
          onTap: () => Navigator.of(context).pop(),
          child: const Text(
            "Masuk di sini",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Color(0xFF124170),
            ),
          ),
        ),
      ],
    );
  }
}
