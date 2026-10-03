import 'app.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  GoogleFonts.config.allowRuntimeFetching = true;
  // Las fuentes vienen en assets/fonts. Se cargan antes del primer cuadro
  // para que el texto no se vuelva a maquetar a mitad del scroll.
  GoogleFonts.pinyonScript();
  for (final weight in [FontWeight.w300, FontWeight.w400, FontWeight.w500]) {
    GoogleFonts.jost(fontWeight: weight);
  }
  for (final style in FontStyle.values) {
    GoogleFonts.cormorantGaramond(
      fontWeight: FontWeight.w500,
      fontStyle: style,
    );
  }
  try {
    await GoogleFonts.pendingFonts();
  } on Object {
    // Si alguna fuente falla, el sitio sigue con la de respaldo.
  }
  runApp(const WeddingApp());
}
