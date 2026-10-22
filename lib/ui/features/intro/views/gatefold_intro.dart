import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'invitation_card.dart';

/// Portada de la invitación: una tarjeta con marco de cinta salvia, lazo y
/// flores de acuarela, cortada al medio en dos puertas que une un sello de
/// cera con el monograma.
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
    super.dispose();
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
    final card = InvitationCard.rectFor(size);
    final sealSize = InvitationCard.sealSizeFor(card.size);
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

        // La sombra va aparte, sin escalar ni recortar: escalar una sombra
        // difuminada en cada cuadro la hace titilar.
        final shadowPad = sealSize * 0.25;
        Widget sealShadow({bool? left}) {
          final shift = left == null ? 0.0 : (left ? -offset : offset);
          final shadow = CustomPaint(painter: _SealShadowPainter(sealSize));
          return Positioned(
            left: half - sealSize / 2 - shadowPad + shift,
            top: sealTop - shadowPad,
            width: sealSize + shadowPad * 2,
            height: sealSize + shadowPad * 2,
            child: IgnorePointer(
              child: left == null
                  ? shadow
                  : ClipRect(
                      clipper: _HalfClipper(left: left),
                      child: shadow,
                    ),
            ),
          );
        }

        Widget seal({bool? left}) {
          final shift = left == null ? 0.0 : (left ? -offset : offset);
          return Positioned(
            left: half - sealSize / 2 + shift,
            top: sealTop,
            width: sealSize,
            height: sealSize,
            child: Transform.scale(
              scale: sealScale,
              // Cerrado se dibuja entero; partirlo en dos mitades recortadas
              // mientras late deja una costura que parpadea.
              child: left == null
                  ? const _WaxSeal()
                  : ClipRect(
                      clipper: _HalfClipper(left: left),
                      child: const _WaxSeal(),
                    ),
            ),
          );
        }

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
                  fullSize: size,
                  originX: half,
                  shadowOnLeft: false,
                  opening: _opening,
                ),
              ),
              Positioned(
                left: -offset,
                top: 0,
                bottom: 0,
                width: half,
                child: _Door(
                  fullSize: size,
                  originX: 0,
                  shadowOnLeft: true,
                  opening: _opening,
                ),
              ),
              if (!_opening) ...[
                sealShadow(),
                seal(),
              ] else ...[
                sealShadow(left: true),
                sealShadow(left: false),
                seal(left: true),
                seal(left: false),
              ],
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
            ],
          ),
        );
      },
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

/// Una puerta: recorta su mitad de la misma tarjeta para que, cerradas, se
/// lean como un solo papel cortado al medio.
class _Door extends StatelessWidget {
  const _Door({
    required this.fullSize,
    required this.originX,
    required this.shadowOnLeft,
    required this.opening,
  });

  final Size fullSize;
  final double originX;
  final bool shadowOnLeft;
  final bool opening;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: DecoratedBox(
        // Cerradas no se nota la costura; la sombra aparece al separarse.
        decoration: BoxDecoration(
          boxShadow: [
            if (opening)
              BoxShadow(
                color: const Color(0x26000000),
                blurRadius: 10,
                offset: Offset(shadowOnLeft ? 4 : -2, 0),
              ),
          ],
        ),
        child: ClipRect(
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Positioned(
                left: -originX,
                top: 0,
                width: fullSize.width,
                height: fullSize.height,
                // La tarjeta se rasteriza una vez y en cada cuadro solo se
                // desplaza, así la apertura va fluida también en la web.
                child: RepaintBoundary(
                  // Las dos puertas pintan la misma tarjeta; solo la
                  // izquierda se anuncia a los lectores de pantalla.
                  child: ExcludeSemantics(
                    excluding: !shadowOnLeft,
                    child: InvitationCard(hideHint: opening),
                  ),
                ),
              ),
              if (opening)
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

/// Sello de cera verde salvia con el monograma G&E.
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
            child: SvgPicture.asset(
              'assets/monogram/monogram.svg',
              width: size * 0.7,
              colorFilter: const ColorFilter.mode(
                Color(0xFFFFFFFF),
                BlendMode.srcIn,
              ),
            ),
          ),
        );
      },
    );
  }
}

/// Contorno irregular de la cera.
Path _sealBlob(Offset center, double r) {
  final blob = Path();
  for (var i = 0; i <= 72; i++) {
    final a = i / 72 * 2 * math.pi;
    final wobble = 1 + 0.03 * math.sin(a * 11) + 0.022 * math.cos(a * 4 + 1);
    final p = center + Offset(math.cos(a), math.sin(a)) * r * 0.97 * wobble;
    i == 0 ? blob.moveTo(p.dx, p.dy) : blob.lineTo(p.dx, p.dy);
  }
  return blob..close();
}

/// Sombra suave del sello sobre el papel.
class _SealShadowPainter extends CustomPainter {
  _SealShadowPainter(this.sealSize);

  final double sealSize;

  @override
  void paint(Canvas canvas, Size size) {
    final r = sealSize / 2;
    canvas.drawPath(
      _sealBlob(size.center(Offset(0, r * 0.07)), r),
      Paint()
        ..color = const Color(0x47000000)
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, r * 0.08),
    );
  }

  @override
  bool shouldRepaint(_SealShadowPainter oldDelegate) =>
      oldDelegate.sealSize != sealSize;
}

class _WaxPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final r = size.width / 2;
    final blob = _sealBlob(center, r);

    canvas.drawPath(
      blob,
      Paint()
        ..shader = const RadialGradient(
          center: Alignment(-0.35, -0.4),
          radius: 1.05,
          colors: [Color(0xFFC9D1BA), Color(0xFF9DA790), Color(0xFF6E7A62)],
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
        ..color = const Color(0xFF6E7A62).withValues(alpha: 0.7),
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
