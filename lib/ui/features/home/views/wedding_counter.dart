import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:wedding_g_and_e/ui/features/home/views/wedding_home_page.dart';

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
  late final AnimationController _entranceController;
  late final Animation<double> _contentAnimation;
  late final Animation<double> _buttonAnimation;

  bool _didConfigureMotionPreference = false;

  @override
  void initState() {
    super.initState();
    _entranceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 920),
    );
    _contentAnimation = CurvedAnimation(
      parent: _entranceController,
      curve: const Interval(0.08, 0.78, curve: Curves.easeOutCubic),
    );
    _buttonAnimation = CurvedAnimation(
      parent: _entranceController,
      curve: const Interval(0.24, 1, curve: Curves.easeOutCubic),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_didConfigureMotionPreference) {
      return;
    }
    _didConfigureMotionPreference = true;
    final prefersReducedMotion =
        MediaQuery.maybeOf(context)?.disableAnimations ?? false;
    if (prefersReducedMotion) {
      _entranceController.value = 1;
    } else {
      if (widget.entranceDelay > Duration.zero) {
        Future<void>.delayed(widget.entranceDelay, () {
          if (!mounted) {
            return;
          }
          _entranceController.forward();
        });
      } else {
        _entranceController.forward();
      }
    }
  }

  @override
  void dispose() {
    _entranceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 680,
      width: double.infinity,
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
          children: [
            Positioned.fill(
              child: Image.network(
                widget.heroImageUrl,
                fit: BoxFit.cover,
                filterQuality: FilterQuality.medium,
              ),
            ),
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [
                      Colors.black.withValues(alpha: 0.58),
                      Colors.black.withValues(alpha: 0.18),
                    ],
                  ),
                ),
              ),
            ),
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Color(0x00F9F6F1),
                      Color(0x1AF9F6F1),
                      Color(0x52F9F6F1),
                    ],
                    stops: [0.52, 0.8, 1],
                  ),
                ),
              ),
            ),
            Positioned(
              top: 0,
              right: 0,
              child: _FadeSlideIn(
                animation: _buttonAnimation,
                beginOffsetY: 16,
                child: SafeArea(
                  minimum: const EdgeInsets.only(top: 18, right: 18),
                  child: _BouncingMusicButton(
                    isPlaying: widget.isMusicPlaying,
                    isBusy: widget.isMusicBusy,
                    labelImageUrl: widget.heroImageUrl,
                    onPressed: widget.onToggleMusic,
                  ),
                ),
              ),
            ),
            Positioned.fill(
              child: _FadeSlideIn(
                animation: _contentAnimation,
                beginOffsetY: 30,
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 860),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.86),
                              borderRadius: BorderRadius.circular(99),
                            ),
                            child: const Text('Save The Date'),
                          ),
                          const SizedBox(height: 20),
                          Text(
                            widget.coupleNames,
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.displayLarge
                                ?.copyWith(color: Colors.white, fontSize: 68),
                          ),
                          const SizedBox(height: 14),
                          _HeroMonogram(coupleNames: widget.coupleNames),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
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

class HeroEventDetailsSection extends StatelessWidget {
  const HeroEventDetailsSection({super.key, required this.weddingDate});

  final DateTime weddingDate;

  @override
  Widget build(BuildContext context) {
    final dateText = DateFormat('dd.MM.yyyy').format(weddingDate);
    final buttonStyle = OutlinedButton.styleFrom(
      foregroundColor: const Color(0xFF151515),
      side: const BorderSide(color: Color(0xFF151515), width: 1.2),
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 13),
      textStyle: const TextStyle(fontWeight: FontWeight.w600),
    );

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 46, 20, 18),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 980),
          child: Column(
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: Container(
                      height: 1.2,
                      margin: const EdgeInsets.only(top: 12, right: 14),
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                          colors: [
                            Color(0x00201E1A),
                            Color(0xFF201E1A),
                            Color(0x00201E1A),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Text(
                    dateText,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.playfairDisplay(
                      fontSize: 36,
                      fontWeight: FontWeight.w500,
                      letterSpacing: 0.8,
                      color: const Color(0xFF1F1C18),
                    ),
                  ),
                  Expanded(
                    child: Container(
                      height: 1.2,
                      margin: const EdgeInsets.only(top: 12, left: 14),
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                          colors: [
                            Color(0x00201E1A),
                            Color(0xFF201E1A),
                            Color(0x00201E1A),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 40),
              _CountdownPill(targetDate: weddingDate),
              const SizedBox(height: 26),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                alignment: WrapAlignment.center,
                children: [
                  OutlinedButton.icon(
                    style: buttonStyle,
                    onPressed: () => launchGoogleCalendar(weddingDate),
                    icon: const Icon(Icons.calendar_month),
                    label: const Text('Agregar a Google Calendar'),
                  ),
                  OutlinedButton.icon(
                    style: buttonStyle,
                    onPressed: () => openExternal(
                      'https://www.google.com/maps/place/IP+Tribus+Prive/@10.231332,-67.9980372,17z/data=!4m14!1m7!3m6!1s0x8e8067427044ab73:0xb249651b3d80e67a!2sIP+Tribus+Prive!8m2!3d10.231332!4d-67.9954623!16s%2Fg%2F11tp7qkc_0!3m5!1s0x8e8067427044ab73:0xb249651b3d80e67a!8m2!3d10.231332!4d-67.9954623!16s%2Fg%2F11tp7qkc_0?entry=ttu&g_ep=EgoyMDI2MDYwMy4xIKXMDSoASAFQAw%3D%3D',
                    ),
                    icon: const Icon(Icons.location_on_outlined),
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

class _HeroMonogram extends StatelessWidget {
  const _HeroMonogram({required this.coupleNames});

  final String coupleNames;

  @override
  Widget build(BuildContext context) {
    final initials = _extractInitials(coupleNames);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Colors.white.withValues(alpha: 0.62)),
      ),
      child: Text(
        initials,
        style: GoogleFonts.playfairDisplay(
          fontSize: 22,
          fontWeight: FontWeight.w600,
          letterSpacing: 1.2,
          color: Colors.white,
        ),
      ),
    );
  }

  String _extractInitials(String value) {
    final letters = value
        .split(RegExp(r'\s+|&|y|and'))
        .where((part) => part.trim().isNotEmpty)
        .map((part) => part.trim()[0].toUpperCase())
        .toList();

    if (letters.isEmpty) {
      return 'E • G';
    }
    if (letters.length == 1) {
      return '${letters.first} • ${letters.first}';
    }
    return '${letters.first} • ${letters.last}';
  }
}

class _CountdownPill extends StatefulWidget {
  const _CountdownPill({required this.targetDate});

  final DateTime targetDate;

  @override
  State<_CountdownPill> createState() => _CountdownPillState();
}

class _CountdownPillState extends State<_CountdownPill> {
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
    final days = _remaining.inDays.clamp(0, 9999);
    final hours = (_remaining.inHours % 24).clamp(0, 23);
    final minutes = (_remaining.inMinutes % 60).clamp(0, 59);
    final seconds = (_remaining.inSeconds % 60).clamp(0, 59);
    final isCompact = MediaQuery.sizeOf(context).width < 430;
    return FittedBox(
      fit: BoxFit.scaleDown,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _CountdownMetric(
            value: '$days',
            label: 'dias',
            compact: isCompact,
            boxWidth: isCompact ? 78 : 110,
          ),
          SizedBox(width: isCompact ? 8 : 12),
          _CountdownMetric(
            value: hours.toString().padLeft(2, '0'),
            label: 'horas',
            compact: isCompact,
            boxWidth: isCompact ? 64 : 86,
          ),
          SizedBox(width: isCompact ? 8 : 12),
          _CountdownMetric(
            value: minutes.toString().padLeft(2, '0'),
            label: 'minutos',
            compact: isCompact,
            boxWidth: isCompact ? 64 : 86,
          ),
          SizedBox(width: isCompact ? 8 : 12),
          _CountdownMetric(
            value: seconds.toString().padLeft(2, '0'),
            label: 'segundos',
            compact: isCompact,
            boxWidth: isCompact ? 64 : 86,
          ),
        ],
      ),
    );
  }
}

class _CountdownMetric extends StatelessWidget {
  const _CountdownMetric({
    required this.value,
    required this.label,
    this.compact = false,
    required this.boxWidth,
  });

  final String value;
  final String label;
  final bool compact;
  final double boxWidth;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: boxWidth,
          height: compact ? 64 : 84,
          padding: EdgeInsets.symmetric(horizontal: compact ? 10 : 14),
          decoration: BoxDecoration(
            color: const Color(0xFFEFEAE1).withValues(alpha: 0.92),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xFFCCC1B2)),
          ),
          child: Center(
            child: _AnimatedCountdownNumber(value: value, compact: compact),
          ),
        ),
        SizedBox(height: compact ? 6 : 8),
        Text(
          label,
          style: GoogleFonts.lora(
            fontSize: compact ? 12 : 13,
            fontWeight: FontWeight.w500,
            letterSpacing: 1.1,
            color: const Color(0xFF1A1A1A),
          ),
        ),
      ],
    );
  }
}

class _AnimatedCountdownNumber extends StatelessWidget {
  const _AnimatedCountdownNumber({required this.value, required this.compact});

  final String value;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 360),
      switchInCurve: Curves.easeOutCubic,
      switchOutCurve: Curves.easeInCubic,
      transitionBuilder: (child, animation) {
        final offsetAnimation = Tween<Offset>(
          begin: const Offset(0, 0.25),
          end: Offset.zero,
        ).animate(animation);
        return FadeTransition(
          opacity: animation,
          child: SlideTransition(position: offsetAnimation, child: child),
        );
      },
      child: Text(
        value,
        key: ValueKey<String>(value),
        textAlign: TextAlign.center,
        maxLines: 1,
        softWrap: false,
        overflow: TextOverflow.visible,
        style: GoogleFonts.lora(
          fontSize: compact ? 30 : 44,
          height: 1,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.3,
          color: const Color(0xFF101010),
        ),
      ),
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
