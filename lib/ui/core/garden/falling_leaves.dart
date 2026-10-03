import 'dart:math' as math;

import 'package:flutter/scheduler.dart';
import 'package:flutter/widgets.dart';

import '../theme/app_motion.dart';
import '../theme/app_theme.dart';

/// Hojas (y algunos pétalos pastel) que caen girando sobre la portada.
/// Un solo [CustomPainter] con un [Ticker]; con movimiento reducido quedan
/// quietas.
class FallingLeaves extends StatefulWidget {
  const FallingLeaves({super.key, this.count = 26});

  final int count;

  @override
  State<FallingLeaves> createState() => _FallingLeavesState();
}

class _FallingLeavesState extends State<FallingLeaves>
    with SingleTickerProviderStateMixin {
  static const _colors = [
    AppTheme.mint,
    AppTheme.oliveLeaf,
    Color(0xFFA3B678),
    Color(0xFFC9DDB9),
    AppTheme.mint,
    AppTheme.lavender,
    AppTheme.sweetPea,
    AppTheme.butter,
    AppTheme.sky,
  ];

  final _random = math.Random(28082027);
  final _time = ValueNotifier<double>(0);
  late final Ticker _ticker;
  final List<_Leaf> _leaves = [];
  Size _size = Size.zero;
  Duration _last = Duration.zero;

  @override
  void initState() {
    super.initState();
    _ticker = createTicker(_tick);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (AppMotion.reduced(context)) {
      _ticker.stop();
    } else if (!_ticker.isActive) {
      _ticker.start();
    }
  }

  @override
  void dispose() {
    _ticker.dispose();
    _time.dispose();
    super.dispose();
  }

  _Leaf _spawn({required bool anywhere}) {
    return _Leaf(
      x: _random.nextDouble() * _size.width,
      y: anywhere ? _random.nextDouble() * _size.height : -30,
      size: 7 + _random.nextDouble() * 9,
      fallSpeed: 24 + _random.nextDouble() * 42,
      phase: _random.nextDouble() * math.pi * 2,
      sway: 18 + _random.nextDouble() * 40,
      rotation: _random.nextDouble() * math.pi * 2,
      spin: (_random.nextDouble() - 0.5) * 1.6,
      flip: _random.nextDouble() * math.pi * 2,
      color: _colors[_random.nextInt(_colors.length)],
    );
  }

  void _ensureLeaves(Size size) {
    if (size == _size && _leaves.isNotEmpty) {
      return;
    }
    _size = size;
    _leaves
      ..clear()
      ..addAll(List.generate(widget.count, (_) => _spawn(anywhere: true)));
  }

  void _tick(Duration elapsed) {
    final dt = (elapsed - _last).inMicroseconds / 1e6;
    _last = elapsed;
    if (_size.isEmpty || dt <= 0 || dt > 0.25) {
      return;
    }
    final t = elapsed.inMicroseconds / 1e6;
    for (var i = 0; i < _leaves.length; i++) {
      final leaf = _leaves[i];
      leaf.y += leaf.fallSpeed * dt;
      leaf.x += math.sin(t * 0.9 + leaf.phase) * leaf.sway * dt;
      leaf.rotation += leaf.spin * dt;
      if (leaf.y > _size.height + 30) {
        _leaves[i] = _spawn(anywhere: false);
      }
    }
    _time.value = t;
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: RepaintBoundary(
        child: LayoutBuilder(
          builder: (context, constraints) {
            _ensureLeaves(constraints.biggest);
            return CustomPaint(
              size: constraints.biggest,
              painter: _LeavesPainter(_leaves, _time),
            );
          },
        ),
      ),
    );
  }
}

class _Leaf {
  _Leaf({
    required this.x,
    required this.y,
    required this.size,
    required this.fallSpeed,
    required this.phase,
    required this.sway,
    required this.rotation,
    required this.spin,
    required this.flip,
    required this.color,
  });

  double x;
  double y;
  final double size;
  final double fallSpeed;
  final double phase;
  final double sway;
  double rotation;
  final double spin;
  final double flip;
  final Color color;
}

class _LeavesPainter extends CustomPainter {
  _LeavesPainter(this.leaves, this.time) : super(repaint: time);

  final List<_Leaf> leaves;
  final ValueNotifier<double> time;

  final _fill = Paint()..style = PaintingStyle.fill;
  final _vein = Paint()
    ..style = PaintingStyle.stroke
    ..strokeWidth = 0.8
    ..color = const Color(0x5934392F);

  @override
  void paint(Canvas canvas, Size size) {
    final t = time.value;
    for (final leaf in leaves) {
      final s = leaf.size;
      canvas
        ..save()
        ..translate(leaf.x, leaf.y)
        ..rotate(leaf.rotation)
        // Volteo: la hoja "gira" sobre su eje mientras cae.
        ..scale(1, (math.cos(t * 1.4 + leaf.flip)).abs() * 0.7 + 0.3);
      final path = Path()
        ..moveTo(-s, 0)
        ..cubicTo(-s * 0.5, -s * 0.62, s * 0.5, -s * 0.62, s, 0)
        ..cubicTo(s * 0.5, s * 0.62, -s * 0.5, s * 0.62, -s, 0);
      _fill.color = leaf.color.withValues(alpha: 0.9);
      canvas
        ..drawPath(path, _fill)
        ..drawLine(Offset(-s * 0.9, 0), Offset(s * 0.9, 0), _vein)
        ..restore();
    }
  }

  @override
  bool shouldRepaint(covariant _LeavesPainter oldDelegate) =>
      oldDelegate.leaves != leaves;
}
