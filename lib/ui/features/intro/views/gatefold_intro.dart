import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import 'monogram.dart';
import 'printed_bouquet.dart';
import 'garden_colors.dart';

/// Portada de la invitación: dos puertas con estampado de flores silvestres
/// unidas al centro por un sello de cera verde oliva con el monograma.
///
/// Un solo toque basta: el sello se parte a la mitad, las puertas se deslizan
/// hacia los lados y debajo queda el sitio. Al terminar llama a [onOpened].
class GatefoldIntro extends StatefulWidget {
  const GatefoldIntro({super.key, required this.onOpened});

  final VoidCallback onOpened;

  @override
  State<GatefoldIntro> createState() => _GatefoldIntroState();
}

class _GatefoldIntroState extends State<GatefoldIntro>
    with TickerProviderStateMixin {
  late final AnimationController _idle;
  late final AnimationController _open;
  bool _opening = false;

  // El estampado se pinta una sola vez a imagen: en la web no hay caché de
  // rasterizado y repintar cientos de degradados en cada cuadro de la
  // apertura la vuelve entrecortada.
  ui.Image? _print;
  Size? _printSize;
  double? _printRatio;

  bool get _reduceMotion => MediaQuery.of(context).disableAnimations;

  @override
  void initState() {
    super.initState();
    _idle = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    );
    _open =
        AnimationController(
          vsync: this,
          duration: const Duration(milliseconds: 1800),
        )..addStatusListener((status) {
          if (status == AnimationStatus.completed && mounted) {
            widget.onOpened();
          }
        });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_reduceMotion) {
      _idle.stop();
    } else if (!_idle.isAnimating && !_opening) {
      _idle.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _idle.dispose();
    _open.dispose();
    _print?.dispose();
    super.dispose();
  }

  void _ensurePrint(Size size, double ratio) {
    if (size.isEmpty || (size == _printSize && ratio == _printRatio)) {
      return;
    }
    _printSize = size;
    _printRatio = ratio;
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder)..scale(ratio);
    paintPrintedBouquet(canvas, size);
    final picture = recorder.endRecording();
    picture
        .toImage((size.width * ratio).ceil(), (size.height * ratio).ceil())
        .then((image) {
          picture.dispose();
          if (!mounted || size != _printSize || ratio != _printRatio) {
            image.dispose();
            return;
          }
          setState(() {
            _print?.dispose();
            _print = image;
          });
        });
  }

  void _openDoors() {
    if (_opening) {
      return;
    }
    HapticFeedback.lightImpact();
    _idle.stop();
    setState(() => _opening = true);
    if (_reduceMotion) {
      _open.duration = const Duration(milliseconds: 250);
    }
    _open.forward();
  }

  KeyEventResult _onKey(FocusNode node, KeyEvent event) {
    if (event is! KeyDownEvent) {
      return KeyEventResult.ignored;
    }
    final key = event.logicalKey;
    if (key == LogicalKeyboardKey.enter ||
        key == LogicalKeyboardKey.numpadEnter ||
        key == LogicalKeyboardKey.space ||
        key == LogicalKeyboardKey.escape) {
      _openDoors();
      return KeyEventResult.handled;
    }
    return KeyEventResult.ignored;
  }

  @override
  Widget build(BuildContext context) {
    return Focus(
      autofocus: true,
      onKeyEvent: _onKey,
      // Mientras está cerrada, cualquier toque abre la invitación y no llega
      // al sitio que espera debajo.
      child: IgnorePointer(
        ignoring: _opening,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: _openDoors,
          child: Material(
            type: MaterialType.transparency,
            child: LayoutBuilder(
              builder: (context, constraints) =>
                  _buildScene(constraints.biggest),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildScene(Size size) {
    final ratio = MediaQuery.devicePixelRatioOf(context);
    _ensurePrint(size, ratio);
    final sealSize = math.min(
      180.0,
      math.min(size.width * 0.36, size.height * 0.22),
    );
    final half = size.width / 2;
    final sealTop = size.height / 2 - sealSize / 2;

    return AnimatedBuilder(
      animation: Listenable.merge([_open, _idle]),
      builder: (context, _) {
        final reduce = _reduceMotion;
        final slide = reduce
            ? _open.value
            : const Interval(
                0.12,
                1,
                curve: Curves.easeInOutCubic,
              ).transform(_open.value);
        final offset = slide * (half + 24);
        final pulse = !_opening && !reduce
            ? Curves.easeInOutSine.transform(_idle.value)
            : 0.0;
        // El sello se hunde un poco antes de partirse.
        final press = reduce
            ? 0.0
            : const Interval(
                0,
                0.12,
                curve: Curves.easeOut,
              ).transform(_open.value);
        final sealScale = 1 + 0.04 * pulse - 0.08 * math.sin(press * math.pi);
        // Con movimiento reducido, las puertas se desvanecen en vez de moverse.
        final fade = reduce ? 1 - _open.value : 1.0;

        Widget sealHalf({required bool left}) => Positioned(
          left: half - sealSize / 2 + (left ? -offset : offset),
          top: sealTop,
          width: sealSize,
          height: sealSize,
          child: Transform.scale(
            scale: sealScale,
            child: ClipRect(
              clipper: _HalfClipper(left: left),
              child: const _WaxSeal(),
            ),
          ),
        );

        return Opacity(
          opacity: fade,
          child: Stack(
            fit: StackFit.expand,
            children: [
              Positioned(
                left: half + offset,
                top: 0,
                bottom: 0,
                width: half,
                child: _Door(
                  image: _print,
                  fullSize: size,
                  originX: half,
                  shadowOnLeft: false,
                ),
              ),
              Positioned(
                left: -offset,
                top: 0,
                bottom: 0,
                width: half,
                child: _Door(
                  image: _print,
                  fullSize: size,
                  originX: 0,
                  shadowOnLeft: true,
                ),
              ),
              sealHalf(left: true),
              sealHalf(left: false),
              // Área del sello para lectores de pantalla y pruebas.
              Positioned(
                left: half - sealSize / 2,
                top: sealTop,
                width: sealSize,
                height: sealSize,
                child: Semantics(
                  button: true,
                  label: 'Abrir invitación',
                  child: MouseRegion(
                    cursor: SystemMouseCursors.click,
                    child: GestureDetector(
                      key: const ValueKey('envelope-seal'),
                      behavior: HitTestBehavior.opaque,
                      onTap: _openDoors,
                    ),
                  ),
                ),
              ),
              if (!_opening)
                Positioned(
                  left: 24,
                  right: 24,
                  bottom: math.max(28, size.height * 0.06),
                  child: Center(child: _hint()),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _hint() {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: GardenColors.paper.withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(999),
        boxShadow: const [BoxShadow(color: Color(0x1A000000), blurRadius: 12)],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: Text(
          'Toca el sello para abrir',
          style: GoogleFonts.cormorantGaramond(
            fontSize: 17,
            fontWeight: FontWeight.w600,
            letterSpacing: 1.2,
            color: GardenColors.ink,
          ),
        ),
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

/// Una puerta: recorta su parte del mismo estampado para que, cerradas, se
/// lean como un solo papel cortado al medio.
class _Door extends StatelessWidget {
  const _Door({
    required this.image,
    required this.fullSize,
    required this.originX,
    required this.shadowOnLeft,
  });

  final ui.Image? image;
  final Size fullSize;
  final double originX;
  final bool shadowOnLeft;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: DecoratedBox(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: const Color(0x26000000),
              blurRadius: 10,
              offset: Offset(shadowOnLeft ? 4 : -2, 0),
            ),
          ],
        ),
        child: ClipRect(
          child: Stack(
            children: [
              Positioned(
                left: -originX,
                top: 0,
                width: fullSize.width,
                height: fullSize.height,
                child: image == null
                    ? const ColoredBox(color: PrintColors.paper)
                    : RawImage(
                        image: image,
                        width: fullSize.width,
                        height: fullSize.height,
                        fit: BoxFit.fill,
                      ),
              ),
              // Grano de papel encima de la tinta para que se sienta impreso.
              Positioned(
                left: -originX,
                top: 0,
                width: fullSize.width,
                height: fullSize.height,
                child: const IgnorePointer(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: AssetImage(
                          'assets/illustrations/paper_texture.jpg',
                        ),
                        repeat: ImageRepeat.repeat,
                        opacity: 0.22,
                      ),
                    ),
                  ),
                ),
              ),
              // Borde interior de papel: un brillo y una sombra suaves.
              Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: shadowOnLeft
                          ? Alignment.centerRight
                          : Alignment.centerLeft,
                      end: shadowOnLeft
                          ? Alignment.centerLeft
                          : Alignment.centerRight,
                      stops: const [0, 0.06],
                      colors: [const Color(0x12000000), Colors.transparent],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Sello de cera verde oliva con el monograma G&E.
class _WaxSeal extends StatelessWidget {
  const _WaxSeal();

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final size = constraints.maxWidth;
        return CustomPaint(
          painter: _WaxPainter(),
          child: Center(
            child: Monogram(size: size * 0.74, color: const Color(0xFFFBF7EA)),
          ),
        );
      },
    );
  }
}

class _WaxPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final r = size.width / 2;

    final blob = Path();
    for (var i = 0; i <= 72; i++) {
      final a = i / 72 * 2 * math.pi;
      final wobble = 1 + 0.03 * math.sin(a * 11) + 0.022 * math.cos(a * 4 + 1);
      final p = center + Offset(math.cos(a), math.sin(a)) * r * 0.97 * wobble;
      i == 0 ? blob.moveTo(p.dx, p.dy) : blob.lineTo(p.dx, p.dy);
    }
    blob.close();

    canvas.drawShadow(blob, Colors.black, 8, false);
    canvas.drawPath(
      blob,
      Paint()
        ..shader = const RadialGradient(
          center: Alignment(-0.35, -0.4),
          radius: 1.05,
          colors: [Color(0xFFC3CF97), Color(0xFF93A160), Color(0xFF6F7D45)],
          stops: [0, 0.6, 1],
        ).createShader(Rect.fromCircle(center: center, radius: r)),
    );
    // Relieve donde se presionó el sello.
    canvas.drawCircle(
      center,
      r * 0.76,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = r * 0.07
        ..color = const Color(0xFF6F7D45).withValues(alpha: 0.7),
    );
    canvas.drawCircle(
      center.translate(-r * 0.02, -r * 0.03),
      r * 0.72,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = r * 0.025
        ..color = Colors.white.withValues(alpha: 0.22),
    );
    // Brillo de la cera.
    canvas.drawOval(
      Rect.fromCenter(
        center: center.translate(-r * 0.38, -r * 0.45),
        width: r * 0.42,
        height: r * 0.18,
      ),
      Paint()..color = Colors.white.withValues(alpha: 0.18),
    );
  }

  @override
  bool shouldRepaint(_WaxPainter oldDelegate) => false;
}
