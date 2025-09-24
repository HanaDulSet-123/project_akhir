import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:tugas_ujk/api/auth_service.dart';
import 'package:tugas_ujk/shared_preferenced/shared_preferenced.dart';
import 'package:tugas_ujk/views/auth/forgot_password.dart';
import 'package:tugas_ujk/views/auth/register_screen.dart';
import 'package:tugas_ujk/views/dashboard_screen.dart';

class LoginPage extends StatefulWidget {
  static const id = "/login";

  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage>
    with SingleTickerProviderStateMixin {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  bool obscure = true;

  // Animasi fade halaman
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
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
    _emailController.dispose();
    _passwordController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  // --- LOGIKA LOGIN ---
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

      // Tutup loading di tombol
      setState(() => _isLoading = false);

      // Tampilkan Lottie success
      showDialog(
        context: context,
        barrierDismissible: false, // tidak bisa ditutup manual
        builder: (_) => Center(
          child: Lottie.asset(
            'assets/lottie/success.json', // ganti dengan file animasi success kamu
            repeat: false,
          ),
        ),
      );

      // Delay 3 detik lalu pindah ke dashboard
      await Future.delayed(const Duration(seconds: 3));

      if (!mounted) return;
      Navigator.of(context).pop(); // tutup dialog Lottie
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const DashboardScreen()),
      );
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Login gagal: $e")));
      }
    }
  }
  // --- END OF LOGIKA LOGIN ---

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
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildHeader(),
                    const SizedBox(height: 48),
                    _buildEmailField(),
                    const SizedBox(height: 16),
                    _buildPasswordField(),
                    const SizedBox(height: 16),
                    _buildForgotPasswordLink(),
                    const SizedBox(height: 32),
                    _buildLoginButton(),
                    const SizedBox(height: 24),
                    _buildRegisterLink(),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        const Icon(Icons.lock_open_rounded, size: 80, color: Color(0xFF124170)),
        const SizedBox(height: 24),
        const Text(
          "Selamat Datang Kembali",
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Color(0xFF124170),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          "Masuk untuk melanjutkan ke akun Anda",
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 16, color: Colors.grey.shade700),
        ),
      ],
    );
  }

  Widget _buildEmailField() {
    return TextFormField(
      controller: _emailController,
      keyboardType: TextInputType.emailAddress,
      decoration: InputDecoration(
        labelText: "Email",
        prefixIcon: const Icon(Icons.email_outlined, color: Color(0xFF476EAE)),
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

  Widget _buildPasswordField() {
    return TextFormField(
      controller: _passwordController,
      obscureText: obscure,
      decoration: InputDecoration(
        labelText: "Kata Sandi",
        prefixIcon: const Icon(Icons.lock_outline, color: Color(0xFF476EAE)),
        suffixIcon: IconButton(
          icon: Icon(
            obscure ? Icons.visibility_off_outlined : Icons.visibility_outlined,
            color: Colors.grey.shade600,
          ),
          onPressed: () {
            setState(() {
              obscure = !obscure;
            });
          },
        ),
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

  Widget _buildForgotPasswordLink() {
    return Align(
      alignment: Alignment.centerRight,
      child: GestureDetector(
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => const ForgotPasswordScreen(),
            ),
          );
        },
        child: const Text(
          "Lupa Kata Sandi?",
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: Color(0xFF124170),
          ),
        ),
      ),
    );
  }

  Widget _buildLoginButton() {
    return SizedBox(
      height: 55,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _login,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF124170),
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 5,
          shadowColor: Colors.black.withOpacity(0.2),
        ),
        child: _isLoading
            ? SizedBox(
                height: 40,
                width: 40,
                child: Lottie.asset(
                  'assets/lottie/loading.json',
                  fit: BoxFit.cover,
                ),
              )
            : const Text(
                "Login",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
      ),
    );
  }

  Widget _buildRegisterLink() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          "Belum punya akun? ",
          style: TextStyle(color: Colors.grey.shade700),
        ),
        GestureDetector(
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(builder: (context) => const RegisterPage()),
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
    );
  }
}
