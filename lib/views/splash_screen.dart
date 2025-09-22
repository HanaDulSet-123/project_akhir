import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lottie/lottie.dart';
import 'package:tugas_ujk/extension/navigaton.dart';
import 'package:tugas_ujk/shared_preferenced/shared_preferenced.dart';
import 'package:tugas_ujk/views/auth/login.dart';
import 'package:tugas_ujk/views/dashboard_screen.dart';
import 'package:tugas_ujk/widgets/appimage.dart';

class Day16SplashScreen extends StatefulWidget {
  const Day16SplashScreen({super.key});
  static const id = "/splash_screen";

  @override
  State<Day16SplashScreen> createState() => _Day16SplashScreenState();
}

class _Day16SplashScreenState extends State<Day16SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkLogin();
  }

  void _checkLogin() async {
    bool? isLogin = await PreferenceHandler.getLogin();

    Future.delayed(const Duration(seconds: 5)).then((value) {
      if (!mounted) return;

      if (isLogin == true) {
        context.pushReplacementNamed(DashboardScreen.id);
      } else {
        context.push(LoginPage());
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      builder: (context, child) {
        return Scaffold(
          body: SizedBox.expand(
            child: Lottie.asset(
              AppImage.Background,
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height,
              repeat: true,
              animate: true,
              fit: BoxFit.fill,
            ),
          ),
        );
      },
    );
  }
}
