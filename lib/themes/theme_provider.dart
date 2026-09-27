import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:titan_tunes/config/constants.dart';

/// Provider pour le thème (Syntaxe moderne Riverpod 3.x)
final themeModeProvider = NotifierProvider<ThemeModeNotifier, ThemeMode>(() {
  return ThemeModeNotifier();
});

class ThemeModeNotifier extends Notifier<ThemeMode> {
  @override
  ThemeMode build() {
    // État initial : Mode sombre par défaut
    return ThemeMode.dark;
  }

  void setTheme(ThemeMode mode) {
    state = mode;
  }

  void toggleTheme() {
    state = state == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
  }
}



class AppTheme {
  AppTheme._();

  // ==================== THÈME CLAIR ====================
  static final ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    primaryColor: Colors.orange,
    scaffoldBackgroundColor: Colors.white,
    colorScheme: ColorScheme.light(
      primary: AppColors.primary,
      secondary: AppColors.secondary,
      error: AppColors.error,
      surface: Colors.white,
    ),
    
    textTheme: GoogleFonts.montserratTextTheme(
      TextTheme(
        displayLarge: TextStyle(fontSize: 28.sp, fontWeight: FontWeight.bold, color: AppColors.textDark),
        displayMedium: TextStyle(fontSize: 24.sp, fontWeight: FontWeight.w600, color: AppColors.textDark),
        displaySmall: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.w600, color: AppColors.textDark),
        bodyLarge: TextStyle(fontSize: 16.sp, color: AppColors.textDark),
        bodyMedium: TextStyle(fontSize: 14.sp, color: AppColors.textDark),
        bodySmall: TextStyle(fontSize: 12.sp, color: AppColors.textDark.withOpacity(0.7)),
      ),
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.white,
      elevation: 0,
      centerTitle: true,
      iconTheme: IconThemeData(color: AppColors.primary),
      titleTextStyle: TextStyle(
        fontSize: 18.sp,
        fontWeight: FontWeight.w600,
        color: AppColors.textDark,
        fontFamily: GoogleFonts.montserrat().fontFamily,
      ),
    ),
    cardTheme: CardThemeData(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        foregroundColor: Colors.white,
        backgroundColor: AppColors.primary,
        elevation: 0,
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r)),
        textStyle: TextStyle(
          fontSize: 14.sp,
          fontWeight: FontWeight.w600,
          fontFamily: GoogleFonts.montserrat().fontFamily,
        ),
      ),
    ),
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: AppColors.primary,
      foregroundColor: Colors.white,
      elevation: 2,
    ),
    dividerTheme: DividerThemeData(color: Colors.grey.shade300, thickness: 1),
    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.r), borderSide: BorderSide(color: Colors.grey.shade300)),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8.r), borderSide: BorderSide(color: Colors.grey.shade300)),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8.r), borderSide: BorderSide(color: AppColors.primary)),
      errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8.r), borderSide: BorderSide(color: AppColors.error)),
      contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
      filled: true,
      fillColor: Colors.grey.shade50,
      hintStyle: TextStyle(fontSize: 14.sp, color: Colors.grey, fontFamily: GoogleFonts.montserrat().fontFamily),
    ),
    switchTheme: SwitchThemeData(
      thumbColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) return AppColors.primary;
        return null;
      }),
      trackColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) return AppColors.primary.withOpacity(0.5);
        return null;
      }),
    ),
    checkboxTheme: CheckboxThemeData(
      fillColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) return AppColors.primary;
        return null;
      }),
    ),
  );

  // ==================== THÈME SOMBRE ====================
  static final ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    primaryColor: Colors.blue,
    scaffoldBackgroundColor: const Color(0xFF121212),
    colorScheme: ColorScheme.dark(
      primary: AppColors.primary,
      secondary: AppColors.secondary,
      error: AppColors.error,
      surface: const Color(0xFF1E1E1E),
    ),
    textTheme: GoogleFonts.montserratTextTheme(
      TextTheme(
        displayLarge: TextStyle(fontSize: 28.sp, fontWeight: FontWeight.bold, color: Colors.white),
        displayMedium: TextStyle(fontSize: 24.sp, fontWeight: FontWeight.w600, color: Colors.white),
        displaySmall: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.w600, color: Colors.white),
        bodyLarge: TextStyle(fontSize: 16.sp, color: Colors.white),
        bodyMedium: TextStyle(fontSize: 14.sp, color: Colors.white),
        bodySmall: TextStyle(fontSize: 12.sp, color: Colors.white.withOpacity(0.7)),
      ),
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: const Color(0xFF1E1E1E),
      elevation: 0,
      centerTitle: true,
      iconTheme: IconThemeData(color: AppColors.primary),
      titleTextStyle: TextStyle(
        fontSize: 18.sp,
        fontWeight: FontWeight.w600,
        color: Colors.white,
        fontFamily: GoogleFonts.montserrat().fontFamily,
      ),
    ),
    cardTheme: CardThemeData(
      elevation: 2,
      color: const Color(0xFF1E1E1E),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        foregroundColor: Colors.white,
        backgroundColor: AppColors.primary,
        elevation: 0,
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r)),
        textStyle: TextStyle(
          fontSize: 14.sp,
          fontWeight: FontWeight.w600,
          fontFamily: GoogleFonts.montserrat().fontFamily,
        ),
      ),
    ),
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: AppColors.primary,
      foregroundColor: Colors.white,
      elevation: 2,
    ),
    dividerTheme: DividerThemeData(color: Colors.grey.shade800, thickness: 1),
    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.r), borderSide: BorderSide(color: Colors.grey.shade700)),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8.r), borderSide: BorderSide(color: Colors.grey.shade700)),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8.r), borderSide: BorderSide(color: AppColors.primary)),
      errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8.r), borderSide: BorderSide(color: AppColors.error)),
      contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
      filled: true,
      fillColor: const Color(0xFF2A2A2A),
      hintStyle: TextStyle(fontSize: 14.sp, color: Colors.grey.shade400, fontFamily: GoogleFonts.montserrat().fontFamily),
    ),
    switchTheme: SwitchThemeData(
      thumbColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) return AppColors.primary;
        return null;
      }),
      trackColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) return AppColors.primary.withOpacity(0.5);
        return null;
      }),
    ),
    checkboxTheme: CheckboxThemeData(
      fillColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) return AppColors.primary;
        return null;
      }),
    ),
  );
}