import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Monograma provisional G&E.
///
/// Cuando el monograma definitivo esté listo (SVG), basta con reemplazar el
/// contenido de [build] por `SvgPicture.asset('assets/monogram/monogram.svg')`
/// y declararlo en `pubspec.yaml`; el resto de la animación no cambia.
class Monogram extends StatelessWidget {
  const Monogram({
    super.key,
    required this.size,
    this.color = const Color(0xFF6F7F4A),
    this.showWreath = true,
  });

  final double size;
  final Color color;
  final bool showWreath;

  @override
  Widget build(BuildContext context) {
    final letterStyle = GoogleFonts.playfairDisplay(
      fontSize: size * 0.34,
      fontStyle: FontStyle.italic,
      fontWeight: FontWeight.w500,
      color: color,
      height: 1,
    );

    return SizedBox.square(
      dimension: size,
      child: CustomPaint(
        painter: showWreath ? _WreathPainter(color: color) : null,
        child: Center(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text('G', style: letterStyle),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: size * 0.02),
                child: Text(
                  '&',
                  style: letterStyle.copyWith(
                    fontSize: size * 0.17,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
              Text('E', style: letterStyle),
            ],
          ),
        ),
      ),
    );
  }
}

/// Corona de hojas abierta en la parte superior, con temática de jardín.
class _WreathPainter extends CustomPainter {
  _WreathPainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final radius = size.width * 0.42;
    final stem = Paint()
      ..color = color.withValues(alpha: 0.75)
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width * 0.012
      ..strokeCap = StrokeCap.round;
    final leaf = Paint()..color = color.withValues(alpha: 0.85);

    // Dos ramas que nacen abajo y suben por cada lado.
    const start = math.pi / 2 + 0.18;
    const sweep = math.pi * 0.78;
    final rect = Rect.fromCircle(center: center, radius: radius);
    canvas.drawArc(rect, start, sweep, false, stem);
    canvas.drawArc(rect, math.pi / 2 - 0.18, -sweep, false, stem);

    const leaves = 7;
    for (var side = -1; side <= 1; side += 2) {
      for (var i = 0; i < leaves; i++) {
        final t = (i + 0.5) / leaves;
        final angle = math.pi / 2 - side * (0.18 + sweep * t);
        final point =
            center + Offset(math.cos(angle), math.sin(angle)) * radius;
        final leafLength = size.width * (0.075 - 0.025 * t);
        for (final offset in [-0.55, 0.55]) {
          canvas.save();
          canvas.translate(point.dx, point.dy);
          canvas.rotate(angle + math.pi / 2 * side * -1 + offset * side);
          canvas.drawPath(_leafPath(leafLength), leaf);
          canvas.restore();
        }
      }
    }

    // Pequeño lirio lavanda donde se unen las ramas.
    final bloom = center + Offset(0, radius);
    final petal = Paint()..color = const Color(0xFFC9BFE6);
    final petalLength = size.width * 0.05;
    for (var i = 0; i < 6; i++) {
      canvas.save();
      canvas.translate(bloom.dx, bloom.dy);
      canvas.rotate(i * math.pi / 3);
      canvas.drawPath(_leafPath(petalLength), petal);
      canvas.restore();
    }
    canvas.drawCircle(
      bloom,
      size.width * 0.01,
      Paint()..color = const Color(0xFFFFEFA3),
    );
  }

  Path _leafPath(double length) {
    return Path()
      ..moveTo(0, 0)
      ..quadraticBezierTo(length * 0.5, -length * 0.38, length, 0)
      ..quadraticBezierTo(length * 0.5, length * 0.38, 0, 0)
      ..close();
  }

  @override
  bool shouldRepaint(_WreathPainter oldDelegate) => oldDelegate.color != color;
}
