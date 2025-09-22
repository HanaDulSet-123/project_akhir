import 'package:flutter/material.dart';
import 'package:tugas_ujk/api/auth_service.dart';
import 'package:tugas_ujk/shared_preferenced/shared_preferenced.dart';
import 'package:tugas_ujk/views/auth/forgot_password.dart';
import 'package:tugas_ujk/views/auth/register_screen.dart';
import 'package:tugas_ujk/views/dashboard_screen.dart';
// Impor halaman forgot_password_screen yang sudah kita buat

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
        MaterialPageRoute(builder: (_) => const DashboardScreen()),
      );
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Login gagal: $e")));
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background
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

                Center(
                  // child: Image.asset(
                  //   "assets/images/logo_prasta_putih.png",
                  //   height: 80,
                  //   width: double.infinity,
                  //   fit: BoxFit.cover,
                  // ),
                ),

                const SizedBox(height: 40),

                // Container putih melengkung
                Container(
                  height: MediaQuery.of(context).size.height,
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: const BoxDecoration(
                    color: Color(0xffD9EAFD),
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(40),
                      topRight: Radius.circular(40),
                    ),
                  ),

                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Login",
                        style: TextStyle(
                          fontSize: 50,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF476EAE),
                        ),
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        "Welcome Back, don't forget to login and absent!",
                        style: TextStyle(
                          fontSize: 20,
                          // fontWeight: FontWeight.bold,
                          color: Color(0xFF19183B),
                        ),
                      ),
                      const SizedBox(height: 100),

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

                      TextField(
                        controller: _passwordController,
                        obscureText: obscure,
                        decoration: InputDecoration(
                          hintText: "Kata Sandi",
                          hintStyle: const TextStyle(color: Color(0xFF11261A)),
                          suffixIcon: IconButton(
                            icon: Icon(
                              obscure ? Icons.visibility_off : Icons.visibility,
                              color: Color(0xFFA5BF99),
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
                              color: Color(0xFF647FBC),
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: const BorderSide(
                              color: Color(0xFF647FBC),
                            ),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12,
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Row(
                          //   children: [
                          //     Checkbox(
                          //       value: rememberMe,
                          //       activeColor: const Color(0xFF647FBC),
                          //       onChanged: (val) {
                          //         setState(() {
                          //           rememberMe = val ?? false;
                          //         });
                          //       },
                          //     ),
                          //     const Text(
                          //       "Ingat saya",
                          //       style: TextStyle(
                          //         fontSize: 12,
                          //         color: Color(0xFF647FBC),
                          //       ),
                          //     ),
                          //   ],
                          // ),
                          GestureDetector(
                            onTap: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) =>
                                      const ForgotPasswordScreen(),
                                ),
                              );
                            },
                            child: const Text(
                              "Lupa Kata Sandi?",
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF57564F),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),

                      SizedBox(
                        width: double.infinity,
                        height: 55,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _login,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF124170),
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

                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            "Belum punya akun? ",
                            style: TextStyle(color: Color(0xFF11261A)),
                          ),
                          GestureDetector(
                            onTap: () {
                              // Arahkan ke register page
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) => const RegisterPage(),
                                ),
                              );
                            },
                            child: const Text(
                              "Daftar di sini",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF124170),
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
