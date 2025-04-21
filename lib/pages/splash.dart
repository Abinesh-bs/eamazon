import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../routes/app_routes.dart';
import '../utils/shared_preference.dart';

class Splash extends StatefulWidget {
  const Splash({super.key});

  @override
  State<Splash> createState() => _SplashState();
}

class _SplashState extends State<Splash> {
  @override
  void initState() {
    String? userId = SharedPreferenceHelper.getUserId() ?? "";
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (userId.isEmpty) {
        Navigator.pushReplacementNamed(context, AppRoutes.login);
      } else {
        Navigator.popAndPushNamed(context, AppRoutes.home);
      }
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // backgroundColor: Theme.of(context).colorScheme.primary,
      body: SafeArea(
        child: Center(
          child: Stack(
            children: [
              Image.asset(
                "assets/icons/logo.png",
                height: 200.h,
                width: MediaQuery.sizeOf(context).width,
              ),
              Text(
                "E- Amazon",
                style: Theme.of(
                  context,
                ).textTheme.headlineSmall?.copyWith(color: Colors.white),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
