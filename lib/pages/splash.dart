import 'package:flutter/material.dart';

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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (SharedPreferenceHelper.getUserId() == null) {
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
      backgroundColor: Theme.of(context).colorScheme.primary,
      body: Center(
        child: Text(
          "E- Amazon",
          style: Theme.of(
            context,
          ).textTheme.headlineSmall?.copyWith(color: Colors.white),
        ),
      ),
    );
  }
}
