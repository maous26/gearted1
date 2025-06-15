import 'package:flutter/material.dart';

class GeartedTheme {
  // Couleurs principales
  static const Color primaryBlue = Color(0xFF1E3A8A);
  static const Color secondaryGreen = Color(0xFF4D5B31);
  static const Color accentOrange = Color(0xFFEA580C);
  static const Color neutralDark = Color(0xFF1F2937);
  static const Color neutralLight = Color(0xFFF9FAFB);
  static const Color lightBlue = Color(0xFF93C5FD);
  static const Color lightGreen = Color(0xFFA3B18A);

  // Thème clair
  static final ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.light(
      primary: primaryBlue,
      secondary: secondaryGreen,
      tertiary: accentOrange,
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      onTertiary: Colors.white,
      background: neutralLight,
      surface: Colors.white,
    ),
    scaffoldBackgroundColor: neutralLight,
    fontFamily: 'Inter',
    textTheme: _createTextTheme(Colors.black),
    appBarTheme: AppBarTheme(
      backgroundColor: primaryBlue,
      foregroundColor: Colors.white,
      elevation: 0,
    ),
    buttonTheme: ButtonThemeData(
      buttonColor: primaryBlue,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryBlue,
        foregroundColor: Colors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: primaryBlue, width: 2),
      ),
      filled: true,
      fillColor: Colors.grey.shade50,
    ),
    cardTheme: CardTheme(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    ),
  );

  // Thème sombre
  static final ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.dark(
      primary: primaryBlue,
      secondary: secondaryGreen,
      tertiary: accentOrange,
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      onTertiary: Colors.white,
      background: Color(0xFF121212),
      surface: Color(0xFF1E1E1E),
    ),
    scaffoldBackgroundColor: Color(0xFF121212),
    fontFamily: 'Inter',
    textTheme: _createTextTheme(Colors.white),
    appBarTheme: AppBarTheme(
      backgroundColor: Color(0xFF1E1E1E),
      foregroundColor: Colors.white,
      elevation: 0,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryBlue,
        foregroundColor: Colors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: Colors.grey.shade800),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: primaryBlue, width: 2),
      ),
      filled: true,
      fillColor: Colors.grey.shade900,
    ),
    cardTheme: CardTheme(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    ),
  );

  // Création du thème de texte
  static TextTheme _createTextTheme(Color textColor) {
    return TextTheme(
      displayLarge: TextStyle(
        fontFamily: 'Montserrat',
        fontWeight: FontWeight.bold,
        color: textColor,
      ),
      displayMedium: TextStyle(
        fontFamily: 'Montserrat',
        fontWeight: FontWeight.bold,
        color: textColor,
      ),
      displaySmall: TextStyle(
        fontFamily: 'Montserrat',
        fontWeight: FontWeight.bold,
        color: textColor,
      ),
      headlineLarge: TextStyle(
        fontFamily: 'Montserrat',
        fontWeight: FontWeight.bold,
        color: textColor,
      ),
      headlineMedium: TextStyle(
        fontFamily: 'Montserrat',
        fontWeight: FontWeight.bold,
        color: textColor,
      ),
      headlineSmall: TextStyle(
        fontFamily: 'Montserrat',
        fontWeight: FontWeight.w600,
        color: textColor,
      ),
      titleLarge: TextStyle(
        fontFamily: 'Montserrat',
        fontWeight: FontWeight.w600,
        color: textColor,
      ),
      titleMedium: TextStyle(
        fontFamily: 'Montserrat',
        fontWeight: FontWeight.w600,
        color: textColor,
      ),
      titleSmall: TextStyle(
        fontFamily: 'Montserrat',
        fontWeight: FontWeight.w600,
        color: textColor,
      ),
      bodyLarge: TextStyle(
        fontFamily: 'Inter',
        fontWeight: FontWeight.normal,
        color: textColor,
      ),
      bodyMedium: TextStyle(
        fontFamily: 'Inter',
        fontWeight: FontWeight.normal,
        color: textColor,
      ),
      bodySmall: TextStyle(
        fontFamily: 'Inter',
        fontWeight: FontWeight.normal,
        color: textColor,
      ),
    );
  }
}
