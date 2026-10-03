import 'dart:math' as math;
import 'dart:ui';

/// Paleta "Garden Party" de Edgar y tonos de apoyo.
abstract final class GardenColors {
  static const bellflower = Color(0xFF9DBCE6);
  static const bellflowerDeep = Color(0xFF8FB0E0);
  static const sky = Color(0xFFBCD7F2);
  static const olive = Color(0xFFB6C489);
  static const oliveDeep = Color(0xFF7D8C52);
  static const sweetPea = Color(0xFFF4C3D3);
  static const bubblegum = Color(0xFFFFA8C1);
  static const peach = Color(0xFFFFCC8F);
  static const butter = Color(0xFFFFEB9F);
  static const lavender = Color(0xFFC9C1E3);
  static const lilac = Color(0xFFDCC2F1);
  static const lavenderDeep = Color(0xFFB8AEE0);
  static const pinkDeep = Color(0xFFF7B3C8);
  static const mint = Color(0xFFB7D7AA);
  static const paper = Color(0xFFFFFDF8);
  static const ink = Color(0xFF34392F);
  static const signature = Color(0xFFB95A84);
}

/// Pinceles de flores silvestres (sin rosas ni margaritas) que comparten el
/// estampado de las puertas y la corona del revelado.
///
/// Todas las funciones dibujan alrededor de [at], con [s] como escala (1 = un
/// tamaño de referencia de ~60 px) y [angle] como dirección del tallo.
abstract final class Wildflowers {
  static Paint _stroke(Color color, double width) => Paint()
    ..color = color
    ..style = PaintingStyle.stroke
    ..strokeWidth = width
    ..strokeCap = StrokeCap.round;

  static Path _leaf(double length, double width) => Path()
    ..moveTo(0, 0)
    ..quadraticBezierTo(length * 0.45, -width, length, 0)
    ..quadraticBezierTo(length * 0.45, width, 0, 0)
    ..close();

  /// Hoja de pasto curva.
  static void grass(Canvas c, Offset at, double s, double angle, Color color) {
    final dir = Offset(math.cos(angle), math.sin(angle));
    final normal = Offset(-dir.dy, dir.dx);
    final tip = at + dir * 70 * s;
    final ctrl = at + dir * 40 * s + normal * 14 * s;
    c.drawPath(
      Path()
        ..moveTo(at.dx, at.dy)
        ..quadraticBezierTo(ctrl.dx, ctrl.dy, tip.dx, tip.dy),
      _stroke(color, 1.6 * s),
    );
  }

  /// Helecho: tallo con folíolos alternos que se achican hacia la punta.
  static void fern(Canvas c, Offset at, double s, double angle, Color color) {
    final dir = Offset(math.cos(angle), math.sin(angle));
    final length = 64 * s;
    c.drawLine(at, at + dir * length, _stroke(color, 1.3 * s));
    final leaf = Paint()..color = color;
    for (var i = 1; i <= 9; i++) {
      final t = i / 10;
      final p = at + dir * length * t;
      final size = (1 - t * 0.7) * 11 * s;
      for (final side in [-1.0, 1.0]) {
        c.save();
        c.translate(p.dx, p.dy);
        c.rotate(angle + side * 0.95);
        c.drawPath(_leaf(size, size * 0.28), leaf);
        c.restore();
      }
    }
  }

  /// Ramita de hojas ovaladas.
  static void leafySprig(
    Canvas c,
    Offset at,
    double s,
    double angle,
    Color color,
  ) {
    final dir = Offset(math.cos(angle), math.sin(angle));
    final length = 48 * s;
    c.drawLine(at, at + dir * length, _stroke(GardenColors.oliveDeep, 1.2 * s));
    final leaf = Paint()..color = color;
    for (var i = 0; i < 4; i++) {
      final p = at + dir * length * (0.3 + i * 0.22);
      final side = i.isEven ? 1.0 : -1.0;
      c.save();
      c.translate(p.dx, p.dy);
      c.rotate(angle + side * 0.7);
      c.drawPath(_leaf(15 * s, 5 * s), leaf);
      c.restore();
    }
  }

  /// Espiga de lavanda o delfinio.
  static void spike(Canvas c, Offset at, double s, double angle, Color color) {
    final dir = Offset(math.cos(angle), math.sin(angle));
    final length = 70 * s;
    c.drawLine(at, at + dir * length, _stroke(GardenColors.oliveDeep, 1.3 * s));
    final bud = Paint()..color = color;
    final shade = Paint()..color = Color.lerp(color, GardenColors.ink, 0.18)!;
    for (var i = 0; i < 10; i++) {
      final t = 0.45 + i * 0.055;
      final p = at + dir * length * t;
      final size = (1 - i * 0.06) * 5.2 * s;
      for (final side in [-1.0, 1.0]) {
        c.save();
        c.translate(p.dx, p.dy);
        c.rotate(angle + side * 0.6);
        c.drawOval(
          Rect.fromCenter(
            center: Offset(size * 0.5, side * size * 0.5),
            width: size * 1.7,
            height: size,
          ),
          side < 0 ? shade : bud,
        );
        c.restore();
      }
    }
  }

  /// Rama arqueada de campanillas colgantes.
  static void bellflowers(
    Canvas c,
    Offset at,
    double s,
    double angle,
    Color color,
  ) {
    final dir = Offset(math.cos(angle), math.sin(angle));
    final normal = Offset(-dir.dy, dir.dx);
    final length = 72 * s;
    final ctrl = at + dir * length * 0.55 - normal * 18 * s;
    final tip = at + dir * length;
    final path = Path()
      ..moveTo(at.dx, at.dy)
      ..quadraticBezierTo(ctrl.dx, ctrl.dy, tip.dx, tip.dy);
    final stem = _stroke(GardenColors.oliveDeep, 1.3 * s);
    c.drawPath(path, stem);

    final bell = Paint()..color = color;
    final inner = Paint()..color = Color.lerp(color, GardenColors.paper, 0.45)!;
    final metric = path.computeMetrics().first;
    for (var d = metric.length * 0.35; d < metric.length; d += 15 * s) {
      final p = metric.getTangentForOffset(d)!.position;
      final hang = p + Offset(0, 7 * s);
      c.drawLine(p, hang, _stroke(GardenColors.oliveDeep, 0.9 * s));
      c.save();
      c.translate(hang.dx, hang.dy);
      c.scale(s);
      final shape = Path()
        ..moveTo(-3.5, 0)
        ..quadraticBezierTo(-5, 6, -7, 10)
        ..quadraticBezierTo(-3.5, 8, -2, 11)
        ..quadraticBezierTo(0, 8.5, 2, 11)
        ..quadraticBezierTo(3.5, 8, 7, 10)
        ..quadraticBezierTo(5, 6, 3.5, 0)
        ..close();
      c.drawPath(shape, bell);
      c.drawOval(const Rect.fromLTWH(-2.5, 1, 5, 4), inner);
      c.restore();
    }
  }

  /// Lirio visto de frente: seis pétalos en punta con estambres.
  static void lily(Canvas c, Offset at, double s, double angle, Color color) {
    final radius = 17 * s;
    final petal = Paint()..color = color;
    final deep = Paint()
      ..color = Color.lerp(color, GardenColors.signature, 0.25)!;
    final vein = _stroke(Color.lerp(color, GardenColors.paper, 0.5)!, 0.9 * s);
    c.save();
    c.translate(at.dx, at.dy);
    c.rotate(angle);
    for (var i = 0; i < 6; i++) {
      c.save();
      c.rotate(i * math.pi / 3 + (i.isOdd ? 0.1 : 0));
      final r = i.isOdd ? radius * 0.85 : radius;
      c.drawPath(_leaf(r, r * 0.3), i.isOdd ? deep : petal);
      c.drawLine(Offset(r * 0.15, 0), Offset(r * 0.8, 0), vein);
      c.restore();
    }
    final stamen = _stroke(GardenColors.oliveDeep, 0.8 * s);
    final pollen = Paint()..color = const Color(0xFFC98A5A);
    for (var i = 0; i < 6; i++) {
      final a = i * math.pi / 3 + math.pi / 6;
      final end = Offset(math.cos(a), math.sin(a)) * radius * 0.48;
      c.drawLine(Offset.zero, end, stamen);
      c.drawCircle(end, 1.4 * s, pollen);
    }
    c.restore();
  }

  /// Guisante de olor: pétalo superior ondulado y quilla.
  static void sweetPea(
    Canvas c,
    Offset at,
    double s,
    double angle,
    Color color,
  ) {
    c.save();
    c.translate(at.dx, at.dy);
    c.rotate(angle);
    c.scale(s);
    final back = Paint()..color = color;
    final keel = Paint()
      ..color = Color.lerp(color, GardenColors.signature, 0.3)!;
    final ruffle = Path()..moveTo(-12, 2);
    for (var i = 0; i <= 6; i++) {
      final a = math.pi + i * math.pi / 6;
      final r = 11 + (i.isEven ? 1.6 : -0.6);
      ruffle.lineTo(math.cos(a) * r, math.sin(a) * r * 0.9);
    }
    ruffle
      ..lineTo(12, 2)
      ..quadraticBezierTo(0, 6, -12, 2)
      ..close();
    c.drawPath(ruffle, back);
    c.drawOval(const Rect.fromLTWH(-6, -1, 12, 8), keel);
    c.drawLine(
      const Offset(0, 6),
      const Offset(0, 22),
      _stroke(GardenColors.oliveDeep, 1.2),
    );
    c.restore();
  }

  /// Ramillete de nomeolvides: flores pequeñas de cinco pétalos.
  static void forgetMeNots(Canvas c, Offset at, double s, Color color) {
    final random = math.Random((at.dx * 7 + at.dy * 13).round());
    final petal = Paint()..color = color;
    final eye = Paint()..color = GardenColors.butter;
    final ring = Paint()..color = GardenColors.paper;
    for (var i = 0; i < 5; i++) {
      final p =
          at +
          Offset(random.nextDouble() * 26 - 13, random.nextDouble() * 26 - 13) *
              s;
      final r = (3 + random.nextDouble() * 1.4) * s;
      for (var k = 0; k < 5; k++) {
        final a = k * 2 * math.pi / 5;
        c.drawCircle(p + Offset(math.cos(a), math.sin(a)) * r, r * 0.95, petal);
      }
      c.drawCircle(p, r * 0.6, ring);
      c.drawCircle(p, r * 0.38, eye);
    }
  }

  /// Ranúnculo: cinco pétalos anchos y brillantes en forma de copa.
  static void buttercup(Canvas c, Offset at, double s) {
    final petal = Paint()..color = GardenColors.butter;
    final shade = Paint()..color = const Color(0xFFF2D27A);
    c.save();
    c.translate(at.dx, at.dy);
    c.scale(s);
    for (var k = 0; k < 5; k++) {
      final a = k * 2 * math.pi / 5 - math.pi / 2;
      c.drawCircle(Offset(math.cos(a), math.sin(a)) * 5.5, 5.4, petal);
    }
    c.drawCircle(Offset.zero, 4.4, shade);
    c.drawCircle(Offset.zero, 2, Paint()..color = GardenColors.oliveDeep);
    c.restore();
  }

  /// Velo de novia: puntitos claros.
  static void babysBreath(Canvas c, Offset at, double s) {
    final random = math.Random((at.dx * 3 + at.dy * 5).round());
    final stem = _stroke(GardenColors.oliveDeep, 0.8 * s);
    final dot = Paint()..color = GardenColors.paper;
    final edge = Paint()..color = const Color(0xFFE8E2CF);
    for (var i = 0; i < 9; i++) {
      final p =
          at +
          Offset(random.nextDouble() * 24 - 12, random.nextDouble() * 24 - 12) *
              s;
      c.drawLine(at, p, stem);
      c.drawCircle(p, 2.8 * s, edge);
      c.drawCircle(p, 2.1 * s, dot);
    }
  }

  /// Dibuja un elemento aleatorio del repertorio; [foliage] elige solo hojas.
  static void any(
    Canvas c,
    math.Random random,
    Offset at,
    double s,
    double angle, {
    bool foliage = false,
  }) {
    if (foliage) {
      switch (random.nextInt(3)) {
        case 0:
          fern(c, at, s, angle, GardenColors.olive);
        case 1:
          leafySprig(c, at, s, angle, GardenColors.mint);
        default:
          grass(c, at, s, angle, GardenColors.mint);
      }
      return;
    }
    switch (random.nextInt(9)) {
      case 0:
        bellflowers(c, at, s, angle, GardenColors.bellflowerDeep);
      case 1:
        lily(c, at, s, angle, GardenColors.bubblegum);
      case 2:
        lily(c, at, s * 0.85, angle, GardenColors.lavenderDeep);
      case 3:
        spike(c, at, s, angle, GardenColors.lavenderDeep);
      case 4:
        sweetPea(c, at, s, angle, GardenColors.pinkDeep);
      case 5:
        forgetMeNots(c, at, s, GardenColors.bellflower);
      case 6:
        buttercup(c, at, s);
      case 7:
        sweetPea(c, at, s * 0.9, angle, GardenColors.lilac);
      default:
        spike(c, at, s * 0.9, angle, GardenColors.bellflowerDeep);
    }
  }
}

/// Estampado denso de flores silvestres que cubre todo el lienzo, como el
/// papel de las puertas de la invitación.
void paintWildflowerPrint(Canvas canvas, Size size, {int seed = 2808}) {
  canvas.drawRect(Offset.zero & size, Paint()..color = GardenColors.paper);
  final random = math.Random(seed);
  final s = (size.shortestSide / 230).clamp(1.3, 2.4);
  final cell = 46 * s;

  // Primero el follaje, luego las flores encima.
  for (final foliage in [true, false]) {
    for (var y = -cell; y < size.height + cell; y += cell) {
      for (var x = -cell; x < size.width + cell; x += cell) {
        final at = Offset(
          x + random.nextDouble() * cell,
          y + random.nextDouble() * cell,
        );
        final angle = random.nextDouble() * 2 * math.pi;
        Wildflowers.any(
          canvas,
          random,
          at,
          s * (0.85 + random.nextDouble() * 0.35),
          angle,
          foliage: foliage,
        );
        if (!foliage && random.nextDouble() < 0.35) {
          Wildflowers.babysBreath(
            canvas,
            at + Offset(cell * 0.4, cell * 0.3),
            s * 0.8,
          );
        }
      }
    }
  }
}
