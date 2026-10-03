import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/painting.dart';

/// Estampado floral "impreso" para las puertas de la portada: rosas,
/// claveles, margaritas, cosmos, billy buttons, alhelí, delfinio y eucalipto
/// pintados con degradados para que se lean como una ilustración realista
/// sobre papel, no como iconos planos.
abstract final class PrintColors {
  static const paper = Color(0xFFFBF8F1);
  static const blushLight = Color(0xFFFBE3DA);
  static const blushDark = Color(0xFFD98878);
  static const creamLight = Color(0xFFFFF7EA);
  static const creamDark = Color(0xFFD6B484);
  static const carnationLight = Color(0xFFFAD0D8);
  static const carnationDark = Color(0xFFDE8199);
  static const cosmosLight = Color(0xFFC9DAF4);
  static const cosmosDark = Color(0xFF7898D4);
  static const lilacLight = Color(0xFFE2DAF4);
  static const lilacDark = Color(0xFF9D8CCB);
  static const sunLight = Color(0xFFFFE89A);
  static const sunDark = Color(0xFFD9A62B);
  static const stockLight = Color(0xFFF9D3E2);
  static const stockDark = Color(0xFFD889A8);
  static const delphLight = Color(0xFFC2D6F5);
  static const delphDark = Color(0xFF6A8ED0);
  static const leafLight = Color(0xFFB7CBB9);
  static const leafDark = Color(0xFF7E9A86);
  static const stem = Color(0xFF8C9E73);
}

Paint _radial(
  Offset center,
  double radius,
  Color inner,
  Color outer, [
  List<double>? stops,
]) {
  return Paint()
    ..shader = ui.Gradient.radial(center, math.max(radius, 0.1), [
      inner,
      outer,
    ], stops ?? const [0, 1]);
}

Paint _line(Color color, double width) => Paint()
  ..color = color
  ..style = PaintingStyle.stroke
  ..strokeWidth = width
  ..strokeCap = StrokeCap.round;

Offset _polar(double angle, double radius) =>
    Offset(math.cos(angle), math.sin(angle)) * radius;

/// Pétalo redondeado que nace en el origen y apunta hacia +x.
Path _petal(double length, double width, {double tipRound = 0.55}) {
  return Path()
    ..moveTo(0, 0)
    ..cubicTo(
      length * 0.2,
      -width * 0.9,
      length * tipRound,
      -width,
      length,
      -width * 0.25,
    )
    ..quadraticBezierTo(length * 1.04, 0, length, width * 0.25)
    ..cubicTo(length * tipRound, width, length * 0.2, width * 0.9, 0, 0)
    ..close();
}

void _rose(Canvas c, Offset at, double r, double rot, Color light, Color dark) {
  c.save();
  c.translate(at.dx, at.dy);
  c.rotate(rot);
  // Sombra suave bajo la flor, como tinta más densa.
  c.drawCircle(
    const Offset(1.5, 2.5),
    r * 1.02,
    Paint()
      ..color = dark.withValues(alpha: 0.18)
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, r * 0.12),
  );
  final edge = _line(dark.withValues(alpha: 0.6), math.max(0.7, r * 0.03));
  final petalShadow = Paint()
    ..color = dark.withValues(alpha: 0.35)
    ..maskFilter = MaskFilter.blur(BlurStyle.normal, r * 0.05);
  // Pétalos exteriores abiertos.
  for (var i = 0; i < 6; i++) {
    final a = i * math.pi / 3 + 0.2;
    c.save();
    c.rotate(a);
    final petal = _petal(r * 1.02, r * 0.5, tipRound: 0.7);
    c.drawPath(petal.shift(Offset(r * 0.03, r * 0.04)), petalShadow);
    c.drawPath(petal, _radial(Offset.zero, r, dark, light, const [0.15, 0.95]));
    c.drawPath(petal, edge);
    c.restore();
  }
  // Segunda corona de pétalos.
  for (var i = 0; i < 5; i++) {
    final a = i * 2 * math.pi / 5 + 0.6;
    c.save();
    c.rotate(a);
    final petal = _petal(r * 0.72, r * 0.42, tipRound: 0.65);
    c.drawPath(petal.shift(Offset(r * 0.03, r * 0.04)), petalShadow);
    c.drawPath(
      petal,
      _radial(Offset.zero, r * 0.72, dark, light, const [0.1, 1]),
    );
    c.drawPath(petal, edge);
    c.restore();
  }
  // Copa central con pétalos enrollados en espiral.
  c.drawCircle(
    Offset.zero,
    r * 0.44,
    _radial(const Offset(-1, -1), r * 0.44, light, dark, const [0.2, 1]),
  );
  for (var k = 0; k < 5; k++) {
    final radius = r * (0.4 - k * 0.07);
    final start = k * 1.25;
    final rect = Rect.fromCircle(
      center: Offset(k * 0.4, -k * 0.3),
      radius: radius,
    );
    c.drawArc(
      rect,
      start,
      3.6,
      false,
      _line(light.withValues(alpha: 0.9), r * 0.05),
    );
    c.drawArc(
      rect.shift(Offset(r * 0.02, r * 0.03)),
      start,
      3.6,
      false,
      _line(dark.withValues(alpha: 0.55), r * 0.035),
    );
  }
  c.restore();
}

Path _ruffledCircle(double radius, double depth, int teeth, math.Random rnd) {
  final path = Path();
  for (var i = 0; i <= teeth * 2; i++) {
    final a = i * math.pi / teeth;
    final rr = radius - (i.isOdd ? depth * (0.6 + rnd.nextDouble() * 0.8) : 0);
    final p = _polar(a, rr);
    i == 0 ? path.moveTo(p.dx, p.dy) : path.lineTo(p.dx, p.dy);
  }
  return path..close();
}

void _carnation(Canvas c, Offset at, double r, double rot, math.Random rnd) {
  c.save();
  c.translate(at.dx, at.dy);
  c.rotate(rot);
  c.drawCircle(
    const Offset(1.5, 2.5),
    r,
    Paint()
      ..color = PrintColors.carnationDark.withValues(alpha: 0.18)
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, r * 0.12),
  );
  for (var layer = 0; layer < 4; layer++) {
    final radius = r * (1 - layer * 0.21);
    final ruffle = _ruffledCircle(radius, r * 0.1, 30 - layer * 4, rnd);
    c.save();
    c.rotate(layer * 0.37);
    c.drawPath(
      ruffle,
      _radial(
        Offset.zero,
        radius,
        PrintColors.carnationDark,
        PrintColors.carnationLight,
        const [0.25, 1],
      ),
    );
    c.drawPath(
      ruffle,
      _line(PrintColors.carnationDark.withValues(alpha: 0.3), r * 0.02),
    );
    // Pliegues de los pétalos.
    final fold = _line(
      PrintColors.carnationDark.withValues(alpha: 0.28),
      r * 0.025,
    );
    for (var i = 0; i < 14; i++) {
      final a = i * 2 * math.pi / 14 + rnd.nextDouble() * 0.2;
      c.drawLine(_polar(a, radius * 0.45), _polar(a, radius * 0.9), fold);
    }
    c.restore();
  }
  c.restore();
}

void _daisy(Canvas c, Offset at, double r, double rot) {
  c.save();
  c.translate(at.dx, at.dy);
  c.rotate(rot);
  final shade = const Color(0xFFDCD6CA);
  const petals = 18;
  for (var i = 0; i < petals; i++) {
    c.save();
    c.rotate(i * 2 * math.pi / petals);
    final petal = _petal(r, r * 0.16, tipRound: 0.8);
    c.drawPath(
      petal,
      Paint()
        ..shader = ui.Gradient.linear(
          Offset.zero,
          Offset(r, 0),
          [shade, const Color(0xFFFFFEFA), const Color(0xFFF4F1EA)],
          const [0.15, 0.55, 1],
        ),
    );
    c.drawPath(
      petal,
      _line(shade.withValues(alpha: 0.8), math.max(0.5, r * 0.02)),
    );
    c.drawLine(
      Offset(r * 0.32, 0),
      Offset(r * 0.85, 0),
      _line(shade.withValues(alpha: 0.6), math.max(0.4, r * 0.012)),
    );
    c.restore();
  }
  _seedHead(c, r * 0.3);
  c.restore();
}

void _seedHead(Canvas c, double radius) {
  c.drawCircle(
    Offset.zero,
    radius,
    _radial(
      Offset(-radius * 0.3, -radius * 0.3),
      radius * 1.3,
      PrintColors.sunLight,
      PrintColors.sunDark,
    ),
  );
  final dot = Paint()..color = const Color(0xFFB98516).withValues(alpha: 0.55);
  for (var i = 0; i < 28; i++) {
    final a = i * 2.399963; // ángulo áureo
    final d = radius * 0.9 * math.sqrt(i / 28);
    c.drawCircle(_polar(a, d), radius * 0.07, dot);
  }
}

void _cosmos(
  Canvas c,
  Offset at,
  double r,
  double rot,
  Color light,
  Color dark,
) {
  c.save();
  c.translate(at.dx, at.dy);
  c.rotate(rot);
  final vein = _line(dark.withValues(alpha: 0.35), math.max(0.4, r * 0.015));
  for (var i = 0; i < 8; i++) {
    c.save();
    c.rotate(i * math.pi / 4);
    final w = r * 0.3;
    // Pétalo ancho con la punta dentada típica del cosmos.
    final petal = Path()
      ..moveTo(0, 0)
      ..cubicTo(r * 0.3, -w * 0.9, r * 0.75, -w * 1.15, r * 0.97, -w * 0.7)
      ..lineTo(r * 0.9, -w * 0.3)
      ..lineTo(r, -w * 0.05)
      ..lineTo(r * 0.9, w * 0.25)
      ..lineTo(r * 0.97, w * 0.7)
      ..cubicTo(r * 0.75, w * 1.15, r * 0.3, w * 0.9, 0, 0)
      ..close();
    c.drawPath(petal, _radial(Offset.zero, r, dark, light, const [0.1, 0.85]));
    c.drawPath(
      petal,
      _line(dark.withValues(alpha: 0.4), math.max(0.5, r * 0.02)),
    );
    for (final t in [-0.5, 0.0, 0.5]) {
      c.drawLine(Offset(r * 0.2, 0), Offset(r * 0.85, w * t * 1.2), vein);
    }
    c.restore();
  }
  _seedHead(c, r * 0.2);
  c.restore();
}

void _billyButton(Canvas c, Offset at, double r) {
  c.drawLine(
    at,
    at + Offset(r * 0.4, r * 3.2),
    _line(PrintColors.stem, r * 0.12),
  );
  c.drawCircle(
    at + Offset(r * 0.12, r * 0.18),
    r,
    Paint()
      ..color = PrintColors.sunDark.withValues(alpha: 0.25)
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, r * 0.2),
  );
  c.drawCircle(
    at,
    r,
    _radial(
      at + Offset(-r * 0.35, -r * 0.35),
      r * 1.45,
      PrintColors.sunLight,
      PrintColors.sunDark,
    ),
  );
  final dot = Paint()..color = const Color(0xFFB98516).withValues(alpha: 0.4);
  for (var i = 0; i < 40; i++) {
    final a = i * 2.399963;
    final d = r * 0.92 * math.sqrt(i / 40);
    c.drawCircle(at + _polar(a, d), r * 0.08, dot);
  }
}

/// Espiga de florecitas (alhelí o delfinio).
void _spike(
  Canvas c,
  Offset at,
  double s,
  double angle,
  Color light,
  Color dark, {
  required int petals,
}) {
  final dir = _polar(angle, 1);
  final normal = Offset(-dir.dy, dir.dx);
  final length = 110 * s;
  c.drawLine(at, at + dir * length, _line(PrintColors.stem, 1.6 * s));
  final rnd = math.Random((at.dx * 31 + at.dy).round());
  for (var i = 0; i < 13; i++) {
    final t = 0.3 + i * 0.055;
    final size = (1 - i * 0.055) * 9 * s;
    final side = (i.isEven ? 1 : -1) * size * 0.75;
    final p = at + dir * length * t + normal * side;
    if (i > 10) {
      // Capullos cerrados en la punta.
      c.drawOval(
        Rect.fromCenter(center: p, width: size * 1.1, height: size * 0.8),
        _radial(p, size, light, dark),
      );
      continue;
    }
    c.save();
    c.translate(p.dx, p.dy);
    c.rotate(rnd.nextDouble() * math.pi);
    for (var k = 0; k < petals; k++) {
      c.save();
      c.rotate(k * 2 * math.pi / petals);
      final petal = _petal(
        size,
        size * (petals == 4 ? 0.55 : 0.42),
        tipRound: petals == 4 ? 0.6 : 0.75,
      );
      c.drawPath(
        petal,
        _radial(Offset.zero, size, dark, light, const [0.05, 0.9]),
      );
      c.drawPath(petal, _line(dark.withValues(alpha: 0.3), 0.5 * s));
      c.restore();
    }
    c.drawCircle(
      Offset.zero,
      size * 0.2,
      Paint()
        ..color = petals == 4
            ? const Color(0xFFF7EBC2)
            : const Color(0xFFFFFFFF).withValues(alpha: 0.9),
    );
    c.restore();
  }
}

void _eucalyptus(Canvas c, Offset at, double s, double angle) {
  final dir = _polar(angle, 1);
  final normal = Offset(-dir.dy, dir.dx);
  final length = 120 * s;
  final ctrl = at + dir * length * 0.5 + normal * 14 * s;
  final tip = at + dir * length;
  final stem = Path()
    ..moveTo(at.dx, at.dy)
    ..quadraticBezierTo(ctrl.dx, ctrl.dy, tip.dx, tip.dy);
  c.drawPath(stem, _line(const Color(0xFF9A8A78), 1.4 * s));
  final metric = stem.computeMetrics().first;
  var side = 1.0;
  for (var d = 10 * s; d < metric.length; d += 13 * s) {
    final tangent = metric.getTangentForOffset(d)!;
    final r = (1 - d / metric.length * 0.55) * 9 * s;
    final n = Offset(-math.sin(-tangent.angle), math.cos(-tangent.angle));
    final center = tangent.position + n * r * 0.95 * side;
    c.drawCircle(
      center,
      r,
      _radial(
        center + Offset(-r * 0.3, -r * 0.3),
        r * 1.4,
        PrintColors.leafLight,
        PrintColors.leafDark,
      ),
    );
    c.drawLine(
      tangent.position,
      center + n * r * 0.6 * side,
      _line(const Color(0xFFDDE6DA).withValues(alpha: 0.7), 0.6 * s),
    );
    side = -side;
  }
}

void _leafyStem(Canvas c, Offset at, double s, double angle) {
  final dir = _polar(angle, 1);
  final length = 80 * s;
  c.drawLine(at, at + dir * length, _line(PrintColors.stem, 1.3 * s));
  for (var i = 0; i < 5; i++) {
    final p = at + dir * length * (0.25 + i * 0.16);
    final side = i.isEven ? 1.0 : -1.0;
    c.save();
    c.translate(p.dx, p.dy);
    c.rotate(angle + side * 0.75);
    final leaf = _petal(20 * s * (1 - i * 0.1), 5 * s, tipRound: 0.5);
    c.drawPath(
      leaf,
      Paint()
        ..shader = ui.Gradient.linear(Offset.zero, Offset(20 * s, 0), [
          const Color(0xFF8FA77F),
          const Color(0xFFC5D6B8),
        ]),
    );
    c.drawLine(
      Offset.zero,
      Offset(16 * s, 0),
      _line(const Color(0xFFE4ECDC).withValues(alpha: 0.8), 0.5 * s),
    );
    c.restore();
  }
}

void _filler(Canvas c, Offset at, double s, math.Random rnd) {
  final stem = _line(PrintColors.stem.withValues(alpha: 0.9), 0.8 * s);
  for (var i = 0; i < 10; i++) {
    final p =
        at + Offset(rnd.nextDouble() * 34 - 17, rnd.nextDouble() * 34 - 17) * s;
    c.drawLine(at, p, stem);
    c.drawCircle(
      p,
      2.6 * s,
      _radial(p, 2.6 * s, const Color(0xFFFFFFFF), const Color(0xFFE6E0D2)),
    );
  }
}

/// Pinta el estampado completo sobre [size].
void paintPrintedBouquet(Canvas canvas, Size size, {int seed = 2808}) {
  canvas.drawRect(Offset.zero & size, Paint()..color = PrintColors.paper);
  final rnd = math.Random(seed);
  final s = (size.shortestSide / 420).clamp(0.9, 1.7);

  void grid(double cell, void Function(Offset at) draw) {
    for (var y = -cell; y < size.height + cell; y += cell) {
      for (var x = -cell; x < size.width + cell; x += cell) {
        draw(Offset(x + rnd.nextDouble() * cell, y + rnd.nextDouble() * cell));
      }
    }
  }

  double angle() => rnd.nextDouble() * 2 * math.pi;

  // 1. Follaje de fondo.
  grid(80 * s, (at) {
    rnd.nextBool()
        ? _eucalyptus(canvas, at, s, angle())
        : _leafyStem(canvas, at, s, angle());
  });
  // 2. Espigas.
  grid(120 * s, (at) {
    rnd.nextBool()
        ? _spike(
            canvas,
            at,
            s,
            angle(),
            PrintColors.stockLight,
            PrintColors.stockDark,
            petals: 4,
          )
        : _spike(
            canvas,
            at,
            s,
            angle(),
            PrintColors.delphLight,
            PrintColors.delphDark,
            petals: 5,
          );
  });
  // 3. Flores principales.
  grid(66 * s, (at) {
    final r = (22 + rnd.nextDouble() * 14) * s;
    final rot = angle();
    final pick = rnd.nextDouble();
    if (pick < 0.2) {
      _rose(canvas, at, r, rot, PrintColors.blushLight, PrintColors.blushDark);
    } else if (pick < 0.3) {
      _rose(
        canvas,
        at,
        r * 0.9,
        rot,
        PrintColors.creamLight,
        PrintColors.creamDark,
      );
    } else if (pick < 0.47) {
      _carnation(canvas, at, r * 0.9, rot, rnd);
    } else if (pick < 0.67) {
      _daisy(canvas, at, r * 0.95, rot);
    } else if (pick < 0.8) {
      _cosmos(
        canvas,
        at,
        r * 0.9,
        rot,
        PrintColors.cosmosLight,
        PrintColors.cosmosDark,
      );
    } else if (pick < 0.88) {
      _cosmos(
        canvas,
        at,
        r * 0.8,
        rot,
        PrintColors.lilacLight,
        PrintColors.lilacDark,
      );
    } else {
      _billyButton(canvas, at, r * 0.42);
    }
  });
  // 4. Relleno blanco entre flores.
  grid(95 * s, (at) => _filler(canvas, at, s, rnd));
}
