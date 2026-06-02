import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:wedding_g_and_e/ui/features/home/views/wedding_home_page.dart';



class HeroSection extends StatelessWidget {
  const HeroSection({super.key, 
    required this.weddingDate,
    required this.heroImageUrl,
    required this.coupleNames,
    required this.isMusicPlaying,
    required this.isMusicBusy,
    required this.onToggleMusic,
  });

  final DateTime weddingDate;
  final String heroImageUrl;
  final String coupleNames;
  final bool isMusicPlaying;
  final bool isMusicBusy;
  final VoidCallback onToggleMusic;

  @override
  Widget build(BuildContext context) {
    final dateText = DateFormat(
      "EEEE d 'de' MMMM 'de' y",
      'es_ES',
    ).format(weddingDate);
    return Stack(
      children: [
        SizedBox(
          height: 680,
          width: double.infinity,
          child: Image.network(
            heroImageUrl,
            fit: BoxFit.cover,
            filterQuality: FilterQuality.medium,
          ),
        ),
        Container(
          height: 680,
          width: double.infinity,
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
        Positioned(
          top: 0,
          right: 0,
          child: SafeArea(
            minimum: const EdgeInsets.only(top: 18, right: 18),
            child: _BouncingMusicButton(
              isPlaying: isMusicPlaying,
              isBusy: isMusicBusy,
              onPressed: onToggleMusic,
            ),
          ),
        ),
        Positioned.fill(
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
                      coupleNames,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.displayLarge?.copyWith(
                        color: Colors.white,
                        fontSize: 68,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      dateText,
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.white, fontSize: 24),
                    ),
                    const SizedBox(height: 22),
                    _CountdownPill(targetDate: weddingDate),
                    const SizedBox(height: 28),
                    Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      alignment: WrapAlignment.center,
                      children: [
                        FilledButton.icon(
                          onPressed: () => launchGoogleCalendar(weddingDate),
                          icon: const Icon(Icons.calendar_month),
                          label: const Text('Agregar a Google Calendar'),
                        ),
                        OutlinedButton.icon(
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.white,
                            side: const BorderSide(color: Colors.white70),
                          ),
                          onPressed: () => openExternal(
                            'https://maps.google.com/?q=Rosewood+Garden+Estate',
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
          ),
        ),
      ],
    );
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
            color: Colors.white.withValues(alpha: 0.10),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: Colors.white.withValues(alpha: 0.54)),
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
            color: Colors.white.withValues(alpha: 0.94),
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
          color: Colors.white,
        ),
      ),
    );
  }
}


class _BouncingMusicButton extends StatefulWidget {
  const _BouncingMusicButton({
    required this.isPlaying,
    required this.isBusy,
    required this.onPressed,
  });

  final bool isPlaying;
  final bool isBusy;
  final VoidCallback onPressed;

  @override
  State<_BouncingMusicButton> createState() => _BouncingMusicButtonState();
}

class _BouncingMusicButtonState extends State<_BouncingMusicButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _offset;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 920),
    )..repeat(reverse: true);
    _offset = Tween<double>(
      begin: 0,
      end: -6,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _offset,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, _offset.value),
          child: child,
        );
      },
      child: Material(
        color: Colors.white.withValues(alpha: 0.90),
        shape: const CircleBorder(),
        elevation: 8,
        shadowColor: Colors.black.withValues(alpha: 0.24),
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: widget.isBusy ? null : widget.onPressed,
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: widget.isBusy
                ? const SizedBox(
                    width: 28,
                    height: 28,
                    child: CircularProgressIndicator(strokeWidth: 2.4),
                  )
                : Icon(
                    widget.isPlaying
                        ? Icons.pause_circle_filled_rounded
                        : Icons.play_circle_fill_rounded,
                    size: 32,
                    color: const Color(0xFF4C5B4F),
                  ),
          ),
        ),
      ),
    );
  }
}

