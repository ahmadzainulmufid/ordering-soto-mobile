import 'package:flutter/material.dart';

class AppTheme {
  static const Color primaryGreen = Color(0xFF28662B); 
  static const Color accentYellow = Color(0xFFF5B800);
  static const Color warmCreamBg = Color(0xFFFDF8F2);  
  static const Color darkBrownText = Color(0xFF4A3500); 

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: warmCreamBg,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryGreen,
        primary: primaryGreen,
        secondary: accentYellow,
        surface: Colors.white,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: accentYellow,
          foregroundColor: darkBrownText,
          textStyle: const TextStyle(fontWeight: FontWeight.bold),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }
}