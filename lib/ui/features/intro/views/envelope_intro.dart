import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import 'monogram.dart';

/// Colores de la invitación (papel, cera y jardín).
class _IntroPalette {
  // Paleta "Garden Party": azul pervinca, verde oliva, rosa, durazno,
  // amarillo mantequilla, lavanda y verde menta.
  static const periwinkle = Color(0xFF9DB9E6);
  static const skyBlue = Color(0xFFBCD8F2);
  static const olive = Color(0xFFA9B77E);
  static const pink = Color(0xFFF5B3C8);
  static const peach = Color(0xFFFFC98C);
  static const butter = Color(0xFFFFEFA3);
  static const lavender = Color(0xFFC9BFE6);
  static const mint = Color(0xFFB8D8A8);

  static const backgroundTop = Color(0xFFFBF8F0);
  static const backgroundBottom = Color(0xFFE4EEF7);
  static const envelope = Color(0xFFF6F0E4);
  static const envelopeShade = Color(0xFFE9E1D2);
  static const envelopeEdge = Color(0xFFD8CCB8);
  static const liner = Color(0xFFDCD5F0);
  static const linerLeaf = olive;
  static const card = Color(0xFFFFFDF8);
  static const sage = Color(0xFF6F7F4A);
  static const wax = Color(0xFF9AA86C);
  static const waxDark = Color(0xFF6F7F4A);
  static const ink = Color(0xFF3F4636);
  static const stem = Color(0xFF8E9E62);
  static const petals = [periwinkle, pink, peach, butter, lavender, mint];
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

/// Ramos de flores silvestres en las esquinas del fondo: lavanda,
/// campanillas, lirios y velo de novia.
class _GardenCornersPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final scale = math.min(size.width, size.height) / 420;
    _bouquet(canvas, Offset.zero, scale, 1, 1);
    _bouquet(canvas, Offset(size.width, size.height), scale, -1, -1);
    _bouquet(canvas, Offset(size.width, 0), scale * 0.7, -1, 1);
    _bouquet(canvas, Offset(0, size.height), scale * 0.7, 1, -1);
  }

  void _bouquet(Canvas canvas, Offset corner, double s, double sx, double sy) {
    canvas.save();
    canvas.translate(corner.dx, corner.dy);
    canvas.scale(sx * s, sy * s);

    // Hierbas finas de fondo.
    final grass = Paint()
      ..color = _IntroPalette.mint
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.6
      ..strokeCap = StrokeCap.round;
    for (var i = 0; i < 6; i++) {
      final a = 0.15 + i * 0.22;
      canvas.drawPath(
        Path()
          ..moveTo(-6, -6)
          ..quadraticBezierTo(
            math.cos(a) * 70,
            math.sin(a) * 40,
            math.cos(a) * 150,
            math.sin(a) * 150,
          ),
        grass,
      );
    }

    _lavender(canvas, const Offset(-6, -6), 0.32, 170, _IntroPalette.lavender);
    _lavender(canvas, const Offset(-6, -6), 1.2, 150, _IntroPalette.periwinkle);
    _bluebells(canvas, const Offset(-6, -6), 0.72, 165);
    _lily(canvas, const Offset(92, 58), 20, 0.4, _IntroPalette.peach);
    _lily(canvas, const Offset(46, 112), 16, 1.1, _IntroPalette.pink);
    _lily(canvas, const Offset(132, 118), 12, 0.9, _IntroPalette.butter);
    _babysBreath(canvas, const Offset(150, 34));
    _babysBreath(canvas, const Offset(22, 160));
    canvas.restore();
  }

  Paint _stemPaint() => Paint()
    ..color = _IntroPalette.stem
    ..style = PaintingStyle.stroke
    ..strokeWidth = 2
    ..strokeCap = StrokeCap.round;

  /// Espiga de lavanda: tallo recto con capullos ovalados hacia la punta.
  void _lavender(
    Canvas canvas,
    Offset base,
    double angle,
    double length,
    Color color,
  ) {
    final dir = Offset(math.cos(angle), math.sin(angle));
    final tip = base + dir * length;
    canvas.drawLine(base, tip, _stemPaint());
    final bud = Paint()..color = color;
    for (var i = 0; i < 9; i++) {
      final t = 0.55 + i * 0.05;
      final p = base + dir * length * t;
      for (final side in [-1.0, 1.0]) {
        canvas.save();
        canvas.translate(p.dx, p.dy);
        canvas.rotate(angle + side * 0.5);
        canvas.drawOval(
          Rect.fromCenter(
            center: Offset(3, side * 3),
            width: 9 - i * 0.4,
            height: 5,
          ),
          bud,
        );
        canvas.restore();
      }
    }
  }

  /// Rama arqueada de campanillas colgantes.
  void _bluebells(Canvas canvas, Offset base, double angle, double length) {
    final dir = Offset(math.cos(angle), math.sin(angle));
    final normal = Offset(-dir.dy, dir.dx);
    final control = base + dir * length * 0.55 - normal * 30;
    final tip = base + dir * length;
    final path = Path()
      ..moveTo(base.dx, base.dy)
      ..quadraticBezierTo(control.dx, control.dy, tip.dx, tip.dy);
    canvas.drawPath(path, _stemPaint());

    final bell = Paint()..color = _IntroPalette.periwinkle;
    final inner = Paint()..color = _IntroPalette.skyBlue;
    final metric = path.computeMetrics().first;
    for (var d = metric.length * 0.45; d < metric.length; d += 22) {
      final tangent = metric.getTangentForOffset(d)!;
      final p = tangent.position;
      final hang = p + const Offset(4, 12);
      canvas.drawLine(p, hang, _stemPaint()..strokeWidth = 1.2);
      canvas.save();
      canvas.translate(hang.dx, hang.dy);
      canvas.rotate(-0.35);
      final shape = Path()
        ..moveTo(-5, 0)
        ..quadraticBezierTo(-7, 9, -9, 14)
        ..quadraticBezierTo(-4, 11, -2, 15)
        ..quadraticBezierTo(0, 11, 2, 15)
        ..quadraticBezierTo(4, 11, 9, 14)
        ..quadraticBezierTo(7, 9, 5, 0)
        ..close();
      canvas.drawPath(shape, bell);
      canvas.drawOval(const Rect.fromLTWH(-3, 1, 6, 5), inner);
      canvas.restore();
    }
  }

  /// Lirio visto de frente: seis pétalos en punta con estambres.
  void _lily(
    Canvas canvas,
    Offset center,
    double radius,
    double rotation,
    Color color,
  ) {
    final petal = Paint()..color = color;
    final vein = Paint()
      ..color = Color.lerp(color, Colors.white, 0.45)!
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(rotation);
    for (var i = 0; i < 6; i++) {
      canvas.save();
      canvas.rotate(i * math.pi / 3 + (i.isOdd ? 0.12 : 0));
      final r = i.isOdd ? radius * 0.86 : radius;
      final shape = Path()
        ..moveTo(0, 0)
        ..quadraticBezierTo(r * 0.45, -r * 0.32, r, 0)
        ..quadraticBezierTo(r * 0.45, r * 0.32, 0, 0)
        ..close();
      canvas.drawPath(shape, petal);
      canvas.drawLine(Offset(r * 0.15, 0), Offset(r * 0.8, 0), vein);
      canvas.restore();
    }
    final stamen = Paint()
      ..color = _IntroPalette.stem
      ..strokeWidth = 1
      ..strokeCap = StrokeCap.round;
    final pollen = Paint()..color = const Color(0xFFE0A85C);
    for (var i = 0; i < 6; i++) {
      final a = i * math.pi / 3 + math.pi / 6;
      final end = Offset(math.cos(a), math.sin(a)) * radius * 0.5;
      canvas.drawLine(Offset.zero, end, stamen);
      canvas.drawCircle(end, 1.6, pollen);
    }
    canvas.restore();
  }

  /// Velo de novia: ramita con puntitos claros.
  void _babysBreath(Canvas canvas, Offset center) {
    final stem = _stemPaint()..strokeWidth = 1;
    final dot = Paint()..color = Colors.white.withValues(alpha: 0.95);
    final dotEdge = Paint()..color = _IntroPalette.butter;
    final random = math.Random(center.dx.toInt() * 31 + center.dy.toInt());
    for (var i = 0; i < 9; i++) {
      final p =
          center +
          Offset(random.nextDouble() * 26 - 13, random.nextDouble() * 26 - 13);
      canvas.drawLine(center, p, stem);
      canvas.drawCircle(p, 3.4, dotEdge);
      canvas.drawCircle(p, 2.6, dot);
    }
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
