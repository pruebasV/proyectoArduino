import 'package:flutter/material.dart';

class AppTheme {
  static final darkTheme = ThemeData(
    scaffoldBackgroundColor: const Color(0xFF0A0E21),
    primaryColor: const Color(0xFF1D1E33),
    colorScheme: const ColorScheme.dark(
      primary: Color(0xFF0D47A1),
      secondary: Color(0xFF64B5F6),
      surface: Color(0xFF1D1E33),
    ),
    textTheme: const TextTheme(
      headlineMedium: TextStyle(
        fontSize: 28,
        fontWeight: FontWeight.w800,
        color: Colors.white,
        letterSpacing: 1.5,
      ),
      titleLarge: TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.w700,
        color: Colors.white,
      ),
      bodyLarge: TextStyle(
        fontSize: 18,
        color: Colors.white70,
        height: 1.5,
      ),
    ),
    iconTheme:  IconThemeData(color: Color(0xFF64B5F6)),
    cardTheme:  CardThemeData( 
      color: Color(0xFF1D1E33),
      elevation: 6,
      margin: EdgeInsets.all(8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
    ),
    buttonTheme: const ButtonThemeData(
      buttonColor: Color(0xFF1976D2),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(16)),
      ),
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: Color(0xFF0D47A1),
    ),
  );

  static const menuGradient = LinearGradient(
    colors: [Color(0xFF0D47A1), Color(0xFF42A5F5)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}