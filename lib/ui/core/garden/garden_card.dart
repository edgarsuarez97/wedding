import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import 'garden_ornaments.dart';

/// Tarjeta de papel claro con borde salvia. Con [withBouquet] lleva un
/// ramillete silvestre en la esquina inferior derecha.
class GardenCard extends StatelessWidget {
  const GardenCard({
    super.key,
    required this.child,
    this.withBouquet = false,
    this.padding,
    this.borderRadius = const BorderRadius.all(Radius.circular(24)),
  });

  final Widget child;
  final bool withBouquet;
  final EdgeInsetsGeometry? padding;
  final BorderRadius borderRadius;

  @override
  Widget build(BuildContext context) {
    final compact = MediaQuery.sizeOf(context).width < 600;
    final inner = compact ? 22.0 : 36.0;
    return ClipRRect(
      borderRadius: borderRadius,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: AppTheme.card,
          borderRadius: borderRadius,
          border: Border.all(color: AppTheme.cardBorder),
        ),
        child: Stack(
          children: [
            Padding(
              padding:
                  padding ??
                  EdgeInsets.fromLTRB(
                    inner,
                    inner,
                    inner,
                    withBouquet ? 130 : inner,
                  ),
              child: child,
            ),
            if (withBouquet)
              const Positioned(right: -14, bottom: -10, child: CornerBouquet()),
          ],
        ),
      ),
    );
  }
}

/// Encabezado de sección: etiqueta en mayúsculas y título con una parte en
/// cursiva lavanda.
class GardenHeading extends StatelessWidget {
  const GardenHeading({
    super.key,
    required this.eyebrow,
    required this.title,
    this.accent,
    this.center = false,
  });

  final String eyebrow;
  final String title;
  final String? accent;
  final bool center;

  @override
  Widget build(BuildContext context) {
    final size = (MediaQuery.sizeOf(context).width * 0.05).clamp(34.0, 46.0);
    return Column(
      crossAxisAlignment: center
          ? CrossAxisAlignment.center
          : CrossAxisAlignment.start,
      children: [
        Text(eyebrow.toUpperCase(), style: AppTheme.eyebrow()),
        const SizedBox(height: 8),
        Text.rich(
          TextSpan(
            children: [
              TextSpan(text: title),
              if (accent != null)
                TextSpan(
                  text: accent,
                  style: AppTheme.display(
                    fontSize: size,
                    color: AppTheme.lavenderInk,
                    fontStyle: FontStyle.italic,
                  ),
                ),
            ],
          ),
          textAlign: center ? TextAlign.center : TextAlign.start,
          style: AppTheme.display(fontSize: size),
        ),
      ],
    );
  }
}
