import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static const Color mint = Color(0xFFBED7D1);
  static const Color lavender = Color(0xFFF7C4F7);
  static const Color lime = Color(0xFFE7FBD4);
  static const Color rose = Color(0xFFF8E1E7);
  static const Color blush = Color(0xFFF8D1E0);
  static const Color paper = Colors.white;

  static ThemeData get lightTheme {
    final base = ThemeData(
      useMaterial3: true,
      colorScheme: const ColorScheme.light(
        primary: mint,
        secondary: blush,
        surface: paper,
      ),
      scaffoldBackgroundColor: paper,
    );

    return base.copyWith(
      textTheme: GoogleFonts.sourceSans3TextTheme(base.textTheme).copyWith(
        displayLarge: GoogleFonts.playfairDisplay(
          fontSize: 58,
          fontWeight: FontWeight.w600,
          color: const Color(0xFF2F3843),
        ),
        displayMedium: GoogleFonts.playfairDisplay(
          fontSize: 44,
          fontWeight: FontWeight.w600,
          color: const Color(0xFF2F3843),
        ),
        headlineMedium: GoogleFonts.playfairDisplay(
          fontSize: 32,
          fontWeight: FontWeight.w600,
          color: const Color(0xFF2F3843),
        ),
        titleLarge: GoogleFonts.playfairDisplay(
          fontSize: 28,
          fontWeight: FontWeight.w600,
          color: const Color(0xFF2F3843),
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        color: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFFFDFDFD),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFFDFDFDF)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFFE5E5E5)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: mint, width: 1.2),
        ),
      ),
    );
  }
}
