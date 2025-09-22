import 'package:flutter/material.dart';
import 'package:tugas_ujk/api/auth_service.dart';
import 'package:tugas_ujk/extension/navigaton.dart';
import 'package:tugas_ujk/shared_preferenced/shared_preferenced.dart';
import 'package:tugas_ujk/views/auth/register_screen.dart';

class LoginPage extends StatefulWidget {
  static const id = "/login";

  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  bool rememberMe = false;
  bool obscure = true;

  Future<void> _login() async {
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Email dan password harus diisi")),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      await AuthenticationAPI.loginUser(
        email: _emailController.text,
        password: _passwordController.text,
      );
      await PreferenceHandler.saveLogin();

      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const RegisterPage()),
      );
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Login gagal: $e")));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background daun
          Positioned.fill(
            child: Image.asset(
              "assets/images/background.png",
              fit: BoxFit.cover,
            ),
          ),

          // Konten utama
          SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(height: 80),

                // Logo Prasta
                Center(
                  child: Image.asset(
                    "assets/images/logo_prasta_putih.png",
                    height: 80,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),

                const SizedBox(height: 40),

                // Container putih melengkung
                Container(
                  height: MediaQuery.of(context).size.height,
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: const BoxDecoration(
                    color: Colors.white, // Putih
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(40),
                      topRight: Radius.circular(40),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Judul
                      const Text(
                        "Masuk ke Akun",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF347338), // Hijau utama
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Input Email
                      TextField(
                        controller: _emailController,
                        decoration: InputDecoration(
                          hintText: "Masukan Email",
                          hintStyle: const TextStyle(color: Color(0xFF11261A)),
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
                        controller: _passwordController,
                        obscureText: obscure,
                        decoration: InputDecoration(
                          hintText: "Kata Sandi",
                          hintStyle: const TextStyle(color: Color(0xFF11261A)),
                          suffixIcon: IconButton(
                            icon: Icon(
                              obscure ? Icons.visibility_off : Icons.visibility,
                              color: const Color(0xFF347338),
                            ),
                            onPressed: () {
                              setState(() {
                                obscure = !obscure;
                              });
                            },
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

                      // Remember me & Lupa password
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Checkbox(
                                value: rememberMe,
                                activeColor: const Color(0xFF347338),
                                onChanged: (val) {
                                  setState(() {
                                    rememberMe = val ?? false;
                                  });
                                },
                              ),
                              const Text(
                                "Ingat saya",
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Color(0xFF11261A),
                                ),
                              ),
                            ],
                          ),
                          GestureDetector(
                            onTap: () {
                              // Arahkan ke forgot password page
                            },
                            child: const Text(
                              "Lupa Kata Sandi?",
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF347338),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),

                      // Tombol login
                      SizedBox(
                        width: double.infinity,
                        height: 55,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _login,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color(0xFF347338),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          child: _isLoading
                              ? const CircularProgressIndicator(
                                  color: Colors.white,
                                )
                              : const Text(
                                  "Login",
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                        ),
                      ),
                      const SizedBox(height: 15),

                      // Belum punya akun?
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            "Belum punya akun? ",
                            style: TextStyle(color: Color(0xFF11261A)),
                          ),
                          GestureDetector(
                            onTap: () {
                              context.pushNamed(RegisterPage.id);
                              // Arahkan ke register page
                            },
                            child: const Text(
                              "Daftar di sini",
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
    );
  }
}
