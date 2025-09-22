import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tugas_ujk/api/auth_service.dart';
import 'package:tugas_ujk/api/batch_service.dart';
import 'package:tugas_ujk/api/training_service.dart';
import 'package:tugas_ujk/extension/navigaton.dart';
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

class _RegisterPageState extends State<RegisterPage> {
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

  @override
  void initState() {
    super.initState();
    // Panggil API saat halaman dimuat
    _loadInitialData();
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
        setState(() {
          _isBatchesLoading = false;
        });
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
        setState(() {
          _isTrainingsLoading = false;
        });
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
    // source: ImageSource.camera
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

    // Validasi input
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
      body: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Stack(
            children: [
              // Positioned.fill(
              //   child: Image.asset(
              //     "assets/images/background.png",
              //     fit: BoxFit.cover,
              //   ),
              // ),
              SingleChildScrollView(
                child: Column(
                  children: [
                    const SizedBox(height: 80),

                    Center(
                      child: Image.asset(
                        "assets/images/logo_prasta_putih.png",
                        height: 80,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      ),
                    ),
                    const SizedBox(height: 40),

                    Container(
                      constraints: BoxConstraints(
                        minHeight: MediaQuery.of(context).size.height * 0.8,
                      ),
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(40),
                          topRight: Radius.circular(40),
                        ),
                      ),
                      child: Column(
                        children: [
                          const Text(
                            "Bergabung di AbDul",
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF347338),
                            ),
                          ),
                          const SizedBox(height: 20),

                          // Pilih Gambar
                          _selectedImage != null
                              ? Column(
                                  children: [
                                    ClipOval(
                                      child: Image.file(
                                        _selectedImage!,
                                        height: 150,
                                        width: 150,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                    const SizedBox(height: 10),
                                    TextButton.icon(
                                      onPressed: _pickImage,
                                      icon: const Icon(Icons.image),
                                      label: const Text("Ganti Gambar"),
                                    ),
                                  ],
                                )
                              : Column(
                                  children: [
                                    GestureDetector(
                                      onTap: _pickImage,
                                      child: CircleAvatar(
                                        radius: 75, // sama dengan ukuran gambar
                                        backgroundColor: Colors.grey[300],
                                        child: const Icon(
                                          Icons.image,
                                          size: 50,
                                          color: Colors.black54,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 10),
                                    const Text("Pilih Gambar"),
                                  ],
                                ),

                          const SizedBox(height: 24),

                          // Input Nama Lengkap
                          TextField(
                            controller: nameController,
                            decoration: InputDecoration(
                              hintText: "Nama Lengkap",
                              hintStyle: const TextStyle(
                                color: Color(0xFF11261A),
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: const BorderSide(
                                  color: Color(0xFFA5BF99),
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: const BorderSide(
                                  color: Color(0xFF347338),
                                ),
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 12,
                              ),
                            ),
                          ),
                          const SizedBox(height: 15),

                          // Input Email
                          TextField(
                            controller: emailController,
                            decoration: InputDecoration(
                              hintText: "Email Kantor",
                              hintStyle: const TextStyle(
                                color: Color(0xFF11261A),
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: const BorderSide(
                                  color: Color(0xFFA5BF99),
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: const BorderSide(
                                  color: Color(0xFF347338),
                                ),
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 12,
                              ),
                            ),
                          ),
                          const SizedBox(height: 15),

                          // Input Password
                          TextField(
                            controller: passwordController,
                            obscureText: true,
                            decoration: InputDecoration(
                              hintText: "Kata Sandi",
                              hintStyle: const TextStyle(
                                color: Color(0xFF11261A),
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: const BorderSide(
                                  color: Color(0xFFA5BF99),
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: const BorderSide(
                                  color: Color(0xFF347338),
                                ),
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 12,
                              ),
                            ),
                          ),
                          const SizedBox(height: 10),

                          // Input Jenis Kelamin
                          const Text(
                            "Jenis Kelamin",
                            style: TextStyle(
                              color: Colors.black54,
                              fontSize: 16,
                            ),
                          ),
                          Row(
                            children: [
                              Expanded(
                                child: RadioListTile<String>(
                                  title: const Text("Laki-laki"),
                                  value: "L",
                                  groupValue: _selectedJk,
                                  onChanged: (value) {
                                    setState(() {
                                      _selectedJk = value;
                                    });
                                  },
                                ),
                              ),
                              Expanded(
                                child: RadioListTile<String>(
                                  title: const Text("Perempuan"),
                                  value: "P",
                                  groupValue: _selectedJk,
                                  onChanged: (value) {
                                    setState(() {
                                      _selectedJk = value;
                                    });
                                  },
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 15),

                          // Input Training ID
                          DropdownButtonFormField<int>(
                            initialValue: _selectedTrainingId,
                            isExpanded: true,
                            hint: Text(
                              _isTrainingsLoading
                                  ? "Memuat..."
                                  : "Pilih Training",
                            ),
                            decoration: InputDecoration(
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 12,
                              ),
                            ),
                            items: _trainings.map((
                              training_model.TrainingData training,
                            ) {
                              // <-- Ubah tipenya di sini
                              return DropdownMenuItem<int>(
                                value: training.id,
                                child: Text(training.title ?? "Tanpa Nama"),
                              );
                            }).toList(),
                            onChanged: _isTrainingsLoading
                                ? null
                                : (value) {
                                    setState(() {
                                      _selectedTrainingId = value;
                                    });
                                  },
                          ),
                          const SizedBox(height: 15),

                          // Input Batch ID
                          DropdownButtonFormField<int>(
                            initialValue: _selectedBatchId,
                            isExpanded: true,
                            hint: Text(
                              _isBatchesLoading ? "Memuat..." : "Pilih Batch",
                            ),
                            decoration: InputDecoration(
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 12,
                              ),
                            ),
                            items: _batches.map((batch_model.Datum batch) {
                              return DropdownMenuItem<int>(
                                value: batch.id,
                                child: Text(
                                  "Batch:  ${batch.batchKe ?? "Tanpa Nama"}",
                                ),
                              );
                            }).toList(),
                            onChanged: _isBatchesLoading
                                ? null
                                : (value) {
                                    setState(() {
                                      _selectedBatchId = value;
                                    });
                                  },
                          ),
                          const SizedBox(height: 20),

                          // Tombol daftar
                          SizedBox(
                            width: double.infinity,
                            height: 50,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(
                                  0xFF347338,
                                ), // Hijau utama
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              onPressed: isLoading ? null : registerUser,
                              child: isLoading
                                  ? const CircularProgressIndicator(
                                      color: Colors.white,
                                    )
                                  : const Text(
                                      "DAFTAR SEKARANG",
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                            ),
                          ),
                          const SizedBox(height: 15),

                          // Sudah punya akun?
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text(
                                "Sudah punya akun? ",
                                style: TextStyle(color: Color(0xFF11261A)),
                              ),
                              GestureDetector(
                                onTap: () {
                                  context.pop();
                                },
                                child: const Text(
                                  "Masuk di sini",
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF347338),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 30),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
