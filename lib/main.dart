import 'package:flutter/material.dart';
import 'package:tugas_ujk/views/auth/login.dart';
import 'package:tugas_ujk/views/auth/register_screen.dart';
import 'package:tugas_ujk/views/dashboard_screen.dart';
import 'package:tugas_ujk/views/splash_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // TRY THIS: Try running your application with "flutter run". You'll see
        // the application has a purple toolbar. Then, without quitting the app,
        // try changing the seedColor in the colorScheme below to Colors.green
        // and then invoke "hot reload" (save your changes or press the "hot
        // reload" button in a Flutter-supported IDE, or press "r" if you used
        // the command line to start the app).
        //
        // Notice that the counter didn't reset back to zero; the application
        // state is not lost during the reload. To reset the state, use hot
        // restart instead.
        //
        // This works for code too, not just values: Most code changes can be
        // tested with just a hot reload.
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      initialRoute: Day16SplashScreen.id,
      routes: {
        // '/': (context) => const MyHomePage(title: 'Flutter Demo Home Page'),
        Day16SplashScreen.id: (context) => Day16SplashScreen(),
        LoginPage.id: (context) => const LoginPage(),
        RegisterPage.id: (context) => const RegisterPage(),
        DashboardScreen.id: (context) => const DashboardScreen(),
      },
    );
  }
}
