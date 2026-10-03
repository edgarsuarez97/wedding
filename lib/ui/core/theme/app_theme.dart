import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Paleta "Garden Party" del sitio y estilos base.
///
/// Los pasteles son para flores, fondos y adornos; nunca para texto. El texto
/// usa las tintas profundas ([ink], [inkSoft], [olive], [lavenderInk],
/// [roseInk]) para mantener contraste AA sobre el papel.
class AppTheme {
  // Paleta principal (Garden Party).
  static const Color bellBlue = Color(0xFF9DBCE6);
  static const Color oliveLeaf = Color(0xFFB6C489);
  static const Color sweetPea = Color(0xFFF4C3D3);
  static const Color peach = Color(0xFFFFCC8F);
  static const Color butter = Color(0xFFFFEB9F);
  static const Color lavender = Color(0xFFC9C1E3);

  // Tonos de apoyo.
  static const Color sky = Color(0xFFBCD7F2);
  static const Color lilac = Color(0xFFDCC2F1);
  static const Color bubblegum = Color(0xFFFFA8C1);
  static const Color mint = Color(0xFFB7D7AA);
  static const Color cream = Color(0xFFF8F0B0);

  // Tintas para texto y trazos.
  static const Color ink = Color(0xFF34392F);
  static const Color inkSoft = Color(0xFF5E6457);
  static const Color olive = Color(0xFF6F7D45);
  static const Color stem = Color(0xFF93A160);
  static const Color lavenderInk = Color(0xFF8A6FC0);
  static const Color roseInk = Color(0xFFB95A84);

  // Superficies.
  static const Color paper = Color(0xFFFBF9F3);
  static const Color card = Color(0xBFFFFFFF);
  static const Color cardBorder = Color(0x3893A160);

  /// Colores sugeridos para el código de vestimenta, en orden de la paleta.
  static const List<({String name, Color color})> palette = [
    (name: 'Azul campanilla', color: bellBlue),
    (name: 'Oliva', color: oliveLeaf),
    (name: 'Rosa guisante', color: sweetPea),
    (name: 'Durazno', color: peach),
    (name: 'Mantequilla', color: butter),
    (name: 'Lavanda', color: lavender),
  ];

  static TextStyle script({double fontSize = 48, Color color = ink}) =>
      GoogleFonts.pinyonScript(fontSize: fontSize, color: color, height: 1.1);

  static TextStyle display({
    double fontSize = 40,
    Color color = ink,
    FontStyle fontStyle = FontStyle.normal,
    FontWeight fontWeight = FontWeight.w500,
  }) => GoogleFonts.cormorantGaramond(
    fontSize: fontSize,
    color: color,
    fontStyle: fontStyle,
    fontWeight: fontWeight,
    height: 1.1,
  );

  static TextStyle eyebrow({Color color = olive}) => GoogleFonts.jost(
    fontSize: 12,
    letterSpacing: 3.1,
    fontWeight: FontWeight.w500,
    color: color,
  );

  static ThemeData get lightTheme {
    final base = ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: lavender,
        primary: lavenderInk,
        secondary: bubblegum,
        surface: paper,
        onSurface: ink,
      ),
      scaffoldBackgroundColor: paper,
    );

    final body = GoogleFonts.jostTextTheme(
      base.textTheme,
    ).apply(bodyColor: ink, displayColor: ink);

    return base.copyWith(
      textTheme: body.copyWith(
        displayLarge: display(fontSize: 58),
        displayMedium: display(fontSize: 46),
        displaySmall: display(fontSize: 40),
        headlineMedium: display(fontSize: 34),
        titleLarge: display(fontSize: 26),
        bodyLarge: body.bodyLarge?.copyWith(
          fontWeight: FontWeight.w300,
          height: 1.6,
        ),
        bodyMedium: body.bodyMedium?.copyWith(
          fontWeight: FontWeight.w300,
          height: 1.55,
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        color: card,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: const BorderSide(color: cardBorder),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFFFDFDFB),
        labelStyle: const TextStyle(color: inkSoft),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFFDDE3D6)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFFDDE3D6)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: stem, width: 1.4),
        ),
      ),
      chipTheme: base.chipTheme.copyWith(
        backgroundColor: Colors.white.withValues(alpha: 0.6),
        selectedColor: lavender,
        side: const BorderSide(color: stem),
        shape: const StadiumBorder(),
        labelStyle: GoogleFonts.jost(color: ink, fontSize: 14.5),
        showCheckmark: false,
      ),
    );
  }
}
