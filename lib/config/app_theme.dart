import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/foundation.dart';

final primaryMaterialColor = Colors.cyan;
final primaryColor = Colors.cyan;

class AppTheme {
  static TextTheme lightTextTheme = TextTheme(
    bodyLarge: GoogleFonts.dmSans(
      fontSize: 16.sp,
      fontWeight: FontWeight.w400,
      color: Colors.black,
    ),
    bodyMedium: GoogleFonts.dmSans(
      fontSize: 14.sp,
      fontWeight: FontWeight.w400,
      color: Colors.black,
    ),
    bodySmall: GoogleFonts.dmSans(
      fontSize: kIsWeb ? 15.sp : 12.sp,
      fontWeight: FontWeight.w400,
      color: Colors.black,
    ),
    displayLarge: GoogleFonts.dmSans(
      fontSize: kIsWeb ? 40.sp : 32.sp,
      fontWeight: FontWeight.bold,
      color: Colors.black,
    ),
    displayMedium: GoogleFonts.dmSans(
      fontSize: kIsWeb ? 36.sp : 28.sp,
      fontWeight: FontWeight.w700,
      color: Colors.black,
    ),
    displaySmall: GoogleFonts.dmSans(
      fontSize: kIsWeb ? 34.sp : 26.sp,
      fontWeight: FontWeight.w700,
      color: Colors.black,
    ),
    headlineMedium: GoogleFonts.dmSans(
      fontSize: kIsWeb ? 24.sp : 18.sp,
      fontWeight: FontWeight.w600,
      color: Colors.black,
    ),
    headlineSmall: GoogleFonts.dmSans(
      fontSize: kIsWeb ? 20.sp : 14.sp,
      fontWeight: FontWeight.w600,
      color: Colors.black,
    ),
    titleLarge: GoogleFonts.dmSans(
      fontSize: kIsWeb ? 28.sp : 22.sp,
      fontWeight: FontWeight.w600,
      color: Colors.black,
    ),
  );

  static TextTheme darkTextTheme = TextTheme(
    bodyLarge: GoogleFonts.dmSans(
      fontSize: 16.sp,
      fontWeight: FontWeight.w400,
      color: Colors.white,
    ),
    bodyMedium: GoogleFonts.dmSans(
      fontSize: 14.sp,
      fontWeight: FontWeight.w400,
      color: Colors.white,
    ),
    bodySmall: GoogleFonts.dmSans(
      fontSize: kIsWeb ? 15.sp : 12.sp,
      fontWeight: FontWeight.w400,
      color: Colors.white,
    ),
    displayLarge: GoogleFonts.dmSans(
      fontSize: kIsWeb ? 40.sp : 32.sp,
      fontWeight: FontWeight.bold,
      color: Colors.white,
    ),
    displayMedium: GoogleFonts.dmSans(
      fontSize: kIsWeb ? 36.sp : 28.sp,
      fontWeight: FontWeight.w700,
      color: Colors.white,
    ),
    displaySmall: GoogleFonts.dmSans(
      fontSize: kIsWeb ? 34.sp : 26.sp,
      fontWeight: FontWeight.w700,
      color: Colors.white,
    ),
    headlineMedium: GoogleFonts.dmSans(
      fontSize: kIsWeb ? 24.sp : 18.sp,
      fontWeight: FontWeight.w600,
      color: Colors.white,
    ),
    headlineSmall: GoogleFonts.dmSans(
      fontSize: kIsWeb ? 20.sp : 14.sp,
      fontWeight: FontWeight.w600,
      color: Colors.white,
    ),
    titleLarge: GoogleFonts.dmSans(
      fontSize: kIsWeb ? 28.sp : 22.sp,
      fontWeight: FontWeight.w600,
      color: Colors.white,
    ),
  );

  static ThemeData light() {
    return ThemeData(
      colorScheme: ColorScheme.light(primary: primaryColor),
      primarySwatch: primaryMaterialColor,
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(backgroundColor: primaryColor),
      ),
      useMaterial3: true,
      dividerTheme: const DividerThemeData(color: Colors.grey, thickness: 0.4),
      brightness: Brightness.light,
      primaryColor: primaryColor,
      fontFamily: 'Roboto',
      textTheme: lightTextTheme,
    );
  }

  static ThemeData dark() {
    return ThemeData(
      colorScheme: ColorScheme.dark(primary: primaryColor),
      primarySwatch: primaryMaterialColor,
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(backgroundColor: primaryColor),
      ),
      useMaterial3: true,
      dividerTheme: const DividerThemeData(color: Colors.grey, thickness: 0.4),
      brightness: Brightness.dark,
      primaryColor: primaryColor,
      fontFamily: 'Roboto',
      textTheme: darkTextTheme,
    );
  }
}
