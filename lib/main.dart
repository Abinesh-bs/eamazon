import 'package:e_amazon/routes/app_routes.dart';
import 'package:e_amazon/utils/shared_preference.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'config/app_theme.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SharedPreferenceHelper.init();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    Size designSize = Size(360, 690);

    if (Theme.of(context).platform == TargetPlatform.android ||
        Theme.of(context).platform == TargetPlatform.iOS) {
      designSize = Size(360, 690);
    } else if (Theme.of(context).platform == TargetPlatform.fuchsia ||
        Theme.of(context).platform == TargetPlatform.macOS) {
      designSize = Size(1440, 900);
    } else {
      designSize = Size(1920, 1080);
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final screenWidth = constraints.maxWidth;
        Size designSize;

        if (screenWidth < 650) {
          designSize = const Size(360, 690);
        } else if (screenWidth >= 650 && screenWidth < 1300) {
          designSize = const Size(768, 1024);
        } else {
          designSize = const Size(1440, 1024);
        }

        return ScreenUtilInit(
          splitScreenMode: true,
          designSize: designSize,
          builder: (_, child) {
            return MaterialApp(
              debugShowCheckedModeBanner: false,
              title: 'Flutter Demo',
              theme: AppTheme.light(),
              initialRoute: AppRoutes.splash,
              onGenerateRoute: AppRoutes.generateRoutes,
            );
          },
        );
      },
    );
  }
}
