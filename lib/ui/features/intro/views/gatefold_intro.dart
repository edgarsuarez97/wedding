import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import 'monogram.dart';
import 'wildflowers.dart';

/// Portada de la invitación: dos puertas con estampado de flores silvestres
/// unidas por un sello de cera con el monograma.
///
/// Al tocar el sello, las puertas se deslizan hacia los lados (el sello viaja
/// con la puerta izquierda) y aparece la tarjeta con la corona floral, los
/// nombres y la fecha. "Ver invitación" despide la escena y llama a
/// [onOpened].
class GatefoldIntro extends StatefulWidget {
  const GatefoldIntro({
    super.key,
    required this.onOpened,
    this.dateLabel = '28 · 08 · 2027',
    this.weekday = 'Sábado',
    this.place = 'Tribus Privé · Mañongo, Valencia',
  });

  final VoidCallback onOpened;
  final String dateLabel;
  final String weekday;
  final String place;

  @override
  State<GatefoldIntro> createState() => _GatefoldIntroState();
}

enum _Stage { closed, opening, revealed, leaving }

class _GatefoldIntroState extends State<GatefoldIntro>
    with TickerProviderStateMixin {
  // Fracción del ancho que ocupa la puerta izquierda; la costura queda un poco
  // a la izquierda del centro, como en la referencia.
  static const _seam = 0.44;

  late final AnimationController _idle;
  late final AnimationController _open;
  late final AnimationController _exit;
  _Stage _stage = _Stage.closed;

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
          duration: const Duration(milliseconds: 2600),
        )..addStatusListener((status) {
          if (status == AnimationStatus.completed && mounted) {
            setState(() => _stage = _Stage.revealed);
          }
        });
    _exit =
        AnimationController(
          vsync: this,
          duration: const Duration(milliseconds: 800),
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
    } else if (!_idle.isAnimating && _stage == _Stage.closed) {
      _idle.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _idle.dispose();
    _open.dispose();
    _exit.dispose();
    super.dispose();
  }

  void _openDoors() {
    if (_stage != _Stage.closed) {
      return;
    }
    HapticFeedback.lightImpact();
    _idle.stop();
    setState(() => _stage = _Stage.opening);
    if (_reduceMotion) {
      _open.value = 1;
    } else {
      _open.forward();
    }
  }

  void _enterSite() {
    if (_stage == _Stage.leaving) {
      return;
    }
    setState(() => _stage = _Stage.leaving);
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
        key == LogicalKeyboardKey.numpadEnter ||
        key == LogicalKeyboardKey.space) {
      _stage == _Stage.closed ? _openDoors() : _enterSite();
      return KeyEventResult.handled;
    }
    if (key == LogicalKeyboardKey.escape) {
      _enterSite();
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
            ignoring: _stage == _Stage.leaving,
            child: Opacity(opacity: 1 - t, child: child),
          );
        },
        child: Material(
          color: GardenColors.paper,
          child: LayoutBuilder(
            builder: (context, constraints) => _buildScene(constraints.biggest),
          ),
        ),
      ),
    );
  }

  Widget _buildScene(Size size) {
    final sealSize = math.min(
      180.0,
      math.min(size.width * 0.36, size.height * 0.22),
    );
    final leftWidth = size.width * _seam;

    return Stack(
      fit: StackFit.expand,
      children: [
        // La tarjeta que espera detrás de las puertas.
        AnimatedBuilder(
          animation: _open,
          builder: (context, child) {
            final t = const Interval(
              0.3,
              0.85,
              curve: Curves.easeOutCubic,
            ).transform(_open.value);
            return _RevealCard(
              progress: t,
              dateLabel: widget.dateLabel,
              weekday: widget.weekday,
              place: widget.place,
            );
          },
        ),
        // Puertas.
        AnimatedBuilder(
          animation: Listenable.merge([_open, _idle]),
          builder: (context, _) {
            final slide = const Interval(
              0.12,
              0.72,
              curve: Curves.easeInOutCubic,
            ).transform(_open.value);
            final rightOffset = slide * (size.width - leftWidth + 24);
            final leftOffset = slide * (leftWidth + sealSize / 2 + 24);
            final pulse = _stage == _Stage.closed && !_reduceMotion
                ? Curves.easeInOutSine.transform(_idle.value)
                : 0.0;
            // El sello se hunde un poco antes de que se abran las puertas.
            final press = const Interval(
              0,
              0.12,
              curve: Curves.easeOut,
            ).transform(_open.value);
            final sealScale =
                1 + 0.04 * pulse - 0.08 * math.sin(press * math.pi);

            return Stack(
              fit: StackFit.expand,
              children: [
                Positioned(
                  left: leftWidth + rightOffset,
                  top: 0,
                  bottom: 0,
                  width: size.width - leftWidth,
                  child: _Door(
                    fullSize: size,
                    originX: leftWidth,
                    shadowOnLeft: false,
                  ),
                ),
                Positioned(
                  left: -leftOffset,
                  top: 0,
                  bottom: 0,
                  width: leftWidth,
                  child: _Door(fullSize: size, originX: 0, shadowOnLeft: true),
                ),
                Positioned(
                  left: leftWidth - sealSize / 2 - leftOffset,
                  top: size.height * 0.46 - sealSize / 2,
                  width: sealSize,
                  height: sealSize,
                  child: Transform.scale(
                    scale: sealScale,
                    child: _WaxSeal(onTap: _openDoors),
                  ),
                ),
              ],
            );
          },
        ),
        Positioned(
          left: 24,
          right: 24,
          bottom: math.max(28, size.height * 0.06),
          child: _buildBottomBar(),
        ),
      ],
    );
  }

  Widget _buildBottomBar() {
    final Widget content = switch (_stage) {
      _Stage.closed => Center(
        key: const ValueKey('hint'),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: GardenColors.paper.withValues(alpha: 0.9),
            borderRadius: BorderRadius.circular(999),
            boxShadow: const [
              BoxShadow(color: Color(0x1A000000), blurRadius: 12),
            ],
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
        ),
      ),
      _Stage.opening => const SizedBox(key: ValueKey('empty'), height: 52),
      _ => Center(
        key: const ValueKey('cta'),
        child: OutlinedButton(
          onPressed: _enterSite,
          style: OutlinedButton.styleFrom(
            foregroundColor: GardenColors.signature,
            backgroundColor: GardenColors.paper,
            side: const BorderSide(color: GardenColors.signature, width: 1.2),
            padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 16),
            shape: const StadiumBorder(),
            textStyle: GoogleFonts.cormorantGaramond(
              fontSize: 19,
              fontWeight: FontWeight.w600,
              letterSpacing: 1.4,
            ),
          ),
          child: const Text('Ver invitación'),
        ),
      ),
    };
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 450),
      child: content,
    );
  }
}

/// Una puerta: recorta su parte del mismo estampado para que, cerradas, se
/// lean como un solo papel cortado al medio.
class _Door extends StatelessWidget {
  const _Door({
    required this.fullSize,
    required this.originX,
    required this.shadowOnLeft,
  });

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
                child: const RepaintBoundary(
                  child: CustomPaint(painter: _PrintPainter()),
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

class _PrintPainter extends CustomPainter {
  const _PrintPainter();

  @override
  void paint(Canvas canvas, Size size) => paintWildflowerPrint(canvas, size);

  @override
  bool shouldRepaint(_PrintPainter oldDelegate) => false;
}

class _RevealCard extends StatelessWidget {
  const _RevealCard({
    required this.progress,
    required this.dateLabel,
    required this.weekday,
    required this.place,
  });

  final double progress;
  final String dateLabel;
  final String weekday;
  final String place;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final size = constraints.biggest;
        final ovalWidth = math.min(size.width * 0.86, size.height * 0.56);
        final ovalHeight = math.min(size.height * 0.6, ovalWidth * 1.45);
        final oval = Rect.fromCenter(
          center: Offset(size.width / 2, size.height * 0.43),
          width: ovalWidth,
          height: ovalHeight,
        );
        final unit = ovalWidth / 320;

        // Cada línea aparece un poco después de la anterior.
        Widget line(int index, Widget child) {
          final t = Interval(
            0.25 + index * 0.1,
            (0.65 + index * 0.1).clamp(0, 1),
            curve: Curves.easeOutCubic,
          ).transform(progress);
          return Opacity(
            opacity: t,
            child: Transform.translate(
              offset: Offset(0, 14 * (1 - t)),
              child: child,
            ),
          );
        }

        return DecoratedBox(
          decoration: const BoxDecoration(
            color: GardenColors.paper,
            image: DecorationImage(
              image: AssetImage('assets/illustrations/paper_texture.jpg'),
              repeat: ImageRepeat.repeat,
              opacity: 0.3,
            ),
          ),
          child: Stack(
            children: [
              Positioned.fill(
                child: Opacity(
                  opacity: Curves.easeOut.transform(progress),
                  child: Transform.scale(
                    scale: 0.94 + 0.06 * progress,
                    child: RepaintBoundary(
                      child: CustomPaint(painter: _WreathPainter(oval)),
                    ),
                  ),
                ),
              ),
              Positioned.fromRect(
                rect: oval.deflate(ovalWidth * 0.12),
                // En pantallas bajas el texto se encoge en vez de desbordar.
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      line(
                        0,
                        Text(
                          'NUESTRA BODA',
                          style: GoogleFonts.cormorantGaramond(
                            fontSize: 14 * unit,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 3,
                            color: GardenColors.ink,
                          ),
                        ),
                      ),
                      SizedBox(height: 10 * unit),
                      line(1, _script('Gabriela', 54 * unit)),
                      line(
                        1,
                        Transform.translate(
                          offset: Offset(28 * unit, -14 * unit),
                          child: _script(
                            '&',
                            34 * unit,
                            color: GardenColors.lavender,
                          ),
                        ),
                      ),
                      line(
                        2,
                        Transform.translate(
                          offset: Offset(0, -24 * unit),
                          child: _script('Edgar', 54 * unit),
                        ),
                      ),
                      line(
                        3,
                        Column(
                          children: [
                            Text(
                              weekday.toUpperCase(),
                              style: GoogleFonts.cormorantGaramond(
                                fontSize: 12 * unit,
                                letterSpacing: 2.5,
                                color: GardenColors.ink,
                              ),
                            ),
                            Text(
                              dateLabel,
                              style: GoogleFonts.cormorantGaramond(
                                fontSize: 22 * unit,
                                fontWeight: FontWeight.w700,
                                color: GardenColors.ink,
                              ),
                            ),
                            SizedBox(height: 6 * unit),
                            Text(
                              place,
                              textAlign: TextAlign.center,
                              style: GoogleFonts.cormorantGaramond(
                                fontSize: 14 * unit,
                                fontStyle: FontStyle.italic,
                                color: GardenColors.oliveDeep,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _script(
    String text,
    double fontSize, {
    Color color = GardenColors.signature,
  }) {
    return Text(
      text,
      maxLines: 1,
      style: GoogleFonts.pinyonScript(
        fontSize: fontSize,
        height: 1.1,
        color: color,
      ),
    );
  }
}

class _WreathPainter extends CustomPainter {
  _WreathPainter(this.oval);

  final Rect oval;

  @override
  void paint(Canvas canvas, Size size) => paintWildflowerWreath(canvas, oval);

  @override
  bool shouldRepaint(_WreathPainter oldDelegate) => oldDelegate.oval != oval;
}

/// Sello de cera azul campanilla con el monograma G&E.
class _WaxSeal extends StatelessWidget {
  const _WaxSeal({required this.onTap});

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
              return CustomPaint(
                painter: _WaxPainter(),
                child: Center(
                  child: Monogram(
                    size: size * 0.74,
                    color: const Color(0xFFF7F1E4),
                  ),
                ),
              );
            },
          ),
        ),
      ),
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
          colors: [Color(0xFF8FA9E2), Color(0xFF5674BE), Color(0xFF3F5BA3)],
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
        ..color = const Color(0xFF3F5BA3).withValues(alpha: 0.7),
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
