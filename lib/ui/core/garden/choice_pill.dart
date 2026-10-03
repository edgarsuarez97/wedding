import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../theme/app_motion.dart';
import '../theme/app_theme.dart';

/// Opción en forma de píldora. Reemplaza a ChoiceChip, que con la altura de
/// línea de Jost recortaba y desvanecía la parte de abajo del texto.
class ChoicePill extends StatelessWidget {
  const ChoicePill({
    super.key,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final duration = AppMotion.reduced(context)
        ? Duration.zero
        : const Duration(milliseconds: 260);
    return Semantics(
      button: true,
      selected: selected,
      child: Material(
        color: Colors.transparent,
        shape: const StadiumBorder(),
        child: InkWell(
          onTap: onTap,
          customBorder: const StadiumBorder(),
          child: AnimatedContainer(
            duration: duration,
            curve: AppMotion.organic,
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
            decoration: ShapeDecoration(
              color: selected
                  ? AppTheme.lavender
                  : Colors.white.withValues(alpha: 0.6),
              shape: StadiumBorder(
                side: BorderSide(
                  color: selected ? AppTheme.lavenderInk : AppTheme.stem,
                ),
              ),
            ),
            child: Text(
              label,
              style: GoogleFonts.jost(
                color: AppTheme.ink,
                fontSize: 15,
                height: 1.25,
                fontWeight: selected ? FontWeight.w500 : FontWeight.w400,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
