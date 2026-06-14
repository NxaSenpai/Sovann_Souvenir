import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppTheme {
  static ThemeData get light => ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.gold,
      brightness: Brightness.light,
      primary: AppColors.gold,
      secondary: AppColors.earth,
      surface: AppColors.ivory,
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      onSurface: AppColors.charcoal,
      surfaceContainerHighest: AppColors.cream,
    ),
    scaffoldBackgroundColor: AppColors.cream,
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.cream,
      foregroundColor: AppColors.charcoal,
      elevation: 0,
      centerTitle: true,
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: Colors.white,
      selectedItemColor: AppColors.gold,
      unselectedItemColor: AppColors.warmGray,
      type: BottomNavigationBarType.fixed,
    ),
    chipTheme: ChipThemeData(
      backgroundColor: AppColors.lightGray,
      selectedColor: AppColors.gold,
      labelStyle: const TextStyle(fontSize: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
    ),
    cardTheme: CardThemeData(
      elevation: 2,
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    ),
    dividerTheme: const DividerThemeData(
      color: AppColors.lightGray,
      thickness: 1,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.gold,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
      ),
    ),
  );

  static ThemeData get dark => ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.gold,
      brightness: Brightness.dark,
      primary: AppColors.goldLight,
      secondary: AppColors.earthLight,
      surface: AppColors.darkSurface,
      onPrimary: AppColors.charcoal,
      onSecondary: Colors.white,
      onSurface: AppColors.cream,
      surfaceContainerHighest: AppColors.darkSurface,
    ),
    scaffoldBackgroundColor: AppColors.darkBg,
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.darkBg,
      foregroundColor: AppColors.cream,
      elevation: 0,
      centerTitle: true,
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: AppColors.darkSurface,
      selectedItemColor: AppColors.goldLight,
      unselectedItemColor: AppColors.warmGray,
      type: BottomNavigationBarType.fixed,
    ),
    chipTheme: ChipThemeData(
      backgroundColor: AppColors.darkCard,
      selectedColor: AppColors.gold,
      labelStyle: const TextStyle(fontSize: 12, color: AppColors.cream),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
    ),
    cardTheme: CardThemeData(
      elevation: 2,
      color: AppColors.darkCard,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    ),
    dividerTheme: const DividerThemeData(
      color: AppColors.darkCard,
      thickness: 1,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.gold,
        foregroundColor: AppColors.charcoal,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.darkCard,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: AppColors.darkSurface),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.goldLight, width: 2),
      ),
    ),
    listTileTheme: const ListTileThemeData(
      textColor: AppColors.cream,
      iconColor: AppColors.goldLight,
    ),
  );
}