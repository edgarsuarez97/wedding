import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import 'monogram.dart';

/// Colores de la invitación (papel, cera y jardín).
class _IntroPalette {
  static const backgroundTop = Color(0xFFF7F4EC);
  static const backgroundBottom = Color(0xFFDDE8D6);
  static const envelope = Color(0xFFF3ECDF);
  static const envelopeShade = Color(0xFFE6DCCB);
  static const envelopeEdge = Color(0xFFD5C8B2);
  static const liner = Color(0xFFC9D8C0);
  static const linerLeaf = Color(0xFF9DB592);
  static const card = Color(0xFFFFFDF8);
  static const sage = Color(0xFF5E7458);
  static const wax = Color(0xFF7E9A78);
  static const waxDark = Color(0xFF5F7A5A);
  static const ink = Color(0xFF3E4A3C);
  static const petals = [
    Color(0xFFF2C9D4),
    Color(0xFFF8E1E7),
    Color(0xFFE4B8C8),
    Color(0xFFB9CDAE),
    Color(0xFFFFF4D9),
  ];
}

/// Pantalla de bienvenida: un sobre sellado con el monograma.
///
/// Al tocar el sello, este se parte a la mitad, la solapa se abre en 3D y la
/// tarjeta sale hasta la mitad del sobre. El botón "Ver invitación" despide la
/// escena y llama a [onOpened].
class EnvelopeIntro extends StatefulWidget {
  const EnvelopeIntro({
    super.key,
    required this.onOpened,
    this.coupleNames = 'Edgar & Gabriela',
    this.dateLabel = '28 · 08 · 2027',
  });

  final VoidCallback onOpened;
  final String coupleNames;
  final String dateLabel;

  @override
  State<EnvelopeIntro> createState() => _EnvelopeIntroState();
}

enum _IntroStage { sealed, opening, revealed, leaving }

class _EnvelopeIntroState extends State<EnvelopeIntro>
    with TickerProviderStateMixin {
  late final AnimationController _ambient;
  late final AnimationController _open;
  late final AnimationController _exit;

  _IntroStage _stage = _IntroStage.sealed;

  bool get _reduceMotion => MediaQuery.of(context).disableAnimations;

  @override
  void initState() {
    super.initState();
    _ambient = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 24),
    );
    _open = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2800),
    )..addStatusListener(_onOpenStatus);
    _exit = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..addStatusListener(_onExitStatus);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_reduceMotion) {
      _ambient.stop();
    } else if (!_ambient.isAnimating) {
      _ambient.repeat();
    }
  }

  @override
  void dispose() {
    _ambient.dispose();
    _open.dispose();
    _exit.dispose();
    super.dispose();
  }

  void _onOpenStatus(AnimationStatus status) {
    if (status == AnimationStatus.completed && mounted) {
      setState(() => _stage = _IntroStage.revealed);
    }
  }

  void _onExitStatus(AnimationStatus status) {
    if (status == AnimationStatus.completed && mounted) {
      widget.onOpened();
    }
  }

  void _openEnvelope() {
    if (_stage != _IntroStage.sealed) {
      return;
    }
    HapticFeedback.lightImpact();
    setState(() => _stage = _IntroStage.opening);
    if (_reduceMotion) {
      _open.value = 1;
    } else {
      _open.forward();
    }
  }

  void _enterSite() {
    if (_stage != _IntroStage.revealed) {
      return;
    }
    setState(() => _stage = _IntroStage.leaving);
    if (_reduceMotion) {
      _exit.duration = const Duration(milliseconds: 200);
    }
    _exit.forward();
  }

  KeyEventResult _onKey(FocusNode node, KeyEvent event) {
    if (event is! KeyDownEvent) {
      return KeyEventResult.ignored;
    }
    final key = event.logicalKey;
    if (key == LogicalKeyboardKey.enter ||
        key == LogicalKeyboardKey.space ||
        key == LogicalKeyboardKey.numpadEnter) {
      if (_stage == _IntroStage.sealed) {
        _openEnvelope();
      } else {
        _enterSite();
      }
      return KeyEventResult.handled;
    }
    return KeyEventResult.ignored;
  }

  @override
  Widget build(BuildContext context) {
    return Focus(
      autofocus: true,
      onKeyEvent: _onKey,
      child: AnimatedBuilder(
        animation: _exit,
        builder: (context, child) {
          final t = Curves.easeInCubic.transform(_exit.value);
          return IgnorePointer(
            ignoring: _stage == _IntroStage.leaving,
            child: Opacity(
              opacity: 1 - t,
              child: Transform.scale(scale: 1 + 0.12 * t, child: child),
            ),
          );
        },
        child: Material(
          color: _IntroPalette.backgroundTop,
          child: LayoutBuilder(
            builder: (context, constraints) => _buildScene(constraints),
          ),
        ),
      ),
    );
  }

  Widget _buildScene(BoxConstraints constraints) {
    final size = constraints.biggest;
    final envelopeWidth = math.min(
      460.0,
      math.min(size.width * 0.84, size.height * 0.5 * 1.5),
    );
    final envelopeHeight = envelopeWidth / 1.5;
    final envelopeTop = size.height * 0.56 - envelopeHeight / 2;

    return Stack(
      fit: StackFit.expand,
      children: [
        const DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                _IntroPalette.backgroundTop,
                _IntroPalette.backgroundBottom,
              ],
            ),
            image: DecorationImage(
              image: AssetImage('assets/illustrations/paper_texture.jpg'),
              repeat: ImageRepeat.repeat,
              opacity: 0.35,
            ),
          ),
        ),
        RepaintBoundary(
          child: CustomPaint(painter: _GardenCornersPainter(), size: size),
        ),
        if (!_reduceMotion)
          RepaintBoundary(
            child: CustomPaint(
              painter: _PetalsPainter(animation: _ambient),
              size: size,
            ),
          ),
        Positioned(
          left: (size.width - envelopeWidth) / 2,
          top: envelopeTop,
          width: envelopeWidth,
          height: envelopeHeight,
          child: AnimatedBuilder(
            animation: Listenable.merge([_open, _ambient]),
            builder: (context, _) =>
                _buildEnvelope(envelopeWidth, envelopeHeight),
          ),
        ),
        Positioned(
          left: 24,
          right: 24,
          top: envelopeTop + envelopeHeight + 36,
          child: _buildCaption(),
        ),
      ],
    );
  }

  Widget _buildEnvelope(double width, double height) {
    final open = _open.value;
    final sealT = const Interval(
      0,
      0.22,
      curve: Curves.easeOutCubic,
    ).transform(open);
    final flapT = const Interval(
      0.12,
      0.52,
      curve: Curves.easeInOut,
    ).transform(open);
    final cardT = const Interval(
      0.5,
      0.92,
      curve: Curves.easeOutBack,
    ).transform(open);

    // Mientras está cerrado el sobre "respira" suavemente.
    final idle = _stage == _IntroStage.sealed && !_reduceMotion
        ? math.sin(_ambient.value * 2 * math.pi * 10)
        : 0.0;
    final flapAngle = flapT * math.pi;
    final flapIsOpen = flapAngle > math.pi / 2;

    final cardWidth = width * 0.8;
    final cardHeight = height * 0.92;
    final cardRest = height * 0.05;
    final cardRise = cardHeight * 0.56 * cardT;

    final flap = _Flap(width: width, height: height, angle: flapAngle);

    return Transform.translate(
      offset: Offset(0, idle * 4),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Sombra y parte trasera con el forro de hojas.
          Positioned.fill(child: CustomPaint(painter: _EnvelopeBackPainter())),
          if (flapIsOpen) Positioned.fill(child: flap),
          Positioned(
            left: (width - cardWidth) / 2,
            top: cardRest - cardRise,
            width: cardWidth,
            height: cardHeight,
            child: GestureDetector(
              onTap: _enterSite,
              child: _InvitationCard(
                coupleNames: widget.coupleNames,
                dateLabel: widget.dateLabel,
              ),
            ),
          ),
          Positioned.fill(
            child: IgnorePointer(
              child: CustomPaint(painter: _EnvelopePocketPainter()),
            ),
          ),
          if (!flapIsOpen) Positioned.fill(child: flap),
          if (sealT < 1)
            Positioned(
              left: width / 2 - width * 0.12,
              top: height * 0.56 - width * 0.12,
              width: width * 0.24,
              height: width * 0.24,
              child: _WaxSeal(
                progress: sealT,
                pulse: idle,
                onTap: _openEnvelope,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildCaption() {
    final style = GoogleFonts.lora(
      fontSize: 15,
      letterSpacing: 1.2,
      color: _IntroPalette.ink.withValues(alpha: 0.8),
    );

    final Widget content = switch (_stage) {
      _IntroStage.sealed => AnimatedBuilder(
        key: const ValueKey('hint'),
        animation: _ambient,
        builder: (context, child) => Opacity(
          opacity: _reduceMotion
              ? 1
              : 0.55 +
                    0.45 *
                        (0.5 +
                            0.5 * math.sin(_ambient.value * 2 * math.pi * 12)),
          child: child,
        ),
        child: Text(
          'Toca el sello para abrir',
          textAlign: TextAlign.center,
          style: style,
        ),
      ),
      _IntroStage.opening => const SizedBox(key: ValueKey('empty'), height: 48),
      _ => Center(
        key: const ValueKey('cta'),
        child: OutlinedButton(
          onPressed: _enterSite,
          style: OutlinedButton.styleFrom(
            foregroundColor: _IntroPalette.sage,
            backgroundColor: Colors.white.withValues(alpha: 0.6),
            side: const BorderSide(color: _IntroPalette.sage, width: 1.2),
            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
            shape: const StadiumBorder(),
            textStyle: GoogleFonts.lora(fontSize: 16, letterSpacing: 1.4),
          ),
          child: const Text('Ver invitación'),
        ),
      ),
    };

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 500),
      child: content,
    );
  }
}

/// Solapa superior del sobre. Gira sobre su borde superior; pasada la mitad
/// del giro se ve su cara interior (el forro).
class _Flap extends StatelessWidget {
  const _Flap({required this.width, required this.height, required this.angle});

  final double width;
  final double height;
  final double angle;

  @override
  Widget build(BuildContext context) {
    final showsInside = angle > math.pi / 2;
    return IgnorePointer(
      child: Transform(
        alignment: Alignment.topCenter,
        transform: Matrix4.identity()
          ..setEntry(3, 2, 0.0016)
          ..rotateX(-angle),
        child: CustomPaint(
          size: Size(width, height),
          painter: _FlapPainter(showsInside: showsInside),
        ),
      ),
    );
  }
}

class _InvitationCard extends StatelessWidget {
  const _InvitationCard({required this.coupleNames, required this.dateLabel});

  final String coupleNames;
  final String dateLabel;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final w = constraints.maxWidth;
        final h = constraints.maxHeight;
        return DecoratedBox(
          decoration: BoxDecoration(
            color: _IntroPalette.card,
            borderRadius: BorderRadius.circular(6),
            boxShadow: const [
              BoxShadow(
                color: Color(0x22000000),
                blurRadius: 10,
                offset: Offset(0, -2),
              ),
            ],
          ),
          child: Padding(
            padding: EdgeInsets.all(w * 0.03),
            child: DecoratedBox(
              decoration: BoxDecoration(
                border: Border.all(
                  color: _IntroPalette.sage.withValues(alpha: 0.45),
                ),
                borderRadius: BorderRadius.circular(4),
              ),
              // Sólo la mitad superior asoma del sobre: ahí va el monograma.
              child: Column(
                children: [
                  SizedBox(height: h * 0.04),
                  Monogram(size: h * 0.34),
                  SizedBox(height: h * 0.015),
                  Text(
                    coupleNames,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.playfairDisplay(
                      fontSize: h * 0.075,
                      fontStyle: FontStyle.italic,
                      color: _IntroPalette.ink,
                    ),
                  ),
                  SizedBox(height: h * 0.01),
                  Text(
                    dateLabel,
                    style: GoogleFonts.lora(
                      fontSize: h * 0.045,
                      letterSpacing: 2,
                      color: _IntroPalette.sage,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

/// Sello de cera con el monograma; al abrir se parte en dos mitades.
class _WaxSeal extends StatelessWidget {
  const _WaxSeal({
    required this.progress,
    required this.pulse,
    required this.onTap,
  });

  final double progress;
  final double pulse;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: 'Abrir invitación',
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: GestureDetector(
          key: const ValueKey('envelope-seal'),
          behavior: HitTestBehavior.opaque,
          onTap: onTap,
          child: LayoutBuilder(
            builder: (context, constraints) {
              final size = constraints.maxWidth;
              final seal = _SealFace(size: size);
              final spread = size * 0.75 * progress;
              final tilt = 0.5 * progress;
              return Opacity(
                opacity: 1 - const Interval(0.45, 1).transform(progress),
                child: Transform.scale(
                  scale: 1 + 0.03 * pulse + 0.1 * progress,
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      _half(seal, left: true, dx: -spread, angle: -tilt),
                      _half(seal, left: false, dx: spread, angle: tilt),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _half(
    Widget seal, {
    required bool left,
    required double dx,
    required double angle,
  }) {
    return Positioned.fill(
      child: Transform.translate(
        offset: Offset(dx, progress * 12),
        child: Transform.rotate(
          angle: angle,
          child: ClipRect(
            clipper: _HalfClipper(left: left),
            child: seal,
          ),
        ),
      ),
    );
  }
}

class _SealFace extends StatelessWidget {
  const _SealFace({required this.size});

  final double size;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _WaxPainter(),
      child: Center(
        child: Monogram(size: size * 0.78, color: const Color(0xFFF4EBD8)),
      ),
    );
  }
}

class _HalfClipper extends CustomClipper<Rect> {
  _HalfClipper({required this.left});

  final bool left;

  @override
  Rect getClip(Size size) => left
      ? Rect.fromLTWH(0, 0, size.width / 2, size.height)
      : Rect.fromLTWH(size.width / 2, 0, size.width / 2, size.height);

  @override
  bool shouldReclip(_HalfClipper oldClipper) => oldClipper.left != left;
}

class _WaxPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final r = size.width / 2;

    // Contorno irregular de cera derretida.
    final blob = Path();
    const bumps = 14;
    for (var i = 0; i <= 64; i++) {
      final a = i / 64 * 2 * math.pi;
      final wobble = 1 + 0.035 * math.sin(a * bumps) + 0.02 * math.cos(a * 5);
      final p = center + Offset(math.cos(a), math.sin(a)) * r * wobble * 0.96;
      i == 0 ? blob.moveTo(p.dx, p.dy) : blob.lineTo(p.dx, p.dy);
    }
    blob.close();

    canvas.drawShadow(blob, Colors.black, 4, false);
    canvas.drawPath(
      blob,
      Paint()
        ..shader = RadialGradient(
          center: const Alignment(-0.3, -0.35),
          colors: const [_IntroPalette.wax, _IntroPalette.waxDark],
        ).createShader(Rect.fromCircle(center: center, radius: r)),
    );
    // Hendidura interior donde se presionó el sello.
    canvas.drawCircle(
      center,
      r * 0.74,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = r * 0.06
        ..color = _IntroPalette.waxDark.withValues(alpha: 0.7),
    );
    canvas.drawCircle(
      center.translate(-r * 0.02, -r * 0.02),
      r * 0.7,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = r * 0.02
        ..color = Colors.white.withValues(alpha: 0.18),
    );
  }

  @override
  bool shouldRepaint(_WaxPainter oldDelegate) => false;
}

class _EnvelopeBackPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final shape = RRect.fromRectAndRadius(rect, const Radius.circular(6));
    canvas.drawShadow(Path()..addRRect(shape), Colors.black, 14, false);
    canvas.drawRRect(shape, Paint()..color = _IntroPalette.envelopeShade);

    // Forro interior con hojas, visible al abrir la solapa.
    final liner = Path()
      ..moveTo(size.width * 0.04, size.height * 0.03)
      ..lineTo(size.width * 0.96, size.height * 0.03)
      ..lineTo(size.width * 0.5, size.height * 0.52)
      ..close();
    canvas.save();
    canvas.clipPath(liner);
    canvas.drawRect(rect, Paint()..color = _IntroPalette.liner);
    _paintLeafPattern(canvas, size, _IntroPalette.linerLeaf);
    canvas.restore();
  }

  @override
  bool shouldRepaint(_EnvelopeBackPainter oldDelegate) => false;
}

class _EnvelopePocketPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final fill = Paint()..color = _IntroPalette.envelope;
    final edge = Paint()
      ..color = _IntroPalette.envelopeEdge
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    final left = Path()
      ..moveTo(0, 0)
      ..lineTo(w * 0.52, h * 0.56)
      ..lineTo(0, h)
      ..close();
    final right = Path()
      ..moveTo(w, 0)
      ..lineTo(w * 0.48, h * 0.56)
      ..lineTo(w, h)
      ..close();
    final bottom = Path()
      ..moveTo(0, h)
      ..quadraticBezierTo(w * 0.42, h * 0.5, w * 0.5, h * 0.46)
      ..quadraticBezierTo(w * 0.58, h * 0.5, w, h)
      ..close();

    canvas.save();
    canvas.clipRRect(
      RRect.fromRectAndRadius(Offset.zero & size, const Radius.circular(6)),
    );
    canvas.drawPath(left, fill..color = _IntroPalette.envelope);
    canvas.drawPath(right, fill..color = _IntroPalette.envelope);
    canvas.drawPath(left, edge);
    canvas.drawPath(right, edge);
    canvas.drawShadow(bottom, Colors.black, 3, false);
    canvas.drawPath(bottom, fill..color = const Color(0xFFF6F0E5));
    canvas.drawPath(bottom, edge);
    canvas.restore();
  }

  @override
  bool shouldRepaint(_EnvelopePocketPainter oldDelegate) => false;
}

class _FlapPainter extends CustomPainter {
  _FlapPainter({required this.showsInside});

  final bool showsInside;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final flap = Path()
      ..moveTo(0, 0)
      ..lineTo(w, 0)
      ..lineTo(w * 0.56, h * 0.54)
      ..quadraticBezierTo(w * 0.5, h * 0.6, w * 0.44, h * 0.54)
      ..close();

    if (showsInside) {
      canvas.drawPath(flap, Paint()..color = _IntroPalette.liner);
      canvas.save();
      canvas.clipPath(flap);
      _paintLeafPattern(canvas, size, _IntroPalette.linerLeaf);
      canvas.restore();
    } else {
      canvas.drawShadow(flap, Colors.black, 4, false);
      canvas.drawPath(
        flap,
        Paint()
          ..shader = const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFF7F1E6), _IntroPalette.envelope],
          ).createShader(Offset.zero & size),
      );
    }
    canvas.drawPath(
      flap,
      Paint()
        ..color = _IntroPalette.envelopeEdge
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1,
    );
  }

  @override
  bool shouldRepaint(_FlapPainter oldDelegate) =>
      oldDelegate.showsInside != showsInside;
}

/// Patrón de ramitas para el forro del sobre.
void _paintLeafPattern(Canvas canvas, Size size, Color color) {
  final stem = Paint()
    ..color = color
    ..style = PaintingStyle.stroke
    ..strokeWidth = 1.2
    ..strokeCap = StrokeCap.round;
  final leaf = Paint()..color = color.withValues(alpha: 0.8);
  final step = size.width / 7;
  for (var row = 0; row * step * 0.8 < size.height; row++) {
    for (var col = -1; col * step < size.width + step; col++) {
      final origin = Offset(
        col * step + (row.isOdd ? step / 2 : 0),
        row * step * 0.8,
      );
      final tip = origin + Offset(step * 0.3, -step * 0.45);
      canvas.drawLine(origin, tip, stem);
      for (var i = 1; i <= 3; i++) {
        final p = Offset.lerp(origin, tip, i / 4)!;
        for (final side in [-1.0, 1.0]) {
          canvas.save();
          canvas.translate(p.dx, p.dy);
          canvas.rotate(-0.98 + side * 0.9);
          canvas.drawOval(
            Rect.fromLTWH(0, -step * 0.035, step * 0.13, step * 0.07),
            leaf,
          );
          canvas.restore();
        }
      }
    }
  }
}

/// Ramas de jardín en las esquinas del fondo.
class _GardenCornersPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final scale = math.min(size.width, size.height) / 420;
    _branch(canvas, Offset.zero, scale, 1, 1);
    _branch(canvas, Offset(size.width, size.height), scale, -1, -1);
    _branch(canvas, Offset(size.width, 0), scale * 0.7, -1, 1);
    _branch(canvas, Offset(0, size.height), scale * 0.7, 1, -1);
  }

  void _branch(Canvas canvas, Offset corner, double s, double sx, double sy) {
    canvas.save();
    canvas.translate(corner.dx, corner.dy);
    canvas.scale(sx * s, sy * s);

    final stem = Paint()
      ..color = const Color(0xFF8EA883)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.4
      ..strokeCap = StrokeCap.round;
    final main = Path()
      ..moveTo(-10, 40)
      ..quadraticBezierTo(70, 50, 150, 10);
    final second = Path()
      ..moveTo(30, -10)
      ..quadraticBezierTo(40, 70, 10, 150);
    canvas.drawPath(main, stem);
    canvas.drawPath(second, stem);

    final leafPaint = Paint()..color = const Color(0xFFA9C09C);
    for (final metric in [
      ...main.computeMetrics(),
      ...second.computeMetrics(),
    ]) {
      for (var d = 18.0; d < metric.length; d += 20) {
        final tangent = metric.getTangentForOffset(d)!;
        for (final side in [-1.0, 1.0]) {
          canvas.save();
          canvas.translate(tangent.position.dx, tangent.position.dy);
          canvas.rotate(-tangent.angle + side * 0.8);
          canvas.drawOval(const Rect.fromLTWH(0, -5, 22, 10), leafPaint);
          canvas.restore();
        }
      }
    }

    // Flores sueltas.
    for (final (center, color) in [
      (const Offset(150, 12), const Color(0xFFE4B8C8)),
      (const Offset(12, 150), const Color(0xFFF2C9D4)),
      (const Offset(70, 70), const Color(0xFFF8E1E7)),
    ]) {
      for (var i = 0; i < 5; i++) {
        final a = i * 2 * math.pi / 5;
        canvas.drawCircle(
          center + Offset(math.cos(a), math.sin(a)) * 8,
          7.5,
          Paint()..color = color,
        );
      }
      canvas.drawCircle(center, 4.5, Paint()..color = const Color(0xFFF1D9A6));
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(_GardenCornersPainter oldDelegate) => false;
}

/// Pétalos que caen lentamente sobre la escena.
class _PetalsPainter extends CustomPainter {
  _PetalsPainter({required this.animation}) : super(repaint: animation);

  final Animation<double> animation;

  static final List<_Petal> _petals = () {
    final random = math.Random(28082027);
    return List.generate(22, (i) {
      return _Petal(
        x: random.nextDouble(),
        offset: random.nextDouble(),
        speed: 0.6 + random.nextDouble() * 0.8,
        size: 6 + random.nextDouble() * 7,
        sway: random.nextDouble() * 2 * math.pi,
        spin: (random.nextDouble() - 0.5) * 4,
        color: _IntroPalette.petals[i % _IntroPalette.petals.length],
      );
    });
  }();

  @override
  void paint(Canvas canvas, Size size) {
    final t = animation.value;
    for (final petal in _petals) {
      final progress = (petal.offset + t * petal.speed * 3) % 1;
      final y = -20 + progress * (size.height + 40);
      final x =
          petal.x * size.width +
          math.sin(progress * 2 * math.pi * 2 + petal.sway) * 24;
      canvas.save();
      canvas.translate(x, y);
      canvas.rotate(petal.sway + progress * petal.spin * math.pi);
      canvas.drawOval(
        Rect.fromCenter(
          center: Offset.zero,
          width: petal.size,
          height: petal.size * 0.62,
        ),
        Paint()..color = petal.color.withValues(alpha: 0.85),
      );
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(_PetalsPainter oldDelegate) => false;
}

class _Petal {
  const _Petal({
    required this.x,
    required this.offset,
    required this.speed,
    required this.size,
    required this.sway,
    required this.spin,
    required this.color,
  });

  final double x;
  final double offset;
  final double speed;
  final double size;
  final double sway;
  final double spin;
  final Color color;
}
