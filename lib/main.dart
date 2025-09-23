import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tugas_ujk/shared_preferenced/shared_preferenced.dart';
import 'package:tugas_ujk/utils/theme.dart'; // ThemeProvider, lightTheme, darkTheme
import 'package:tugas_ujk/views/about.dart';
import 'package:tugas_ujk/views/auth/login.dart';
import 'package:tugas_ujk/views/auth/register_screen.dart';
import 'package:tugas_ujk/views/settings.dart';
import 'package:tugas_ujk/views/dashboard_screen.dart';
import 'package:tugas_ujk/views/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // penting untuk SharedPreferences
  await PreferenceHandler.getThemeMode(); // ambil dari shared_pref
  runApp(
    ChangeNotifierProvider(
      create: (context) =>
          ThemeProvider(), // otomatis load theme dari SharedPreferences
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Flutter Demo',

          // ====== Global Theme ======
          theme: lightTheme, // mode terang → biru soft
          darkTheme: darkTheme, // mode gelap → pink soft
          themeMode: themeProvider.themeMode, // ambil dari provider
          // ====== Routing ======
          initialRoute: Day16SplashScreen.id,
          routes: {
            Day16SplashScreen.id: (context) => Day16SplashScreen(),
            LoginPage.id: (context) => const LoginPage(),
            RegisterPage.id: (context) => const RegisterPage(),
            AboutAPPScreen.id: (context) => const AboutAPPScreen(),
            DashboardScreen.id: (context) => const DashboardScreen(),
            SettingsPresensi.id: (context) => const SettingsPresensi(),
          },
        );
      },
    );
  }
}
