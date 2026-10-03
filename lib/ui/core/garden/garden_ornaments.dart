import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../theme/app_motion.dart';
import '../theme/app_theme.dart';

/// Ramillete silvestre para la esquina inferior derecha de una tarjeta.
/// Se mece muy despacio.
class CornerBouquet extends StatefulWidget {
  const CornerBouquet({super.key, this.size = 150});

  final double size;

  @override
  State<CornerBouquet> createState() => _CornerBouquetState();
}

class _CornerBouquetState extends State<CornerBouquet>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: AppMotion.cornerSway,
  );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (AppMotion.reduced(context)) {
      _controller.stop();
    } else if (!_controller.isAnimating) {
      _controller.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final picture = SvgPicture.asset(
      'assets/illustrations/wildflowers/corner_bouquet.svg',
      width: widget.size,
      height: widget.size,
      excludeFromSemantics: true,
    );
    return IgnorePointer(
      child: RepaintBoundary(
        // El SVG crece desde abajo a la izquierda; lo reflejamos para la
        // esquina derecha.
        child: Transform.flip(
          flipX: true,
          child: AnimatedBuilder(
            animation: _controller,
            child: picture,
            builder: (context, child) {
              final angle =
                  (-2.5 + 5.5 * AppMotion.gentle.transform(_controller.value)) *
                  math.pi /
                  180;
              return Transform.rotate(
                angle: angle,
                alignment: Alignment.bottomLeft,
                child: child,
              );
            },
          ),
        ),
      ),
    );
  }
}

/// Mariposa que cruza la pantalla de vez en cuando.
class GardenButterfly extends StatefulWidget {
  const GardenButterfly({super.key});

  @override
  State<GardenButterfly> createState() => _GardenButterflyState();
}

class _GardenButterflyState extends State<GardenButterfly>
    with TickerProviderStateMixin {
  late final AnimationController _flight = AnimationController(
    vsync: this,
    duration: AppMotion.butterflyFlight,
  );
  late final AnimationController _flap = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 280),
  );
  double _lane = 0.35;
  bool _started = false;
  final _random = math.Random();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_started || AppMotion.reduced(context)) {
      return;
    }
    _started = true;
    _flight.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _flap.stop();
        Future<void>.delayed(
          AppMotion.butterflyEvery - AppMotion.butterflyFlight,
          _fly,
        );
      }
    });
    Future<void>.delayed(const Duration(seconds: 5), _fly);
  }

  void _fly() {
    if (!mounted) {
      return;
    }
    setState(() => _lane = 0.2 + _random.nextDouble() * 0.5);
    _flap.repeat(reverse: true);
    _flight.forward(from: 0);
  }

  @override
  void dispose() {
    _flight.dispose();
    _flap.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: AnimatedBuilder(
        animation: Listenable.merge([_flight, _flap]),
        builder: (context, _) {
          if (!_flight.isAnimating) {
            return const SizedBox.shrink();
          }
          final size = MediaQuery.sizeOf(context);
          final t = _flight.value;
          final x = -60 + (size.width + 120) * t;
          final y =
              size.height * _lane + math.sin(t * math.pi * 4) * 60 - 40 * t;
          return Stack(
            children: [
              Positioned(
                left: x,
                top: y,
                child: Transform.rotate(
                  angle: math.sin(t * math.pi * 6) * 0.15,
                  child: CustomPaint(
                    size: const Size(42, 34),
                    painter: _ButterflyPainter(1 - 0.7 * _flap.value),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _ButterflyPainter extends CustomPainter {
  _ButterflyPainter(this.open);

  final double open;

  @override
  void paint(Canvas canvas, Size size) {
    canvas
      ..translate(size.width / 2, size.height / 2)
      ..scale(size.width / 120);
    final wing = Path()
      ..moveTo(0, 0)
      ..cubicTo(20, -40, 52, -30, 40, -4)
      ..cubicTo(50, 8, 30, 30, 0, 4)
      ..close();
    final fill = Paint()..color = AppTheme.sweetPea;
    final stroke = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..color = AppTheme.roseInk;
    for (final side in [1.0, -1.0]) {
      canvas
        ..save()
        ..scale(side * open, 1)
        ..drawPath(wing, fill)
        ..drawPath(wing, stroke)
        ..restore();
    }
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(-2.5, -16, 5, 30),
        const Radius.circular(2.5),
      ),
      Paint()..color = AppTheme.ink,
    );
  }

  @override
  bool shouldRepaint(covariant _ButterflyPainter oldDelegate) =>
      oldDelegate.open != open;
}

/// Lanza una lluvia de pétalos desde el centro de [origin].
void showPetalBurst(BuildContext context, Rect origin) {
  if (AppMotion.reduced(context)) {
    return;
  }
  final overlay = Overlay.maybeOf(context);
  if (overlay == null) {
    return;
  }
  late final OverlayEntry entry;
  entry = OverlayEntry(
    builder: (_) =>
        _PetalBurst(origin: origin.center, onDone: () => entry.remove()),
  );
  overlay.insert(entry);
}

class _PetalBurst extends StatefulWidget {
  const _PetalBurst({required this.origin, required this.onDone});

  final Offset origin;
  final VoidCallback onDone;

  @override
  State<_PetalBurst> createState() => _PetalBurstState();
}

class _PetalBurstState extends State<_PetalBurst>
    with SingleTickerProviderStateMixin {
  static const _colors = [
    AppTheme.bellBlue,
    AppTheme.oliveLeaf,
    AppTheme.sweetPea,
    AppTheme.peach,
    AppTheme.butter,
    AppTheme.lavender,
    AppTheme.bubblegum,
  ];

  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: AppMotion.petalBurst,
  )..forward().whenComplete(widget.onDone);

  late final List<_Petal> _petals = List.generate(36, (i) {
    final random = math.Random(i * 7919);
    return _Petal(
      angle: random.nextDouble() * math.pi * 2,
      distance: 80 + random.nextDouble() * 140,
      spin: (random.nextDouble() - 0.5) * 12,
      color: _colors[i % _colors.length],
    );
  });

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: CustomPaint(
        size: Size.infinite,
        painter: _PetalBurstPainter(_controller, widget.origin, _petals),
      ),
    );
  }
}

class _Petal {
  const _Petal({
    required this.angle,
    required this.distance,
    required this.spin,
    required this.color,
  });

  final double angle;
  final double distance;
  final double spin;
  final Color color;
}

class _PetalBurstPainter extends CustomPainter {
  _PetalBurstPainter(this.progress, this.origin, this.petals)
    : super(repaint: progress);

  final Animation<double> progress;
  final Offset origin;
  final List<_Petal> petals;

  @override
  void paint(Canvas canvas, Size size) {
    final t = progress.value;
    final burst = Curves.easeOutCubic.transform((t / 0.55).clamp(0.0, 1.0));
    final fall = ((t - 0.55) / 0.45).clamp(0.0, 1.0);
    final opacity = 1 - fall;
    final paint = Paint();
    for (final petal in petals) {
      final dx = math.cos(petal.angle) * petal.distance * (burst + 0.15 * fall);
      final dy =
          math.sin(petal.angle) * petal.distance * burst -
          50 * burst +
          190 * fall * fall;
      paint.color = petal.color.withValues(alpha: opacity);
      canvas
        ..save()
        ..translate(origin.dx + dx, origin.dy + dy)
        ..rotate(petal.spin * t)
        ..drawPath(
          Path()
            ..moveTo(-6, 0)
            ..quadraticBezierTo(-6, -5, 0, -5)
            ..quadraticBezierTo(6, -5, 6, 0)
            ..quadraticBezierTo(6, 5, 0, 5)
            ..close(),
          paint,
        )
        ..restore();
    }
  }

  @override
  bool shouldRepaint(covariant _PetalBurstPainter oldDelegate) => false;
}
