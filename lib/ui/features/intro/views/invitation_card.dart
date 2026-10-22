import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../core/garden/wildflower.dart';
import '../../../core/theme/app_theme.dart';

/// Tarjeta de la portada: papel crema, marco de cinta salvia con lazo arriba
/// y ramilletes de flores silvestres en acuarela que trepan por los lados,
/// como una invitación impresa. Ocupa toda la pantalla; la tarjeta queda
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
  // del ancho. El orden va del fondo al frente.
  static const _cardFlowers = [
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
            // Lazo atado sobre el borde superior del marco.
            Positioned(
              left: card.center.dx - card.width * 0.11,
              top: card.top - card.width * 0.095,
              width: card.width * 0.22,
              child: SvgPicture.asset(
                'assets/illustrations/watercolor/bow.svg',
                excludeFromSemantics: true,
              ),
            ),
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
    final gap = sealSize / 2 + w * 0.045;
    final top = card.top + card.height * 0.12;
    return [
      // Nombres y fecha sobre el sello.
      Positioned(
        left: card.left + w * 0.14,
        width: w * 0.72,
        top: top,
        height: card.center.dy - gap - top,
        child: FittedBox(
          fit: BoxFit.scaleDown,
          alignment: Alignment.bottomCenter,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'NOS CASAMOS',
                style: AppTheme.eyebrow(
                  color: _Paper.sage,
                ).copyWith(fontSize: w * 0.034, letterSpacing: w * 0.012),
              ),
              SizedBox(height: w * 0.025),
              Text(
                'Gabriela\n& Edgar',
                textAlign: TextAlign.center,
                style: AppTheme.script(
                  fontSize: w * 0.15,
                  color: _Paper.sageInk,
                ).copyWith(height: 1.05),
              ),
              SizedBox(height: w * 0.03),
              Text(
                '28 · 08 · 2027',
                style: AppTheme.display(
                  fontSize: w * 0.07,
                  color: _Paper.sageInk,
                ),
              ),
              SizedBox(height: w * 0.01),
              Text(
                'VALENCIA',
                style: AppTheme.eyebrow(
                  color: _Paper.sage,
                ).copyWith(fontSize: w * 0.03, letterSpacing: w * 0.012),
              ),
            ],
          ),
        ),
      ),
      Positioned(
        left: card.left + w * 0.2,
        width: w * 0.6,
        top: card.center.dy + gap,
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
  static const sage = Color(0xFF7E8A70);
  static const sageInk = Color(0xFF5F6B55);
}
