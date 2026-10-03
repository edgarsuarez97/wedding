import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:wedding_g_and_e/ui/core/garden/falling_leaves.dart';
import 'package:wedding_g_and_e/ui/core/garden/wildflower.dart';
import 'package:wedding_g_and_e/ui/core/theme/app_motion.dart';
import 'package:wedding_g_and_e/ui/core/theme/app_theme.dart';
import 'package:wedding_g_and_e/ui/features/home/views/wedding_home_page.dart';

const _venueLine = 'Tribus Privé · Mañongo, Valencia';
const _mapsUrl =
    'https://www.google.com/maps/place/IP+Tribus+Prive/@10.231332,-67.9980372,17z/data=!4m14!1m7!3m6!1s0x8e8067427044ab73:0xb249651b3d80e67a!2sIP+Tribus+Prive!8m2!3d10.231332!4d-67.9954623!16s%2Fg%2F11tp7qkc_0!3m5!1s0x8e8067427044ab73:0xb249651b3d80e67a!8m2!3d10.231332!4d-67.9954623!16s%2Fg%2F11tp7qkc_0?entry=ttu&g_ep=EgoyMDI2MDYwMy4xIKXMDSoASAFQAw%3D%3D';

class HeroSection extends StatefulWidget {
  const HeroSection({
    super.key,
    required this.weddingDate,
    required this.heroImageUrl,
    required this.coupleNames,
    required this.isMusicPlaying,
    required this.isMusicBusy,
    required this.onToggleMusic,
    this.entranceDelay = Duration.zero,
  });

  final DateTime weddingDate;
  final String heroImageUrl;
  final String coupleNames;
  final bool isMusicPlaying;
  final bool isMusicBusy;
  final VoidCallback onToggleMusic;
  final Duration entranceDelay;

  @override
  State<HeroSection> createState() => _HeroSectionState();
}

class _HeroSectionState extends State<HeroSection>
    with SingleTickerProviderStateMixin {
  late final AnimationController _entranceController = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1600),
  );

  bool _didConfigureMotionPreference = false;

  Animation<double> _step(double begin, double end) => CurvedAnimation(
    parent: _entranceController,
    curve: Interval(begin, end, curve: AppMotion.organic),
  );

  late final Animation<double> _namesAnimation = _step(0.1, 0.7);
  late final Animation<double> _dateAnimation = _step(0.3, 0.85);
  late final Animation<double> _placeAnimation = _step(0.42, 1);
  late final Animation<double> _buttonAnimation = _step(0.2, 0.8);

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_didConfigureMotionPreference) {
      return;
    }
    _didConfigureMotionPreference = true;
    if (AppMotion.reduced(context)) {
      _entranceController.value = 1;
    } else if (widget.entranceDelay > Duration.zero) {
      Future<void>.delayed(widget.entranceDelay, () {
        if (mounted) {
          _entranceController.forward();
        }
      });
    } else {
      _entranceController.forward();
    }
  }

  @override
  void dispose() {
    _entranceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final namesSize = (width * 0.11).clamp(54.0, 104.0);
    final names = widget.coupleNames.split('&').map((s) => s.trim()).toList();
    final dateText = DateFormat('dd · MM · yyyy').format(widget.weddingDate);

    return SizedBox(
      height: 680,
      width: double.infinity,
      child: Stack(
        children: [
          // La foto y su velo son estáticos: se graban una vez con su fundido
          // hacia el papel, y las hojas se animan en una capa aparte.
          Positioned.fill(
            child: RepaintBoundary(
              child: ShaderMask(
                blendMode: BlendMode.dstIn,
                shaderCallback: (bounds) {
                  return const LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.white,
                      Colors.white,
                      Colors.white,
                      Colors.transparent,
                    ],
                    stops: [0, 0.62, 0.84, 1],
                  ).createShader(bounds);
                },
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.network(
                      widget.heroImageUrl,
                      fit: BoxFit.cover,
                      filterQuality: FilterQuality.medium,
                    ),
                    DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                          colors: [
                            const Color(0xFF1E2028).withValues(alpha: 0.55),
                            const Color(0xFF1E2028).withValues(alpha: 0.14),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          // Las hojas se desvanecen solas al llegar al borde inferior.
          const Positioned.fill(child: FallingLeaves(fadeFrom: 0.84)),
          Positioned(
            top: 0,
            right: 0,
            child: _FadeSlideIn(
              animation: _buttonAnimation,
              beginOffsetY: 16,
              child: SafeArea(
                minimum: const EdgeInsets.only(top: 18, right: 18),
                child: RepaintBoundary(
                  child: _BouncingMusicButton(
                    isPlaying: widget.isMusicPlaying,
                    isBusy: widget.isMusicBusy,
                    labelImageUrl: widget.heroImageUrl,
                    onPressed: widget.onToggleMusic,
                  ),
                ),
              ),
            ),
          ),
          Positioned.fill(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 40, 24, 90),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _FadeSlideIn(
                    animation: _namesAnimation,
                    beginOffsetY: 22,
                    child: Text.rich(
                      TextSpan(
                        children: [
                          TextSpan(text: names.first),
                          if (names.length > 1) ...[
                            TextSpan(
                              text: ' & ',
                              style: TextStyle(
                                color: const Color(0xFFFFC3D3),
                                fontSize: namesSize * 0.66,
                              ),
                            ),
                            TextSpan(text: names.last),
                          ],
                        ],
                      ),
                      textAlign: TextAlign.center,
                      style:
                          AppTheme.script(
                            fontSize: namesSize,
                            color: Colors.white,
                          ).copyWith(
                            shadows: const [
                              Shadow(color: Color(0x40000000), blurRadius: 18),
                            ],
                          ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  _FadeSlideIn(
                    animation: _dateAnimation,
                    beginOffsetY: 18,
                    child: Column(
                      children: [
                        Container(
                          width: 140,
                          height: 1,
                          decoration: const BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Color(0x00FFEB9F),
                                AppTheme.butter,
                                Color(0x00FFEB9F),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 14),
                        Text(
                          dateText,
                          style: AppTheme.display(
                            fontSize: width < 500 ? 18 : 22,
                            color: Colors.white,
                          ).copyWith(letterSpacing: 7),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  _FadeSlideIn(
                    animation: _placeAnimation,
                    beginOffsetY: 16,
                    child: Text(
                      _venueLine.toUpperCase(),
                      textAlign: TextAlign.center,
                      style: GoogleFonts.jost(
                        fontSize: 12.5,
                        letterSpacing: 2.5,
                        color: Colors.white.withValues(alpha: 0.88),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FadeSlideIn extends StatelessWidget {
  const _FadeSlideIn({
    required this.animation,
    required this.child,
    this.beginOffsetY = 24,
  });

  final Animation<double> animation;
  final Widget child;
  final double beginOffsetY;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      child: child,
      builder: (context, child) {
        final t = animation.value;
        final dy = beginOffsetY * (1 - t);
        return Opacity(
          opacity: t,
          child: Transform.translate(offset: Offset(0, dy), child: child),
        );
      },
    );
  }
}

/// Segunda sección: "Save the date", cuenta regresiva y accesos rápidos.
class HeroEventDetailsSection extends StatelessWidget {
  const HeroEventDetailsSection({super.key, required this.weddingDate});

  final DateTime weddingDate;

  @override
  Widget build(BuildContext context) {
    final buttonStyle = OutlinedButton.styleFrom(
      foregroundColor: AppTheme.ink,
      backgroundColor: Colors.white.withValues(alpha: 0.5),
      side: const BorderSide(color: AppTheme.ink),
      shape: const StadiumBorder(),
      padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 16),
      textStyle: GoogleFonts.jost(fontSize: 15, letterSpacing: 0.5),
    );
    final width = MediaQuery.sizeOf(context).width;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 40, 20, 24),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 980),
          child: Column(
            children: [
              Text(
                'Save the date',
                textAlign: TextAlign.center,
                style: AppTheme.script(
                  fontSize: (width * 0.07).clamp(40.0, 56.0),
                ),
              ),
              const SizedBox(height: 30),
              _Countdown(targetDate: weddingDate),
              const SizedBox(height: 30),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                alignment: WrapAlignment.center,
                children: [
                  OutlinedButton.icon(
                    style: buttonStyle,
                    onPressed: () => launchGoogleCalendar(weddingDate),
                    icon: const Icon(Icons.calendar_month_outlined, size: 18),
                    label: const Text('Agregar a Google Calendar'),
                  ),
                  OutlinedButton.icon(
                    style: buttonStyle,
                    onPressed: () => openExternal(_mapsUrl),
                    icon: const Icon(Icons.location_on_outlined, size: 18),
                    label: const Text('Ver lugar'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Countdown extends StatefulWidget {
  const _Countdown({required this.targetDate});

  final DateTime targetDate;

  @override
  State<_Countdown> createState() => _CountdownState();
}

class _CountdownState extends State<_Countdown> {
  late Duration _remaining;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _remaining = widget.targetDate.difference(DateTime.now());
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) {
        return;
      }
      setState(() {
        _remaining = widget.targetDate.difference(DateTime.now());
      });
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final remaining = _remaining.isNegative ? Duration.zero : _remaining;
    final cellSize = (MediaQuery.sizeOf(context).width * 0.18).clamp(
      74.0,
      104.0,
    );
    String two(int v) => v.toString().padLeft(2, '0');
    final cells = [
      ('${remaining.inDays}', 'días'),
      (two(remaining.inHours % 24), 'horas'),
      (two(remaining.inMinutes % 60), 'minutos'),
      (two(remaining.inSeconds % 60), 'segundos'),
    ];

    return Semantics(
      label:
          'Faltan ${remaining.inDays} días, ${remaining.inHours % 24} horas y ${remaining.inMinutes % 60} minutos',
      excludeSemantics: true,
      child: Wrap(
        alignment: WrapAlignment.center,
        spacing: 16,
        runSpacing: 16,
        children: [
          for (final (i, (value, label)) in cells.indexed)
            _WreathCell(
              value: value,
              label: label,
              size: cellSize,
              withBloom: i == cells.length - 1,
            ),
        ],
      ),
    );
  }
}

/// Un número de la cuenta regresiva dentro de una pequeña corona de hojas.
class _WreathCell extends StatelessWidget {
  const _WreathCell({
    required this.value,
    required this.label,
    required this.size,
    this.withBloom = false,
  });

  final String value;
  final String label;
  final double size;
  final bool withBloom;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.center,
        children: [
          Positioned.fill(child: CustomPaint(painter: _WreathPainter())),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _TickingNumber(value: value, fontSize: size * 0.38),
              const SizedBox(height: 2),
              Text(
                label.toUpperCase(),
                style: GoogleFonts.jost(
                  fontSize: 10.5,
                  letterSpacing: 2,
                  color: AppTheme.inkSoft,
                ),
              ),
            ],
          ),
          if (withBloom)
            Positioned(top: -size * 0.1, child: const _BeatingBloom(size: 28)),
        ],
      ),
    );
  }
}

class _WreathPainter extends CustomPainter {
  static final Path _leaf = Path()
    ..moveTo(0, 0)
    ..cubicTo(8, -9, 22, -10, 32, 0)
    ..cubicTo(22, 10, 8, 9, 0, 0)
    ..close();

  @override
  void paint(Canvas canvas, Size size) {
    final r = size.width / 2;
    final center = Offset(r, r);
    canvas
      ..drawCircle(
        center,
        r * 0.92,
        Paint()..color = Colors.white.withValues(alpha: 0.6),
      )
      ..drawCircle(
        center,
        r * 0.92,
        Paint()
          ..style = PaintingStyle.stroke
          ..color = AppTheme.mint,
      );
    final fill = Paint()..color = AppTheme.mint;
    final stroke = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.6
      ..color = AppTheme.stem;
    final scale = size.width / 100 * 0.45;
    for (final (x, y, deg) in const [
      (14.0, 74.0, -60.0),
      (86.0, 74.0, -120.0),
    ]) {
      canvas
        ..save()
        ..translate(x * size.width / 100, y * size.height / 100)
        ..rotate(deg * math.pi / 180)
        ..scale(scale)
        ..translate(-16, 0)
        ..drawPath(_leaf, fill)
        ..drawPath(_leaf, stroke)
        ..restore();
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _TickingNumber extends StatelessWidget {
  const _TickingNumber({required this.value, required this.fontSize});

  final String value;
  final double fontSize;

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: AppMotion.reduced(context)
          ? Duration.zero
          : AppMotion.countdownTick,
      switchInCurve: AppMotion.organic,
      switchOutCurve: Curves.easeIn,
      transitionBuilder: (child, animation) {
        return FadeTransition(
          opacity: animation,
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0, -0.35),
              end: Offset.zero,
            ).animate(animation),
            child: child,
          ),
        );
      },
      child: Text(
        value,
        key: ValueKey<String>(value),
        maxLines: 1,
        style: AppTheme.display(fontSize: fontSize, fontWeight: FontWeight.w600)
            .copyWith(
              height: 1,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
      ),
    );
  }
}

/// Nomeolvides que late una vez por segundo junto a los segundos.
class _BeatingBloom extends StatefulWidget {
  const _BeatingBloom({required this.size});

  final double size;

  @override
  State<_BeatingBloom> createState() => _BeatingBloomState();
}

class _BeatingBloomState extends State<_BeatingBloom>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 1),
  );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (AppMotion.reduced(context)) {
      _controller.stop();
    } else if (!_controller.isAnimating) {
      _controller.repeat();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      child: WildflowerIcon(Wildflower.forgetMeNot, size: widget.size),
      builder: (context, child) {
        final t = _controller.value;
        final beat = t < 0.15 ? t / 0.15 : (1 - (t - 0.15) / 0.85);
        return Transform.scale(
          scale: 1 + 0.25 * beat.clamp(0, 1),
          child: child,
        );
      },
    );
  }
}

class _BouncingMusicButton extends StatefulWidget {
  const _BouncingMusicButton({
    required this.isPlaying,
    required this.isBusy,
    required this.labelImageUrl,
    required this.onPressed,
  });

  final bool isPlaying;
  final bool isBusy;
  final String labelImageUrl;
  final VoidCallback onPressed;

  @override
  State<_BouncingMusicButton> createState() => _BouncingMusicButtonState();
}

class _BouncingMusicButtonState extends State<_BouncingMusicButton>
    with TickerProviderStateMixin {
  late final AnimationController _bounceController;
  late final AnimationController _spinController;
  late final Animation<double> _offset;

  @override
  void initState() {
    super.initState();
    _bounceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 920),
    )..repeat(reverse: true);
    _spinController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 7),
    );
    if (widget.isPlaying) {
      _spinController.repeat();
    }
    _offset = Tween<double>(begin: 0, end: -6).animate(
      CurvedAnimation(parent: _bounceController, curve: Curves.easeInOut),
    );
  }

  @override
  void didUpdateWidget(covariant _BouncingMusicButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isPlaying && !_spinController.isAnimating) {
      _spinController.repeat();
    }
    if (!widget.isPlaying && _spinController.isAnimating) {
      _spinController.stop(canceled: false);
    }
  }

  @override
  void dispose() {
    _bounceController.dispose();
    _spinController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([_offset, _spinController]),
      builder: (context, _) {
        return Transform.translate(
          offset: Offset(0, _offset.value),
          child: Material(
            color: Colors.transparent,
            shape: const CircleBorder(),
            child: InkWell(
              customBorder: const CircleBorder(),
              onTap: widget.isBusy ? null : widget.onPressed,
              child: SizedBox(
                width: 84,
                height: 84,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Transform.rotate(
                      angle: _spinController.value * (2 * math.pi),
                      child: _VinylDisc(labelImageUrl: widget.labelImageUrl),
                    ),
                    Positioned(
                      right: 1,
                      bottom: 2,
                      child: Container(
                        width: 26,
                        height: 26,
                        decoration: BoxDecoration(
                          color: const Color(0xCC0E0E0E),
                          shape: BoxShape.circle,
                          border: Border.all(color: const Color(0xFF252525)),
                        ),
                        child: Icon(
                          widget.isPlaying
                              ? Icons.pause_rounded
                              : Icons.play_arrow_rounded,
                          size: 16,
                          color: const Color(0xFFF4F4F4),
                        ),
                      ),
                    ),
                    if (widget.isBusy)
                      Container(
                        width: 84,
                        height: 84,
                        decoration: const BoxDecoration(
                          color: Color(0x55000000),
                          shape: BoxShape.circle,
                        ),
                        child: const Center(
                          child: SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(strokeWidth: 2.2),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _VinylDisc extends StatelessWidget {
  const _VinylDisc({required this.labelImageUrl});

  final String labelImageUrl;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.34),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
        gradient: const RadialGradient(
          colors: [Color(0xFF1A1A1A), Color(0xFF111111)],
          radius: 0.92,
        ),
        border: Border.all(color: const Color(0xFF232323), width: 1.4),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          for (final diameter in [74.0, 66.0, 58.0, 50.0, 42.0])
            Container(
              width: diameter,
              height: diameter,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: const Color(0xFF252525).withValues(alpha: 0.72),
                  width: 0.8,
                ),
              ),
            ),
          Container(
            width: 44,
            height: 44,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Color(0xFF0F0F0F),
            ),
            child: ClipOval(
              child: Image.asset(
                'assets/illustrations/vinyl-label.jpg',
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Image.network(
                    labelImageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return const DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Color(0xFFF4D230), Color(0xFFF0A42A)],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ),
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0xFF000000), width: 1.2),
            ),
          ),
        ],
      ),
    );
  }
}
