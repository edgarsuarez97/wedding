import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../core/garden/wildflower.dart';
import '../../../core/theme/app_theme.dart';

/// Tarjeta de la portada: papel crema y marco de cinta salvia cubierto de
/// flores silvestres en acuarela a lo largo de todo su contorno, como una
/// invitación impresa. Ocupa toda la pantalla; la tarjeta queda
/// centrada y, si sobra espacio a los lados, asoman más flores en el papel.
class InvitationCard extends StatelessWidget {
  const InvitationCard({super.key, this.hideHint = false});

  final bool hideHint;

  /// Proporción del marco (ancho / alto) tal como viene dibujado.
  static const frameAspect = 278.25 / 393;

  /// Lo más que se deja estirar el marco a lo alto en pantallas angostas,
  /// para que llene el teléfono sin que las ondas se deformen de más.
  static const _maxStretch = 1.45;

  /// Rectángulo de la tarjeta dentro de una pantalla de [screen].
  static Rect rectFor(Size screen) {
    final margin = (screen.shortestSide * 0.06).clamp(20.0, 48.0);
    final maxW = screen.width - margin * 2;
    final maxH = screen.height - margin * 2;
    var w = math.min(maxW, 620.0);
    var h = w / frameAspect;
    if (h > maxH) {
      h = maxH;
      w = h * frameAspect;
    } else {
      h = math.min(maxH, h * _maxStretch);
    }
    return Rect.fromCenter(
      center: screen.center(Offset.zero),
      width: w,
      height: h,
    );
  }

  static double sealSizeFor(Size card) =>
      math.min(170.0, math.min(card.width * 0.34, card.height * 0.22));

  // Flores dentro de la tarjeta: (flor, x, y, tamaño, giro en grados,
  // reflejada). x e y marcan dónde nace el tallo, en fracciones del ancho y
  // del alto de la tarjeta; el tamaño es el lado de su caja, en fracciones
  // del ancho. El orden va del fondo al frente. Las del borde superior
  // cuelgan (giro cercano a 180°) y las de los lados suben junto al marco.
  static const _cardFlowers = [
    // Borde superior.
    (Wildflower.lavenderArc, 0.1, 0.02, 0.44, 150.0, false),
    (Wildflower.lilacVine, 0.32, 0.0, 0.44, 176.0, true),
    (Wildflower.yellowBranch, 0.68, 0.0, 0.42, 184.0, false),
    (Wildflower.tealBudsTall, 0.9, 0.02, 0.42, 205.0, true),
    (Wildflower.forgetMeNotSprig, 0.5, 0.0, 0.3, 180.0, false),
    (Wildflower.purpleAnemone, 0.2, 0.015, 0.32, 200.0, false),
    (Wildflower.peachButtercups, 0.8, 0.015, 0.3, 160.0, true),
    // Lados: ramitas que suben pegadas al marco.
    (Wildflower.blueBellflower, 0.03, 0.3, 0.34, 10.0, false),
    (Wildflower.violets, 0.04, 0.44, 0.3, 14.0, false),
    (Wildflower.pinkPoppy, 0.03, 0.6, 0.36, 8.0, false),
    (Wildflower.lilacPeony, 0.97, 0.31, 0.32, -10.0, true),
    (Wildflower.tealBudsTall, 0.97, 0.47, 0.36, -8.0, false),
    (Wildflower.yellowCosmos, 0.96, 0.58, 0.3, -14.0, true),
    // Borde inferior y esquinas de abajo.
    (Wildflower.lavender, 0.06, 0.82, 0.72, -6.0, false),
    (Wildflower.buttercupSprig, 0.1, 0.74, 0.4, 8.0, false),
    (Wildflower.violets, 0.13, 0.9, 0.34, 8.0, false),
    (Wildflower.coralCosmos, 0.08, 1.0, 0.36, -10.0, false),
    (Wildflower.yellowPrimrose, 0.25, 0.98, 0.26, 10.0, false),
    (Wildflower.purpleAnemone, 0.9, 0.68, 0.44, 8.0, true),
    (Wildflower.tealBuds, 0.93, 0.84, 0.42, -6.0, false),
    (Wildflower.peachButtercups, 0.82, 0.94, 0.32, -12.0, false),
    (Wildflower.yellowCosmos, 0.93, 1.0, 0.36, -8.0, false),
    (Wildflower.lilacPeony, 0.71, 1.0, 0.27, -16.0, false),
    (Wildflower.forgetMeNotSprig, 0.57, 0.99, 0.26, -4.0, false),
    (Wildflower.pinkWildRose, 0.4, 1.01, 0.28, 6.0, false),
  ];

  // Prado de flores que nace al pie de la pantalla a los lados de la
  // tarjeta (pantallas anchas):
  // (flor, x, y, tamaño, giro, reflejada) con x e y en fracciones de la
  // franja libre de cada lado y tamaño en fracciones de su ancho.
  static const _sideFlowers = [
    (Wildflower.pinkPoppy, 0.18, 1.02, 0.62, -10.0, false),
    (Wildflower.lavender, 0.42, 1.03, 0.9, -4.0, false),
    (Wildflower.blueBellflower, 0.68, 1.02, 0.66, 8.0, true),
    (Wildflower.tealBudsTall, 0.32, 1.02, 0.86, -6.0, false),
    (Wildflower.yellowPrimrose, 0.58, 1.02, 0.56, 10.0, true),
    (Wildflower.lilacPeony, 0.84, 1.03, 0.62, 12.0, true),
  ];

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final screen = constraints.biggest;
        final card = rectFor(screen);
        final sealSize = sealSizeFor(card.size);
        final side = card.left;

        return Stack(
          clipBehavior: Clip.none,
          children: [
            const Positioned.fill(child: ColoredBox(color: _Paper.backdrop)),
            if (side > 120)
              for (final (i, f) in _sideFlowers.indexed)
                _flower(
                  f,
                  // Las tres primeras van a la izquierda, el resto a la derecha.
                  i < 3
                      ? Rect.fromLTWH(0, 0, side, screen.height)
                      : Rect.fromLTWH(card.right, 0, side, screen.height),
                  sizeBase: math.min(side, 360),
                  opacity: 0.85,
                ),
            // Grano de papel encima de todo para que se sienta impreso.
            const Positioned.fill(
              child: IgnorePointer(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage(
                        'assets/illustrations/paper_texture.jpg',
                      ),
                      repeat: ImageRepeat.repeat,
                      opacity: 0.2,
                    ),
                  ),
                ),
              ),
            ),
            Positioned.fromRect(
              rect: card,
              child: SvgPicture.asset(
                'assets/illustrations/watercolor/frame.svg',
                fit: BoxFit.fill,
                excludeFromSemantics: true,
              ),
            ),
            ..._text(card, sealSize),
            for (final f in _cardFlowers)
              _flower(f, card, sizeBase: card.width),
          ],
        );
      },
    );
  }

  Widget _flower(
    (Wildflower, double, double, double, double, bool) f,
    Rect area, {
    required double sizeBase,
    double opacity = 1,
  }) {
    final (flower, x, y, size, degrees, flip) = f;
    final box = size * sizeBase;
    return Positioned(
      left: area.left + x * area.width - box / 2,
      top: area.top + y * area.height - box,
      width: box,
      height: box,
      child: Opacity(
        opacity: opacity,
        child: Transform.rotate(
          angle: degrees * math.pi / 180,
          alignment: Alignment.bottomCenter,
          child: WildflowerIcon(
            flower,
            size: box,
            flipX: flip,
            alignment: Alignment.bottomCenter,
          ),
        ),
      ),
    );
  }

  List<Widget> _text(Rect card, double sealSize) {
    final w = card.width;
    return [
      Positioned(
        left: card.left + w * 0.2,
        width: w * 0.6,
        top: card.center.dy + sealSize / 2 + w * 0.045,
        child: AnimatedOpacity(
          opacity: hideHint ? 0 : 1,
          duration: const Duration(milliseconds: 200),
          child: Text(
            'Toca el sello para abrir',
            textAlign: TextAlign.center,
            style: AppTheme.display(
              fontSize: math.max(15, w * 0.045),
              color: AppTheme.inkSoft,
              fontStyle: FontStyle.italic,
            ),
          ),
        ),
      ),
    ];
  }
}

abstract final class _Paper {
  static const backdrop = Color(0xFFFBF8F1);
}
