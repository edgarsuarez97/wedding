import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../theme/app_motion.dart';
import '../theme/app_theme.dart';
import 'viewport.dart';
import 'wildflower.dart';

/// Separador entre secciones: dos ramas que se dibujan hacia el centro, hojas
/// que brotan y una orquídea que abre al final. Se anima al entrar en pantalla.
class GardenDivider extends StatefulWidget {
  const GardenDivider({super.key});

  @override
  State<GardenDivider> createState() => _GardenDividerState();
}

class _GardenDividerState extends State<GardenDivider>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: AppMotion.vineDraw,
  );
  late final Animation<double> _bloom = CurvedAnimation(
    parent: _controller,
    curve: const Interval(0.55, 1, curve: AppMotion.sproutCurve),
  );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (AppMotion.reduced(context)) {
      _controller.value = 1;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return InViewTrigger(
      onEnter: () {
        if (!_controller.isCompleted) {
          _controller.forward();
        }
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 20),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: AspectRatio(
              aspectRatio: 400 / 60,
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final scale = constraints.maxWidth / 400;
                  final orchidSize = 40 * scale;
                  return Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Positioned.fill(
                        child: CustomPaint(painter: _VinePainter(_controller)),
                      ),
                      Positioned(
                        left: 200 * scale - orchidSize / 2,
                        top: 30 * scale - orchidSize / 2,
                        width: orchidSize,
                        height: orchidSize,
                        child: ScaleTransition(
                          scale: _bloom,
                          child: RotationTransition(
                            turns: Tween<double>(
                              begin: -0.25,
                              end: 0,
                            ).animate(_bloom),
                            child: WildflowerIcon(
                              Wildflower.orchid,
                              size: orchidSize,
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _VinePainter extends CustomPainter {
  _VinePainter(this.progress) : super(repaint: progress);

  final Animation<double> progress;

  static final Path _vines = Path()
    ..moveTo(10, 30)
    ..cubicTo(60, 6, 110, 54, 170, 30)
    ..moveTo(390, 30)
    ..cubicTo(340, 54, 290, 6, 230, 30);

  // (x, y, grados, escala, orden de aparición)
  static const _leaves = [
    (50.0, 18.0, -60.0, 0.55, 0),
    (100.0, 38.0, 40.0, 0.55, 1),
    (142.0, 38.0, -50.0, 0.5, 2),
    (258.0, 22.0, -130.0, 0.5, 2),
    (300.0, 42.0, 140.0, 0.55, 1),
    (350.0, 22.0, -120.0, 0.55, 0),
  ];

  static final Path _leaf = Path()
    ..moveTo(0, 0)
    ..cubicTo(8, -9, 22, -10, 32, 0)
    ..cubicTo(22, 10, 8, 9, 0, 0)
    ..close();

  final _stroke = Paint()
    ..style = PaintingStyle.stroke
    ..strokeCap = StrokeCap.round
    ..strokeWidth = 1.5
    ..color = AppTheme.olive;
  final _leafFill = Paint()..color = AppTheme.mint;
  final _leafStroke = Paint()
    ..style = PaintingStyle.stroke
    ..strokeWidth = 0.7
    ..color = AppTheme.stem;

  @override
  void paint(Canvas canvas, Size size) {
    final t = progress.value;
    canvas.scale(size.width / 400, size.height / 60);

    final draw = (t / 0.8).clamp(0.0, 1.0);
    final eased = Curves.easeInOut.transform(draw);
    for (final metric in _vines.computeMetrics()) {
      canvas.drawPath(metric.extractPath(0, metric.length * eased), _stroke);
    }

    for (final (x, y, deg, s, order) in _leaves) {
      final start = 0.25 + order * 0.08;
      final local = ((t - start) / 0.3).clamp(0.0, 1.0);
      if (local == 0) {
        continue;
      }
      final grow = Curves.easeOutBack.transform(local);
      canvas
        ..save()
        ..translate(x, y)
        ..rotate(deg * math.pi / 180)
        ..scale(s * grow)
        ..translate(-16, 0)
        ..drawPath(_leaf, _leafFill)
        ..drawPath(_leaf, _leafStroke)
        ..restore();
    }
  }

  @override
  bool shouldRepaint(covariant _VinePainter oldDelegate) => false;
}
