import 'package:flutter/material.dart';

class AppTheme {
  // Dark forest green theme
  static const Color primaryColor = Color(0xFF2C3E2D); // Dark forest green
  static const Color accentColor = Color(0xFFC5C8A6);  // Moss green
  static const Color backgroundColor = Color(0xFF121212); // Dark background
  static const Color textColor = Color(0xFFE6E6E6);    // Off-white
  static const Color secondaryColor = Color(0xFF4D6A4C); // Medium forest green
  
  static ThemeData get darkTheme {
    return ThemeData(
      primaryColor: primaryColor,
      scaffoldBackgroundColor: backgroundColor,
      appBarTheme: const AppBarTheme(
        backgroundColor: primaryColor,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          fontFamily: 'Montserrat',
          fontSize: 22,
          fontWeight: FontWeight.w600,
          color: textColor,
        ),
      ),
      textTheme: const TextTheme(
        headlineMedium: TextStyle(
          color: textColor,
          fontFamily: 'Montserrat',
          fontWeight: FontWeight.w600,
        ),
        bodyLarge: TextStyle(
          color: textColor,
          fontFamily: 'Montserrat',
        ),
        bodyMedium: TextStyle(
          color: textColor,
          fontFamily: 'Montserrat',
        ),
      ),
      colorScheme: ColorScheme.dark(
        primary: primaryColor,
        secondary: accentColor,
        background: backgroundColor,
        surface: backgroundColor,
        onSurface: textColor,
        onBackground: textColor,
        onPrimary: textColor,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: accentColor,
          foregroundColor: backgroundColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.0),
          ),
          padding: const EdgeInsets.symmetric(vertical: 16.0),
          textStyle: const TextStyle(
            fontFamily: 'Montserrat',
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: primaryColor.withOpacity(0.3),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
          borderSide: BorderSide(color: primaryColor.withOpacity(0.2)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
          borderSide: const BorderSide(color: accentColor),
        ),
        labelStyle: TextStyle(color: textColor.withOpacity(0.7)),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: accentColor,
          textStyle: const TextStyle(
            fontFamily: 'Montserrat',
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}